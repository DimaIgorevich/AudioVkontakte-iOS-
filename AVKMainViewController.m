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
#import "AVKEmptyCell.h"

#import "AVKPreloaderView.h"

@interface AVKMainViewController() <VKConnectorDelegate, UITableViewDataSource, UITableViewDelegate>{
    AVKAudioPlayerViewController *vcAudioPlayer;
}

@property (weak, nonatomic) IBOutlet UIWebView *vcWebView;
@property (weak, nonatomic) IBOutlet UITableView *vcTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *vcSegmentControl;
@property (weak, nonatomic) IBOutlet AVKPreloaderView *vcPreloaderView;

@end

@implementation AVKMainViewController

- (void)viewDidLoad{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLoadAudioList:) name:kFinishLoadAudioList object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkInternetConnection) name:kCheckInternetConnection object:nil];
    
    self.title = @"AudioVkontakte";
    
    if(![VKUser currentUser]){
        [self.vcWebView setHidden:NO];
    }
    
    [self.vcPreloaderView showProcessLoadingData];
    [self checkInternetConnection];
    
    [self selectedDataSource];

}

- (void)checkInternetConnection{
    if(self.vcSegmentControl.selectedSegmentIndex == kAudioListFromInternet){
        if(![ITReachabilityUtils isNetworkAvailable]){
            NSString *message = [NSString stringWithFormat:@"No Internet Connection"];
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AudioVkontakte" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
            [alert show];
        }
    } else {
        NSString *message = [NSString stringWithFormat:@"No saved song in cache storage"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AudioVkontakte" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(self.vcTableView){
        [self.vcTableView reloadData];
    }
}

- (void)selectedDataSource{
    [self.vcTableView setHidden:YES];
    [self.vcPreloaderView showProcessLoadingData];
    
    if(self.vcSegmentControl.selectedSegmentIndex == kAudioListFromCache){
        [self loadDataFromCache];
        [self loadViewWithCacheData];
    } else {
        [self loadMainView];
    }
}

- (void)loadMainView{
    if([ITReachabilityUtils isNetworkAvailable]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[VKConnector sharedInstance] startWithAppID:kVKAppID permissons:[kVKPermissionsArray componentsSeparatedByString:@","] webView:self.vcWebView delegate:self];
        });
    } else {
        [[AVKContainer sharedInstance] setAudioContainer:nil];
        [self finishLoadAudioList:nil];
    }
}

- (void)loadViewWithCacheData{
    [self finishLoadAudioList:nil];
}

#pragma mark - VKConnectorDelegate

- (void)connector:(VKConnector *)connector accessTokenRenewalSucceeded:(VKAccessToken *)accessToken{
    NSLog(@"Access token: %@", accessToken);
    if([ITReachabilityUtils isNetworkAvailable]){
        [self.vcWebView setHidden:YES];
        [[[AVKEngine sharedInstance] requestManager] setUser:[VKUser currentUser]];
        [[AVKEngine sharedInstance] requestManager].startAllRequestsImmediately = NO;
    
        [self audioRequest];
    } else {
        [self finishLoadAudioList:nil];
    }
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
    if([[AVKContainer sharedInstance] audioContainer].count == 0){
        self.vcTableView.separatorColor = [UIColor clearColor];
        return 1;
    }
    
    self.vcTableView.separatorColor = [UIColor grayColor];
    return [[AVKContainer sharedInstance] audioContainer].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *returnCell;
    
    if([[AVKContainer sharedInstance] audioContainer].count){
        static NSString *identifierCell = @"AVKAudioCell";
        AVKAudioCell *cell = (AVKAudioCell *)[tableView dequeueReusableCellWithIdentifier:identifierCell];
    
        if(cell == nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AudioCell" owner:self options:nil];
            cell = [nib firstObject];
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
        
        returnCell = cell;
    } else {
        static NSString *identifierCell = @"AVKEmptyCell";
        AVKEmptyCell *cell = (AVKEmptyCell *)[tableView dequeueReusableCellWithIdentifier:identifierCell];
        
        if(cell == nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EmptyCell" owner:self options:nil];
            cell = [nib firstObject];
        }
        
        [cell setDataSource: (DataSourceType)self.vcSegmentControl.selectedSegmentIndex];
        
        returnCell = cell;
    }
    
    return returnCell;
}


#pragma mark - UITableViewDelegate

- (void)initUITableView{
    [self.vcTableView setHidden:NO];
    [self.vcTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([[AVKContainer sharedInstance] audioContainer].count){
        return 70.f;
    }
    return 25.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([[AVKContainer sharedInstance] audioContainer].count){
        if(vcAudioPlayer == nil){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboardAudioPlayer bundle:nil];
            vcAudioPlayer = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass   (AVKAudioPlayerViewController.class)];
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
    } else {
        [self.vcTableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - Post Notification

- (void)finishLoadAudioList:(NSNotification *)notification{
    [self.vcPreloaderView didFinishLoadData];
    [self.vcSegmentControl setHidden:NO];
    [self initUITableView];
}

#pragma mark - Cache Data Methods

- (void)loadDataFromCache{
    NSArray *cacheData = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyValueURLsCache];
    [[AVKContainer sharedInstance] setAudioContainer:[AVKEngine arrayOfObjectsOfClass:[AVKAudio class] fromJSON:cacheData]];
}

#pragma mark - UI Segment Control

- (IBAction)changeDataSource:(id)sender {
    [self selectedDataSource];
}

@end
