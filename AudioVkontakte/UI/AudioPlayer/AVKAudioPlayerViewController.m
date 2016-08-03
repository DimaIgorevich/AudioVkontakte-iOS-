//
//  AVKAudioPlayerViewController.m
//  AudioVkontakte
//
//  Created by dRumyankov on 8/3/16.
//  Copyright © 2016 DimaRumyankov. All rights reserved.
//

#import "AVKAudioPlayerViewController.h"

CGFloat const kStartValue = 0.0f;

@interface AVKAudioPlayerViewController () <AVAudioPlayerDelegate>{
    NSTimer *updateSongTimer;
}

@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mirrorAlbumImageView;

@property (weak, nonatomic) IBOutlet UISlider *sliderProgressSong;
@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UILabel *duration;

@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *artist;

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
    return self.audioPlayer != nil;
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
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    self.sliderProgressSong.value = kStartValue;
}

- (void)loadSong{
    
//    VKRequest *songRequest = [[[AVKEngine sharedInstance] requestManager] audioGetByID:@{@"owner_id" : @(currentTrack.owner_id), @"audio_id" : @(currentTrack.aid)}];
//    
//    songRequest.signature = kRequestSignatureAudioInfoById;
//    [songRequest start];
    
    
    NSURL *audioTrackURL = [NSURL URLWithString:self.song.url];
    NSData *audioData = [NSData dataWithContentsOfURL:audioTrackURL];
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
    _audioPlayer.delegate = self;
    _audioPlayer.numberOfLoops = 0;
    
    [self startPlaySong];
}

- (void)startPlaySong{
    [_audioPlayer play];
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

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self nextTrack];
    [self prepareToNewSong];
}

- (void)prepareToNewSong{
    [self stopTimer];
    [self clearAudioPlayer];
    [self setSongIntoPlayer];
    [self loadSong];
}

#pragma mark - Timer Methods

- (void)stopTimer{
    [updateSongTimer invalidate];
    updateSongTimer = nil;
}

- (void)updateSongTime{
    self.currentTime.text = [AVKAudio durationToString:self.audioPlayer.currentTime];
    self.sliderProgressSong.value = self.audioPlayer.currentTime/self.song.duration;
}

#pragma mark - Handlers

- (IBAction)changeTimeline:(id)sender {
    [self stopTimer];
    [self.audioPlayer stop];
    
    [self.audioPlayer setCurrentTime:self.sliderProgressSong.value*self.song.duration];
    self.currentTime.text = [AVKAudio durationToString:self.audioPlayer.currentTime];
    [self startPlaySong];
}

- (IBAction)playActionButton:(id)sender{
    NSLog(@"play");
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
    
}

@end
