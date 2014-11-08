/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
#import <Foundation/Foundation.h>
#import "Upload.h"

#import "URLConnection.h"
@class WooTagPlayerAppDelegate;
@class UploadOperation;

@protocol UploadOperationDelegate<NSObject>
- (void) uploadOperationDidStart: (UploadOperation*) operation;
- (void) uploadOperationDidFinish: (UploadOperation*) operation;
- (void) uploadOperationDidFail: (UploadOperation*) operation;
- (void) uploadOperationDidMakeProgress: (UploadOperation*) operation;
@end

@interface UploadOperation : NSOperation {
	WooTagPlayerAppDelegate *appDelegate;
  @private
    NSMutableData* data_;
	Upload       * upload_;
	id<UploadOperationDelegate> delegate_;
	URLConnection* connection_;
	NSInteger statusCode_;
	BOOL executing_;
	BOOL finished_;
	int try_ ;
}

- (id) initWithUpload: (Upload*) upload delegate: (id<UploadOperationDelegate>) delegate;

@property (nonatomic,readonly) Upload* upload;
@property (nonatomic,readonly) NSData* data;

@end
