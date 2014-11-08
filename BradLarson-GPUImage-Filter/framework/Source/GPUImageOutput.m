#import "GPUImageOutput.h"
#import "GPUImageMovieWriter.h"
#import "GPUImagePicture.h"
#import <mach/mach.h>

void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
	if ([NSThread isMainThread])
	{
		block();
	}
	else
	{
		dispatch_sync(dispatch_get_main_queue(), block);
	}
}

void runSynchronouslyOnVideoProcessingQueue(void (^block)(void))
{
    dispatch_queue_t videoProcessingQueue = [GPUImageContext sharedContextQueue];
#if (!defined(__IPHONE_6_0) || (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0))
    if (dispatch_get_current_queue() == videoProcessingQueue)
#else
	if (dispatch_get_specific([GPUImageContext contextKey]))
#endif
	{
		block();
	}else
	{
		dispatch_sync(videoProcessingQueue, block);
	}
}

void runAsynchronouslyOnVideoProcessingQueue(void (^block)(void))
{
    dispatch_queue_t videoProcessingQueue = [GPUImageContext sharedContextQueue];
    
#if (!defined(__IPHONE_6_0) || (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0))
    if (dispatch_get_current_queue() == videoProcessingQueue)
#else
    if (dispatch_get_specific([GPUImageContext contextKey]))
#endif
	{
		block();
	}else
	{
		dispatch_async(videoProcessingQueue, block);
	}
}

void reportAvailableMemoryForGPUImage(NSString *tag) 
{    
    if (!tag)
        tag = @"Default";
    
    struct task_basic_info info;
    
    mach_msg_type_number_t size = sizeof(info);
    
    kern_return_t kerr = task_info(mach_task_self(),
                                   
                                   TASK_BASIC_INFO,
                                   
                                   (task_info_t)&info,
                                   
                                   &size);    
    if( kerr == KERN_SUCCESS ) {        
        NSLog(@"%@ - Memory used: %u", tag, (unsigned int)info.resident_size); //in bytes
    } else {        
        NSLog(@"%@ - Error: %s", tag, mach_error_string(kerr));        
    }    
}

@implementation GPUImageOutput

@synthesize shouldSmoothlyScaleOutput = _shouldSmoothlyScaleOutput;
@synthesize shouldIgnoreUpdatesToThisTarget = _shouldIgnoreUpdatesToThisTarget;
@synthesize audioEncodingTarget = _audioEncodingTarget;
@synthesize targetToIgnoreForUpdates = _targetToIgnoreForUpdates;
@synthesize frameProcessingCompletionBlock = _frameProcessingCompletionBlock;
@synthesize enabled = _enabled;
@synthesize outputTextureOptions = _outputTextureOptions;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init; 
{
    @try {
        if (!(self = [super init]))
        {
            return nil;
        }
        
        targets = [[NSMutableArray alloc] init];
        targetTextureIndices = [[NSMutableArray alloc] init];
        _enabled = YES;
        allTargetsWantMonochromeData = YES;
        
        // set default texture options
        _outputTextureOptions.minFilter = GL_LINEAR;
        _outputTextureOptions.magFilter = GL_LINEAR;
        _outputTextureOptions.wrapS = GL_CLAMP_TO_EDGE;
        _outputTextureOptions.wrapT = GL_CLAMP_TO_EDGE;
        _outputTextureOptions.internalFormat = GL_RGBA;
        _outputTextureOptions.format = GL_BGRA;
        _outputTextureOptions.type = GL_UNSIGNED_BYTE;
        
        return self;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
	
}

- (void)dealloc 
{
    [self removeAllTargets];
    [self deleteOutputTexture];
}

#pragma mark -
#pragma mark Managing targets

- (void)setInputTextureForTarget:(id<GPUImageInput>)target atIndex:(NSInteger)inputTextureIndex;
{
    @try {
        [target setInputTexture:[self textureForOutput] atIndex:inputTextureIndex];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
    
}

- (GLuint)textureForOutput;
{
    return outputTexture;
}

- (void)notifyTargetsAboutNewOutputTexture;
{
    @try {
        for (id<GPUImageInput> currentTarget in targets)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            [self setInputTextureForTarget:currentTarget atIndex:textureIndex];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

- (NSArray*)targets;
{
	return [NSArray arrayWithArray:targets];
}

- (void)addTarget:(id<GPUImageInput>)newTarget;
{
    @try {
        NSInteger nextAvailableTextureIndex = [newTarget nextAvailableTextureIndex];
        [self addTarget:newTarget atTextureLocation:nextAvailableTextureIndex];
        
        if ([newTarget shouldIgnoreUpdatesToThisTarget])
        {
            _targetToIgnoreForUpdates = newTarget;
        }

    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
   }

- (void)addTarget:(id<GPUImageInput>)newTarget atTextureLocation:(NSInteger)textureLocation;
{
    @try {
        if([targets containsObject:newTarget])
        {
            return;
        }
        
        cachedMaximumOutputSize = CGSizeZero;
        runSynchronouslyOnVideoProcessingQueue(^{
            [self setInputTextureForTarget:newTarget atIndex:textureLocation];
            [newTarget setTextureDelegate:self atIndex:textureLocation];
            [targets addObject:newTarget];
            [targetTextureIndices addObject:[NSNumber numberWithInteger:textureLocation]];
            
            allTargetsWantMonochromeData = allTargetsWantMonochromeData && [newTarget wantsMonochromeInput];
        });
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
    
}

- (void)removeTarget:(id<GPUImageInput>)targetToRemove;
{
    @try {
        if(![targets containsObject:targetToRemove])
        {
            return;
        }
        
        if (_targetToIgnoreForUpdates == targetToRemove)
        {
            _targetToIgnoreForUpdates = nil;
        }
        
        cachedMaximumOutputSize = CGSizeZero;
        
        NSInteger indexOfObject = [targets indexOfObject:targetToRemove];
        NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
        
        runSynchronouslyOnVideoProcessingQueue(^{
            [targetToRemove setInputTexture:0 atIndex:textureIndexOfTarget];
            [targetToRemove setInputSize:CGSizeZero atIndex:textureIndexOfTarget];
            [targetToRemove setTextureDelegate:nil atIndex:textureIndexOfTarget];
            [targetToRemove setInputRotation:kGPUImageNoRotation atIndex:textureIndexOfTarget];
            
            [targetTextureIndices removeObjectAtIndex:indexOfObject];
            [targets removeObject:targetToRemove];
            [targetToRemove endProcessing];
        });
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

- (void)removeAllTargets;
{
    @try {
        cachedMaximumOutputSize = CGSizeZero;
        runSynchronouslyOnVideoProcessingQueue(^{
            for (id<GPUImageInput> targetToRemove in targets)
            {
                NSInteger indexOfObject = [targets indexOfObject:targetToRemove];
                NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
                
                [targetToRemove setInputTexture:0 atIndex:textureIndexOfTarget];
                [targetToRemove setInputSize:CGSizeZero atIndex:textureIndexOfTarget];
                [targetToRemove setTextureDelegate:nil atIndex:textureIndexOfTarget];
                [targetToRemove setInputRotation:kGPUImageNoRotation atIndex:textureIndexOfTarget];
            }
            [targets removeAllObjects];
            [targetTextureIndices removeAllObjects];
            
            allTargetsWantMonochromeData = YES;
        });
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

#pragma mark -
#pragma mark Manage the output texture

- (void)initializeOutputTextureIfNeeded;
{
    @try {
        runSynchronouslyOnVideoProcessingQueue(^{
            if (!outputTexture)
            {
                [GPUImageContext useImageProcessingContext];
                
                glActiveTexture(GL_TEXTURE0);
                glGenTextures(1, &outputTexture);
                glBindTexture(GL_TEXTURE_2D, outputTexture);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, self.outputTextureOptions.minFilter);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, self.outputTextureOptions.magFilter);
                // This is necessary for non-power-of-two textures
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, self.outputTextureOptions.wrapS);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, self.outputTextureOptions.wrapT);
                glBindTexture(GL_TEXTURE_2D, 0);
            }
        });
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

- (void)deleteOutputTexture;
{
    @try {
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext useImageProcessingContext];
            
            if (outputTexture)
            {
                glDeleteTextures(1, &outputTexture);
                outputTexture = 0;
            }
        });
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

- (void)forceProcessingAtSize:(CGSize)frameSize;
{
    
}

- (void)forceProcessingAtSizeRespectingAspectRatio:(CGSize)frameSize;
{
}

- (void)cleanupOutputImage;
{
    NSLog(@"WARNING: Undefined image cleanup");
}

#pragma mark -
#pragma mark Still image processing

- (CGImageRef)newCGImageFromCurrentlyProcessedOutputWithOrientation:(UIImageOrientation)imageOrientation;
{
    return nil;
}

- (CGImageRef)newCGImageByFilteringCGImage:(CGImageRef)imageToFilter
{
    @try {
        return [self newCGImageByFilteringCGImage:imageToFilter orientation:UIImageOrientationUp];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

- (CGImageRef)newCGImageByFilteringCGImage:(CGImageRef)imageToFilter orientation:(UIImageOrientation)orientation;
{
    @try {
        GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithCGImage:imageToFilter];
        
        [stillImageSource addTarget:(id<GPUImageInput>)self];
        [stillImageSource processImage];
        
        CGImageRef processedImage = [self newCGImageFromCurrentlyProcessedOutputWithOrientation:orientation];
        
        [stillImageSource removeTarget:(id<GPUImageInput>)self];
        return processedImage;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

- (BOOL)providesMonochromeOutput;
{
    return NO;
}

- (void)prepareForImageCapture;
{
    
}

- (void)conserveMemoryForNextFrame;
{
    @try {
        shouldConserveMemoryForNextFrame = YES;
        
        for (id<GPUImageInput> currentTarget in targets)
        {
            if (currentTarget != self.targetToIgnoreForUpdates)
            {
                [currentTarget conserveMemoryForNextFrame];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

#pragma mark -
#pragma mark Platform-specific image output methods

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE

- (CGImageRef)newCGImageFromCurrentlyProcessedOutput;
{
    @try {
        UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
        UIImageOrientation imageOrientation = UIImageOrientationLeft;
        switch (deviceOrientation)
        {
            case UIDeviceOrientationPortrait:
                imageOrientation = UIImageOrientationUp;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                imageOrientation = UIImageOrientationDown;
                break;
            case UIDeviceOrientationLandscapeLeft:
                imageOrientation = UIImageOrientationLeft;
                break;
            case UIDeviceOrientationLandscapeRight:
                imageOrientation = UIImageOrientationRight;
                break;
            default:
                imageOrientation = UIImageOrientationUp;
                break;
        }
        
        return [self newCGImageFromCurrentlyProcessedOutputWithOrientation:imageOrientation];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
	
}

- (UIImage *)imageFromCurrentlyProcessedOutput;
{
    @try {
        UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
        UIImageOrientation imageOrientation = UIImageOrientationLeft;
        switch (deviceOrientation)
        {
            case UIDeviceOrientationPortrait:
                imageOrientation = UIImageOrientationUp;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                imageOrientation = UIImageOrientationDown;
                break;
            case UIDeviceOrientationLandscapeLeft:
                imageOrientation = UIImageOrientationLeft;
                break;
            case UIDeviceOrientationLandscapeRight:
                imageOrientation = UIImageOrientationRight;
                break;
            default:
                imageOrientation = UIImageOrientationUp;
                break;
        }
        
        return [self imageFromCurrentlyProcessedOutputWithOrientation:imageOrientation];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
	
}

- (UIImage *)imageFromCurrentlyProcessedOutputWithOrientation:(UIImageOrientation)imageOrientation;
{
    @try {
        CGImageRef cgImageFromBytes = [self newCGImageFromCurrentlyProcessedOutputWithOrientation:imageOrientation];
        UIImage *finalImage = [UIImage imageWithCGImage:cgImageFromBytes scale:1.0 orientation:imageOrientation];
        CGImageRelease(cgImageFromBytes);
        
        return finalImage;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

- (UIImage *)imageByFilteringImage:(UIImage *)imageToFilter;
{
    @try {
        CGImageRef image = [self newCGImageByFilteringCGImage:[imageToFilter CGImage] orientation:[imageToFilter imageOrientation]];
        UIImage *processedImage = [UIImage imageWithCGImage:image scale:[imageToFilter scale] orientation:[imageToFilter imageOrientation]];
        CGImageRelease(image);
        return processedImage;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

- (CGImageRef)newCGImageByFilteringImage:(UIImage *)imageToFilter
{
    @try {
        return [self newCGImageByFilteringCGImage:[imageToFilter CGImage] orientation:[imageToFilter imageOrientation]];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

#else

- (CGImageRef)newCGImageFromCurrentlyProcessedOutput;
{
    @try {
        return [self newCGImageFromCurrentlyProcessedOutputWithOrientation:UIImageOrientationLeft];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

- (NSImage *)imageFromCurrentlyProcessedOutput;
{
    @try {
        return [self imageFromCurrentlyProcessedOutputWithOrientation:UIImageOrientationLeft];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

- (NSImage *)imageFromCurrentlyProcessedOutputWithOrientation:(UIImageOrientation)imageOrientation;
{
    @try {
        CGImageRef cgImageFromBytes = [self newCGImageFromCurrentlyProcessedOutputWithOrientation:imageOrientation];
        NSImage *finalImage = [[NSImage alloc] initWithCGImage:cgImageFromBytes size:NSZeroSize];
        CGImageRelease(cgImageFromBytes);
        
        return finalImage;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

- (NSImage *)imageByFilteringImage:(NSImage *)imageToFilter;
{
    @try {
        CGImageRef image = [self newCGImageByFilteringCGImage:[imageToFilter CGImageForProposedRect:NULL context:[NSGraphicsContext currentContext] hints:nil] orientation:UIImageOrientationLeft];
        NSImage *processedImage = [[NSImage alloc] initWithCGImage:image size:NSZeroSize];
        CGImageRelease(image);
        return processedImage;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

- (CGImageRef)newCGImageByFilteringImage:(NSImage *)imageToFilter
{
    @try {
        return [self newCGImageByFilteringCGImage:[imageToFilter CGImageForProposedRect:NULL context:[NSGraphicsContext currentContext] hints:nil] orientation:UIImageOrientationLeft];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

#endif

#pragma mark -
#pragma mark GPUImageTextureDelegate methods

- (void)textureNoLongerNeededForTarget:(id<GPUImageInput>)textureTarget;
{
    @try {
        outputTextureRetainCount--;
        if (outputTextureRetainCount < 1)
        {
            [self cleanupOutputImage];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

#pragma mark -
#pragma mark Accessors

- (void)setAudioEncodingTarget:(GPUImageMovieWriter *)newValue;
{
    @try {
        _audioEncodingTarget = newValue;
        if( ! _audioEncodingTarget.hasAudioTrack )
        {
            _audioEncodingTarget.hasAudioTrack = YES;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

@end
