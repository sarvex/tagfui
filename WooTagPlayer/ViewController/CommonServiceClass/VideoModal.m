/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "VideoModal.h"

@implementation VideoModal


@synthesize clientId;
@synthesize comments;
@synthesize creationTime;
@synthesize info;
//@dynamic isUploaded;
//@dynamic isUploading;
@synthesize numberOfCmnts;
@synthesize numberOfLikes;
@synthesize numberOfTags;
@synthesize numberOfViews;
@synthesize path;
@synthesize public;
@synthesize tags;
@synthesize title;
@synthesize videoId;

@synthesize userId;
@synthesize userName;
@synthesize userPhoto;
@synthesize userCountry;
@synthesize userProfession;
@synthesize userWebsite;
@synthesize userDesc;

@synthesize videoThumbPath;
//@dynamic waitingToUpload;
@synthesize videoDurationTime;
@synthesize likesList;
@synthesize browseType;
@synthesize myotherStuff;
@synthesize latestTagExpression;

@synthesize hasCommentedOnVideo;
@synthesize hasLovedVideo;
@synthesize shareUrl;
@synthesize fbShareUrl;

@synthesize numberOfVideosOfHashTag;


- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.clientId forKey:@"clientId"];
    [encoder encodeObject:self.comments forKey:@"comments"];
    [encoder encodeObject:self.creationTime forKey:@"creationTime"];
    [encoder encodeObject:self.info forKey:@"info"];
   
    [encoder encodeBool:self.hasCommentedOnVideo forKey:@"hasCommentedOnVideo"];
    [encoder encodeBool:self.hasLovedVideo forKey:@"hasLovedVideo"];
    [encoder encodeObject:self.shareUrl forKey:@"shareUrl"];
//    [encoder encodeBool:self.public forKey:@"public"];
//    [encoder encodeBool:self.waitingToUpload forKey:@"waitingToUpload"];
    [encoder encodeObject:self.public forKey:@"public"];
    [encoder encodeObject:self.numberOfCmnts forKey:@"numberOfCmnts"];
    [encoder encodeObject:self.numberOfLikes forKey:@"numberOfLikes"];
    [encoder encodeObject:self.numberOfTags forKey:@"numberOfTags"];
    [encoder encodeObject:self.numberOfViews forKey:@"numberOfViews"];
    
    [encoder encodeObject:self.path forKey:@"path"];
    [encoder encodeObject:self.tags forKey:@"tags"];
    [encoder encodeObject:self.title forKey:@"title"];
    
    [encoder encodeObject:self.userId forKey:@"userId"];
    [encoder encodeObject:self.userName forKey:@"userName"];
    [encoder encodeObject:self.userPhoto forKey:@"userPhoto"];
    [encoder encodeObject:self.userWebsite forKey:@"userWebsite"];
    [encoder encodeObject:self.userProfession forKey:@"userProfession"];
    [encoder encodeObject:self.userCountry forKey:@"userCountry"];
    [encoder encodeObject:self.userDesc forKey:@"userDesc"];
    
    [encoder encodeObject:self.videoId forKey:@"videoId"];
    [encoder encodeObject:self.videoThumbPath forKey:@"videoThumbPath"];
    [encoder encodeObject:self.videoDurationTime forKey:@"videoDurationTime"];
    [encoder encodeObject:self.likesList forKey:@"likesList"];
    [encoder encodeObject:self.browseType forKey:@"browseType"];
    [encoder encodeObject:self.latestTagExpression forKey:@"latestTagExpression"];
    [encoder encodeObject:self.myotherStuff forKey:@"myotherStuff"];
    [encoder encodeObject:self.fbShareUrl forKey:@"fbShareUrl"];
    [encoder encodeObject:self.numberOfVideosOfHashTag forKey:@"numberOfVideosOfHashTag"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.clientId = [decoder decodeObjectForKey:@"clientId"];
        self.comments = [decoder decodeObjectForKey:@"comments"];
        self.creationTime = [decoder decodeObjectForKey:@"creationTime"];
        self.info = [decoder decodeObjectForKey:@"info"];
        
        self.hasLovedVideo = [decoder decodeBoolForKey:@"hasLovedVideo"];
        self.hasCommentedOnVideo = [decoder decodeBoolForKey:@"hasCommentedOnVideo"];
//        self.public = [decoder decodeBoolForKey:@"public"];
//        self.waitingToUpload = [decoder decodeBoolForKey:@"waitingToUpload"];
        self.public = [decoder decodeObjectForKey:@"public"];
        self.numberOfCmnts = [decoder decodeObjectForKey:@"numberOfCmnts"];
        self.numberOfLikes = [decoder decodeObjectForKey:@"numberOfLikes"];
        self.numberOfViews = [decoder decodeObjectForKey:@"numberOfViews"];
        
        self.tags = [decoder decodeObjectForKey:@"tags"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.shareUrl = [decoder decodeObjectForKey:@"shareUrl"];
        self.path = [decoder decodeObjectForKey:@"path"];
        
        self.userId = [decoder decodeObjectForKey:@"userId"];
        self.userName = [decoder decodeObjectForKey:@"userName"];
        self.userPhoto = [decoder decodeObjectForKey:@"userPhoto"];
        self.userWebsite = [decoder decodeObjectForKey:@"userWebsite"];
        self.userProfession = [decoder decodeObjectForKey:@"userProfession"];
        self.userCountry = [decoder decodeObjectForKey:@"userCountry"];
        self.userDesc = [decoder decodeObjectForKey:@"userDesc"];
        
        self.videoId = [decoder decodeObjectForKey:@"videoId"];
        self.videoThumbPath = [decoder decodeObjectForKey:@"videoThumbPath"];
        self.videoDurationTime = [decoder decodeObjectForKey:@"videoDurationTime"];
        self.likesList = [decoder decodeObjectForKey:@"likesList"];
        self.browseType = [decoder decodeObjectForKey:@"browseType"];
        self.numberOfTags = [decoder decodeObjectForKey:@"numberOfTags"];
        self.latestTagExpression = [decoder decodeObjectForKey:@"latestTagExpression"];
        self.myotherStuff = [decoder decodeObjectForKey:@"myotherStuff"];
        self.fbShareUrl = [decoder decodeObjectForKey:@"fbShareUrl"];
        
        self.numberOfVideosOfHashTag = [decoder decodeObjectForKey:@"numberOfVideosOfHashTag"];
    }
    return self;
}

@end
