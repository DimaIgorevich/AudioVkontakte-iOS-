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

//Storyboards.
NSString * const kStoryboardAudioPlayer = @"AudioPlayer";

@end