//
//  AVKAudioPlayerViewController.h
//  AudioVkontakte
//
//  Created by dRumyankov on 8/3/16.
//  Copyright © 2016 DimaRumyankov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AVKAudioPlayerViewController : UIViewController

@property NSInteger currentSong;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

- (void)clearAudioPlayer;

@end
