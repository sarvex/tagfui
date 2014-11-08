/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "BrowseService.h"
#import "NetworkConnection.h"

@implementation BrowseService
@synthesize browseType;
@synthesize pageNumber;
@synthesize requestURL;
@synthesize userId_;
@synthesize trendsTagName;

-(id)initWithCaller:(id)caller {
    if (self = [super init]) {
        caller_ = caller;
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return  self;
}

#pragma mark Browse Request and  Delegate methods
- (void)requestForBrowse {
    TCSTART
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys: [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:browseType,@"browse_by",[NSNumber numberWithInteger:pageNumber],@"page_no",userId_?:@"",@"userid",@"iPhone",@"device", nil],@"user", nil],@"user",requestURL,@"url",@"browse",@"requestfor", nil];
    [self networkCall:myPageRequest];
    TCEND
}

- (void)requestForTrends {
    TCSTART
    browseType = @"trends";
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys: [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:pageNumber],@"page_no", nil],@"user", nil],@"user",requestURL,@"url",@"trends",@"requestfor", nil];
    [self networkCall:myPageRequest];
    TCEND
}

- (void)requestForTrendsDetails {
    TCSTART
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys: [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:browseType,@"browse_by",[NSNumber numberWithInteger:pageNumber],@"page_no",userId_?:@"",@"userid",trendsTagName,@"name", nil],@"user", nil],@"user",requestURL,@"url",@"trendsdetails",@"requestfor", nil];
    [self networkCall:myPageRequest];
    TCEND
}

- (void)didFinishedToGetBrowseDetails:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetBrowseDetails:)]) {
        NSMutableDictionary *resultsDict = [[NSMutableDictionary alloc] init];
       
        if ([self isNotNull:[results objectForKey:browseType]] ) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            if ([browseType caseInsensitiveCompare:@"tags"] == NSOrderedSame || [browseType caseInsensitiveCompare:@"trends"] == NSOrderedSame || [browseType caseInsensitiveCompare:@"videos"] == NSOrderedSame) {
                for (NSDictionary *dict in [results objectForKey:browseType]) {
                    VideoModal *modal = [appDelegate returnVideoModalObjectByParsing:dict];
                    [array addObject:modal];
                }
                
            } else {
                for (NSDictionary *dict in [results objectForKey:browseType]) {
                    UserModal *modal = [appDelegate returnUserModalObjectByParsing:dict isLogdedInUser:NO];
                    [array addObject:modal];
                }
            }
            [resultsDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:array,@"results",[NSNumber numberWithInt:pageNumber],@"pagenumber",browseType,@"browseType", nil]];
        }
        //        if (pageNumber == 1) {
        //            if ([self isNotNull:[results objectForKey:@"videos"]] && [[results objectForKey:@"videos"] isKindOfClass:[NSArray class]]) {
        //                NSMutableArray *array = [[NSMutableArray alloc] init];
        //                for (NSDictionary *dict in [results objectForKey:@"videos"]) {
        //                    VideoModal *modal = [appDelegate returnVideoModalObjectByParsing:dict];
        //                    [array addObject:modal];
        //                }
        //                [resultsDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:array,@"results",[NSNumber numberWithInt:pageNumber],@"pagenumber",@"videos",@"browseType", nil]];
        //            }
        //
        //            if ([self isNotNull:[results objectForKey:@"tags"]] && [[results objectForKey:@"tags"] isKindOfClass:[NSArray class]]) {
        //                NSMutableArray *array = [[NSMutableArray alloc] init];
        //                for (NSDictionary *dict in [results objectForKey:@"tags"]) {
        //                    VideoModal *modal = [appDelegate returnVideoModalObjectByParsing:dict];
        //                    [array addObject:modal];
        //                }
        //                [resultsDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:array,@"results",[NSNumber numberWithInt:pageNumber],@"pagenumber",@"tags",@"browseType", nil]];
        //            }
        //
        //            if ([self isNotNull:[results objectForKey:@"people"]] && [[results objectForKey:@"people"] isKindOfClass:[NSArray class]]) {
        //                [resultsDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[results objectForKey:@"people"],@"results",[NSNumber numberWithInt:pageNumber],@"pagenumber",@"people",@"browseType", nil]];
        //            }
        //
        //        } else {
        //            if ([self isNotNull:[results objectForKey:@"videos"]] && [[results objectForKey:@"videos"] isKindOfClass:[NSArray class]]) {
        //                NSMutableArray *array = [[NSMutableArray alloc] init];
        //                for (NSDictionary *dict in [results objectForKey:@"videos"]) {
        //                    VideoModal *modal = [appDelegate returnVideoModalObjectByParsing:dict];
        //                    [array addObject:modal];
        //                }
        //                [resultsDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:array,@"results",[NSNumber numberWithInt:pageNumber],@"pagenumber",browseType,@"browseType", nil]];
        //            } else {
        //                [resultsDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[results objectForKey:browseType]?:[NSArray arrayWithObjects: nil],@"results",[NSNumber numberWithInt:pageNumber],@"pagenumber",browseType,@"browseType", nil]];
        //            }
        //        }
        [caller_ didFinishedToGetBrowseDetails:resultsDict];
    }
    TCEND
}

- (void)didFailToGetBrowseDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetBrowseDetailsWithError:)]) {
        [caller_ didFailToGetBrowseDetailsWithError:errorDict];
    }
    TCEND
}

#pragma mark Request For Search and Delegate methods
- (void)requestForSearchWithSearchString:(NSString *)searchString {
    TCSTART
    if ([browseType caseInsensitiveCompare:@"trends"] == NSOrderedSame) {
        requestURL = [NSString stringWithFormat:@"%@/searchTrends",requestURL];
    } else {
        requestURL = [NSString stringWithFormat:@"%@/search",requestURL];
    }
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys: [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:browseType,@"browse_by",[NSNumber numberWithInteger:pageNumber],@"page_no",searchString,@"name",@"iPhone",@"device",userId_?:@"",@"userid", nil],@"user", nil],@"user",requestURL,@"url",@"search",@"requestfor", nil];
    [self networkCall:myPageRequest];
    TCEND
}

- (void)didFinishedToGetSearchDetails:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetSearchDetails:)]) {
            NSMutableDictionary *resultsDict = [[NSMutableDictionary alloc] init];
            
            if ([self isNotNull:[results objectForKey:browseType]]) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                if ([browseType caseInsensitiveCompare:@"tags"] == NSOrderedSame || [browseType caseInsensitiveCompare:@"videos"] == NSOrderedSame || [browseType caseInsensitiveCompare:@"trends"] == NSOrderedSame) {
                    for (NSDictionary *dict in [results objectForKey:browseType]) {
                        VideoModal *modal = [appDelegate returnVideoModalObjectByParsing:dict];
                        [array addObject:modal];
                    }
                } else {
                    for (NSDictionary *dict in [results objectForKey:browseType]) {
                        UserModal *modal = [appDelegate returnUserModalObjectByParsing:dict isLogdedInUser:NO];
                        [array addObject:modal];
                    }
                }
                [resultsDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:array,@"results",[NSNumber numberWithInt:pageNumber],@"pagenumber",browseType,@"browseType", nil]];
            }
            [caller_ didFinishedToGetSearchDetails:resultsDict];
    }
    TCEND
}

- (void)didFailToGetSearchDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetSearchDetailsWithError:)]) {
        [caller_ didFailToGetSearchDetailsWithError:errorDict];
    }
    TCEND
}

#pragma mark Browse Detail
- (void)requestForBrowseDetailsWithVideoId:(NSString *)videoId {
    TCSTART
    NSDictionary *browseDetailRequest = [[NSDictionary alloc] initWithObjectsAndKeys: [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:pageNumber],@"page_no",videoId,@"video_id",userId_,@"userid",@"iPhone",@"device", nil],@"user", nil],@"user",requestURL,@"url",@"browsedetail",@"requestfor", nil];
    [self networkCall:browseDetailRequest];
    TCEND
}
- (void)didFinishedToGetBrowseVideoDetails:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetBrowseVideoDetails:)]) {
         NSMutableArray *array = [[NSMutableArray alloc] init];
        if ([self isNotNull:[results objectForKey:@"videos"]]  && [[results objectForKey:@"videos"] isKindOfClass:[NSArray class]] && [[results objectForKey:@"videos"] count] > 0) {
            NSMutableDictionary *videosDict = [[NSMutableDictionary alloc] initWithDictionary:[[results objectForKey:@"videos"] objectAtIndex:0]];
            if ([self isNotNull:[results objectForKey:@"myotherstuff"]]) {
                [videosDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[results objectForKey:@"myotherstuff"],@"myotherstuff", nil]];
            }
            VideoModal *modal = [appDelegate returnVideoModalObjectByParsing:videosDict];
            [array addObject:modal];
        
        }
        [caller_ didFinishedToGetBrowseVideoDetails:[NSDictionary dictionaryWithObjectsAndKeys:array,@"results",[NSNumber numberWithInt:pageNumber],@"pagenumber", nil]];
    }
    TCEND
}
- (void)didFailToGetBrowseVideoDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetBrowseVideoDetailsWithError:)]) {
        [caller_ didFailToGetBrowseVideoDetailsWithError:errorDict];
    }
    TCEND
}

#pragma mark OtherStuff
- (void)requestForMyotherStuff {
    TCSTART
//    NSDictionary *browseDetailRequest = [[NSDictionary alloc] initWithObjectsAndKeys: [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:pageNumber],@"page_no",userId_,@"user_id",@"iPhone",@"device", nil],@"user", nil],@"user",requestURL,@"url",@"otherstuff",@"requestfor", nil];
     NSDictionary *browseDetailRequest = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInteger:pageNumber],@"page_no",userId_,@"user_id",requestURL,@"url",@"otherstuff",@"requestfor", nil];
    [self networkCall:browseDetailRequest];
    
    TCEND
}
- (void)didFinishedToGetOtherStuffDetails:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetOtherStuffDetails:)]) {
        [caller_ didFinishedToGetOtherStuffDetails:[NSDictionary dictionaryWithObjectsAndKeys:[results objectForKey:@"myotherstuff"]?:[NSArray arrayWithObjects:nil],@"videos",[NSNumber numberWithInt:pageNumber],@"pagenumber", nil]];
    }
    TCEND
}
- (void)didFailToGetOtherStuffDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetOtherStuffDetailsWithError:)]) {
        [caller_ didFailToGetOtherStuffDetailsWithError:errorDict];
    }
    TCEND
}
#pragma mark NetWork Call
- (void)networkCall:(NSDictionary *)requestParams {
    
    @try {
        // Create a network request
        NetworkConnection *networkConn = [[NetworkConnection alloc] init];
        
        if([[requestParams objectForKey:@"requestfor"] isEqualToString:@"browse"]) {
            // thread call for browse
            [NSThread detachNewThreadSelector:@selector(requestForBrowse:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } if([[requestParams objectForKey:@"requestfor"] isEqualToString:@"trends"]) {
            
            // thread call for browse
            [NSThread detachNewThreadSelector:@selector(requestForTrends:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } if([[requestParams objectForKey:@"requestfor"] isEqualToString:@"trendsdetails"]) {
            // thread call for browse
            [NSThread detachNewThreadSelector:@selector(requestForTrendsDetails:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"search"]){
            //thread call for search.
            [NSThread detachNewThreadSelector:@selector(requestForBrowseSearch:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"otherstuff"]){
            //thread call for search.
            [NSThread detachNewThreadSelector:@selector(requestForMyotherStuff:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"browsedetail"]){
            //thread call for search.
            [NSThread detachNewThreadSelector:@selector(requestForBrowseDetails:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
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
