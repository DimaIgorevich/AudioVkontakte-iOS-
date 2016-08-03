//
//  AVKMainViewController.m
//  AudioVkontakte
//
//  Created by dRumyankov on 8/2/16.
//  Copyright © 2016 DimaRumyankov. All rights reserved.
//

#import "AVKMainViewController.h"
#import "AVKAudioPlayerViewController.h"
#import "AVKAudioCell.h"

#define kMarginTop 20.0f

@interface AVKMainViewController() <VKConnectorDelegate, UITableViewDataSource, UITableViewDelegate>{
    AVKAudioPlayerViewController *vcAudioPlayer;
}

@property (weak, nonatomic) IBOutlet UIWebView *vcWebView;
@property (strong, nonatomic) UITableView *vcTableView;

@end

@implementation AVKMainViewController

- (void)viewDidLoad{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLoadAudioList:) name:kFinishLoadAudioList object:nil];
    self.title = @"ГЛАВНАЯ";
    [self loadMainView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)loadMainView{
    [[VKConnector sharedInstance] startWithAppID:kVKAppID permissons:[kVKPermissionsArray componentsSeparatedByString:@","] webView:self.vcWebView delegate:self];
}

#pragma mark - VKConnectorDelegate

- (void)connector:(VKConnector *)connector accessTokenRenewalSucceeded:(VKAccessToken *)accessToken{
    NSLog(@"Access token: %@", accessToken);
    [[[AVKEngine sharedInstance] requestManager] setUser:[VKUser currentUser]];
    [[AVKEngine sharedInstance] requestManager].startAllRequestsImmediately = NO;
    
    [self audioRequest];
}

- (void)audioRequest{
    VKRequestManager *rm = [[AVKEngine sharedInstance] requestManager];
    VKRequest *audioRequest = [rm audioGet:nil];
    audioRequest.cacheLiveTime = VKCacheLiveTimeOneDay;
    audioRequest.signature = kRequestSignatureAudio;
    
    [audioRequest start];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[AVKContainer sharedInstance] audioContainer].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifierCell = @"AVKAudioCell";
    AVKAudioCell *cell = (AVKAudioCell *)[tableView dequeueReusableCellWithIdentifier:identifierCell];
    
    if(cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AudioCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    AVKAudio *audioItem = [[[AVKContainer sharedInstance] audioContainer] objectAtIndex:indexPath.row];
    
    cell.title.text = audioItem.title;
    cell.artist.text = audioItem.artist;
    cell.duration.text = [AVKAudio durationToString:audioItem.duration];
    
    if(vcAudioPlayer){
        if(indexPath.row == vcAudioPlayer.currentSong){
            [cell activePlayStatus];
        } else {
            [cell disablePlayStatus];
        }
    } else {
        [cell disablePlayStatus];
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)initUITableView{
    //CGSize parrentFrameSize = self.vcWebView.frame.size;
    CGSize parrentFrameSize = self.navigationController.view.frame.size;
    CGFloat navBarHeight = CGRectGetMaxY(self.navigationController.navigationBar.bounds) + kMarginTop;
    CGRect frame = CGRectMake(0, navBarHeight, parrentFrameSize.width, parrentFrameSize.height - navBarHeight);
    
    self.vcTableView = [[UITableView alloc] initWithFrame:frame];
    self.vcTableView.delegate = self;
    self.vcTableView.dataSource = self;
    
    [self.view addSubview:self.vcTableView];
    [self.vcTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(vcAudioPlayer == nil){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboardAudioPlayer bundle:nil];
        vcAudioPlayer = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(AVKAudioPlayerViewController.class)];
        AVKAudioCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell activePlayStatus];
    } else {
        if(vcAudioPlayer.currentSong != indexPath.row){
            AVKAudioCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:vcAudioPlayer.currentSong inSection:0]];
            [cell disablePlayStatus];
            
            cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell activePlayStatus];
            
            [vcAudioPlayer clearAudioPlayer];
        }
    }

    
    [vcAudioPlayer setCurrentSong:indexPath.row];
    [self.navigationController pushViewController:vcAudioPlayer animated:YES];
    [self.vcTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Post Notification

- (void)finishLoadAudioList:(NSNotification *)notification{
    [self.vcWebView setHidden:YES];
    
    [self initUITableView];
}

@end
