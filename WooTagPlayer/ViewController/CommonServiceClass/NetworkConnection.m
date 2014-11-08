/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "NetworkConnection.h"
#import "SBJson.h"
//#import <ASJSON/ASJSON.h>
#import "NSObject+PE.h"
#import "TagService.h"
#import "Reachability.h"
#import "ShowAlert.h"
#import "UserService.h"
#import "VideoService.h"
#import "ProfileService.h"
#import "BrowseService.h"
#import "NotificationService.h"
#import "WooTagPlayerAppDelegate.h"

@implementation NetworkConnection

#pragma mark Signup request
- (void)requestForSignUp:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        
        
        NSDictionary *signUpReqDict = [NSDictionary dictionaryWithObjectsAndKeys:[paramsDict objectForKey:@"user"],@"user", nil];
        NSLog(@"DICT: %@",signUpReqDict);
        
        //        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"signup"]];
        NSString *jRequest = [writer stringWithObject:signUpReqDict];
        NSLog(@"jRequest: %@", jRequest);
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/signup",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        
        NSLog(@"Response is: %@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFinishGetLoggedInUserProfileResponse:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishGetLoggedInUserProfileResponse:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetLoggedInUserProfileResponseWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetLoggedInUserProfileResponseWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetLoggedInUserProfileResponseWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetLoggedInUserProfileResponseWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetLoggedInUserProfileResponseWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetLoggedInUserProfileResponseWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Login Request
- (void)requestForLogin:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        
        
        NSDictionary *loginReqDict = [NSDictionary dictionaryWithObjectsAndKeys:[paramsDict objectForKey:@"login"],@"user", nil];
        NSLog(@"DICT: %@",loginReqDict);
        
        //        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"signup"]];
        NSString *jRequest = [writer stringWithObject:loginReqDict];
        NSLog(@"jRequest: %@", jRequest);
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/login",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        
        NSLog(@"Response is: %@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFinishGetLoggedInUserProfileResponse:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishGetLoggedInUserProfileResponse:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetLoggedInUserProfileResponseWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetLoggedInUserProfileResponseWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
        
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetLoggedInUserProfileResponseWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetLoggedInUserProfileResponseWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetLoggedInUserProfileResponseWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetLoggedInUserProfileResponseWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark SocialLogin Request
- (void)requestForSocialLogin:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"user"]];
        NSLog(@"jRequest: %@", jRequest);
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/sociallogin",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        
        NSLog(@"Response is: %@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFinishGetLoggedInUserProfileResponse:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishGetLoggedInUserProfileResponse:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetLoggedInUserProfileResponseWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetLoggedInUserProfileResponseWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetLoggedInUserProfileResponseWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetLoggedInUserProfileResponseWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetLoggedInUserProfileResponseWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetLoggedInUserProfileResponseWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Forgot Password request
- (void)requestForEmailNewPassword:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        
        
        NSDictionary *loginReqDict = [NSDictionary dictionaryWithObjectsAndKeys:[paramsDict objectForKey:@"email"],@"user", nil];
        NSLog(@"DICT: %@",loginReqDict);
        
        NSString *jRequest = [writer stringWithObject:loginReqDict];
        NSLog(@"jRequest: %@", jRequest);
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/forgotpassword",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        
        NSLog(@"Response is: %@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFinishEmailNewPasswordRequest:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishEmailNewPasswordRequest:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailEmailNewPasswordequestWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailEmailNewPasswordequestWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailEmailNewPasswordequestWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailEmailNewPasswordequestWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailEmailNewPasswordequestWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailEmailNewPasswordequestWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Change Password request
- (void)requestForChangePassword:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"user"]];
        NSLog(@"jRequest: %@", jRequest);
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/update_mypassword",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        
        NSLog(@"Response is: %@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedChangePasswordRequest:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedChangePasswordRequest:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailChangePasswordRequestWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailChangePasswordRequestWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailChangePasswordRequestWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailChangePasswordRequestWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailChangePasswordRequestWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailChangePasswordRequestWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}


#pragma mark Account details request
- (void)requestForGetAccountDetails:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];

        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:[paramsDict objectForKey:@"user_id"],@"user_id", nil];
        SBJsonWriter *writer = [SBJsonWriter new];
        NSString *jRequest = [writer stringWithObject:[NSDictionary dictionaryWithObjectsAndKeys:userDict,@"user", nil]];
        NSLog(@"jRequest: %@", jRequest);
        
        NSString *url = [NSString stringWithFormat:@"%@/myaccount",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        
        NSLog(@"Response is: %@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetAccountDetialsLoggedInUser:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetAccountDetialsLoggedInUser:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetAccountDetialsLoggedInUserWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetAccountDetialsLoggedInUserWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetAccountDetialsLoggedInUserWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetAccountDetialsLoggedInUserWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetAccountDetialsLoggedInUserWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetAccountDetialsLoggedInUserWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}


#pragma mark Update profile request
- (void)requestForUpdateUserProfile:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"user"]];
//        NSLog(@"jRequest: %@", jRequest);
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/update_myaccount",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        
        NSLog(@"Response is: %@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToUpdateUserProfile:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToUpdateUserProfile:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUpdateUserProfileWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToUpdateUserProfileWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUpdateUserProfileWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToUpdateUserProfileWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUpdateUserProfileWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToUpdateUserProfileWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Products list request
- (void)requestForGetProductsList:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/product_info/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"user_id"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        
        NSLog(@"Response is: %@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetProductsList:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetProductsList:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetProductsListWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetProductsListWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetProductsListWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetProductsListWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetProductsListWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetProductsListWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}


#pragma mark purchase details of product request request
- (void)requestForGetPurchaseRequestsOfProduct:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"user"]];
        NSLog(@"jRequest: %@", jRequest);
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/purchase_request",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        
        NSLog(@"Response is: %@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToPurchaseRequestForProduct:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToPurchaseRequestForProduct:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetPurchaseRequestForProductWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetPurchaseRequestForProductWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetPurchaseRequestForProductWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetPurchaseRequestForProductWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(ProfileServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetPurchaseRequestForProductWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetPurchaseRequestForProductWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark AddTags category
- (void)requestForAddTags:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        NSLog(@"DICT: %@",[paramsDict objectForKey:@"tags"]);
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"tags"]];
        NSLog(@"jRequest: %@", jRequest); 
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/addtags",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);

        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedAddingTags:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedAddingTags:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
//                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
//                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFailToAddTagsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToAddTagsWithError:) withObject:responseDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFailToAddTagsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToAddTagsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];

            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFailToAddTagsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToAddTagsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }    
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark AddTags category
- (void)requestForBuyProduct:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        NSLog(@"DICT: %@",[paramsDict objectForKey:@"parameters"]);
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"parameters"]];
        NSLog(@"jRequest: %@", jRequest);
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/buy",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller respondsToSelector:@selector(didFinishedBuyingProductWithResults:)]) {
                        [caller performSelectorOnMainThread:@selector(didFinishedBuyingProductWithResults:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    if (caller && [caller respondsToSelector:@selector(didFailedToBuyProduct:)]) {
                        [caller performSelectorOnMainThread:@selector(didFailedToBuyProduct:) withObject:responseDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller respondsToSelector:@selector(didFailedToBuyProduct:)]) {
                    [caller performSelectorOnMainThread:@selector(didFailedToBuyProduct:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller respondsToSelector:@selector(didFailedToBuyProduct:)]) {
                [caller performSelectorOnMainThread:@selector(didFailedToBuyProduct:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

- (void)requestForPlayBack:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/playback/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"videoId"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedPlayBackRequest:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedPlayBackRequest:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFailedPlayBackRequestWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailedPlayBackRequestWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFailedPlayBackRequestWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailedPlayBackRequestWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFailedPlayBackRequestWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailedPlayBackRequestWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

- (void)requestForDeleteTag:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/deletetag/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"tagId"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedDeleteTag:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedDeleteTag:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                   NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFailToDeleteTagWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToDeleteTagWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFailToDeleteTagWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToDeleteTagWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFailToDeleteTagWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToDeleteTagWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

- (void)requestForUpdateTags:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
       
        SBJsonWriter *writer = [SBJsonWriter new];
        NSLog(@"DICT: %@",[paramsDict objectForKey:@"tags"]);
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"tags"]];
        NSLog(@"jRequest: %@", jRequest);

        NSString *url = [NSString stringWithFormat:@"%@/updatetags",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);

        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedUpdatingTags:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedUpdatingTags:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
//                    NSString *msg = [self returnError:caller withObject:responseDict];
//                    
//                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUpdateTagsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToUpdateTagsWithError:) withObject:responseDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription],@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUpdateTagsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToUpdateTagsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUpdateTagsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToUpdateTagsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark MyPage Request
- (void)requestForMyPage:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
//        user
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        SBJsonWriter *writer = [SBJsonWriter new];
        NSString *jRequest = [writer stringWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[paramsDict objectForKey:@"user"],@"user", nil]];
        NSLog(@"jRequest: %@", jRequest);
        
        NSString *url = [NSString stringWithFormat:@"%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"requestfor"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict  objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetMypageDetails:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetMypageDetails:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
//                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                     NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetMypageDetailsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetMypageDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetMypageDetailsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetMypageDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetMypageDetailsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetMypageDetailsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Reset badge count Request
- (void)requestForResetBadge:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
       
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
       
        NSData *responseData = [self createNetworkConnection:[parameters objectForKey:@"url"] WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (caller && [caller respondsToSelector:@selector(didFinishedResetBadgeCount)]) {
            
            [caller performSelectorOnMainThread:@selector(didFinishedResetBadgeCount) withObject:nil waitUntilDone:NO];
        }
        
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Request For Follow user
- (void)requestForUserFollow:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/follow/%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"userId"],[paramsDict objectForKey:@"followerId"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToFollowUser:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToFollowUser:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
//                     NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                     NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToFollowUserWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToFollowUserWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
 
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToFollowUserWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToFollowUserWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToFollowUserWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToFollowUserWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Request For unfollow user
- (void)requestForUserUnfollow:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/unfollow/%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"userId"],[paramsDict objectForKey:@"followerId"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToUnFollowUser:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToUnFollowUser:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
//                     NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                     NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUnFollowUserWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToUnFollowUserWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUnFollowUserWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToUnFollowUserWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUnFollowUserWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToUnFollowUserWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Request For Unprivate user
- (void)requestForUserUnPrivate:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/decline_pvtgroup/%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"userId"],[paramsDict objectForKey:@"privateUserId"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToUnPrivateUser:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToUnPrivateUser:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                     NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUnPrivateUserWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToUnPrivateUserWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUnPrivateUserWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToUnPrivateUserWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUnPrivateUserWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToUnPrivateUserWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Request For private user
- (void)requestForUserPrivate:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/follow_pvtgroup/%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"userId"],[paramsDict objectForKey:@"privateUserId"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToPrivateUser:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToPrivateUser:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                     NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToPrivateUserWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToPrivateUserWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToPrivateUserWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToPrivateUserWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToPrivateUserWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToPrivateUserWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Request For private user
- (void)requestForAcceptPrivateGroup:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/accept_pvtgroup/%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"userId"],[paramsDict objectForKey:@"privateUserId"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToAcceptPrivateUser:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToAcceptPrivateUser:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                     NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToAcceptPrivateUserWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToAcceptPrivateUserWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToAcceptPrivateUserWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToAcceptPrivateUserWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToAcceptPrivateUserWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToAcceptPrivateUserWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Request for User Followings
- (void)requestForUserFollowings:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/followings/%@/%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"loggedIn"],[paramsDict objectForKey:@"userId"],[paramsDict objectForKey:@"pagenumber"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetUserFollowings:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetUserFollowings:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
//                     NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                     NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetUserFollowingsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetUserFollowingsWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
            
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetUserFollowingsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetUserFollowingsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetUserFollowingsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetUserFollowingsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma  mark Request for User Followers
- (void)requestForUserFollowers:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/followers/%@/%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"loggedIn"],[paramsDict objectForKey:@"userId"],[paramsDict objectForKey:@"pagenumber"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetUserFollowers:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetUserFollowers:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
//                     NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                     NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetUserFollowersWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetUserFollowersWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetUserFollowersWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetUserFollowersWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetUserFollowersWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetUserFollowersWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma  mark Request for User Private users
- (void)requestForPrivateUsers:(NSDictionary *) parameters {
    //Thread Pool
    TCSTART
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/%@/%d",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"userId"],[[paramsDict objectForKey:@"pagenumber"] intValue]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetPrivateUsers:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetPrivateUsers:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                     NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetPrivateUsersWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetPrivateUsersWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetPrivateUsersWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetPrivateUsersWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetPrivateUsersWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetPrivateUsersWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma  mark Request for User Private users
- (void)requestForWooTagFriends:(NSDictionary *) parameters {
    //Thread Pool
    TCSTART
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
       
        NSString *url = [NSString stringWithFormat:@"%@/wootagfriends/%@/%@/%d",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"userId"],[paramsDict objectForKey:@"userId"],[[paramsDict objectForKey:@"pagenumber"] intValue]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetWooTagFreinds:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetWooTagFreinds:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                     NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                   NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetWooTagFreindsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetWooTagFreindsWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetWooTagFreindsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetWooTagFreindsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetWooTagFreindsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetWooTagFreindsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma  mark Request for User Followers
- (void)requestForSocialUsersInformation:(NSDictionary *) parameters {
    //Thread Pool
    TCSTART
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        SBJsonWriter *writer = [SBJsonWriter new];
        NSString *jRequest = [writer stringWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[paramsDict objectForKey:@"friends"],@"friends",[paramsDict objectForKey:@"userId"],@"user_id", nil]];
        NSLog(@"jRequest: %@", jRequest);
        
        NSString *url = [NSString stringWithFormat:@"%@/findfriends",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetSocialNetWorkFriendsInfo:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetSocialNetWorkFriendsInfo:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                     NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetSocialNetWorkFriendsInfoWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetSocialNetWorkFriendsInfoWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetSocialNetWorkFriendsInfoWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetSocialNetWorkFriendsInfoWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetSocialNetWorkFriendsInfoWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetSocialNetWorkFriendsInfoWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma  mark Request for Suggested Users
- (void)requestForSuggestedUsers:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
//        pagenumber
        NSString *url = [NSString stringWithFormat:@"%@/suggested_users/%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"userId"],[paramsDict objectForKey:@"pagenumber"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetSuggestedUsers:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetSuggestedUsers:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                     NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetSuggestedUsersWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetSuggestedUsersWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetSuggestedUsersWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetSuggestedUsersWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetSuggestedUsersWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetSuggestedUsersWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma  mark Request for Tag comment users
- (void)requestForTagCommentUsers:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"comments"]];
        NSLog(@"jRequest: %@", jRequest);
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        //        pagenumber
        NSString *url = [NSString stringWithFormat:@"%@/tagusercomments",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetTagCommentUsersInfo:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetTagCommentUsersInfo:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                     NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetTagCommentUsersInfoWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetTagCommentUsersInfoWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetTagCommentUsersInfoWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetTagCommentUsersInfoWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetTagCommentUsersInfoWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetTagCommentUsersInfoWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Get All comments
- (void)requestForGetAllComments:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/getallcomments/%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"videoId"],[paramsDict objectForKey:@"pagenumber"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetAllCommentsOfVideo:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetAllCommentsOfVideo:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
//                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                     NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetAllCommentsOfVideoWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetAllCommentsOfVideoWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
        
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetAllCommentsOfVideoWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetAllCommentsOfVideoWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetAllCommentsOfVideoWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetAllCommentsOfVideoWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Delete video
- (void)requestForDeleteVideo:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/deletevideo/%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"userId"],[paramsDict objectForKey:@"videoId"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedDeleteVideo:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedDeleteVideo:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
//                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                     NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailedDeleteVideoWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailedDeleteVideoWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailedDeleteVideoWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailedDeleteVideoWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailedDeleteVideoWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailedDeleteVideoWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}


#pragma mark Report video
- (void)requestForReportVideo:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        SBJsonWriter *writer = [SBJsonWriter new];
//        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[paramsDict objectForKey:@"user"],@"user", nil];
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"user"]];
        NSLog(@"jRequest: %@", jRequest);
        
        NSString *url = [NSString stringWithFormat:@"%@/addReport",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedReportVideo:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedReportVideo:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailedReportVideoWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailedReportVideoWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
              
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailedReportVideoWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailedReportVideoWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailedReportVideoWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailedReportVideoWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark
#pragma mark  Feedback
- (void)requestToSendFeedback:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        //        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[paramsDict objectForKey:@"user"],@"user", nil];
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"user"]];
        NSLog(@"jRequest: %@", jRequest);
        
        NSString *url = [NSString stringWithFormat:@"%@/addFeedback",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToSendFeedback:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToSendFeedback:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailedToSendFeedbackWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailedToSendFeedbackWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailedToSendFeedbackWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailedToSendFeedbackWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(UserServiceDelegate)] && [caller respondsToSelector:@selector(didFailedToSendFeedbackWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailedToSendFeedbackWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark
#pragma mark change access permissions of video
- (void)requestForChangeAccessPermissions:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[paramsDict objectForKey:@"permissions"],@"video", nil];
        NSString *jRequest = [writer stringWithObject:dict];
        NSLog(@"jRequest: %@", jRequest);
        
        NSString *url = [NSString stringWithFormat:@"%@/update_videoaccess",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedChangeVideoAccessPermission:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedChangeVideoAccessPermission:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailedToChangeVideoAccessPermissionWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailedToChangeVideoAccessPermissionWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailedToChangeVideoAccessPermissionWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailedToChangeVideoAccessPermissionWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailedToChangeVideoAccessPermissionWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailedToChangeVideoAccessPermissionWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark like video
- (void)requestForLikeVideo:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/likevideo/%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"videoId"],[paramsDict objectForKey:@"userId"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedLikeVideo:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedLikeVideo:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
//                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                     NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailedLikeVideoWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailedLikeVideoWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailedLikeVideoWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailedLikeVideoWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailedLikeVideoWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailedLikeVideoWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark unlike video
- (void)requestForUnLikeVideo:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/dislikevideo/%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"videoId"],[paramsDict objectForKey:@"userId"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedUnLikeVideo:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedUnLikeVideo:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailedUnLikeVideoWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailedUnLikeVideoWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailedUnLikeVideoWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailedUnLikeVideoWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailedUnLikeVideoWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailedUnLikeVideoWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark AllLikes
- (void)requestForGetAllLikes:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/likelist/%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"videoId"],[paramsDict objectForKey:@"pagenumber"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetAllLikesOfVideo:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetAllLikesOfVideo:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetAllLikesOfVideoWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetAllLikesOfVideoWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetAllLikesOfVideoWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetAllLikesOfVideoWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetAllLikesOfVideoWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetAllLikesOfVideoWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}


#pragma mark PostComment
- (void)postComment:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[paramsDict objectForKey:@"user"],@"user", nil];
        NSString *jRequest = [writer stringWithObject:dict];
        NSLog(@"jRequest: %@", jRequest);
        
        NSString *url = [NSString stringWithFormat:@"%@/commentvideo",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedCommentingVideo:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedCommentingVideo:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
//                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                     NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToCommentVideoWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToCommentVideoWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToCommentVideoWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToCommentVideoWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToCommentVideoWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToCommentVideoWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Delete comment
- (void)deleteComment:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        NSString *url = [NSString stringWithFormat:@"%@/deletevideocomment/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"cmnt_id"]/**,[paramsDict objectForKey:@"userid"]*/];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedDeleteCommentVideo:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedDeleteCommentVideo:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                   NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToDeleteCommentVideoWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToDeleteCommentVideoWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToDeleteCommentVideoWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToDeleteCommentVideoWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToDeleteCommentVideoWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToDeleteCommentVideoWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}


#pragma mark MypageVideo
- (void)requestForMyPageVideos:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[paramsDict objectForKey:@"user"],@"user", nil];
        NSString *jRequest = [writer stringWithObject:dict];
        NSLog(@"jRequest: %@", jRequest);
        
        NSString *url = [NSString stringWithFormat:@"%@/mypagevideos",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedGetMypageVideos:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedGetMypageVideos:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
//                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                     NSString *msg = [self returnError:caller withObject:responseDict];
                    
                   NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetMypageVideosWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetMypageVideosWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetMypageVideosWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetMypageVideosWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetMypageVideosWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetMypageVideosWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark video feed
- (void)requestForVideoFeed:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[paramsDict objectForKey:@"user"],@"user", nil];
        NSString *jRequest = [writer stringWithObject:dict];
        NSLog(@"jRequest: %@", jRequest);
        
        NSString *url = [NSString stringWithFormat:@"%@/videofeed",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetVideoFeed:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetVideoFeed:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetVideoFeedWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetVideoFeedWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetVideoFeedWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetVideoFeedWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetVideoFeedWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetVideoFeedWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark video feed
- (void)requestForPrivateFeed:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[paramsDict objectForKey:@"user"],@"user", nil];
        NSString *jRequest = [writer stringWithObject:dict];
        NSLog(@"jRequest: %@", jRequest);
        
        NSString *url = [NSString stringWithFormat:@"%@/pvtgroup_videofeed",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetPrivateFeed:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetPrivateFeed:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetPrivateFeedWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetPrivateFeedWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetPrivateFeedWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetPrivateFeedWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetPrivateFeedWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetPrivateFeedWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Videos Search
- (void)requestForSearch:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"user"]];
        NSLog(@"jRequest: %@", jRequest);
        
        NSString *url = [NSString stringWithFormat:@"%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"type"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetSearchReqDetails:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetSearchReqDetails:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetSearchReqDetailsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetSearchReqDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetSearchReqDetailsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetSearchReqDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetSearchReqDetailsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetSearchReqDetailsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}


#pragma mark Browse Request
- (void)requestForBrowse:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"user"]];
        NSLog(@"jRequest: %@", jRequest);

        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/browse",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict  objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetBrowseDetails:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetBrowseDetails:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetBrowseDetailsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetBrowseDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetBrowseDetailsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetBrowseDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetBrowseDetailsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetBrowseDetailsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark BrowseDetials Request
- (void)requestForBrowseDetails:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"user"]];
        NSLog(@"jRequest: %@", jRequest);
        
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/browsedetail",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict  objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetBrowseVideoDetails:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetBrowseVideoDetails:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetBrowseVideoDetailsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetBrowseVideoDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetBrowseVideoDetailsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetBrowseVideoDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetBrowseVideoDetailsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetBrowseVideoDetailsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}


#pragma mark Myother stuff Request
- (void)requestForMyotherStuff:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
//        SBJsonWriter *writer = [SBJsonWriter new];
//        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"user"]];
//        NSLog(@"jRequest: %@", jRequest);
//        
//        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/myotherstuff/%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"user_id"],[paramsDict objectForKey:@"page_no"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict  objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetOtherStuffDetails:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetOtherStuffDetails:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetOtherStuffDetailsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetOtherStuffDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetOtherStuffDetailsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetOtherStuffDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetOtherStuffDetailsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetOtherStuffDetailsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Browse Search Request
- (void)requestForBrowseSearch:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
//        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        SBJsonWriter *writer = [SBJsonWriter new];
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"user"]];
        NSLog(@"jRequest: %@", jRequest);
        
        NSString *url = [paramsDict objectForKey:@"url"];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict  objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetSearchDetails:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetSearchDetails:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetSearchDetailsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetSearchDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetSearchDetailsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetSearchDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetSearchDetailsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetSearchDetailsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}


#pragma mark Trends Request
- (void)requestForTrends:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"user"]];
        NSLog(@"jRequest: %@", jRequest);
        
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/getAllTrends",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict  objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetBrowseDetails:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetBrowseDetails:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetBrowseDetailsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetBrowseDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetBrowseDetailsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetBrowseDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetBrowseDetailsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetBrowseDetailsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Trends details Request
- (void)requestForTrendsDetails:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"user"]];
        NSLog(@"jRequest: %@", jRequest);
        
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/trends",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict  objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetBrowseDetails:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetBrowseDetails:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetBrowseDetailsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetBrowseDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetBrowseDetailsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetBrowseDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(BrowseServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetBrowseDetailsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetBrowseDetailsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}



#pragma mark Notifications
- (void)requestToGetNotifications:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
    
        NSString *url = [NSString stringWithFormat:@"%@/notifications/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"userid"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetUserNotifications:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetUserNotifications:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetUserNotificationsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetUserNotificationsWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetUserNotificationsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetUserNotificationsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetUserNotificationsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetUserNotificationsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Remove Notifications
- (void)requestToRemoveNotifications:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
   
        NSString *url = [NSString stringWithFormat:@"%@/remove_notification/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"notificationid"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToRemoveUserNotification:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToRemoveUserNotification:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToRemoveUserNotificationWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToRemoveUserNotificationWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToRemoveUserNotificationWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToRemoveUserNotificationWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToRemoveUserNotificationWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToRemoveUserNotificationWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Get NotificationsSettings
- (void)requestToGetNotificationsSettings:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSString *url = [NSString stringWithFormat:@"%@/notificationsettings/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"userId"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetNotificationSettings:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetNotificationSettings:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetNotificationSettingsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetNotificationSettingsWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetNotificationSettingsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetNotificationSettingsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetNotificationSettingsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetNotificationSettingsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark update Notificationsettings
- (void)requestToUpdateNotificationSettings:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        NSString *jRequest = [writer stringWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[paramsDict objectForKey:@"push"],@"push", nil]];
        NSLog(@"jRequest: %@", jRequest);
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *url = [NSString stringWithFormat:@"%@/updatenotificationsettings",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToUpdateNotificationsSettings:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToUpdateNotificationsSettings:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUpdateNotificationsSettingsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToUpdateNotificationsSettingsWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUpdateNotificationsSettingsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToUpdateNotificationsSettingsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUpdateNotificationsSettingsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToUpdateNotificationsSettingsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Notifications Search
- (void)requestForNotificationsSearch:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        SBJsonWriter *writer = [SBJsonWriter new];
        NSString *jRequest = [writer stringWithObject:[paramsDict objectForKey:@"user"]];
        NSLog(@"jRequest: %@", jRequest);
        
        NSString *url = [NSString stringWithFormat:@"%@/notificationssearch",[paramsDict objectForKey:@"url"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:60];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetUserNotificationsSearch:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetUserNotificationsSearch:) withObject:responseDict waitUntilDone:NO];
                    }
                } else{
                    
                    //                    NSString *msg = [self returnError:caller withObject:[responseDict objectForKey:@"result"]];
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetUserNotificationsSearchWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetUserNotificationsSearchWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetUserNotificationsSearchWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetUserNotificationsSearchWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetUserNotificationsSearchWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetUserNotificationsSearchWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark Get Video details
- (void)requestForGetVideoDetails:(NSDictionary *) parameters {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSString *url = [NSString stringWithFormat:@"%@/videodetails/%@/%@",[paramsDict objectForKey:@"url"],[paramsDict objectForKey:@"videoId"],[paramsDict objectForKey:@"notificationType"]];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToGetVideoDetails:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToGetVideoDetails:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
            
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetVideoDetailsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToGetVideoDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetVideoDetailsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToGetVideoDetailsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(NotificationServiceDelegate)] && [caller respondsToSelector:@selector(didFailToGetVideoDetailsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToGetVideoDetailsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

- (void)videoFileUploadRequestWithParameters:(NSDictionary *)parameters  {
    TCSTART
   
    //Thread Pool
	@autoreleasepool {
        NSString *jRequest = [parameters objectForKey:@"body"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSString *url = [parameters objectForKey:@"url"];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@ body :%@", url,jRequest);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:62];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoUploadServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToFileUploadVideoInfo:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToFileUploadVideoInfo:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:currentStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoUploadServiceDelegate)] && [caller respondsToSelector:@selector(didFailToFileUploadVideoInfoWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToFileUploadVideoInfoWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:currentStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(VideoUploadServiceDelegate)] && [caller respondsToSelector:@selector(didFailToFileUploadVideoInfoWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToFileUploadVideoInfoWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:currentStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(VideoUploadServiceDelegate)] && [caller respondsToSelector:@selector(didFailToFileUploadVideoInfoWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToFileUploadVideoInfoWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

- (void)videoUploadRequestWithParameters:(NSDictionary *)parameters  {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSString *jRequest = [parameters objectForKey:@"body"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSString *url = [parameters objectForKey:@"url"];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@ body :%@", url,jRequest);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:jRequest WithHTTPMethod:@"POST" timeOutInterVal:62];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoUploadServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedToUploadVideoInfo:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedToUploadVideoInfo:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:currentStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(VideoUploadServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUploadVideoInfoWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailToUploadVideoInfoWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:currentStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(VideoUploadServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUploadVideoInfoWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailToUploadVideoInfoWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:currentStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(VideoUploadServiceDelegate)] && [caller respondsToSelector:@selector(didFailToUploadVideoInfoWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailToUploadVideoInfoWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}


- (void)analyticsRequestWithParameters:(NSDictionary *)parameters  {
    TCSTART
    //Thread Pool
	@autoreleasepool {
        NSDictionary *paramsDict = [parameters objectForKey:@"params"];
        id caller = [parameters objectForKey:@"caller"];
        
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        /** analyticsId
            0 --- video views
            1 --- facebook link
            2 --- googleplus link
            3 --- twitterlink
            4 --- url link
         */
        NSString *url = [paramsDict objectForKey:@"url"];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"URL: %@", url);
        
        NSData *responseData = [self createNetworkConnection:url WithBody:nil WithHTTPMethod:@"GET" timeOutInterVal:60];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
        NSLog(@"CurrentstatusCode:%d",currentStatusCode);
        NSLog(@"%@",responseString);
        
        if (currentStatusCode == 200 || currentStatusCode == 201 || currentStatusCode == 202) {
            networkStatusCode = 0;
            NSError *error;
            NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
            
            if (!error) {
                NSNumber *code = [responseDict objectForKey:@"error_code"];
                if ([code intValue] == 0) {
                    
                    if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFinishedSendAnalyticsInfo:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFinishedSendAnalyticsInfo:) withObject:responseDict waitUntilDone:NO];
                    }
                } else {
                    
                    NSString *msg = [self returnError:caller withObject:responseDict];
                    
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                    
                    if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFailedToSendAnalyticsWithError:)]) {
                        
                        [caller performSelectorOnMainThread:@selector(didFailedToSendAnalyticsWithError:) withObject:errorDict waitUntilDone:NO];
                    }
                }
            } else {
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server is under maintenance, Please try again in some time",@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
                
                if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFailedToSendAnalyticsWithError:)]) {
                    
                    [caller performSelectorOnMainThread:@selector(didFailedToSendAnalyticsWithError:) withObject:errorDict waitUntilDone:NO];
                }
            }
        } else {
            
            NSDictionary *responseMap = [parser objectWithString:responseString error:nil];
            NSString *msg = [self returnError: caller withObject:responseMap withUrl:url];
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",[NSNumber numberWithInt:networkStatusCode],@"networkstatuscode", nil];
            
            if (caller && [caller conformsToProtocol:@protocol(TagServiceDelegate)] && [caller respondsToSelector:@selector(didFailedToSendAnalyticsWithError:)]) {
                
                [caller performSelectorOnMainThread:@selector(didFailedToSendAnalyticsWithError:) withObject:errorDict waitUntilDone:NO];
            }
        }
        parser = nil;
        responseData = nil;
        responseString = nil;
    }
    TCEND
}

#pragma mark CreateNetworkConnection with Body and httpmethod.
- (NSData *)createNetworkConnection:(NSString *)url WithBody:(NSString *)body WithHTTPMethod:(NSString *) httpMethod timeOutInterVal:(NSInteger)timeInterval {
    @try {
         
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: url]];
        
        // creation the cookie
        NSURL *_server_url = [NSURL URLWithString:url];
        NSHTTPCookie *cook = [NSHTTPCookie cookieWithProperties:
                              [NSDictionary dictionaryWithObjectsAndKeys:
                               [_server_url host], NSHTTPCookieDomain,
                               [_server_url path], NSHTTPCookiePath,
                               @"testcookie",  NSHTTPCookieName,
                               @"1", NSHTTPCookieValue,
                               nil]];
        // Posting the cookie
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cook];
        
            [request setHTTPMethod: httpMethod];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//            [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody: [body dataUsingEncoding:NSUTF8StringEncoding]];
            [request setTimeoutInterval:timeInterval];
        
            NSHTTPURLResponse *resp = nil;
            NSError *error = nil;
            NSData *response = nil;
            int try = 0;
            while (try < 2) {
                try++;
            
                response = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error: &error];
            
                if (error) {
                    networkStatusCode = 1;
                    currentStatusCode = 0;
                    if ([error code] == -1012) {//NSURLErrorUserCancelledAuthentication
                        currentStatusCode = 401;
                    } else if ([error code] == -1001) { //NSURLErrorTimedOut
                        currentStatusCode = 408;
                        try = 100;
                    } else { // check for error description which got throgh the responsse
                    
                        response = [[NSString stringWithFormat:@"{\"error\":\"%@\"}", [error localizedDescription]] dataUsingEncoding:NSUTF8StringEncoding];
                     currentStatusCode = [error code];
                   }
                } else if (resp) {
                    currentStatusCode = [resp statusCode];
                }    
            
            // Try again for things like service unavailable and connection failure conditions.
            /*  503 - The Web server (running the Web site) is currently unable to handle the HTTP request due to a temporary overloading or maintenance of the server. The implication is that this is a temporary condition which will be alleviated after some delay. Some servers in this state may also simply refuse the socket connection, in which case a different error may be generated because the socket creation timed out. 
             */
            if (currentStatusCode != 503 && currentStatusCode != 0)
                try = 100;
            else
                [NSThread sleepForTimeInterval:2];
        }
            NSData *returnValue = [response copy];
            response = nil;
            lastResponse = returnValue;
            request = nil;
            return returnValue;
      
    }
    @catch (NSException *exception) {
         NSLog(@"exception raised in NetworkConnection createNetworkConnection %@",exception);
    }
    @finally {
        
    }
}

//Error message for unsuccessful results
-(NSString *) returnError:(id)caller withObject: (NSDictionary*)responseDict {
    @try {
//        NSDictionary *errorDict = [responseDict objectForKey:@"status"];
        NSString *str = [responseDict objectForKey:@"msg"];
        return str;
    }
    @catch (NSException *exception) {
        NSLog(@"exception raised in NetworkConnection createNetworkConnection %@",exception);
    }
    @finally {
        
    }
}

//Error message for error code from web.
-(NSString *) returnError:(id)caller withObject: (NSDictionary*)responseMap withUrl:(NSString *)urlString {
    @try {
        NSURL *appUrl = [NSURL URLWithString:urlString];
        
        NSString *message = @"";
        if (currentStatusCode == 408) {
            message = @"";
        } else if (currentStatusCode == 500) {
            message = @"";
        } else if (currentStatusCode == 503) {
            
            NSString *body = [[NSString alloc] initWithData:lastResponse encoding: NSUTF8StringEncoding];
            NSString *url = [NSString stringWithFormat:@"%@/exceptions.json?exception[error_class]=%@&exception[error_message]=%@",
                             appUrl,
                             @"iPhone_503",
                             [body stringByAddingPercentEscapesUsingEncoding:
                              NSASCIIStringEncoding]];
            
            [self createNetworkConnection:url WithBody:@"" WithHTTPMethod:@"POST" timeOutInterVal:60];
            message = @"";
            body = nil;
            
        } else if ([self isNotNull:responseMap]) {
            if ([self isNotNull:[responseMap objectForKey:@"errors"]]
                && [[responseMap objectForKey:@"errors"] respondsToSelector:@selector(allKeys)]) {
                responseMap = [responseMap objectForKey:@"errors"];
            }
            
            NSArray *keys = [responseMap allKeys];
            for (NSString *key in keys) {
                
                NSString *value = [responseMap objectForKey:key];
                if ([key isEqualToString:@"error"])
                    message = [message stringByAppendingFormat:@"%@\n ", value];
                else if ([key isEqualToString:@"errors"])
                    message = [message stringByAppendingFormat:@"%@\n ", value];
                else
                    message = [message stringByAppendingFormat:@"%@\n ", value];
                
            }
        }
        if ([message isEqualToString:@""]) {
            // If we ever reach this then we've got problems...
            message = @"Something went wrong with your connection,please try again in sometime";
        }
        return message;
    }
    @catch (NSException *exception) {
        NSLog(@"exception raised in NetworkConnection createNetworkConnection %@",exception);
    }
    @finally {
        
    }
}

@end
