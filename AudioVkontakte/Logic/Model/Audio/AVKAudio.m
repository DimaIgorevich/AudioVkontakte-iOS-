//
//  AVKAudio.m
//  AudioVkontakte
//
//  Created by dRumyankov on 8/2/16.
//  Copyright © 2016 DimaRumyankov. All rights reserved.
//

#import "AVKAudio.h"

CGFloat const kSecondsInMinutes = 60.0f;

@implementation AVKAudio

- (instancetype)initWithDictionary:(NSDictionary *)dictionary{
    if(self = [super initWithDictionary:dictionary]){
        self.aid = [[dictionary objectForKey:@"aid"] unsignedIntegerValue];
        self.artist  = [dictionary objectForKey:@"artist"];
        self.duration = [[dictionary objectForKey:@"duration"] unsignedIntegerValue];
        self.genre = [[dictionary objectForKey:@"genre"] unsignedIntegerValue];
        
//        self.lyrics_id = [[dictionary objectForKey:@"lyrics_id"] unsignedIntegerValue];
        self.owner_id = [[dictionary objectForKey:@"owner_id"] integerValue];
        self.title = [dictionary objectForKey:@"title"];
        self.url = [dictionary objectForKey:@"url"];
    }
    return self;
}

- (NSDictionary *)audioObjectJson{
    return @{
             @"aid" : @(self.aid),
             @"artist" : self.artist,
             @"duration" : @(self.duration),
             @"genre" : @(self.genre),
             @"owner_id" : @(self.owner_id),
             @"title" : self.title,
             @"url" : self.url
             };
}

+ (NSString *)durationToString:(NSUInteger)duration{
    CGFloat currentDuration = duration;
    NSInteger minutes = currentDuration/kSecondsInMinutes;
    NSInteger seconds = currentDuration - minutes*kSecondsInMinutes;
    
    NSString *resultValue;
    if(minutes < 10){
        if(seconds < 10){
            resultValue = [NSString stringWithFormat:@"%d:0%d", (int)minutes, (int)seconds];
        } else {
            resultValue = [NSString stringWithFormat:@"%d:%d", (int)minutes, (int)seconds];
        }
    } else {
        if(seconds < 10){
            resultValue = [NSString stringWithFormat:@"%d:0%d", (int)minutes, (int)seconds];
        } else {
            resultValue = [NSString stringWithFormat:@"%d:%d", (int)minutes, (int)seconds];
        }
    }
    
    return resultValue;
}

@end

