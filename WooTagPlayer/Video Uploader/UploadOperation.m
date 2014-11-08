/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
#import "UploadOperation.h"
#import "WooTagPlayerAppDelegate.h"

@implementation UploadOperation

@synthesize upload = upload_;
@synthesize data   = data_;

- (id) initWithUpload: (Upload*) upload delegate: (id<UploadOperationDelegate>) delegate
{
	appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication]delegate];
	if ((self = [super init]) != nil) {
		upload_ = upload;
		delegate_ = delegate;
	}
	return self;
}

- (void) dealloc
{
//	[connection_ release];
//	[upload_ release];
//	[super dealloc];
}

// This method is just for convenience. It cancels the URL connection if it
// still exists and finishes up the operation.
- (void)done
{
	if( connection_ ) {
		[connection_ cancel];
		//[connection_ autorelease];
		connection_ = nil;
	}
	
	// Alert anyone that we are finished
	[self willChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	executing_ = NO;
	finished_  = YES;
	[self didChangeValueForKey:@"isFinished"];
	[self didChangeValueForKey:@"isExecuting"];
}


-(NSMutableURLRequest*)getPreparedRequest
{
	
//	NSString * contentType = nil;
	NSString * fileId      = nil;
	
	if (upload_.fileId)
	{
		fileId = [NSString stringWithFormat:@"&fileId=%@",upload_.fileId];
	}
	else
	{
		fileId = @"";
	}
	
	//////////////////////////////PREPARING URL//////////////////////////////////////////////////////////
	//NSString * checkSumInformation = [NSString stringWithFormat:@"&finalChecksum=%@&partChecksum=%@",[upload_ getCheckSumForCompleteFile],[upload_ getCheckSumForCurrentPart]];
	NSString *checkSum = [upload_ getCheckSumForCurrentPart];
    Video *video = upload_.userInfo;
	NSString * urlToHit  = [NSString stringWithFormat:@"%@?userid=%@&clientvideoId=%@&File_name=%@.mov&checksum=%@&partNo=%d&Totalcount=%d",[upload_.url absoluteString],video.userId?:@"1",upload_.mediaId,upload_.fileName,checkSum,upload_.currentPart,upload_.totalParts];
    //NSString * urlToHit  = [NSString stringWithFormat:@"http://spoors.in/videouplaod?userid=1&clientvideoId=%@&File_name=%@.mov&checksum=%@&partNo=%d&Totalcount=%d",upload_.mediaId,upload_.fileName,checkSum,upload_.currentPart,upload_.totalParts];
    urlToHit = [urlToHit stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"file upload request URL is %@",urlToHit);
    //NSString *body = [NSString stringWithFormat:@"{\"video\":{\"userid\":\"1\",\"clientvideoId\":\"%@\",\"File_name\":\"video0.mov\",\"Binary data\":\"%@\",\"partNo\":%d,\"Totalcount\":%d}}",upload_.mediaId,[upload_ getFileDataToSend],upload_.currentPart,upload_.totalParts];
    //NSLog(@"file upload request data %@",body);
    NSData *postbody = [upload_ getFileDataToSend];
    
	NSMutableURLRequest *uploadRequest = [[NSMutableURLRequest alloc]
										  initWithURL:[NSURL URLWithString:urlToHit]
										  cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
										  timeoutInterval:60];
	
	[uploadRequest setHTTPMethod:@"POST"];
    // creation the cookie
    NSURL *_server_url = [NSURL URLWithString:urlToHit];
    NSLog(@"host:%@ path:%@",[_server_url host],[_server_url path]);
    NSHTTPCookie *cook = [NSHTTPCookie cookieWithProperties:
                          [NSDictionary dictionaryWithObjectsAndKeys:
                           [_server_url host], NSHTTPCookieDomain,
                           [_server_url path], NSHTTPCookiePath,
                           @"testcookie",  NSHTTPCookieName,
                           @"1", NSHTTPCookieValue,
                           nil]];
    // Posting the cookie
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cook];
    [uploadRequest setHTTPShouldHandleCookies:YES];
	//[uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[uploadRequest setHTTPBody:postbody];
	
	return uploadRequest;	
}

- (void)uploadProcess {
	if ([appDelegate statusForNetworkConnectionWithOutMessage]) {
		if(try_ < 3 && ![upload_ isCompleted]) {
			try_++;
			
			connection_ = [[URLConnection alloc]initWithRequest:[self getPreparedRequest] delegate:self andtag:nil];
			
			if (connection_) {
                [delegate_ uploadOperationDidStart:self];
			} else {
                [self uploadCompleted];
            }
		}
	}
	else
	{
		[self uploadCompleted];
	}
}


-(void)uploadCompleted
{
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
	
	if ([upload_ isCompleted]) {
		upload_.serverResponseData = data_;
		[delegate_ uploadOperationDidFinish: self];
	} else {
        [[NSUserDefaults standardUserDefaults]setObject:upload_.mediaId forKey:@"clientVideoid"];
        [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d",upload_.currentPart] forKey:@"partNumber"];
		[delegate_ uploadOperationDidFail: self];
	}
	
	// Alert anyone that we are finished
	[self willChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	executing_ = NO;
	finished_  = YES;
	[self didChangeValueForKey:@"isFinished"];
	[self didChangeValueForKey:@"isExecuting"];
}

#pragma mark -

- (void) start
{
	if (![NSThread isMainThread])
	{
		[self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
		return;
	}
	if (![self isCancelled])
	{
		[self willChangeValueForKey:@"isExecuting"];
		executing_ = YES;
		[self didChangeValueForKey:@"isExecuting"];
		
		if ([appDelegate statusForNetworkConnectionWithOutMessage])
		{
			[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:TRUE];
			[self uploadProcess];
		}
		else
		{
			[self uploadCompleted];
		}
	}
	else
	{
		// If it's already been cancelled, mark the operation as finished.
		[self willChangeValueForKey:@"isFinished"]; {
			finished_ = YES;
		}
		[self didChangeValueForKey:@"isFinished"];
	}
}

- (BOOL) isConcurrent
{
	return YES;
}

- (BOOL) isExecuting
{
	return executing_;
}

- (BOOL) isFinished {
	return finished_;
}

#pragma mark NSURLConnection Delegate Methods
-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
    //NSLog(@"totalBytesExpectedToWrite %d totalBytesWritten %d bytesWritten %d",totalBytesExpectedToWrite,totalBytesWritten,bytesWritten);
    
    if (upload_.totalParts == 1) {
        upload_.percentageComplete = (float)totalBytesWritten/totalBytesExpectedToWrite;
        //NSLog(@"single part percentage complete is %f",upload_.percentageComplete);
    }
    //float partPercentageComeplete = (float)totalBytesWritten/totalBytesExpectedToWrite;
    
    if ([self isCancelled]) {
        //NSLog(@"Connection Cancelled");
        
        [self done];
        [self uploadCompleted];
        
        return;
    }
    
    [delegate_ uploadOperationDidMakeProgress:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    
	URLConnection *conn = (URLConnection*)connection;
    conn.responseData = [NSMutableData data];
	statusCode_ = [response statusCode];
	[conn.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    URLConnection *conn = (URLConnection*)connection;
	[conn.responseData appendData:data];
	[delegate_ uploadOperationDidMakeProgress: self];
	
	//NSLog(@"receiving .....");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//[AKSMethods printErrorMessage:error showit:NO];
    NSLog(@"connection didFailWithError........... %@",error);
    upload_.error = error;
	if(try_ > 3 || [upload_ isCompleted]) {
		[self uploadCompleted];
	} else {
		[self uploadProcess];
	}
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection {
	URLConnection *conn = (URLConnection*)connection;
	
	data_ = conn.responseData;
	
	NSString *responseString = [[NSString alloc]initWithData:conn.responseData encoding:NSUTF8StringEncoding];
	
	NSLog(@"\n\n\nresponse received from server %@\n\n\n",responseString);
	
	
	NSError *error;
	
	id parsedJSONResponse = removeNull([NSJSONSerialization JSONObjectWithData:(NSData *)data_ options:NSJSONReadingMutableContainers error:&error]);
	
	if (parsedJSONResponse)
	{
		//NSLog(@"FILE_UPLOAD_RESPONSE_RECEIVED %@",responseDictionary);
		//update upload object with this response
		
		if ([[parsedJSONResponse valueForKey:@"error_code"] integerValue] == 0)
		{
			//upload_.fileId = [parsedJSONResponse objectForKey:@"fileId"];
			try_ = 0;
            upload_.percentageComplete = (float)((upload_.currentPart * 100)/upload_.totalParts);
            upload_.percentageComplete = upload_.percentageComplete/100;
            NSLog(@"current uploded part is %d, total parts are %d",upload_.currentPart,upload_.totalParts);

            NSLog(@"===================== uploading progressValue %f ================",upload_.percentageComplete);
			
            upload_.currentPart++;
			upload_.completedPartsCount++;
            if ([upload_ isCompleted]) {
                [self uploadCompleted];   
            }
		} else {
            upload_.error = [NSError errorWithDomain:@"Upload Failed" code:[[parsedJSONResponse valueForKey:@"error_code"] integerValue] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"UploadFailed",@"userInfoDict", nil]];
            upload_.serverResponseData = data_;
            try_ = 4;
        }
	}
	
	if(try_ > 3)
	{
		[self uploadCompleted];
	}
	else
	{
		[self uploadProcess];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
}

@end
