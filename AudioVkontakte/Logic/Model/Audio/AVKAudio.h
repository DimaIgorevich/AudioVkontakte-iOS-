//
//  AVKAudio.h
//  AudioVkontakte
//
//  Created by dRumyankov on 8/2/16.
//  Copyright © 2016 DimaRumyankov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVKObject.h"

@interface AVKAudio : AVKObject

@property NSUInteger aid;
@property NSString *artist;
@property NSUInteger duration;
@property NSUInteger genre;
@property NSUInteger lyrics_id;
@property NSInteger owner_id;
@property NSString *title;
@property NSString *url;

+ (NSString *)durationToString:(NSUInteger)duration;

@end
