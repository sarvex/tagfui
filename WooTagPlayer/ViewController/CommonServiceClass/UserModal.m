/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "UserModal.h"

@implementation UserModal
@synthesize userName;
@synthesize userId;
@synthesize totalNoOfFollowings;
@synthesize totalNoOfFollowers;
@synthesize photoPath;
@synthesize bannerPath;
@synthesize lastUpdate;
@synthesize totalNoOfLikes;
@synthesize totalNoOfVideos;
@synthesize totalNoOfTags;
@synthesize videos;
@synthesize followers;
@synthesize followings;
@synthesize youFollowing;
@synthesize country;
@synthesize profession;
@synthesize website;
@synthesize suggestedUsers;
@synthesize moreVideos;
@synthesize userDesc;
@synthesize totalNoOfPrivateUsers;
@synthesize privateUsers;
@synthesize youPrivate;
@synthesize privateReqSent;
@synthesize respondToPvtReq;
@synthesize privateFeed;
@synthesize videoFeed;
@synthesize emailAddress;
@synthesize gender;
@synthesize phoneNumber;
@synthesize bio;
@synthesize socialContactsDictionary;
@synthesize totalNoOfPeningPrivateUsers;

@synthesize address;
@synthesize mobileNumber;

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.userName forKey:@"userName"];
    [encoder encodeObject:self.userId forKey:@"userId"];
    [encoder encodeObject:self.totalNoOfFollowings forKey:@"totalNoOfFollowings"];
    [encoder encodeObject:self.totalNoOfFollowers forKey:@"totalNoOfFollowers"];
    [encoder encodeObject:self.totalNoOfPrivateUsers forKey:@"totalNoOfPrivateUsers"];
    [encoder encodeObject:self.totalNoOfPeningPrivateUsers forKey:@"totalNoOfPeningPrivateUsers"];
    
    [encoder encodeBool:self.youFollowing forKey:@"youFollowing"];
    [encoder encodeBool:self.youPrivate forKey:@"youPrivate"];
    [encoder encodeBool:self.privateReqSent forKey:@"privateReqSent"];
    [encoder encodeBool:self.respondToPvtReq forKey:@"respondToPvtReq"];
    
    [encoder encodeObject:self.photoPath forKey:@"photoPath"];
    [encoder encodeObject:self.bannerPath forKey:@"bannerPath"];
    [encoder encodeObject:self.lastUpdate forKey:@"lastUpdate"];
    [encoder encodeObject:self.totalNoOfLikes forKey:@"totalNoOfLikes"];
    [encoder encodeObject:self.totalNoOfVideos forKey:@"totalNoOfVideos"];
    [encoder encodeObject:self.totalNoOfTags forKey:@"totalNoOfTags"];
    
    [encoder encodeObject:self.videos forKey:@"videos"];
    [encoder encodeObject:self.followers forKey:@"followers"];
    [encoder encodeObject:self.followings forKey:@"followings"];
    [encoder encodeObject:self.privateUsers forKey:@"privateUsers"];
    [encoder encodeObject:self.country forKey:@"country"];
    [encoder encodeObject:self.profession forKey:@"profession"];
    [encoder encodeObject:self.website forKey:@"website"];
    [encoder encodeObject:self.suggestedUsers forKey:@"suggestedUsers"];
    [encoder encodeObject:self.moreVideos forKey:@"moreVideos"];
    [encoder encodeObject:self.userDesc forKey:@"userDesc"];
    [encoder encodeObject:self.privateFeed forKey:@"privateFeed"];
    [encoder encodeObject:self.videoFeed forKey:@"videoFeed"];
    
    [encoder encodeObject:self.emailAddress forKey:@"emailAddress"];
    [encoder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
    [encoder encodeObject:self.gender forKey:@"gender"];
    [encoder encodeObject:self.bio forKey:@"bio"];
    [encoder encodeObject:self.socialContactsDictionary forKey:@"socialContactsDictionary"];
    
    [encoder encodeObject:self.address forKey:@"address"];
    [encoder encodeObject:self.mobileNumber forKey:@"mobileNumber"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.userName = [decoder decodeObjectForKey:@"userName"];
        self.userId = [decoder decodeObjectForKey:@"userId"];
        self.totalNoOfFollowings = [decoder decodeObjectForKey:@"totalNoOfFollowings"];
        self.totalNoOfFollowers = [decoder decodeObjectForKey:@"totalNoOfFollowers"];
        self.totalNoOfPrivateUsers = [decoder decodeObjectForKey:@"totalNoOfPrivateUsers"];
        self.totalNoOfPeningPrivateUsers = [decoder decodeObjectForKey:@"totalNoOfPeningPrivateUsers"];
        
        self.youFollowing = [decoder decodeBoolForKey:@"youFollowing"];
        self.youPrivate = [decoder decodeBoolForKey:@"youPrivate"];
        self.privateReqSent = [decoder decodeBoolForKey:@"privateReqSent"];
        self.respondToPvtReq = [decoder decodeBoolForKey:@"respondToPvtReq"];
        
        self.photoPath = [decoder decodeObjectForKey:@"photoPath"];
        self.bannerPath = [decoder decodeObjectForKey:@"bannerPath"];
        self.lastUpdate = [decoder decodeObjectForKey:@"lastUpdate"];
        
        self.totalNoOfLikes = [decoder decodeObjectForKey:@"totalNoOfLikes"];
        self.totalNoOfVideos = [decoder decodeObjectForKey:@"totalNoOfVideos"];
        self.totalNoOfTags = [decoder decodeObjectForKey:@"totalNoOfTags"];
        self.videos = [decoder decodeObjectForKey:@"videos"];
        self.followers = [decoder decodeObjectForKey:@"followers"];
        self.followings = [decoder decodeObjectForKey:@"followings"];
        self.privateUsers = [decoder decodeObjectForKey:@"privateUsers"];
        self.country = [decoder decodeObjectForKey:@"country"];
        self.profession = [decoder decodeObjectForKey:@"profession"];
        self.website = [decoder decodeObjectForKey:@"website"];
        self.suggestedUsers = [decoder decodeObjectForKey:@"suggestedUsers"];
        self.moreVideos = [decoder decodeObjectForKey:@"moreVideos"];
        self.userDesc = [decoder decodeObjectForKey:@"userDesc"];
        self.privateFeed = [decoder decodeObjectForKey:@"privateFeed"];
        self.videoFeed = [decoder decodeObjectForKey:@"videoFeed"];
        
        self.emailAddress = [decoder decodeObjectForKey:@"emailAddress"];
        self.phoneNumber = [decoder decodeObjectForKey:@"phoneNumber"];
        self.gender = [decoder decodeObjectForKey:@"gender"];
        self.socialContactsDictionary = [decoder decodeObjectForKey:@"socialContactsDictionary"];
        
        self.address = [decoder decodeObjectForKey:@"address"];
        self.mobileNumber = [decoder decodeObjectForKey:@"mobileNumber"];
    }
    return self;
}

@end
