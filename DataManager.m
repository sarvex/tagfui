/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "DataManager.h"
#import <CoreData/CoreData.h>
#import "CoreDataModelHeader.h"
#import "NSDate+Helper.h"

@implementation DataManager

@synthesize lastSyncTime,managedObjectContext,managedObjectModel,persistentStoreCoordinator;

static DataManager *DataManager_ = nil;

+(DataManager*)sharedDataManager
{
	TCSTART
	
	if([NSThread isMainThread])
	{
		static dispatch_once_t pred;
		dispatch_once(&pred, ^{
			if (DataManager_==nil) {
				DataManager_ = [[DataManager alloc]init];
				WooTagPlayerAppDelegate* appDelegate = ((WooTagPlayerAppDelegate* )[[UIApplication sharedApplication]delegate]);
				DataManager_.managedObjectContext = appDelegate.managedObjectContext;
				DataManager_.managedObjectModel = appDelegate.managedObjectModel;
				DataManager_.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
			}
		});
		return DataManager_;
	} else {
		[ShowAlert showWarning:@"Core data is accessed in non main thread"];
		return nil;
	}
	
	TCEND
}

+(id)alloc
{
	NSAssert(DataManager_ == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

-(void)saveChanges
{
	NSError *error;
	if (![managedObjectContext save:&error])
		NSLog(@"Error in saving database:%@",[error localizedDescription]);
}

///////////////////////////////////////////RESET EVERYTHING///////////////////////////////////////////////
///////////////////////////////////////////RESET EVERYTHING///////////////////////////////////////////////

-(void)resetEverything
{
	TCSTART
	
//	[self resetNSUserDefaults];
	
	[self resetDatabase];
	
//	[self resetCachedMediaFiles];
	
//	[self resetContentsFromDocumentsFolder];
	
	TCEND
}


-(void)resetDatabase {
	TCSTART
	
    NSPersistentStore *store = [self.persistentStoreCoordinator.persistentStores lastObject];
    NSError *error = nil;
    NSURL *storeURL = store.URL;
    [self.persistentStoreCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
	
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
	{
        [ShowAlert showError:[error localizedDescription]];
    }
	
	TCEND
}



///////////////////////////////////////////RESET EVERYTHING///////////////////////////////////////////////
///////////////////////////////////////////RESET EVERYTHING///////////////////////////////////////////////

-(BOOL)isValidId:(NSNumber*)id_
{
	return ([self isNotNull:id_]&&id_.intValue>0);
}

#pragma mark - FOR FETCHING ENTITIES WITH CLIENT AND SERVER ID



-(id)executeAndReturnOne:(NSFetchRequest *)fetchRequest {
	TCSTART
	
	if (fetchRequest == nil){NSLog(@"nil fetch request found");return nil;}
	
	NSError *error;
	
    NSArray* data_ =  [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	if(data_.count > 1)
		NSLog(@"solve this bug");
	if(data_.count > 0)
		return [data_ objectAtIndex:0];
	else
		return nil;
	
	TCEND
}

-(NSArray*)executeAndReturnAll:(NSFetchRequest *)fetchRequest
{
	TCSTART
	if (fetchRequest == nil){NSLog(@"nil fetch request found");return nil;}
	
	NSError *error;
	
    NSArray* data_ =  [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	if(data_.count > 0)
		return data_;
	else
		return [[NSArray alloc] init];
	
	TCEND
}

- (NSArray*)executeAndReturnAllForEntity:(NSString *)entityName
{
	TCSTART
	

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
	
    NSArray* objects =  [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	if ([self isNotNull:objects]) {
		return objects;
	} else {
		return [[NSArray alloc]init];
	}
	TCEND
}

- (void)deleteAllForEntity:(NSString *)entityName {
	TCSTART
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
	
    NSArray* objects =  [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	for (int i = 0 ; i < objects.count ; i++)
		[managedObjectContext deleteObject:[objects objectAtIndex:i]];
	
	
	[self saveChanges];
	
	TCEND
}

- (void)deleteAllWithFetchRequest:(NSFetchRequest *)fetchRequest {
	TCSTART
	
	NSError *error;
	
    NSArray* objects =  [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	for (int i = 0 ; i < objects.count ; i++)
		[managedObjectContext deleteObject:[objects objectAtIndex:i]];
	
	
	[self saveChanges];
	
	TCEND
}

- (void)removeAllKeysHavingNullValue:(NSMutableDictionary*)dictionary
{
	TCSTART
	
	NSSet *nullSet = [dictionary keysOfEntriesWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id key, id obj, BOOL *stop) {
		return [obj isEqual:[NSNull null]] ? YES : NO;
	}];
	
	TCSTART
	[dictionary removeObjectsForKeys:[nullSet allObjects]];
	TCEND
	
	TCEND
}

-(NSFetchRequest*)getFetchRequestForPredicate:(NSPredicate *)predicate forEntity:(NSString*)entity 
{
	TCSTART
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	if(predicate) {
		[fetchRequest setPredicate:predicate];
	}
	[fetchRequest setEntity:[NSEntityDescription
                             entityForName:entity inManagedObjectContext:managedObjectContext]];
	return fetchRequest;
    TCEND
}

#pragma mark - ADDING, RETRIEVING BUYERINFO'S
- (void)addBuyerInfo:(NSMutableDictionary *)params {
    TCSTART
    if(!params)return;
	
	[self removeAllKeysHavingNullValue:params];
	
	BuyerInfo *info = nil;
	
    if ([self isNotNull:[params objectForKey:@"buyerId"]]) {
        info = [self getBuyerInfoByUserId:[params objectForKey:@"buyerId"]];
    } else {
        info = [self getBuyerInfoByTagIdOrClientTagId:params];
    }
	
	if(info != nil)
		NSLog(@"updating old");
	else
		NSLog(@"adding new");
	
	if(info == nil) {
		info = [NSEntityDescription
				insertNewObjectForEntityForName:@"BuyerInfo"
				inManagedObjectContext:managedObjectContext];
    }
    
    if ([self isNotNull:[params objectForKey:@"videoId"]]) {
        info.videoId = [params objectForKey:@"videoId"];
    }
    
    if ([self isNotNull:[params objectForKey:@"tagId"]]) {
        info.tagId = [params objectForKey:@"tagId"];
    }
    
    if ([self isNotNull:[params objectForKey:@"clientTagId"]]) {
        info.clientTagId = [params objectForKey:@"clientTagId"];
    }
    
    if ([self isNotNull:[params objectForKey:@"requestTime"]]) {
        info.requestTime = [params objectForKey:@"requestTime"];
    }
    
    if ([self isNotNull:[params objectForKey:@"name"]]) {
        info.name = [params objectForKey:@"name"];
    }
    
    if ([self isNotNull:[params objectForKey:@"address"]]) {
        info.address = [params objectForKey:@"address"];
    }
    
    if ([self isNotNull:[params objectForKey:@"mobileNumber"]]) {
        info.mobileNumber = [params objectForKey:@"mobileNumber"];
    }
    
    if ([self isNotNull:[params objectForKey:@"message"]]) {
        info.message = [params objectForKey:@"message"];
    }
    if ([self isNotNull:[params objectForKey:@"sellerId"]]) {
        info.sellerId = [params objectForKey:@"sellerId"];
    }
    if ([self isNotNull:[params objectForKey:@"buyerId"]]) {
        info.buyerId = [params objectForKey:@"buyerId"];
    }
    if ([self isNotNull:[params objectForKey:@"emailId"]]) {
        info.emailId = [params objectForKey:@"emailId"];
    }
    [self saveChanges];
    TCEND
}

- (BuyerInfo *)getBuyerInfoByUserId:(NSString *)userId {
    TCSTART
    if ([self isNotNull:userId]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"buyerId == %@", userId];
        return [self executeAndReturnOne:[self getFetchRequestForPredicate:predicate forEntity:@"BuyerInfo"]];
    }
    TCEND
}
- (BuyerInfo *)getBuyerInfoByTagIdOrClientTagId:(NSDictionary *)data {
    TCSTART
    if ([self isNotNull:data]) {
        NSPredicate *predicate;
        if ([self isNotNull:[data objectForKey:@"tagId"]] && [[data objectForKey:@"tagId"] intValue] > 0) {
            predicate = [NSPredicate predicateWithFormat:@"tagId == %@", [data objectForKey:@"tagId"]];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"clientTagId == %@",[data objectForKey:@"clientTagId"]];
        }
        return [self executeAndReturnOne:[self getFetchRequestForPredicate:predicate forEntity:@"BuyerInfo"]];
    }
    TCEND
}

- (NSDictionary *)buyerInfoToDictionary:(BuyerInfo *)buyerInfo {
    TCSTART
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:buyerInfo.videoId?:@"",@"boughtvideoid",buyerInfo.name?:@"",@"buyername",buyerInfo.address?:@"",@"buyeraddress",buyerInfo.mobileNumber?:@"",@"buyermobilenumber",buyerInfo.message?:@"",@"buyermessage",buyerInfo.sellerId?:@"",@"sellersid",buyerInfo.buyerId?:@"",@"buyersid",buyerInfo.requestTime?:@"",@"requesttime",buyerInfo.tagId?:@"",@"tag_id",buyerInfo.emailId?:@"",@"buyeremail", nil];
    
    return dictionary;
    TCEND
}

#pragma mark - ADDING , RETRIEVING AND REMOVING TAG'S
- (void)addTag:(NSMutableDictionary*)tagDict {
	TCSTART
	
	if(!tagDict)return;
	
	[self removeAllKeysHavingNullValue:tagDict];
	
	Tag *info = nil;
	
	info = [self getTagByVideoIdAndTagId:tagDict];
	
	if(info != nil)
		NSLog(@"updating old");
	else
		NSLog(@"adding new");
	
	if(info == nil) {
		info = [NSEntityDescription
				insertNewObjectForEntityForName:@"Tag"
				inManagedObjectContext:managedObjectContext];
        
    }

    if ([self isNotNull:[tagDict objectForKey:@"videoplaybacktime"]] ) {
        info.videoPlaybackTime = [tagDict objectForKey:@"videoplaybacktime"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"tagX"]]) {
        info.tagX = [NSString stringWithFormat:@"%f",[[tagDict objectForKey:@"tagX"] floatValue]];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"tagY"]]) {
        info.tagY = [NSString stringWithFormat:@"%f",[[tagDict objectForKey:@"tagY"] floatValue]];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"tagid"]]) {
         info.tagId   = [tagDict objectForKey:@"tagid"];
    } else if ([self isNotNull:[tagDict objectForKey:@"id"]]) {
        info.tagId   = [tagDict objectForKey:@"id"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"clientTagId"]]) {
        info.clientTagId = [tagDict objectForKey:@"clientTagId"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"name"]]) {
        info.name = [tagDict objectForKey:@"name"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"link"]]) {
         info.link = [tagDict objectForKey:@"link"];
    } else {
        info.link = @"";
    }
    if ([self isNotNull:[tagDict objectForKey:@"fbtagid"]]) {
        info.fbId = [tagDict objectForKey:@"fbtagid"];
    } else {
        info.fbId = @"";
    }
    if ([self isNotNull:[tagDict objectForKey:@"twtagid"]]) {
        info.twId = [tagDict objectForKey:@"twtagid"];
    } else {
        info.twId = @"";
    }
    if ([self isNotNull:[tagDict objectForKey:@"wtId"]]) {
        info.wtId = [tagDict objectForKey:@"wtId"];
    } else {
        info.wtId = @"";
    }
    if ([self isNotNull:[tagDict objectForKey:@"gplustagid"]]) {
        info.gPlusId = [tagDict objectForKey:@"gplustagid"];
    } else {
        info.gPlusId = @"";
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"displaytime"]]) {
        info.displayTime = [tagDict objectForKey:@"displaytime"];
    }

    if ([self isNotNull:[tagDict objectForKey:@"tagColorName"]]) {
        info.tagColorName = [tagDict objectForKey:@"tagColorName"];
    }
    if ([self isNotNull:[tagDict objectForKey:@"videoId"]]) {
        info.videoId = [tagDict objectForKey:@"videoId"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"imagename"]]) {
        info.imageName = [tagDict objectForKey:@"imagename"];
    
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"screenWidth"]]) {
        info.screenWidth = [tagDict objectForKey:@"screenWidth"];
        
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"screenHeight"]]) {
        info.screenHeight = [tagDict objectForKey:@"screenHeight"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"screenX"]]) {
        info.screenX = [tagDict objectForKey:@"screenX"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"screenY"]]) {
        info.screenY = [tagDict objectForKey:@"screenY"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"videoX"]]) {
        info.videoX = [tagDict objectForKey:@"videoX"];
    }
    if ([self isNotNull:[tagDict objectForKey:@"videoY"]]) {
        info.videoY = [tagDict objectForKey:@"videoY"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"videoWidth"]]) {
        info.videoWidth = [tagDict objectForKey:@"videoWidth"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"videoHeight"]]) {
        info.videoHeight = [tagDict objectForKey:@"videoHeight"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"isWaitingForUpload"]]) {
        info.isWaitingForUpload = [tagDict objectForKey:@"isWaitingForUpload"] ;
    } else {
        info.isWaitingForUpload = [NSNumber numberWithBool:NO];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"isAdded"]]) {
        info.isAdded = [tagDict objectForKey:@"isAdded"];
    } else {
        info.isAdded = [NSNumber numberWithBool:NO];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"isModified"]]) {
        info.isModified = [tagDict objectForKey:@"isModified"];
    } else {
        info.isModified = [NSNumber numberWithBool:NO];
    }
    if ([self isNotNull:[tagDict objectForKey:@"isdeleted"]]) {
        info.isdeleted = [tagDict objectForKey:@"isdeleted"];
    } else {
        info.isdeleted = [NSNumber numberWithBool:NO];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"clientVideoId"]]) {
        info.clientVideoId = [tagDict objectForKey:@"clientVideoId"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"uid"]]) {
        info.uid = [tagDict objectForKey:@"uid"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"productName"]]) {
        info.productName = [tagDict objectForKey:@"productName"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"productLink"]]) {
        info.productLink = [tagDict objectForKey:@"productLink"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"productCategory"]]) {
        info.productCategory = [tagDict objectForKey:@"productCategory"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"productDescription"]]) {
        info.productDescription = [tagDict objectForKey:@"productDescription"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"productPrice"]]) {
        info.productPrice = [tagDict objectForKey:@"productPrice"];
    }
    
    if ([self isNotNull:[tagDict objectForKey:@"productCurrencyType"]]) {
        info.productCurrencyType = [tagDict objectForKey:@"productCurrencyType"];
    }

    
	[self saveChanges];
	
	TCEND
}

- (NSArray*)getAddedTagsArrayAndWaitingForPostWithUserId:(NSString *)userId {
    TCSTART
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(videoId.integerValue > 0) AND (%@ == %d) AND (%@ == %d) AND (uid == %@)",@"isAdded",TRUE,@"isWaitingForUpload",TRUE,userId]];

	return [self executeAndReturnAll:[self getFetchRequestForPredicate:predicate forEntity:@"Tag"]];
    TCEND
}

- (NSArray *)getUpdatedTagsArrayAndWaitingForPost {
    TCSTART
     NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(videoId.integerValue > 0) AND (%@ == %d) AND (%@ == %d)",@"isModified",TRUE,@"isWaitingForUpload",TRUE]];
    return [self executeAndReturnAll:[self getFetchRequestForPredicate:predicate forEntity:@"Tag"]];
   
    TCEND
}
- (Tag *)getTagByVideoIdAndTagId:(NSMutableDictionary*)data {
	TCSTART
    NSPredicate *predicate;
    // when videoId is then only we can have tagId.
    if ([self isNotNull:[data objectForKey:@"tagid"]] && [[data objectForKey:@"tagid"] intValue] > 0) {
        predicate = [NSPredicate predicateWithFormat:@" (videoId == %@) AND (tagId == %@)", [data objectForKey:@"videoId"],[data objectForKey:@"tagid"]];
    } else {
        if ([self isNotNull:[data objectForKey:@"videoId"]] && [[data objectForKey:@"videoId"] intValue] > 0) {
            predicate = [NSPredicate predicateWithFormat:@" (videoId == %@) AND (clientTagId == %@)",[data objectForKey:@"videoId"],[data objectForKey:@"clientTagId"]];
        } else {
            predicate = [NSPredicate predicateWithFormat:@" (clientVideoId == %@) AND (clientTagId == %@)",[data objectForKey:@"clientVideoId"],[data objectForKey:@"clientTagId"]];
        }
    }
    
	NSLog(@"client Data: %@",data);
	return [self executeAndReturnOne:[self getFetchRequestForPredicate:predicate forEntity:@"Tag"]];
	
	TCEND
}

- (NSArray *)getAllTagsByVideoIdAndClientVideoId:(NSDictionary *)data {
    TCSTART
    NSLog(@"client Data: %@",data);
    NSPredicate *predicate;
    if ([self isNotNull:[data objectForKey:@"clientVideoId"]] && [[data objectForKey:@"clientVideoId"] intValue] > 0)  {
        predicate = [NSPredicate predicateWithFormat:@"clientVideoId == %@", [data objectForKey:@"clientVideoId"]];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"videoId == %@", [data objectForKey:@"videoId"]];
    }
	return [self executeAndReturnAll:[self getFetchRequestForPredicate:predicate forEntity:@"Tag"]];
	
	TCEND
}
-(Tag *)getTagByTagId:(NSNumber *)tagId {
    TCSTART
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(tagId == %@)", tagId];
	NSLog(@"TagId: %@",tagId);
	return [self executeAndReturnOne:[self getFetchRequestForPredicate:predicate forEntity:@"Tag"]];
	
	TCEND
}
- (NSArray *)getAllTags {
    TCSTART
    return [self executeAndReturnAllForEntity:@"Tag"];
    TCEND
}
- (Tag *)getTagByTagIdORClientTagId:(NSDictionary *)data {
    TCSTART
    if ([self isNotNull:data]) {
        NSPredicate *predicate;
        if ([self isNotNull:[data objectForKey:@"tagid"]] && [[data objectForKey:@"tagid"] intValue] > 0) {
            predicate = [NSPredicate predicateWithFormat:@"tagId == %@", [data objectForKey:@"tagid"]];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"clientTagId == %@",[data objectForKey:@"clientTagId"]];
        }
        return [self executeAndReturnOne:[self getFetchRequestForPredicate:predicate forEntity:@"Tag"]];
    }
    TCEND
}

- (void)deleteAllTagsWhereClientVideoId:(NSNumber *)clientVideoId {
    TCSTART
    NSArray *array = [self getAllTagsByVideoIdAndClientVideoId:[NSDictionary dictionaryWithObjectsAndKeys:clientVideoId,@"clientVideoId", nil]];
    if ([self isNotNull:array] && array.count > 0) {
        for (Tag *tag in array) {
            [managedObjectContext deleteObject:tag];
        }
        [self saveChanges];
    }
    TCEND
}
//- (void)deleteTag:(NSMutableDictionary*)tagDict {
//    TCSTART
//	
//	if(!tagDict)return;
//	
//	[self removeAllKeysHavingNullValue:tagDict];
//	
//	Tag *info = nil;
//	
//    
//	info = [self getTagByVideoIdAndTagId:tagDict];
//	
//	if(info != nil) {
//		NSLog(@"old found and deleting");
//    }
//	else
//	{
//		NSLog(@"nothing found ..skipping deletion..but this message is not expected");
//		return;
//	}
//	
//	if(info)
//		[managedObjectContext deleteObject:info];
//	
//	[self saveChanges];
//	
//	TCEND
//}
- (void)deleteTag:(Tag *)tag {
    TCSTART
		
		
	if(tag) {
		[managedObjectContext deleteObject:tag];
        NSLog(@"Tag deleted");
	}
	[self saveChanges];
	
	TCEND
}

#pragma mark - ADDING, RETRIEVING USERS
- (void)addUser:(NSMutableDictionary *)userFields {
    
    TCSTART
	
	if(!userFields)return;
	
	[self removeAllKeysHavingNullValue:userFields];
	
	User *user = nil;
	
	user = [self getUserByUserId:userFields];
	
	if(user != nil)
		NSLog(@"updating old");
	else
		NSLog(@"adding new");
	
	if(user == nil)
		user = [NSEntityDescription
                 insertNewObjectForEntityForName:@"User"
                 inManagedObjectContext:managedObjectContext];
    
    
    if ([self isNotNull:[userFields objectForKey:@"name"]]) {
        user.userName = [userFields objectForKey:@"name"];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"userId"]]) {
        user.userId = [userFields objectForKey:@"userId"];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"photo_path"]]) {
        user.photoPath = [userFields objectForKey:@"photo_path"];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"banner_path"]]) {
        user.bannerPath = [userFields objectForKey:@"banner_path"];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"last_update"]]) {
        user.lastUpdate = [NSString stringWithFormat:@"%d",[[userFields objectForKey:@"last_update"] intValue]];
    }

    if ([self isNotNull:[userFields objectForKey:@"total_no_of_likes"]]) {
        user.totalNoOfLikes = [NSNumber numberWithInt:[[userFields objectForKey:@"total_no_of_likes"] intValue]];
    } else {
        user.totalNoOfLikes = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"total_no_of_tags"]]) {
        user.totalNoOfTags = [NSNumber numberWithInt:[[userFields objectForKey:@"total_no_of_tags"] intValue]];
    } else {
        user.totalNoOfTags = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"total_no_of_videos"]]) {
        user.totalNoOfVideos = [NSNumber numberWithInt:[[userFields objectForKey:@"total_no_of_videos"] intValue]];
    } else {
        user.totalNoOfVideos = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"total_no_of_following"]]) {
        user.totalNoOfFollowings = [NSNumber numberWithInt:[[userFields objectForKey:@"total_no_of_following"] intValue]];
    } else {
        user.totalNoOfFollowings = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"total_no_of_followers"]]) {
        user.totalNoOfFollowers = [NSNumber numberWithInt:[[userFields objectForKey:@"total_no_of_followers"] intValue]];
    } else {
        user.totalNoOfFollowers = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"followings"]]) {
        user.followings = [userFields objectForKey:@"followings"];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"followers"]]) {
        user.followers = [userFields objectForKey:@"followers"];
    }
    
    NSArray *array = [self getAllVideosOfUserWithUserId:[userFields objectForKey:@"userId"]];
    if ([self isNotNull:array] && array.count > 0) {
        user.videos = array;
    }
    
    [self saveChanges];
    TCEND
}


- (User *)getUserByUserId:(NSMutableDictionary *)data {
    TCSTART
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", [data objectForKey:@"userId"]];
    
	NSLog(@"client Data: %@",data);
	return [self executeAndReturnOne:[self getFetchRequestForPredicate:predicate forEntity:@"User"]];
    TCEND
}
- (void)deleteUser:(User *)user {
    if(user) {
		[managedObjectContext deleteObject:user];
        NSLog(@"User deleted");
	}
	[self saveChanges];
}

#pragma mark - ADDING , RETRIEVING AND REMOVING VIDEOS
- (void)addVideo:(NSMutableDictionary *)videoFields {
    
    TCSTART
	
	if(!videoFields)return;
	
	[self removeAllKeysHavingNullValue:videoFields];
	
	Video *video = nil;
	
	video = [self getVideoByVideoIdOrVideoClientId:videoFields];
	
	if(video != nil)
		NSLog(@"updating old");
	else
		NSLog(@"adding new");
	
	if(video == nil)
		video = [NSEntityDescription
				insertNewObjectForEntityForName:@"Video"
				inManagedObjectContext:managedObjectContext];
    
    if([self isNotNull:[videoFields objectForKey:@"videoId"]] && [[videoFields objectForKey:@"videoId"] length] > 0) {
        video.videoId = [videoFields objectForKey:@"videoId"];
    } else if([self isNotNull:[videoFields objectForKey:@"video_id"]] && [[videoFields objectForKey:@"video_id"] length] > 0) {
        video.videoId = [videoFields objectForKey:@"video_id"];
    }  else {
        video.clientId = [videoFields objectForKey:@"clientId"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"path"]]) {
        video.path = [videoFields objectForKey:@"path"];
    } else if ([self isNotNull:[videoFields objectForKey:@"video_url"]]) {
        video.path = [videoFields objectForKey:@"video_url"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"creationTime"]]) {
        video.creationTime = [videoFields objectForKey:@"creationTime"];
    } else if ([self isNotNull:[videoFields objectForKey:@"upload_date"]]) {
        video.creationTime = [videoFields objectForKey:@"upload_date"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"isUploading"]]) {
        video.isUploading = [videoFields objectForKey:@"isUploading"];
    }
    
    video.fileUploadCompleted = [NSNumber numberWithBool:NO];
    video.checkSumFailed = [NSNumber numberWithBool:NO];
    video.videoPublishingFailed = [NSNumber numberWithBool:NO];
    
    if ([self isNotNull:[videoFields objectForKey:@"isUploaded"]]) {
        video.isUploaded = [videoFields objectForKey:@"isUploaded"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"waitingToUpload"]]) {
        video.waitingToUpload = [videoFields objectForKey:@"waitingToUpload"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"title"]]) {
        video.title = [videoFields objectForKey:@"title"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"info"]]) {
        video.info = [videoFields objectForKey:@"info"];
    } else if ([self isNotNull:[videoFields objectForKey:@"description"]]) {
        video.info = [videoFields objectForKey:@"description"];
    } else {
        video.info = @"";
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"no_of_likes"]]) {
        video.numberOfLikes = [NSNumber numberWithInt:[[videoFields objectForKey:@"no_of_likes"] intValue]];
    } else {
        video.numberOfLikes = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"video_thumb_path"]]) {
        video.videoThumbPath = [videoFields objectForKey:@"video_thumb_path"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"no_of_views"]]) {
        video.numberOfViews = [NSNumber numberWithInt:[[videoFields objectForKey:@"no_of_views"] intValue]];
    } else {
        video.numberOfViews = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"no_of_comments"]]) {
        video.numberOfCmnts = [NSNumber numberWithInt:[[videoFields objectForKey:@"no_of_comments"] intValue]];
    } else {
        video.numberOfCmnts = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"no_of_tags"]]) {
        video.numberOfTags = [NSNumber numberWithInt:[[videoFields objectForKey:@"no_of_tags"] intValue]];
    } else {
        video.numberOfTags = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"comments"]]) {
        video.comments = [videoFields objectForKey:@"comments"];
    } else if ([self isNotNull:[videoFields objectForKey:@"coments"]]) {
        video.comments = [videoFields objectForKey:@"coments"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"public"]]) {
//        video.public = [NSNumber numberWithBool:[[videoFields objectForKey:@"public"] boolValue]];
        video.public = [NSNumber numberWithInt:[[videoFields objectForKey:@"public"] intValue]];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"tags"]]) {
        video.tags = [videoFields objectForKey:@"tags"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"uploadedTime"]]) {
        video.uploadedTime = [videoFields objectForKey:@"uploadedTime"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"uid"]]) {
        video.userId = [videoFields objectForKey:@"uid"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"user_name"]]) {
        video.userName = [videoFields objectForKey:@"user_name"];
    } else {
        video.userName = @"";
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"user_photo"]]) {
        video.userPhoto = [videoFields objectForKey:@"user_photo"];
    } else {
        video.userPhoto = @"";
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"browseType"]]) {
        video.browseType = [videoFields objectForKey:@"browseType"];
    }
    
//    [videoFields setObject:[self likes] forKey:@"likes"];
    if ([self isNotNull:[videoFields objectForKey:@"likes"]]) {
        video.likesList = [videoFields objectForKey:@"likes"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"shareToFB"]]) {
        video.shareToFB = [videoFields objectForKey:@"shareToFB"];
    }
    if ([self isNotNull:[videoFields objectForKey:@"shareToGPlus"]]) {
        video.shareToGPlus = [videoFields objectForKey:@"shareToGPlus"];
    }
    if ([self isNotNull:[videoFields objectForKey:@"shareToTw"]]) {
        video.shareToTw = [videoFields objectForKey:@"shareToTw"];
    }
    if ([self isNotNull:[videoFields objectForKey:@"filterNumber"]]) {
        video.filterNumber = [videoFields objectForKey:@"filterNumber"];
    }
    if ([self isNotNull:[videoFields objectForKey:@"isLibraryVideo"]]) {
        video.isLibraryVideo = [videoFields objectForKey:@"isLibraryVideo"];
    }
    video.hitCount = [NSNumber numberWithInt:1];
    
    video.loadingViewHidden = [NSNumber numberWithBool:NO];
    
    if ([self isNotNull:[videoFields objectForKey:@"frame_time"]]) {
        video.coverFrameValue = [[videoFields objectForKey:@"frame_time"] floatValue];
    } else {
        video.coverFrameValue = 0.0;
    }
    [self saveChanges];
    TCEND
}

- (NSArray *)likes {
    return [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"10045",@"user_id",@"mamatha",@"user_name", nil], nil];
}

- (Video *)getVideoByVideoIdOrVideoClientId:(NSMutableDictionary *)data {
    TCSTART
    NSPredicate *predicate;
    if ([self isNotNull:[data objectForKey:@"clientId"]] && [[data objectForKey:@"clientId"] intValue] > 0) {
        predicate = [NSPredicate predicateWithFormat:@"clientId == %@", [data objectForKey:@"clientId"]];
    } else if ([self isNotNull:[data objectForKey:@"videoId"]] && [[data objectForKey:@"videoId"] intValue] > 0){
        predicate = [NSPredicate predicateWithFormat:@"videoId == %@", [data objectForKey:@"videoId"]];
    } else if ([self isNotNull:[data objectForKey:@"video_id"]] && [[data objectForKey:@"video_id"] intValue] > 0) {
        predicate = [NSPredicate predicateWithFormat:@"videoId == %@", [data objectForKey:@"video_id"]];
    } else {
        return Nil;
    }

	return [self executeAndReturnOne:[self getFetchRequestForPredicate:predicate forEntity:@"Video"]];
    TCEND
}

- (NSArray *)getAllVideosOfUserWithUserId:(NSString *)userId {
    TCSTART
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@",userId];

	NSLog(@"userId: %@",userId);
	return [self executeAndReturnAll:[self getFetchRequestForPredicate:predicate forEntity:@"Video"]];
    TCEND
}
- (NSArray *)getAllUploadedVideosOfUserId:(NSString *)userId {
    TCSTART
    NSString * predicateString = [NSString stringWithFormat:@"(%@ == %d && userId == %@)",@"isUploaded",TRUE,userId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
	
	return [self executeAndReturnAll:[self getFetchRequestForPredicate:predicate forEntity:@"Video"]];
    
    TCEND
}
- (NSArray *)getAllUploadingVideos {
    TCSTART
    NSString * predicateString = [NSString stringWithFormat:@"(%@ == %d)",@"isUploading",TRUE];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
	
	return [self executeAndReturnAll:[self getFetchRequestForPredicate:predicate forEntity:@"Video"]];

    TCEND
}
- (NSArray *)getAllVideos {
    TCSTART
    return [self executeAndReturnAllForEntity:@"Video"];
    TCEND
}
- (void)deleteVideo:(Video *)video {
    if(video) {
		[managedObjectContext deleteObject:video];
        NSLog(@"Video deleted");
	}
	[self saveChanges];
}

- (NSMutableDictionary *)tagToDictionary:(Tag *)tag {
    TCSTART
   
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tag.videoId,@"video_id",tag.name,@"tag_name",tag.tagColorName,@"tag_color",[NSNumber numberWithFloat:[tag.tagX floatValue]],@"coordinate_x",[NSNumber numberWithFloat:[tag.tagY floatValue]],@"coordinate_y",tag.link?:@"",@"tag_link",tag.displayTime,@"tag_duration",tag.fbId?:@"",@"tag_fblink",tag.twId?:@"",@"tag_twlink",tag.gPlusId?:@"",@"tag_gplink",tag.wtId?:@"",@"tag_wtlink",tag.videoPlaybackTime,@"video_current_time",tag.videoX,@"video_res_x",tag.videoY,@"video_res_y",tag.videoWidth,@"video_width",tag.videoHeight,@"video_height",tag.screenX,@"screen_res_x",tag.screenY,@"screen_res_y",tag.screenHeight,@"screen_height",tag.screenWidth,@"screen_width",tag.productName?:@"",@"productName",tag.productLink?:@"",@"productLink",tag.productDescription?:@"",@"productDescription",tag.productCategory?:@"",@"productCategory",tag.productCurrencyType?:@"",@"currency",tag.productPrice?:@"",@"productPrice", nil];
    if ([tag.isAdded boolValue]) {
        [dictionary setObject:tag.clientTagId forKey:@"clienttagid"];
    } else if ([tag.isModified boolValue]) {
        [dictionary setObject:tag.tagId forKey:@"id"];
        [dictionary setObject:tag.uid?:@"" forKey:@"uid"];
    }
    
//    WooTagPlayerAppDelegate* appDelegate = ((WooTagPlayerAppDelegate* )[[UIApplication sharedApplication]delegate]);
//    [appDelegate writeLog:[NSString stringWithFormat:@"Tag Info : ClientTagId:%@\t TagName:%@ TagIdIfTagModified:%@ \t VideoId:%@ \n",tag.clientTagId,tag.name,tag.tagId?:@"",tag.videoId]];
    [self removeAllKeysHavingNullValue:dictionary];
    return dictionary;
    TCEND
}

#pragma mark Notifications
- (void)addNotification:(NSMutableDictionary *)notificationDict {
    TCSTART
    if(!notificationDict)return;
	WooTagPlayerAppDelegate* appDelegate = ((WooTagPlayerAppDelegate* )[[UIApplication sharedApplication]delegate]);
	[self removeAllKeysHavingNullValue:notificationDict];
	
	NotificationModal *notificationModal = nil;
	
	notificationModal = [self getNotificationByNotificationId:notificationDict];
	
	if(notificationModal != nil)
		NSLog(@"updating old");
	else
		NSLog(@"adding new");
    if(notificationModal == nil) {
		notificationModal = [NSEntityDescription
				insertNewObjectForEntityForName:@"NotificationModal"
				inManagedObjectContext:managedObjectContext];
        
    }
    notificationModal.loggedInUserId = appDelegate.loggedInUser.userId;
    if ([self isNotNull:[notificationDict objectForKey:@"sender_id"]]) {
        notificationModal.otherUserId = [notificationDict objectForKey:@"sender_id"];
    }
    
    if ([self isNotNull:[notificationDict objectForKey:@"sender_name"]]) {
        notificationModal.otherUserName = [notificationDict objectForKey:@"sender_name"];
    }
    
    if ([self isNotNull:[notificationDict objectForKey:@"sender_photo"]]) {
        notificationModal.otherUserProfileImgUrl = [notificationDict objectForKey:@"sender_photo"];
    }
    
    if ([self isNotNull:[notificationDict objectForKey:@"notice_id"]]) {
        notificationModal.notificationId = [notificationDict objectForKey:@"notice_id"];
    }
    
    
    if ([self isNotNull:[notificationDict objectForKey:@"video_id"]]) {
        notificationModal.videoId = [notificationDict objectForKey:@"video_id"];
    }
    
    if ([self isNotNull:[notificationDict objectForKey:@"video_thumb_path"]]) {
        notificationModal.videoImgUrl = [notificationDict objectForKey:@"video_thumb_path"];
    }
    
    if ([self isNotNull:[notificationDict objectForKey:@"message"]]) {
        if (notificationModal.otherUserId.intValue == appDelegate.loggedInUser.userId.intValue) {
            notificationModal.messageText = [NSString stringWithFormat:@"You %@", [notificationDict objectForKey:@"message"]];
        } else {
            notificationModal.messageText = [NSString stringWithFormat:@"%@ %@",notificationModal.otherUserName?:@"", [notificationDict objectForKey:@"message"]];
        }
    }
    
    // Description, time format
    if ([self isNotNull:[notificationDict objectForKey:@"comment_text"]]) {
        notificationModal.descriptionText = [Base64Converter decodedString:[notificationDict objectForKey:@"comment_text"]];
    }
    
    if ([self isNotNull:[notificationDict objectForKey:@"created_date"]]) {
        notificationModal.createdTime = [notificationDict objectForKey:@"created_date"];
    }
    
//    if ([self isNotNull:notificationModal.descriptionText] && notificationModal.descriptionText.length > 0) {
//        notificationModal.descriptionText = [NSString stringWithFormat:@"%@, ",notificationModal.descriptionText];
//    }

    if ([self isNotNull:[notificationDict objectForKey:@"type"]]) {
        switch ([[notificationDict objectForKey:@"type"] intValue]) {
            case 1:
                notificationModal.notificationType = [NSNumber numberWithInt:Follow];
                break;
            case 2:
                notificationModal.notificationType = [NSNumber numberWithInt:Comment];
                break;
            case 3:
                notificationModal.notificationType = [NSNumber numberWithInt:UserTag];
                break;
            case 4:
                notificationModal.notificationType = [NSNumber numberWithInt:PrivateGroup];
                break;
            case 5:
                notificationModal.notificationType = [NSNumber numberWithInt:Like];
                break;
            case 6:
                notificationModal.notificationType = [NSNumber numberWithInt:AcceptPrivateGroup];
                break;
            default:
                break;
        }
    }
    
    [self saveChanges];
    TCEND
}
- (NotificationModal *)getNotificationByNotificationId:(NSMutableDictionary *)notificationFields {
    TCSTART
    NSPredicate *predicate;
    if ([self isNotNull:[notificationFields objectForKey:@"notice_id"]]) {
        predicate = [NSPredicate predicateWithFormat:@"notificationId == %@", [notificationFields objectForKey:@"notice_id"]];
    } else {
        return nil;
    }
    
	return [self executeAndReturnOne:[self getFetchRequestForPredicate:predicate forEntity:@"NotificationModal"]];
    TCEND
}
- (void)deleteNotificationModal:(NotificationModal *)notification {
    TCSTART
    [managedObjectContext deleteObject:notification];
    [self saveChanges];
    TCEND
}

- (NSArray *)getAllNotificationsByUserId:(NSString *)userId {
    TCSTART
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"loggedInUserId == %@", userId];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	if(predicate) {
		[fetchRequest setPredicate:predicate];
	}
	[fetchRequest setEntity:[NSEntityDescription
                             entityForName:@"NotificationModal" inManagedObjectContext:managedObjectContext]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdTime" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    return [self executeAndReturnAll:fetchRequest];
    
    TCEND
}

- (void)removeAllNotificationsWhichAreCreated7DaysAgo {
    TCSTART
    WooTagPlayerAppDelegate *appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray *array = [self getAllNotificationsByUserId:appDelegate.loggedInUser.userId];
    for (NotificationModal *notification in array) {
        if ([self isNotNull:notification.createdTime] && ![appDelegate isNotificationCreatedTimeIsLessThanOrEqual7Days:notification.createdTime]) {
            [managedObjectContext deleteObject:notification];
        }
    }
    [self saveChanges];
    
    TCEND
}
- (void)removeAllNotificationsOfUserId:(NSString *)userId {
    TCSTART
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"loggedInUserId == %@", userId];
    [self deleteAllWithFetchRequest:[self getFetchRequestForPredicate:predicate forEntity:@"NotificationModal"]];
    TCEND
}


- (FirstTimeUserExperience *)createFirstTimeUserExprience {
    TCSTART
	FirstTimeUserExperience *ftue;
    
	ftue = [self executeAndReturnOne:[self getFetchRequestForPredicate:nil forEntity:@"FirstTimeUserExperience"]];
    
	if(ftue != nil) {
        NSLog(@"old one");
		return ftue;
    } else {
		NSLog(@"adding new");
	}
	if(ftue == nil)
		ftue = [NSEntityDescription
                 insertNewObjectForEntityForName:@"FirstTimeUserExperience"
                 inManagedObjectContext:managedObjectContext];
    
    [self saveChanges];
    return ftue;
    TCEND
}


@end
