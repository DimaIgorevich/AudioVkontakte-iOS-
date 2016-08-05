//
//  AVKContainer.h
//  AudioVkontakte
//
//  Created by dRumyankov on 8/2/16.
//  Copyright © 2016 DimaRumyankov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVKAudio.h"

@interface AVKContainer : NSObject{
    NSArray <AVKAudio *>*audioContainer;
    NSArray <AVKAudio *>*audioWhichCached;
}

@property (nonatomic, strong) NSArray <AVKAudio *>*audioContainer;
@property (nonatomic, strong) NSArray <AVKAudio *>*audioWhichCached;

+ (id)sharedInstance;

@end
