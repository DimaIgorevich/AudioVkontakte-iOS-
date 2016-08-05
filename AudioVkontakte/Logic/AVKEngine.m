//
//  VKEngine.m
//  AudioVkontakte
//
//  Created by dRumyankov on 8/2/16.
//  Copyright © 2016 DimaRumyankov. All rights reserved.
//

#import "AVKEngine.h"

@interface AVKEngine()<VKRequestDelegate>

@end

@implementation AVKEngine

@synthesize requestManager = requestManager;

- (id)init{
    if(self = [super init]){
        requestManager = [[VKRequestManager alloc] initWithDelegate:self];
    }
    return self;
}

+ (instancetype)sharedInstance{
    static AVKEngine *instanceVKEngine = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^
                  {
                      instanceVKEngine = [[self alloc] init];
                      
                  });
    
    return instanceVKEngine;
}

+ (NSArray *)arrayOfObjectsOfClass:(Class)obj_class fromJSON:(id)json{
    return [AVKEngine arrayOfObjectsOfClass:obj_class fromJSON:json postItrationBlock:nil];
}

+ (NSArray *)arrayOfObjectsOfClass:(Class)obj_class fromJSON:(id)json postItrationBlock:(void (^)(AVKObject *))block{
    NSMutableArray *result = [NSMutableArray array];
    
    for(NSDictionary *info in json){
        AVKObject *obj = [[obj_class alloc] initWithDictionary:info];
        [result addObject:obj];
        if(block){
            block(obj);
        }
    }
    return result.count > 0 ? result : nil;
}

#pragma mark - VKRequestDelegate

- (void)request:(VKRequest *)request response:(id)response{
    if(request.signature == kRequestSignatureAudio){
        
        //[[response objectForKey:@"response"] removeObjectAtIndex:0];
        
        NSArray *musicsFromRequest = [AVKEngine arrayOfObjectsOfClass:[AVKAudio class] fromJSON:[response objectForKey:@"response"]];
        [[AVKContainer sharedInstance] setAudioContainer:musicsFromRequest];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFinishLoadAudioList object:nil];
    }
}



@end
