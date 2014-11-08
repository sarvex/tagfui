/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
#import <Foundation/Foundation.h>

@interface Upload : NSObject {
	NSURL     *url;
	NSString  *fileName;
	NSString  *fileType;
	NSString  *filePath;
	NSData    *serverResponseData;
	id userInfo;
	int        totalParts;
	int        currentPart;
	int        completedPartsCount;
	NSString * fileId;
	long long  fileSize;
	long long  MAXIMUM_PART_SIZE;
	
	NSString *clientMD5StringForCurrentPart;
	NSString *MD5StringForCompleteFile;
    NSError *error;
    NSString *mediaId;

}

@property (nonatomic, retain) NSError *error;
@property (nonatomic,retain)NSString * mediaId;
@property (nonatomic,strong)UITableViewCell *cell;
@property (nonatomic,strong)NSIndexPath *indexPath;

@property (nonatomic,readwrite)float   percentageComplete;
@property (nonatomic,retain)id userInfo;
@property (nonatomic,retain)NSData   * serverResponseData;
@property (nonatomic,retain)NSURL    * url;
@property (nonatomic,retain)NSString * fileName;
@property (nonatomic,retain)NSString * fileType;
@property (nonatomic,retain)NSString * filePath;
@property (nonatomic,readwrite)int     totalParts;
@property (nonatomic,readwrite)int     currentPart;
@property (nonatomic,readwrite)int     completedPartsCount;
@property (nonatomic,readwrite)long long  fileSize;
@property (nonatomic,readwrite)long long  MAXIMUM_PART_SIZE;
@property (nonatomic,retain)NSString * fileId;

- (id)initWithUrl:(NSURL*)url_  WithFileName:(NSString*)fileName_ WithfileType:(NSString*)fileType_ WithfilePath:(NSString*)filePath_ withMediaId:(NSString *)mediaId_ WithUserInfo:(id)userInfo_ withUploadPartNumber:(int)partNumber;
- (id)initWithMediaId:(NSString *)mediaId_ WithUserInfo:(id)userInfo_;
-(NSData*)getFileDataToSend;
-(BOOL)isCompleted;
-(NSString*)getCheckSumForCurrentPart;
-(NSString*)getCheckSumForCompleteFile;

@end
