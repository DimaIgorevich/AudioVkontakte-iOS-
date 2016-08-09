//
//  AVKStringConstants.h
//  AudioVkontakte
//
//  Created by dRumyankov on 8/2/16.
//  Copyright © 2016 DimaRumyankov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVKStringConstants : NSObject

//SDK startUpConstants.

FOUNDATION_EXTERN NSString * const kVKAppID;
FOUNDATION_EXTERN NSString * const kVKPermissionsArray;

//Request signature constants
FOUNDATION_EXTERN NSString * const kRequestSignatureAudio;
FOUNDATION_EXTERN NSString * const kRequestSignatureAudioInfoById;

//Notifications.
FOUNDATION_EXTERN NSString * const kFinishLoadAudioList;
FOUNDATION_EXTERN NSString * const kCheckInternetConnection;

//Storyboards.
FOUNDATION_EXTERN NSString * const kStoryboardAudioPlayer;

//Key For Cache URL's
FOUNDATION_EXTERN NSString * const kKeyValueURLsCache;

//Data Source String Type
FOUNDATION_EXTERN NSString * const kDataSourceAudioListFromInternet;
FOUNDATION_EXTERN NSString * const kDataSourceAudioListFromCache;

@end
