/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
#import "UploadManager.h"
#import "UploadOperation.h"

#define CONCURRENT_UPLOADS_COUNT 1

static UploadManager* sSharedUploadManager = nil;

@implementation UploadManager

@synthesize uploads = uploads_;

+ (id) sharedUploadManager
{
	@synchronized (self) {
		if (sSharedUploadManager == nil) {
			sSharedUploadManager = [UploadManager new];
		}
	}
	
	return sSharedUploadManager;
}

#pragma mark -

- (id) init
{
	if ((self = [super init]) != nil) {
		uploads_ = [NSMutableArray new];
		delegates_ = [NSMutableArray new];
		operationQueue_ = [NSOperationQueue new];
		[operationQueue_ setMaxConcurrentOperationCount: CONCURRENT_UPLOADS_COUNT];
	}
	return self;
}

- (void) dealloc
{
//	[operationQueue_ release];
//	[uploads_ release];
//	[delegates_ release];
//	[super dealloc];
}

#pragma mark -

- (void)addDelegate: (id<UploadManagerDelegate>) delegate
{
	NSValue* delegateValue = [NSValue valueWithPointer: (__bridge const void *)(delegate)];
	[delegates_ addObject: delegateValue];
}

- (void)removeDelegate: (id<UploadManagerDelegate>) delegate
{
	NSValue* delegateValue = [NSValue valueWithPointer: (__bridge const void *)(delegate)];
	[delegates_ removeObject: delegateValue];
}

- (BOOL) isUploadingMediaWithMediaId:(int)mediaId
{
	if (uploads_.count>0)
	{
		Upload * object_  = [uploads_ objectAtIndex:0];
		if(object_.mediaId.intValue == mediaId) {
			return YES;
        }
	}
	return NO;
}

#pragma mark -

- (BOOL) queueUpload: (Upload*) upload {
    NSLog(@"Added to queue");
	for (int i = 0 ; i < uploads_.count ; i++) {
		if ([((Upload*)[uploads_ objectAtIndex:i]).filePath isEqual: upload.filePath]) {
			return FALSE;
		}
	}
	
	[uploads_ addObject: upload];
	
	for (NSValue* delegateValue in delegates_) {
		id<UploadManagerDelegate> delegate = [delegateValue pointerValue];
		if([delegate respondsToSelector: @selector(uploadManager:didQueueUpload:)] == YES) {
			[delegate uploadManager:self didQueueUpload:upload];
		}
	}
	UploadOperation* uploadOperation = [[UploadOperation alloc] initWithUpload:upload delegate:self];
	
	//NSLog(@"[operationQueue_ operationCount] %d",[operationQueue_ operationCount]);
	[operationQueue_ addOperation:uploadOperation];
	return TRUE;
}

- (void) stopUpload: (Upload*) upload {
	if ([uploads_ containsObject: upload]) {
		//[upload retain];
        
		[uploads_ removeObject: upload];
		
		for (NSValue* delegateValue in delegates_) {
			id<UploadManagerDelegate> delegate = [delegateValue pointerValue];
			if([delegate respondsToSelector: @selector(uploadManager:didCancelUpload:)] == YES) {
				[delegate uploadManager:self didCancelUpload:upload];
			}
		}
		//[upload release];
	}
}

- (void) stopAllUploads {
	[operationQueue_ cancelAllOperations];
	Upload* upload;
	for (int i = 0 ; i < uploads_.count; i++) {
		upload = [uploads_ objectAtIndex:i];
        [self stopUpload:upload];
		//[upload retain];
		//[uploads_ removeObject: upload];
		//[upload release];
	}
}

#pragma mark UploadManagerDelegate Methods

- (void) uploadOperationDidStart: (UploadOperation*) operation
{
	for (NSValue* delegateValue in delegates_)
	{
		id<UploadManagerDelegate> delegate = [delegateValue pointerValue];
		
		if([delegate respondsToSelector: @selector(uploadManager:didStartUpload:)] == YES)
		{
			[delegate uploadManager: self didStartUpload: operation.upload];
		}
	}
}

- (void) uploadOperationDidFinish: (UploadOperation*) operation
{
	//NSLog(@"\n\n\n****************UPLOAD OPERATION COMPLETED*******************\n\n\n");

	if ([uploads_ containsObject: operation.upload])
	{
		for (NSValue* delegateValue in delegates_)
		{
			id<UploadManagerDelegate> delegate = [delegateValue pointerValue];
			
			if([delegate respondsToSelector: @selector(uploadManager:didFinishUpload:withData:)] == YES)
			{
				[delegate uploadManager: self didFinishUpload: operation.upload withData: operation.data];
			}
		}
		[uploads_ removeObject:operation.upload];
	}
}

- (void) uploadOperationDidFail: (UploadOperation*) operation
{
	
	//NSLog(@"\n\n\n****************UPLOAD OPERATION FAILED*******************\n\n\n");
	
	if ([uploads_ containsObject: operation.upload])
	{
		[uploads_ removeObject: operation.upload];
		
		for (NSValue* delegateValue in delegates_)
		{
			id<UploadManagerDelegate> delegate = [delegateValue pointerValue];
			
			if([delegate respondsToSelector: @selector(uploadManager:didCancelUpload:)] == YES)
			{
				[delegate uploadManager: self didCancelUpload: operation.upload];
			}
		}
	}
}

- (void) uploadOperationDidMakeProgress: (UploadOperation*) operation
{
	for (NSValue* delegateValue in delegates_)
	{
		id<UploadManagerDelegate> delegate = [delegateValue pointerValue];
		
		if([delegate respondsToSelector: @selector(uploadManager:didUpdateUpload:)] == YES)
		{
			[delegate uploadManager: self didUpdateUpload: operation.upload];
		}
	}
}

@end
