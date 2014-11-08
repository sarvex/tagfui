/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "NotificationService.h"
#import "NetworkConnection.h"
#import "NotificationModal.h"

@implementation NotificationService
@synthesize loginUserId;
@synthesize otherUserId;
@synthesize pageNumber;
@synthesize videoId;
@synthesize requestURL;
@synthesize indexPath;

-(id)initWithCaller:(id)caller {
    if (self = [super init]) {
        caller_ = caller;
//        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return  self;
}


#pragma mark GetAllNotifications
- (void)makeNetworkConnectionForUserNotifications {
    TCSTART
    NSDictionary *allcmntsRequest = [[NSDictionary alloc] initWithObjectsAndKeys: loginUserId?:@"",@"userid",requestURL,@"url",@"AllNotifications",@"requestfor", nil];
   
    [self networkCall:allcmntsRequest];
    
    TCEND
}

- (void)didFinishedToGetUserNotifications:(NSDictionary *)results {
    TCSTART
    WooTagPlayerAppDelegate *appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [[DataManager sharedDataManager] removeAllNotificationsWhichAreCreated7DaysAgo];
//    int notificationsCount = [[[DataManager sharedDataManager] getAllNotificationsByUserId:appDelegate.loggedInUser.userId] count];
    [[DataManager sharedDataManager] removeAllNotificationsOfUserId:appDelegate.loggedInUser.userId];
    BOOL isResponseNull = YES;
//    BOOL areTheyNewNotifications = NO;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"notifications"]] && [[results objectForKey:@"notifications"] isKindOfClass:[NSArray class]]) {
        isResponseNull = NO;
        NSMutableArray *notificationsArray = [[NSMutableArray alloc]initWithArray:[results objectForKey:@"notifications"]];
        for (NSMutableDictionary *notificationDict in [results objectForKey:@"notifications"]) {
            if ([self isNotNull:[notificationDict objectForKey:@"created_date"]] && ![appDelegate isNotificationCreatedTimeIsLessThanOrEqual7Days:[notificationDict objectForKey:@"created_date"]]) {
                [notificationsArray removeObject:notificationDict];
            }
        }
        
//        if (notificationsCount < notificationsArray.count) {
//            areTheyNewNotifications = YES;
//        }
        for (NSMutableDictionary *notificationDict in notificationsArray) {
            if ([self isNotNull:[notificationDict objectForKey:@"notice_id"]]) {
                [[DataManager sharedDataManager] addNotification:notificationDict];
            }
        }
    }
    if (caller_ && [caller_ conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetUserNotifications:)]) {
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isResponseNull],@"isResponseNull"/**,[NSNumber numberWithBool:areTheyNewNotifications],@"newnotifications"*/, nil]];
        [caller_ didFinishedToGetUserNotifications:dict];
    }
    TCEND
}

- (void)didFailToGetUserNotificationsWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetUserNotificationsWithError:)]) {
        [caller_ didFailToGetUserNotificationsWithError:errorDict];
    }
    TCEND
}

#pragma mark Notification search
- (void)makeNotificationsSearchRequestWithSearchKeyword:(NSString *)searchKeyword {
    TCSTART
    
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys: [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:searchKeyword,@"name",@"iPhone",@"device",loginUserId?:@"",@"userid", nil],@"user", nil],@"user",requestURL,@"url",@"search",@"requestfor", nil];
    [self networkCall:myPageRequest];
    TCEND
}
- (void)didFinishedToGetUserNotificationsSearch:(NSDictionary *)results {
    TCSTART
    WooTagPlayerAppDelegate *appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    BOOL isResponseNull = YES;

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray * searchedNotificationArray = [[NSMutableArray alloc] init];
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"notifications"]] && [[results objectForKey:@"notifications"] isKindOfClass:[NSArray class]]) {
        isResponseNull = NO;
        NSMutableArray *notificationsArray = [[NSMutableArray alloc]initWithArray:[results objectForKey:@"notifications"]];
        for (NSMutableDictionary *notificationDict in [results objectForKey:@"notifications"]) {
            if ([self isNotNull:[notificationDict objectForKey:@"created_date"]] && ![appDelegate isNotificationCreatedTimeIsLessThanOrEqual7Days:[notificationDict objectForKey:@"created_date"]]) {
                [notificationsArray removeObject:notificationDict];
            }
        }
        
        for (NSMutableDictionary *notificationDict in notificationsArray) {
            if ([self isNotNull:[notificationDict objectForKey:@"notice_id"]]) {
                [[DataManager sharedDataManager] addNotification:notificationDict];
            }
        }
        
        for (NSMutableDictionary *notificationDict in notificationsArray) {
            if ([self isNotNull:[notificationDict objectForKey:@"notice_id"]]) {
                [searchedNotificationArray addObject:[[DataManager sharedDataManager] getNotificationByNotificationId:notificationDict]];
            }
        }
    }
    if (caller_ && [caller_ conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetUserNotificationsSearch:)]) {
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isResponseNull],@"isResponseNull",searchedNotificationArray,@"searcResponse", nil]];
        [caller_ didFinishedToGetUserNotificationsSearch:dict];
    }
    TCEND
}

- (void)didFailToGetUserNotificationsSearchWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetUserNotificationsSearchWithError:)]) {
        [caller_ didFailToGetUserNotificationsSearchWithError:errorDict];
    }
    TCEND
}

#pragma mark Remove Notifications
- (void)makeNetworkConnectionToRemoveNotificationWithNotificationId:(NSString *)notificationId {
    TCSTART
    NSDictionary *allcmntsRequest = [[NSDictionary alloc] initWithObjectsAndKeys: notificationId,@"notificationid",requestURL,@"url",@"RemoveNotifications",@"requestfor", nil];
    
    [self networkCall:allcmntsRequest];
    TCEND
}

- (void)didFinishedToRemoveUserNotification:(NSDictionary *)results {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToRemoveUserNotification:)]) {
        [caller_ didFinishedToRemoveUserNotification:results];
    }
    TCEND
}
- (void)didFailToRemoveUserNotificationWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToRemoveUserNotificationWithError:)]) {
        [caller_ didFailToRemoveUserNotificationWithError:errorDict];
    }
    TCEND
}

#pragma mark Video Details
- (void)makeNetworkConnectionForVideoDetailsOfNotificationsWithNotificationType:(NSInteger) notificaitonType {
    TCSTART
    NSDictionary *allcmntsRequest = [[NSDictionary alloc] initWithObjectsAndKeys: videoId?:@"",@"videoId",[NSNumber numberWithInt:notificaitonType],@"notificationType",requestURL,@"url",@"Videodetails",@"requestfor", nil];
    
    [self networkCall:allcmntsRequest];
    TCEND
}

- (void)didFinishedToGetVideoDetails:(NSDictionary *)results {
    TCSTART
    WooTagPlayerAppDelegate *appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetVideoDetails:)]) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if ([self isNotNull:[results objectForKey:@"video"]]) {
            NSMutableDictionary *videosDict = [[NSMutableDictionary alloc] initWithDictionary:[results objectForKey:@"video"]];
            if ([self isNotNull:[results objectForKey:@"coments"]]) {
                [videosDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[results objectForKey:@"coments"],@"recent_comments", nil]];
                
            }
            if ([self isNotNull:[results objectForKey:@"likes"]]) {
                [videosDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[results objectForKey:@"likes"],@"recent_liked_by", nil]];
                
            }
            VideoModal *modal = [appDelegate returnVideoModalObjectByParsing:videosDict];
            [array addObject:modal];
            
        }
        [caller_ didFinishedToGetVideoDetails:[NSDictionary dictionaryWithObjectsAndKeys:array,@"videos",indexPath,@"indexpath", nil]];
    }
    
    TCEND
}
- (void)didFailToGetVideoDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetVideoDetailsWithError:)]) {
        [caller_ didFailToGetVideoDetailsWithError:errorDict];
    }
    TCEND
}


#pragma mark Get Notifications settings
- (void)makeNetworkConnectionToGetNotificationSettings:(NSString *)userId {
    TCSTART
    NSDictionary *allcmntsRequest = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userId",requestURL,@"url",@"NotificationSettings",@"requestfor", nil];
    
    [self networkCall:allcmntsRequest];
    TCEND
}

- (void)didFinishedToGetNotificationSettings:(NSDictionary *)results {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetNotificationSettings:)]) {
        [caller_ didFinishedToGetNotificationSettings:results];
    }
    TCEND
}
- (void)didFailToGetNotificationSettingsWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetNotificationSettingsWithError:)]) {
        [caller_ didFailToGetNotificationSettingsWithError:errorDict];
    }
    TCEND
}


#pragma mark Update Notifications
- (void)makeNetworkConnectionToUpdateNotificationsSettingsWithDictionary:(NSString *)notificationsDict {
    TCSTART
    NSDictionary *allcmntsRequest = [[NSDictionary alloc] initWithObjectsAndKeys: notificationsDict,@"push",requestURL,@"url",@"UpdateNotification",@"requestfor", nil];
    
    [self networkCall:allcmntsRequest];
    TCEND
}

- (void)didFinishedToUpdateNotificationsSettings:(NSDictionary *)results {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToUpdateNotificationsSettings:)]) {
        [caller_ didFinishedToUpdateNotificationsSettings:results];
    }
    TCEND
}
- (void)didFailToUpdateNotificationsSettingsWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToUpdateNotificationsSettingsWithError:)]) {
        [caller_ didFailToUpdateNotificationsSettingsWithError:errorDict];
    }
    TCEND
}


#pragma mark NetWork Call
- (void)networkCall:(NSDictionary *)requestParams {
    
    @try {
        // Create a network request
        NetworkConnection *networkConn = [[NetworkConnection alloc] init];
        
        if([[requestParams objectForKey:@"requestfor"] isEqualToString:@"AllNotifications"]) {
            // thread call for mypage
            
            [NSThread detachNewThreadSelector:@selector(requestToGetNotifications:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if([[requestParams objectForKey:@"requestfor"] isEqualToString:@"RemoveNotifications"]) {
            // thread call for mypage
            [NSThread detachNewThreadSelector:@selector(requestToRemoveNotifications:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"Videodetails"]){
            //thread call for follow.
            [NSThread detachNewThreadSelector:@selector(requestForGetVideoDetails:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if([[requestParams objectForKey:@"requestfor"] isEqualToString:@"NotificationSettings"]) {
            // thread call for Get Notifications settings
            [NSThread detachNewThreadSelector:@selector(requestToGetNotificationsSettings:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if([[requestParams objectForKey:@"requestfor"] isEqualToString:@"UpdateNotification"]) {
            // thread call for Update Notifications
            [NSThread detachNewThreadSelector:@selector(requestToUpdateNotificationSettings:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if([[requestParams objectForKey:@"requestfor"] isEqualToString:@"search"]) {
            // thread call for Update Notifications
            [NSThread detachNewThreadSelector:@selector(requestForNotificationsSearch:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        }
        
        networkConn = nil;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}


@end
