//
//  AVKAudioCell.h
//  AudioVkontakte
//
//  Created by dRumyankov on 8/2/16.
//  Copyright © 2016 DimaRumyankov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AVKAudioCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *artist;
@property (weak, nonatomic) IBOutlet UILabel *duration;

- (void)activePlayStatus;
- (void)disablePlayStatus;

@end
