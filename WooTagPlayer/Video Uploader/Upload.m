/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
#import "Upload.h"
#import "NSData+MD5.h"


@implementation Upload

@synthesize url,fileName,fileType,filePath,serverResponseData,userInfo,completedPartsCount,totalParts,currentPart,fileSize,fileId,MAXIMUM_PART_SIZE,mediaId,error;
@synthesize percentageComplete;
@synthesize cell,indexPath;

#pragma mark -

- (id)initWithUrl:(NSURL*)url_  WithFileName:(NSString*)fileName_ WithfileType:(NSString*)fileType_ WithfilePath:(NSString*)filePath_ withMediaId:(NSString *)mediaId_ WithUserInfo:(id)userInfo_ withUploadPartNumber:(int)partNumber
{
	if(![[NSFileManager defaultManager]fileExistsAtPath:filePath_])
	{
		//NSLog(@"\n\n\nfile not found.......\n\n");
		return nil;
	}
	
	if ((self = [super init]) != nil)
	{
		if (url_)
		{
			url = [url_ copy];
		}
		if (fileName_)
		{
			fileName = [fileName_ copy];
		}
		if (fileType_)
		{
			fileType = [fileType_ copy];
		}
		if (filePath_)
		{
			filePath = [filePath_ copy];
		}
		if (userInfo_)
		{
			userInfo = userInfo_;
		}
		mediaId = mediaId_;
        //indexPath = indexPath_;
        //cell = cell_;
        
		MAXIMUM_PART_SIZE = 0;
		
		//if ([ap isConnectedViaWifi])
		//{
//			MAXIMUM_PART_SIZE = 1024*2048;
			//MAXIMUM_PART_SIZE = 1024*64;
		//}
		//else
		//{
			MAXIMUM_PART_SIZE = 1024*1024;
		//}
		
		fileSize = 0;
		
		fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath_ error:nil][NSFileSize] longLongValue];
				
		if (fileSize<=MAXIMUM_PART_SIZE)
		{
			totalParts = 1;
		}
		else
		{
			totalParts = fileSize/MAXIMUM_PART_SIZE;
			if ((fileSize-(totalParts*MAXIMUM_PART_SIZE))>0)
				totalParts++;
		}
		
		//NSLog(@"\n totalParts %d\n",totalParts);
		//NSLog(@"\n fileSize %lld\n",fileSize);
		
		fileId  = nil;
        currentPart = partNumber;
		completedPartsCount = currentPart - 1;
		
		MD5StringForCompleteFile = [[NSData dataWithContentsOfFile:filePath_] MD5];
		
		//NSLog(@"clientMD5StringForCurrentPart %@",clientMD5StringForCurrentPart);
		NSLog(@"MD5String %@ ForComplete file %@",MD5StringForCompleteFile,filePath_);

		[self getFileDataToSend];
	}
	return self;
}

- (id)initWithMediaId:(NSString *)mediaId_ WithUserInfo:(id)userInfo_
{
	
	
	if ((self = [super init]) != nil)
	{

		if (userInfo_)
		{
			userInfo = userInfo_;
		}
		mediaId = mediaId_;
        
	}
	return self;
}

-(NSData *)getFileDataToSend
{
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
	
	if(currentPart > 1) {
		[fileHandle seekToFileOffset:MAXIMUM_PART_SIZE*(currentPart-1)];
	}
	
	NSData * data = [fileHandle readDataOfLength:MAXIMUM_PART_SIZE];
	
	return data;
}

-(NSString*)getCheckSumForCurrentPart
{
	return clientMD5StringForCurrentPart = [[NSString alloc]initWithString:[[self getFileDataToSend] MD5]];
}

-(NSString*)getCheckSumForCompleteFile
{
	return MD5StringForCompleteFile;
}

-(BOOL)isCompleted
{
	//NSLog(@"\ncompletedPartsCount %d",completedPartsCount);
	//NSLog(@"\ntotalParts %d",totalParts);
	if (completedPartsCount == totalParts) {
		return YES;
	}
	
	return NO;
}

- (void) dealloc
{
//	[url release];
//	[fileName release];
//	[fileType release];
//	[filePath release];
//	[userInfo release];
//	[super dealloc];
}
@end
