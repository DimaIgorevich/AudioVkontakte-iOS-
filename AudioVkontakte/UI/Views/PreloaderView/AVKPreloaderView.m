//
//  AVKPreloaderView.m
//  AudioVkontakte
//
//  Created by dRumyankov on 8/9/16.
//  Copyright © 2016 DimaRumyankov. All rights reserved.
//

#import "AVKPreloaderView.h"

@interface AVKPreloaderView()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *vIndicatorActivity;
@property (weak, nonatomic) IBOutlet UILabel *vLabelTitle;

@end

@implementation AVKPreloaderView

- (void)showProcessLoadingData{
    [self setHidden:NO];
    
    [self.vIndicatorActivity setColor:[UIColor grayColor]];
    [self.vIndicatorActivity startAnimating];
    
    [self.vLabelTitle sizeToFit];
}

- (void)didFinishLoadData{
    [self.vIndicatorActivity stopAnimating];
    [self setHidden:YES];
}

@end
