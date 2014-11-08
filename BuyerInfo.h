/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BuyerInfo : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * mobileNumber;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * videoId;
@property (nonatomic, retain) NSString * sellerId;
@property (nonatomic, retain) NSString * buyerId;
@property (nonatomic, retain) NSString * requestTime;
@property (nonatomic, retain) NSString * tagId;
@property (nonatomic, retain) NSString * clientTagId;
@property (nonatomic, retain) NSString * emailId;
@end
