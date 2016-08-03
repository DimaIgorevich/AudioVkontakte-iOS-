//
//  AVKAudioCell.m
//  AudioVkontakte
//
//  Created by dRumyankov on 8/2/16.
//  Copyright © 2016 DimaRumyankov. All rights reserved.
//

#define kImagePlayStatus @"play_status.png"

#import "AVKAudioCell.h"

@interface AVKAudioCell()

@property (weak, nonatomic) IBOutlet UIImageView *imgViewPlayStatus;

@end

@implementation AVKAudioCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)activePlayStatus{
    self.imgViewPlayStatus.image = [UIImage imageNamed:kImagePlayStatus];
}

- (void)disablePlayStatus{
    self.imgViewPlayStatus.image = nil;
}

@end
