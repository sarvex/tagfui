/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>

@protocol ProfileServiceDelegate <NSObject>

@optional

//Login or Signup
- (void)didFinishGetLoggedInUserProfileResponse:(NSDictionary *)results;
- (void)didFailToGetLoggedInUserProfileResponseWithError:(NSDictionary *)errorDict;

//Forgot password
- (void)didFinishEmailNewPasswordRequest:(NSDictionary *)results;
- (void)didFailEmailNewPasswordequestWithError:(NSDictionary *)errorDict;

// change password
- (void)didFinishedChangePasswordRequest:(NSDictionary *)results;
- (void)didFailChangePasswordRequestWithError:(NSDictionary *)errorDict;

//Account detials
- (void)didFinishedToGetAccountDetialsLoggedInUser:(NSDictionary *)results;
- (void)didFailToGetAccountDetialsLoggedInUserWithError:(NSDictionary *)errorDict;

// update profile
- (void)didFinishedToUpdateUserProfile:(NSDictionary *)results;
- (void)didFailToUpdateUserProfileWithError:(NSDictionary *)errorDict;

// Products Related
- (void)didFinishedToGetProductsList:(NSDictionary *)results;
- (void)didFailToGetProductsListWithError:(NSDictionary *)errorDict;

// Product Purchases Related
- (void)didFinishedToPurchaseRequestForProduct:(NSDictionary *)results;
- (void)didFailToGetPurchaseRequestForProductWithError:(NSDictionary *)errorDict;

@end

@interface ProfileService : NSObject<ProfileServiceDelegate>
{
    id caller_;
    NSString *requestURL;       //set the host URL
    NSString *user_name;
    NSString *password;
    NSString *email;
    NSString *apiKey;
    NSString *deviceToken;
    NSString *device;
    
    //Social Site login
    NSString *loginType;
    NSString *profilePicture;
    NSArray *friendsList;
}


@property (nonatomic, retain) NSString *requestURL;
@property (nonatomic, retain) NSString *user_name;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *apiKey;
@property (nonatomic, retain) NSString *deviceToken;
@property (nonatomic, retain) NSString *device;
@property (nonatomic, retain) NSString *loginType;
@property (nonatomic, retain) NSString *profilePicture;
@property (nonatomic, retain) NSArray *friendsList;

- (id)initWithCaller:(id)caller;
- (void)signup;
- (void)login;
- (void)loginThroughSocialSitesWithUserInfo:(NSDictionary *)userInfo;
- (void)emailNewPassword;
- (void)changePasswordWithChangedPassword:(NSString *)changedPwd andUserId:(NSString *)userId;
- (void)getAccountDetailsOfLoggedInUser:(NSString *)userId;
- (void)updateUserProfileOfLoggedInUserWithInfo:(NSDictionary *)userDict;


- (void)getProductsListOfUserWithUserId:(NSString *)userId;
- (void)getPurchaseRequestsOfProductId:(NSString *)productId ofUserId:(NSString *)userId;

@end
