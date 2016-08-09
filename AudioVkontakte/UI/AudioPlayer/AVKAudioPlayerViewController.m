//
//  AVKAudioPlayerViewController.m
//  AudioVkontakte
//
//  Created by dRumyankov on 8/3/16.
//  Copyright © 2016 DimaRumyankov. All rights reserved.
//

#import "AVKAudioPlayerViewController.h"

#define kPlayImageStatusButton @"play_button.png"
#define kPauseImageStatusButton @"pause_button.png"

CGFloat const kStartValue = 0.0f;

@interface AVKAudioPlayerViewController ()<UIAlertViewDelegate, AVAudioPlayerDelegate>{
    NSTimer *updateSongTimer;
}

@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mirrorAlbumImageView;

@property (weak, nonatomic) IBOutlet UISlider *sliderProgressSong;
@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UILabel *duration;

@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *artist;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property BOOL isLoopSong;

@property (strong, nonatomic) AVKAudio *song;

@end

@implementation AVKAudioPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self backgroundSetup];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(![self isFinishLoadSongData]){
        [self setSongIntoPlayer];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(![self isPlayingSong]){
        [self loadSong];
    }
}

- (BOOL)isFinishLoadSongData{
    return self.song == [[[AVKContainer sharedInstance] audioContainer] objectAtIndex:self.currentSong];
}

- (BOOL)isPlayingSong{
    return self.audioPlayer != nil || self.cacheAudioPlayer != nil;
}

- (void)nextTrack{
    if(self.currentSong+1 < [[AVKContainer sharedInstance] audioContainer].count){
        self.currentSong++;
    }
}

- (void)beforeTrack{
    if((self.currentSong - 1) > -1){
        self.currentSong --;
    }
}

- (void)setSongIntoPlayer{
    self.song = [[[AVKContainer sharedInstance] audioContainer] objectAtIndex:self.currentSong];
    [self setSongData];
}

- (void)clearAudioPlayer{
    if([ITReachabilityUtils isNetworkAvailable]){
        [self.audioPlayer seekToTime:CMTimeMake(0, 1)];
        [self.audioPlayer pause];
    
        self.audioPlayer = nil;
    } else {
        [self.cacheAudioPlayer stop];
        self.cacheAudioPlayer = nil;
    }
    self.sliderProgressSong.value = kStartValue;
}

- (void)loadSong{
    
//    VKRequest *songRequest = [[[AVKEngine sharedInstance] requestManager] audioGetByID:@{@"owner_id" : @(currentTrack.owner_id), @"audio_id" : @(currentTrack.aid)}];
//    
//    songRequest.signature = kRequestSignatureAudioInfoById;
//    [songRequest start];
    
    if([ITReachabilityUtils isNetworkAvailable]){
        [self loadSongFromInternet];
    } else {
        [self loadSongFromCache];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.audioPlayer currentItem]];
    
    [self startPlaySong];
}

- (void)loadSongFromInternet{
    NSURL *audioTrackURL = [NSURL URLWithString:self.song.url];
    self.audioPlayer = [AVPlayer playerWithURL:audioTrackURL];
}

- (void)loadSongFromCache{
    NSUInteger userID = [VKUser currentUser].accessToken.userID;
    VKStorageItem *item = [[VKStorage sharedStorage] storageItemForUserID:userID];
    
    NSData *dataSong = [item.cache cacheForURL:[NSURL URLWithString:self.song.url]];
    self.cacheAudioPlayer = [[AVAudioPlayer alloc] initWithData:dataSong error:nil];
    self.cacheAudioPlayer.delegate = self;
    self.cacheAudioPlayer.numberOfLoops = 0;
}

- (void)startPlaySong{
    if([ITReachabilityUtils isNetworkAvailable]){
        [_audioPlayer play];
    } else {
        [_cacheAudioPlayer play];
        if(_cacheAudioPlayer == nil){
            NSString *messageError = [NSString stringWithFormat:@"Sorry, %@ - %@ can't be play", self.song.artist, self.song.title];
            UIAlertView *alertErrorPlaying = [[UIAlertView alloc] initWithTitle:@"AudioVkontakte" message:messageError delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
            [alertErrorPlaying show];
        }
        NSLog(@"play: %@", self.cacheAudioPlayer);
    }
    
    [self changeOnPauseStatusBackgroundForButton];
    updateSongTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateSongTime) userInfo:nil repeats:YES];
}

- (void)setSongData{
    UIImage* sourceImage = [UIImage imageNamed:@"unknown_song.png"];
    UIImage* flippedImage = [UIImage imageWithCGImage:sourceImage.CGImage
                                                scale:sourceImage.scale
                                          orientation:UIImageOrientationUpMirrored];
    self.mirrorAlbumImageView.image = flippedImage;
    
    self.duration.text = [AVKAudio durationToString:self.song.duration];
    self.songTitle.text = [self.song.title uppercaseString];
    self.artist.text = self.song.artist;
}

- (void)backgroundSetup{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareToNewSong{
    [self stopTimer];
    [self clearAudioPlayer];
    [self setSongIntoPlayer];
    [self loadSong];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self nextTrack];
    [self prepareToNewSong];
}

#pragma mark - AVPlayerNotifications

- (void)avPlayerDidFinishPlaying:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[self.audioPlayer currentItem]];
    [self nextTrack];
    [self prepareToNewSong];
}

#pragma mark - Timer Methods

- (void)stopTimer{
    [updateSongTimer invalidate];
    updateSongTimer = nil;
}

- (void)updateSongTime{
    if([ITReachabilityUtils isNetworkAvailable]){
        CGFloat currentTimeInSeconds = CMTimeGetSeconds(self.audioPlayer.currentTime);
        self.currentTime.text = [AVKAudio durationToString:currentTimeInSeconds];
        self.sliderProgressSong.value = currentTimeInSeconds/self.song.duration;
    } else {
        self.currentTime.text = [AVKAudio durationToString:self.cacheAudioPlayer.currentTime];
        self.sliderProgressSong.value = self.cacheAudioPlayer.currentTime/self.song.duration;
    }
}

#pragma mark - Handlers

- (IBAction)changeTimeline:(id)sender {
    [self stopTimer];
    CGFloat newTimeValue = self.sliderProgressSong.value*self.song.duration;
    if([ITReachabilityUtils isNetworkAvailable]){
        [self.audioPlayer pause];
        
        CMTime newTime = CMTimeMake(newTimeValue, 1);
        [self.audioPlayer seekToTime:newTime];
        CGFloat currentTimeInSeconds = CMTimeGetSeconds(self.audioPlayer.currentTime);
        self.currentTime.text = [AVKAudio durationToString:currentTimeInSeconds];
    } else {
        [self.cacheAudioPlayer stop];
        
        [self.cacheAudioPlayer setCurrentTime:newTimeValue];
        self.currentTime.text = [AVKAudio durationToString:self.cacheAudioPlayer.currentTime];
    }
    
    [self startPlaySong];
}

- (IBAction)playActionButton:(id)sender{
    if(self.audioPlayer){
        [self changeStatusAVPlayer];
    }
    
    if(self.cacheAudioPlayer){
        [self changeStatusAVAudioPlayer];
    }
}

- (void)changeStatusAVPlayer{
    if(self.audioPlayer.rate != 0){
        [self.audioPlayer pause];
        [self changeOnPlayStatusBackgroundForButton];
    } else {
        [self.audioPlayer play];
        [self changeOnPauseStatusBackgroundForButton];
    }
}

- (void)changeStatusAVAudioPlayer{
    if([self.cacheAudioPlayer isPlaying]){
        [self.cacheAudioPlayer stop];
        [self changeOnPlayStatusBackgroundForButton];
    } else {
        [self.cacheAudioPlayer play];
        [self changeOnPauseStatusBackgroundForButton];
    }
}

- (void)changeOnPauseStatusBackgroundForButton{
    [self.playButton setBackgroundImage:[UIImage imageNamed:kPauseImageStatusButton] forState:UIControlStateNormal];
}

- (void)changeOnPlayStatusBackgroundForButton{
    [self.playButton setBackgroundImage:[UIImage imageNamed:kPlayImageStatusButton] forState:UIControlStateNormal];
}

- (IBAction)nextActionButton:(id)sender{
    [self nextTrack];
    [self prepareToNewSong];
}

- (IBAction)backActionButton:(id)sender {
    [self beforeTrack];
    [self prepareToNewSong];
}

- (IBAction)repeatActionButton:(id)sender {
    
}

- (IBAction)moreActionButton:(id)sender {
    NSString *messageForView = [NSString stringWithFormat:@"%@ - %@", self.song.artist, self.song.title];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add to cache storage" message:messageForView delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Add",nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0){
    if (buttonIndex == [alertView cancelButtonIndex]){
        NSLog(@"cancel");
    }else{
        NSLog(@"Add");
        [self addDataSongToCache];
    }
}

#pragma mark - VKFramework Cache Data Method

- (void)addDataSongToCache{
    AVKAudio *selectedSongItem = self.song;
    
    NSUInteger userID = [VKUser currentUser].accessToken.userID;
    VKStorageItem *item = [[VKStorage sharedStorage] storageItemForUserID:userID];
    
    NSData *songData = [item.cache cacheForURL:[NSURL URLWithString:selectedSongItem.url]];
    
    if(songData == nil){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *songTmpData = [NSData dataWithContentsOfURL:[NSURL URLWithString:selectedSongItem.url]];
            
            NSMutableArray <AVKAudio *>*newCachedAudiosData = [[NSMutableArray alloc] init];
            for(AVKAudio *objectAudio in [[AVKContainer sharedInstance] audioWhichCached]){
                [newCachedAudiosData addObject:objectAudio];
            }
            [newCachedAudiosData addObject:selectedSongItem];
            
            [[AVKContainer sharedInstance] setAudioWhichCached:newCachedAudiosData];
            [self writeCacheURL];
            
            [item.cache addCache:songTmpData forURL:[NSURL URLWithString:selectedSongItem.url] liveTime:VKCacheLiveTimeOneWeek];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *messageForView = [NSString stringWithFormat:@"%@ - %@", selectedSongItem.artist, selectedSongItem.title];
                
                UIAlertView *alertFinishUpload = [[UIAlertView alloc] initWithTitle:@"Finish upload to cache storage" message:messageForView delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
                [alertFinishUpload show];
            });
            
        });
    } else {
        NSString *messageForView = [NSString stringWithFormat:@"%@ - %@ is already in cache storage", selectedSongItem.artist, selectedSongItem.title];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AudioVkontakte" message:messageForView delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AudioVkontakte" message:@"Start upload song to cache storage" delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
    [alert show];
}

- (void)writeCacheURL{
    NSMutableArray <NSDictionary *>*jsonAudioObjects = [NSMutableArray array];
    for(AVKAudio *audioObject in [[AVKContainer sharedInstance] audioWhichCached]){
        [jsonAudioObjects addObject:[audioObject audioObjectJson]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:jsonAudioObjects forKey:kKeyValueURLsCache];
}

@end
