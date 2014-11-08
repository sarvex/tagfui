/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "ProfileService.h"
#import "NetworkConnection.h"
#import "NSObject+PE.h"
#import "ShowAlert.h"


@implementation ProfileService

@synthesize requestURL;
@synthesize user_name;
@synthesize password;
@synthesize email;
@synthesize apiKey;
@synthesize deviceToken;
@synthesize device;
@synthesize friendsList;
@synthesize loginType;
@synthesize profilePicture;

-(id)initWithCaller:(id)caller
{
    if (self = [super init]) {
        caller_ = caller;
    }
    return  self;
}

#pragma mark Sign up request======
- (void)signup
{
    TCSTART
    NSLog(@"device token: %@, device : %@",deviceToken,device);
    NSDictionary *signUpReqDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:user_name,@"username",email,@"email",password,@"password",device,@"device",deviceToken?:@"",@"device_token", nil],@"user",requestURL,@"url",@"signup",@"requestfor", nil];
        
        [self networkCall:signUpReqDict];
        
    TCEND
}


#pragma mark Profile Dalegate methods
- (void)didFinishGetLoggedInUserProfileResponse:(NSDictionary *)results{
    NSLog(@"Login response:%@",results);
    TCSTART
    if ([caller_ conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishGetLoggedInUserProfileResponse:)]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([loginType caseInsensitiveCompare:@"normal"] == NSOrderedSame) {
//            if ([defaults boolForKey:@"remember"]) {
//                
//            }
            [defaults setObject:email forKey:@"username"];
            [defaults setObject:password forKey:@"password"];
            [defaults setBool:NO forKey:@"issociallogin"];
        } else {
            [defaults setBool:NO forKey:@"remember"];
            [defaults removeObjectForKey:@"username"];
            [defaults removeObjectForKey:@"password"];
            [defaults setBool:YES forKey:@"issociallogin"];
        }
        NSMutableDictionary *loginDict = [results mutableCopy];
        if ([self isNotNull:email]) {
            [loginDict setObject:email forKey:@"email"];
        }
        [caller_ didFinishGetLoggedInUserProfileResponse:loginDict];
    }
    TCEND
}

- (void)didFailToGetLoggedInUserProfileResponseWithError:(NSDictionary *)errorDict {
    
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetLoggedInUserProfileResponseWithError:)]) {
        [caller_ didFailToGetLoggedInUserProfileResponseWithError:errorDict];
    }
    TCEND
}

#pragma mark Login request======
- (void)login {
    TCSTART
    NSDictionary *loginReqDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:email,@"username",password,@"password",device,@"device",deviceToken?:@"",@"device_token", nil],@"login",requestURL,@"url",@"login",@"requestfor", nil];
        
    [self networkCall:loginReqDict];
    
    TCEND
}

- (void)loginThroughSocialSitesWithUserInfo:(NSDictionary *)userInfo {
    TCSTART
    NSDictionary *loginReqDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:userInfo,@"user", nil],@"user",requestURL,@"url",@"socailLogin",@"requestfor", nil];
    
    [self networkCall:loginReqDict];
    TCEND
}

#pragma mark Email new password request======
- (void)emailNewPassword
{
    TCSTART
    
    NSDictionary *emailReqDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:email,@"email",nil],@"email",requestURL,@"url",@"forgotPassword",@"requestfor", nil];
    
    [self networkCall:emailReqDict];
    
    TCEND
}

#pragma mark Forgot password related
- (void)didFinishEmailNewPasswordRequest:(NSDictionary *)results{
    NSLog(@"Login response:%@",results);
    TCSTART
    if ([caller_ conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishEmailNewPasswordRequest:)]) {
        [caller_ didFinishEmailNewPasswordRequest:results];
    }
    TCEND
}
- (void)didFailEmailNewPasswordequestWithError:(NSDictionary *)errorDict {
    
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailEmailNewPasswordequestWithError:)]) {
        [caller_ didFailEmailNewPasswordequestWithError:errorDict];
    }
    TCEND
}

#pragma mark change password related
- (void)changePasswordWithChangedPassword:(NSString *)changedPwd andUserId:(NSString *)userId {
    TCSTART
    NSDictionary *changePWDReqDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:password,@"current_password",changedPwd,@"updated_password",userId,@"user_id", nil],@"user", nil],@"user",requestURL,@"url",@"changepassword",@"requestfor", nil];
   
    [self networkCall:changePWDReqDict];
    
    TCEND
}


- (void)didFinishedChangePasswordRequest:(NSDictionary *)results {
//    NSLog(@"Change password response:%@",results);
    TCSTART
    if ([caller_ conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedChangePasswordRequest:)]) {
        [caller_ didFinishedChangePasswordRequest:results];
    }
    TCEND
}
- (void)didFailChangePasswordRequestWithError:(NSDictionary *)errorDict {
    
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailChangePasswordRequestWithError:)]) {
        [caller_ didFailChangePasswordRequestWithError:errorDict];
    }
    TCEND
}


#pragma mark Account details related
- (void)getAccountDetailsOfLoggedInUser:(NSString *)userId {
    TCSTART
    NSDictionary *changePWDReqDict = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"user_id",requestURL,@"url",@"accountinfo",@"requestfor", nil];
    
    [self networkCall:changePWDReqDict];
    
    TCEND
}


- (void)didFinishedToGetAccountDetialsLoggedInUser:(NSDictionary *)results {
//    NSLog(@"Change password response:%@",results);
    TCSTART
    if ([caller_ conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetAccountDetialsLoggedInUser:)]) {
        [caller_ didFinishedToGetAccountDetialsLoggedInUser:results];
    }
    TCEND
}
- (void)didFailToGetAccountDetialsLoggedInUserWithError:(NSDictionary *)errorDict {
    
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetAccountDetialsLoggedInUserWithError:)]) {
        [caller_ didFailToGetAccountDetialsLoggedInUserWithError:errorDict];
    }
    TCEND
}

#pragma mark Account details related
- (void)updateUserProfileOfLoggedInUserWithInfo:(NSDictionary *)userDict {
    TCSTART
    NSDictionary *changePWDReqDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:userDict,@"user", nil],@"user",requestURL,@"url",@"updateprofile",@"requestfor", nil];
    
    [self networkCall:changePWDReqDict];
    
    TCEND
}


- (void)didFinishedToUpdateUserProfile:(NSDictionary *)results {
//    NSLog(@"Change password response:%@",results);
    TCSTART
    if ([caller_ conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToUpdateUserProfile:)]) {
        [caller_ didFinishedToUpdateUserProfile:results];
    }
    TCEND
}
- (void)didFailToUpdateUserProfileWithError:(NSDictionary *)errorDict {
    
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToUpdateUserProfileWithError:)]) {
        [caller_ didFailToUpdateUserProfileWithError:errorDict];
    }
    TCEND
}

#pragma mark Products list
- (void)getProductsListOfUserWithUserId:(NSString *)userId {
    TCSTART
    NSDictionary *changePWDReqDict = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"user_id",requestURL,@"url",@"productlist",@"requestfor", nil];
    
    [self networkCall:changePWDReqDict];
    TCEND
}

- (void)didFinishedToGetProductsList:(NSDictionary *)results {
    TCSTART
    if ([caller_ conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetProductsList:)]) {
        [caller_ didFinishedToGetProductsList:results];
    }
    TCEND
}
- (void)didFailToGetProductsListWithError:(NSDictionary *)errorDict {
    TCSTART
    if ([caller_ conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetProductsListWithError:)]) {
        [caller_ didFailToGetProductsListWithError:errorDict];
    }
    TCEND
}


#pragma mark Purchase request of product
- (void)getPurchaseRequestsOfProductId:(NSString *)productId ofUserId:(NSString *)userId {
    TCSTART
    NSDictionary *changePWDReqDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:userId?:@"",@"user_id",productId?:@"",@"product_id", nil],@"user",requestURL,@"url",@"purchases",@"requestfor", nil];
    
    [self networkCall:changePWDReqDict];
    TCEND
}
- (void)didFinishedToPurchaseRequestForProduct:(NSDictionary *)results {
    TCSTART
    if ([caller_ conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToPurchaseRequestForProduct:)]) {
        [caller_ didFinishedToPurchaseRequestForProduct:results];
    }
    TCEND
}
- (void)didFailToGetPurchaseRequestForProductWithError:(NSDictionary *)errorDict {
    TCSTART
    if ([caller_ conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetPurchaseRequestForProductWithError:)]) {
        [caller_ didFailToGetPurchaseRequestForProductWithError:errorDict];
    }
    TCEND
}

#pragma mark NetWork Call
- (void)networkCall:(NSDictionary *)requestParams {
    
    TCSTART
            // Create a network request
        NetworkConnection *networkConn = [[NetworkConnection alloc] init];
        
        if([[requestParams objectForKey:@"requestfor"] isEqualToString:@"signup"]) { 
            [NSThread detachNewThreadSelector:@selector(requestForSignUp:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
           
        }
        else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"login"]){
            
            [NSThread detachNewThreadSelector:@selector(requestForLogin:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"socailLogin"]){
            
            [NSThread detachNewThreadSelector:@selector(requestForSocialLogin:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"forgotPassword"]){ //thread call for search.
            
            [NSThread detachNewThreadSelector:@selector(requestForEmailNewPassword:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"changepassword"]){ //thread call for search.
            
            [NSThread detachNewThreadSelector:@selector(requestForChangePassword:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"accountinfo"]){ //thread call for search.
            
            [NSThread detachNewThreadSelector:@selector(requestForGetAccountDetails:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"updateprofile"]){ //thread call for search.
            
            [NSThread detachNewThreadSelector:@selector(requestForUpdateUserProfile:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"productlist"]){ //thread call for search.
            
            [NSThread detachNewThreadSelector:@selector(requestForGetProductsList:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
            
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"purchases"]){ //thread call for search.
            
            [NSThread detachNewThreadSelector:@selector(requestForGetPurchaseRequestsOfProduct:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        }
        networkConn = nil;
    TCEND
}



@end
