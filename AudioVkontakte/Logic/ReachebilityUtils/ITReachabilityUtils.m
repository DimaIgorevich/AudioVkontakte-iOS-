//
//  ITReachabilityUtils.m
//  Increditechs
//
//  Created by dRumyankov on 5/19/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

#import "ITReachabilityUtils.h"
#import "AFNetworkReachabilityManager.h"

@implementation ITReachabilityUtils

+ (BOOL)isNetworkAvailable{
    BOOL connected;
    const char *host = "www.apple.com";
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host);
    SCNetworkReachabilityFlags flags;
    connected = SCNetworkReachabilityGetFlags(reachability, &flags);
    BOOL isConnected = connected &&	(flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
    CFRelease(reachability);
    return isConnected;
}

@end
