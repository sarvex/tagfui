/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>
#import "WooTagPlayerAppDelegate.h"
@protocol BrowseServiceDelegate <NSObject>

@optional

//Browse
- (void)didFinishedToGetBrowseDetails:(NSDictionary *)results;
- (void)didFailToGetBrowseDetailsWithError:(NSDictionary *)errorDict;

//Search
- (void)didFinishedToGetSearchDetails:(NSDictionary *)results;
- (void)didFailToGetSearchDetailsWithError:(NSDictionary *)errorDict;

//Browse Detail
- (void)didFinishedToGetBrowseVideoDetails:(NSDictionary *)results;
- (void)didFailToGetBrowseVideoDetailsWithError:(NSDictionary *)errorDict;

//otherstuff
- (void)didFinishedToGetOtherStuffDetails:(NSDictionary *)results;
- (void)didFailToGetOtherStuffDetailsWithError:(NSDictionary *)errorDict;

@end

@interface BrowseService : NSObject <BrowseServiceDelegate> {
    
    id caller_;
    NSString *requestURL;
    
    NSString *videoId_;
    NSString *userId_;
    
    NSInteger pageNumber;
    NSString *browseType;
    NSString *trendsTagName;
    WooTagPlayerAppDelegate *appDelegate;
}

@property (nonatomic, retain) NSString *requestURL;
@property (nonatomic, readwrite) NSInteger pageNumber;
@property (nonatomic, retain) NSString *browseType;
@property (nonatomic, retain) NSString *userId_;
@property (nonatomic, retain) NSString *trendsTagName;

- (id)initWithCaller:(id)caller;

- (void)requestForBrowse;
- (void)requestForTrends;
- (void)requestForTrendsDetails;
- (void)requestForSearchWithSearchString:(NSString *)searchString;

- (void)requestForBrowseDetailsWithVideoId:(NSString *)videoId;
- (void)requestForMyotherStuff;
@end
