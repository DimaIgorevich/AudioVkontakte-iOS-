//
//  AVKStringConstants.m
//  AudioVkontakte
//
//  Created by dRumyankov on 8/2/16.
//  Copyright © 2016 DimaRumyankov. All rights reserved.
//

#import "AVKStringConstants.h"

@implementation AVKStringConstants

//SDK startUpConstants.
NSString *const kVKAppID = @"4249589";
NSString *const kVKPermissionsArray = @"photos,friends,wall,audio,video,docs,notes,pages,status,groups,messages";

//Request signature constants
NSString * const kRequestSignatureAudio = @"audio";
NSString * const kRequestSignatureAudioInfoById = @"audioById";

//Notifications.
NSString * const kFinishLoadAudioList = @"finishLoadAudioList";
NSString * const kCheckInternetConnection = @"checkInternetConnection";

//Storyboards.
NSString * const kStoryboardAudioPlayer = @"AudioPlayer";

//Key For Cache URL's
NSString * const kKeyValueURLsCache = @"URLsCache";

//Data Source String Type
NSString * const kDataSourceAudioListFromInternet = @"Internet";
NSString * const kDataSourceAudioListFromCache = @"Cache";

@end
