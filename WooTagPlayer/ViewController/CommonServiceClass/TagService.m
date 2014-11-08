/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "TagService.h"
#import "NetworkConnection.h"
#import "NSObject+PE.h"
#import "ShowAlert.h"
#import "WooTagPlayerAppDelegate.h"

@implementation TagService
@synthesize requestURL;
@synthesize deviceId;
@synthesize user_id;
@synthesize indexPath;
@synthesize requestForRefresh;
-(id)initWithCaller:(id)caller
{
    if (self = [super init]) {
        caller_ = caller;
    }
    return  self;
}

#pragma mark ADD Tags request======
- (void)addTags:(NSArray *)tagsArray
{
    @try {
        afterUpdateTagsArray = tagsArray;
        NSDictionary *tagsRequestDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:user_id,@"uid",deviceId,@"device_id",tagsArray,@"tags", nil],@"tags",requestURL,@"url",@"addtags",@"requestfor", nil];
        
        [self networkCall:tagsRequestDict];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

#pragma mark GetFeedItems related
- (void)didFinishedAddingTags:(NSDictionary *)results {
    NSLog(@"TagsData:%@",results);
    @try {
        BOOL isAddTagsResponseNull = YES;
        NSMutableArray *tagsArrayM = [[NSMutableArray alloc] init];
        if([self isNotNull:results] && [results isKindOfClass:[NSDictionary class]])  {
            isAddTagsResponseNull = NO;
            if ([self isNotNull:[results objectForKey:@"tags"]]) {
                NSArray *tagsArray = [results objectForKey:@"tags"];
                for (NSDictionary *tagDict in tagsArray) {
                    Tag *tag = [[DataManager sharedDataManager] getTagByTagIdORClientTagId:[NSDictionary dictionaryWithObjectsAndKeys:[tagDict objectForKey:@"clinetsidetag_ids"],@"clientTagId", nil]];
                    if ([self isNotNull:[tagDict objectForKey:@"tag_ids"]]) {
                        tag.tagId = [NSNumber numberWithInt:[[tagDict objectForKey:@"tag_ids"] intValue]];
                    } else if ([self isNotNull:[tagDict objectForKey:@"tag_id"]]) {
                        tag.tagId = [NSNumber numberWithInt:[[tagDict objectForKey:@"tag_id"] intValue]];
                    }
                    
                    tag.isWaitingForUpload = [NSNumber numberWithBool:NO];
                    tag.isAdded = [NSNumber numberWithBool:NO];
                    if ([self isNotNull:tag]) {
                        [tagsArrayM addObject:tag];
                    }
                }
                [[DataManager sharedDataManager] saveChanges];
            }
        }
        
        NSDictionary *tagsInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:isAddTagsResponseNull],@"isResponseNull",tagsArrayM,@"tags", nil];
        
        if ([caller_ conformsToProtocol:@protocol(TagServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedAddingTags:)]) {
            [caller_ didFinishedAddingTags:tagsInfoDict];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)didFailToAddTagsWithError:(NSDictionary *)errorDict {
    
    @try {
        if (caller_ && [caller_ conformsToProtocol:@protocol(TagServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToAddTagsWithError:)]) {
            if([self isNotNull:afterUpdateTagsArray] && [self isNotNull:[errorDict objectForKey:@"error_code"]] && [[errorDict objectForKey:@"error_code"] intValue] == 1)  {
                for (NSDictionary *tagDict in afterUpdateTagsArray) {
                    Tag *tag = [[DataManager sharedDataManager] getTagByTagIdORClientTagId:[NSDictionary dictionaryWithObjectsAndKeys:[tagDict objectForKey:@"clienttagid"],@"clientTagId", nil]];
                   [[DataManager sharedDataManager] deleteTag:tag];
                }
            }
            [caller_ didFailToAddTagsWithError:errorDict];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

#pragma mark update tags request
- (void)updateTags:(NSArray *)tagsArray {
    afterUpdateTagsArray = tagsArray;
    NSDictionary *tagsRequestDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:tagsArray,@"tags", nil],@"tags",requestURL,@"url",@"updatetag",@"requestfor", nil];
    
    [self networkCall:tagsRequestDict];
}
- (void)didFinishedUpdatingTags:(NSDictionary *)results {
    TCSTART
     NSMutableArray *tagsArrayM = [[NSMutableArray alloc] init];
    if([self isNotNull:afterUpdateTagsArray])  {
        for (NSDictionary *tagDict in afterUpdateTagsArray) {
            Tag *tag = [[DataManager sharedDataManager] getTagByTagIdORClientTagId:[NSDictionary dictionaryWithObjectsAndKeys:[tagDict objectForKey:@"id"],@"tagid", nil]];
            tag.isWaitingForUpload = [NSNumber numberWithBool:NO];
            tag.isModified = [NSNumber numberWithBool:NO];
            if ([self isNotNull:tag]) {
                [tagsArrayM addObject:tag];
            }
        }
        [[DataManager sharedDataManager] saveChanges];
    }
    NSDictionary *tagsInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:tagsArrayM,@"tags", nil];
    if ([caller_ conformsToProtocol:@protocol(TagServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedUpdatingTags:)]) {
        [caller_ didFinishedUpdatingTags:tagsInfoDict];
    }
    TCEND
}
-(void)didFailToUpdateTagsWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(TagServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToUpdateTagsWithError:)]) {
        [caller_ didFailToUpdateTagsWithError:errorDict];
    }
    TCEND
}

#pragma mark DeleteTag
- (void)deleteTagWithTagId:(NSString *)tagId {
    TCSTART
    deleteReqtagId = tagId;
    NSDictionary *tagsRequestDict = [[NSDictionary alloc] initWithObjectsAndKeys:tagId,@"tagId",requestURL,@"url",@"deletetag",@"requestfor", nil];
    
    [self networkCall:tagsRequestDict];
    TCEND
}
- (void)didFinishedDeleteTag:(NSDictionary *)results {
    TCSTART
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:deleteReqtagId?:@"",@"tagid",results,@"results", nil];
    if ([caller_ conformsToProtocol:@protocol(TagServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedDeleteTag:)]) {
        [caller_ didFinishedDeleteTag:dictionary];
    }
    TCEND
}
-(void)didFailToDeleteTagWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(TagServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToDeleteTagWithError:)]) {
        [caller_ didFailToDeleteTagWithError:errorDict];
    }
    TCEND
}

#pragma mark playback request
- (void)playBackRequestWithVideoId:(NSString *)videoId {
    TCSTART
    
    NSDictionary *tagsRequestDict = [[NSDictionary alloc] initWithObjectsAndKeys:videoId,@"videoId",requestURL,@"url",@"playback",@"requestfor", nil];
    
    [self networkCall:tagsRequestDict];
    TCEND
}

- (void)didFinishedPlayBackRequest:(NSDictionary *)results {
    NSLog(@"TagsData:%@",results);
    @try {
        WooTagPlayerAppDelegate *appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        BOOL isPlayBackResponseNull = YES;
        VideoModal *video = nil;
        if([self isNotNull:results] && [results isKindOfClass:[NSDictionary class]])  {
            isPlayBackResponseNull = NO;
           
            if ([self isNotNull:[results objectForKey:@"video_id"]]) {
                if (requestForRefresh) {
                    video = [appDelegate returnVideoModalObjectByParsing:results];
                }
                if ([self isNotNull:[results objectForKey:@"tags"]]) {
                    for (NSDictionary *tagDict in [results objectForKey:@"tags"]) {
                        NSMutableDictionary *tagMDict = [[NSMutableDictionary alloc] init];
                        
                        if ([self isNotNull:[tagDict objectForKey:@"id"]]) {
                            [tagMDict setObject:[NSNumber numberWithInt:[[tagDict objectForKey:@"id"] intValue]] forKey:@"tagid"];
                        }
                        
                        if ([self isNotNull:[tagDict objectForKey:@"clienttagid"]] ) {
                            [tagMDict setObject:[NSNumber numberWithInt:[[tagDict objectForKey:@"clienttagid"]intValue]] forKey:@"clientTagId"];
                        }

                        
                        if ([self isNotNull:[tagDict objectForKey:@"tag_name"]] && [[tagDict objectForKey:@"tag_name"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[tagDict objectForKey:@"tag_name"] forKey:@"name"];
                        }
                        
                        if ([self isNotNull:[tagDict objectForKey:@"tag_color"]] && [[tagDict objectForKey:@"tag_color"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[tagDict objectForKey:@"tag_color"] forKey:@"tagColorName"];
                        }
                        if ([self isNotNull:[results objectForKey:@"uid"]] && [[results objectForKey:@"uid"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[results objectForKey:@"uid"] forKey:@"uid"];
                        }
                        if ([self isNotNull:[tagDict objectForKey:@"tag_link"]] && [[tagDict objectForKey:@"tag_link"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[tagDict objectForKey:@"tag_link"] forKey:@"link"];
                        }
                    
                        if ([self isNotNull:[tagDict objectForKey:@"coordinate_x"]]) {
                            [tagMDict setObject:[NSNumber numberWithFloat:[[tagDict objectForKey:@"coordinate_x"] floatValue]] forKey:@"tagX"];
                        }
                        
                        if ([self isNotNull:[tagDict objectForKey:@"coordinate_y"]]) {
                             [tagMDict setObject:[NSNumber numberWithFloat:[[tagDict objectForKey:@"coordinate_y"] floatValue]] forKey:@"tagY"];
                        }
                        
                        if ([self isNotNull:[tagDict objectForKey:@"tag_duration"]] && [[tagDict objectForKey:@"tag_duration"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[tagDict objectForKey:@"tag_duration"] forKey:@"displaytime"];
                        }
                        
                                                
                        if ([self isNotNull:[tagDict objectForKey:@"tag_gplink"]] && [[tagDict objectForKey:@"tag_gplink"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[tagDict objectForKey:@"tag_gplink"] forKey:@"gplustagid"];
                        }
                        
                        if ([self isNotNull:[tagDict objectForKey:@"tag_twlink"]] && [[tagDict objectForKey:@"tag_twlink"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[tagDict objectForKey:@"tag_twlink"] forKey:@"twtagid"];
                        }
                        
                        if ([self isNotNull:[tagDict objectForKey:@"tag_wtlink"]] && [[tagDict objectForKey:@"tag_wtlink"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[tagDict objectForKey:@"tag_wtlink"] forKey:@"wtId"];
                        }
                        
                        if ([self isNotNull:[tagDict objectForKey:@"productName"]] && [[tagDict objectForKey:@"productName"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[tagDict objectForKey:@"productName"] forKey:@"productName"];
                        }
                        if ([self isNotNull:[tagDict objectForKey:@"productLink"]] && [[tagDict objectForKey:@"productLink"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[tagDict objectForKey:@"productLink"] forKey:@"productLink"];
                        }
                        if ([self isNotNull:[tagDict objectForKey:@"productCategory"]] && [[tagDict objectForKey:@"productCategory"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[tagDict objectForKey:@"productCategory"] forKey:@"productCategory"];
                        }
                        if ([self isNotNull:[tagDict objectForKey:@"productDescription"]] && [[tagDict objectForKey:@"productDescription"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[tagDict objectForKey:@"productDescription"] forKey:@"productDescription"];
                        }
                        if ([self isNotNull:[tagDict objectForKey:@"productPrice"]] && [[tagDict objectForKey:@"productPrice"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[tagDict objectForKey:@"productPrice"] forKey:@"productPrice"];
                        }
                        
                        if ([self isNotNull:[tagDict objectForKey:@"currency"]] && [[tagDict objectForKey:@"currency"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[tagDict objectForKey:@"currency"] forKey:@"productCurrencyType"];
                        }
                        
                        if ([self isNotNull:[tagDict objectForKey:@"tag_fblink"]] && [[tagDict objectForKey:@"tag_fblink"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[tagDict objectForKey:@"tag_fblink"] forKey:@"fbtagid"];
                        }
                        
                        if ([self isNotNull:[tagDict objectForKey:@"video_id"]] && [[tagDict objectForKey:@"video_id"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[tagDict objectForKey:@"video_id"] forKey:@"videoId"];
                        }
                        if ([self isNotNull:[tagDict objectForKey:@"video_res_x"]]) {
                            [tagMDict setObject:[NSNumber numberWithFloat:[[tagDict objectForKey:@"video_res_x"] floatValue]] forKey:@"videoX"];
                        }
                        if ([self isNotNull:[tagDict objectForKey:@"video_res_y"]]) {
                            [tagMDict setObject:[NSNumber numberWithFloat:[[tagDict objectForKey:@"video_res_y"] floatValue]] forKey:@"videoY"];
                        }
                        if ([self isNotNull:[tagDict objectForKey:@"video_width"]] ) {
                            [tagMDict setObject:[NSNumber numberWithFloat:[[tagDict objectForKey:@"video_width"] floatValue]] forKey:@"videoWidth"];
                        }
                        if ([self isNotNull:[tagDict objectForKey:@"video_height"]]) {
                            [tagMDict setObject:[NSNumber numberWithFloat:[[tagDict objectForKey:@"video_height"] floatValue]] forKey:@"videoHeight"];
                        }
                        if ([self isNotNull:[tagDict objectForKey:@"video_current_time"]] && [[tagDict objectForKey:@"video_current_time"] isKindOfClass:[NSString class]]) {
                            [tagMDict setObject:[tagDict objectForKey:@"video_current_time"] forKey:@"videoplaybacktime"];
                        }
                        
                        if ([self isNotNull:[tagDict objectForKey:@"screen_res_x"]]) {
                            [tagMDict setObject:[NSNumber numberWithFloat:[[tagDict objectForKey:@"screen_res_x"] floatValue]] forKey:@"screenX"];
                        }
                        if ([self isNotNull:[tagDict objectForKey:@"screen_res_y"]]) {
                            [tagMDict setObject:[NSNumber numberWithFloat:[[tagDict objectForKey:@"screen_res_y"] floatValue]] forKey:@"screenY"];
                        }
                        if ([self isNotNull:[tagDict objectForKey:@"screen_width"]]) {
                            [tagMDict setObject:[NSNumber numberWithFloat:[[tagDict objectForKey:@"screen_width"] floatValue]] forKey:@"screenWidth"];
                        }
                        if ([self isNotNull:[tagDict objectForKey:@"screen_height"]]) {
                            [tagMDict setObject:[NSNumber numberWithFloat:[[tagDict objectForKey:@"screen_height"] floatValue]] forKey:@"screenHeight"];
                        }
                        [[DataManager sharedDataManager] addTag:tagMDict];
                    }
                }
            }
        }
        
        NSDictionary *tagsInfoDict;
        if (!isPlayBackResponseNull) {
            tagsInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:isPlayBackResponseNull],@"isResponseNull",results,@"results",[NSNumber numberWithBool:requestForRefresh],@"refresh",indexPath?:@"",@"indexpath",video,@"video", nil];
        } else {
            tagsInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:isPlayBackResponseNull],@"isResponseNull", nil];
        }
       
                                                   
        if ([caller_ conformsToProtocol:@protocol(TagServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedPlayBackRequest:)]) {
                [caller_ didFinishedPlayBackRequest:tagsInfoDict];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

-(void)didFailedPlayBackRequestWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(TagServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailedPlayBackRequestWithError:)]) {
        [caller_ didFailedPlayBackRequestWithError:errorDict];
    }
    TCEND
}
#pragma mark NetWork Call
- (void)networkCall:(NSDictionary *)requestParams {
    
    @try {
        // Create a network request
        NetworkConnection *networkConn = [[NetworkConnection alloc] init];
        
        if([[requestParams objectForKey:@"requestfor"] isEqualToString:@"addtags"]) { //thread call for addtags.
//            [requestParams removeObjectForKey:@"requestfor"];
            [NSThread detachNewThreadSelector:@selector(requestForAddTags:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
            
        } 
        else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"playback"]){ //thread call for search.
            
            [NSThread detachNewThreadSelector:@selector(requestForPlayBack:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"updatetag"]){ //thread call for search.
            
            [NSThread detachNewThreadSelector:@selector(requestForUpdateTags:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"deletetag"]){ //thread call for search.
            
            [NSThread detachNewThreadSelector:@selector(requestForDeleteTag:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
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
