//
//  AVKEmptyCell.m
//  AudioVkontakte
//
//  Created by dRumyankov on 8/9/16.
//  Copyright © 2016 DimaRumyankov. All rights reserved.
//

#import "AVKEmptyCell.h"

@interface AVKEmptyCell()

@property (weak, nonatomic) IBOutlet UILabel *titleDataSource;

@end

@implementation AVKEmptyCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setDataSource:(DataSourceType)dataSource{
    if(dataSource == kAudioListFromCache){
        self.titleDataSource.text = [NSString stringWithFormat:@"No item in %@ data", kDataSourceAudioListFromCache];
    } else {
        self.titleDataSource.text = [NSString stringWithFormat:@"No item in %@ data", kDataSourceAudioListFromInternet];
    }
}

- (IBAction)infoButtonAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCheckInternetConnection object:self];
}


@end
