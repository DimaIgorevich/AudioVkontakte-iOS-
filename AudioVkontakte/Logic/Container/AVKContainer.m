//
//  AVKContainer.m
//  AudioVkontakte
//
//  Created by dRumyankov on 8/2/16.
//  Copyright © 2016 DimaRumyankov. All rights reserved.
//

#import "AVKContainer.h"

@implementation AVKContainer

@synthesize audioContainer = audioContainer;

- (id)init{
    if(self = [super init]){
        self.audioContainer = [NSArray array];
    }
    return self;
}

+ (instancetype)sharedInstance{
    static AVKContainer *instanceVKContainer = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^
                  {
                      instanceVKContainer = [[self alloc] init];
                      
                  });
    
    return instanceVKContainer;
}

@end
