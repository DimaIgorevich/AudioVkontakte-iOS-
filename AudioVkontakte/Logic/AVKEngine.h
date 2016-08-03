//
//  VKEngine.h
//  AudioVkontakte
//
//  Created by dRumyankov on 8/2/16.
//  Copyright © 2016 DimaRumyankov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVKObject.h"
#import "VkontakteSDK.h"

@interface AVKEngine : NSObject{
    VKRequestManager *requestManager;
}

@property (nonatomic, strong) VKRequestManager *requestManager;

+ (id)sharedInstance;

+ (NSArray *)arrayOfObjectsOfClass:(Class)obj_class
                          fromJSON:(id)json;
+ (NSArray *)arrayOfObjectsOfClass:(Class)obj_class
                          fromJSON:(id)json
                 postItrationBlock:(void (^) (AVKObject *obj))block;

@end
