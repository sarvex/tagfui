#import "GPUImagePicture.h"

@implementation GPUImagePicture

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithURL:(NSURL *)url;
{
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:url];
    
    if (!(self = [self initWithData:imageData]))
    {
        return nil;
    }
    
    return self;
}

- (id)initWithData:(NSData *)imageData;
{
    UIImage *inputImage = [[UIImage alloc] initWithData:imageData];
    
    if (!(self = [self initWithImage:inputImage]))
    {
		return nil;
    }
    
    return self;
}

- (id)initWithImage:(UIImage *)newImageSource;
{
    if (!(self = [self initWithImage:newImageSource smoothlyScaleOutput:NO]))
    {
		return nil;
    }
    
    return self;
}

- (id)initWithCGImage:(CGImageRef)newImageSource;
{
    if (!(self = [self initWithCGImage:newImageSource smoothlyScaleOutput:NO]))
    {
		return nil;
    }
    return self;
}

- (id)initWithImage:(UIImage *)newImageSource smoothlyScaleOutput:(BOOL)smoothlyScaleOutput;
{
    return [self initWithCGImage:[newImageSource CGImage] smoothlyScaleOutput:smoothlyScaleOutput];
}

- (id)initWithCGImage:(CGImageRef)newImageSource smoothlyScaleOutput:(BOOL)smoothlyScaleOutput;
{
    @try {
        if (!(self = [super init]))
        {
            return nil;
        }
        
        hasProcessedImage = NO;
        self.shouldSmoothlyScaleOutput = smoothlyScaleOutput;
        imageUpdateSemaphore = dispatch_semaphore_create(1);
        
        // TODO: Dispatch this whole thing asynchronously to move image loading off main thread
        CGFloat widthOfImage = CGImageGetWidth(newImageSource);
        CGFloat heightOfImage = CGImageGetHeight(newImageSource);
        
        // If passed an empty image reference, CGContextDrawImage will fail in future versions of the SDK.
        NSAssert( widthOfImage > 0 && heightOfImage > 0, @"Passed image must not be empty - it should be at least 1px tall and wide");
        
        pixelSizeOfImage = CGSizeMake(widthOfImage, heightOfImage);
        CGSize pixelSizeToUseForTexture = pixelSizeOfImage;
        
        BOOL shouldRedrawUsingCoreGraphics = YES;
        
        // For now, deal with images larger than the maximum texture size by resizing to be within that limit
        CGSize scaledImageSizeToFitOnGPU = [GPUImageContext sizeThatFitsWithinATextureForSize:pixelSizeOfImage];
        if (!CGSizeEqualToSize(scaledImageSizeToFitOnGPU, pixelSizeOfImage))
        {
            pixelSizeOfImage = scaledImageSizeToFitOnGPU;
            pixelSizeToUseForTexture = pixelSizeOfImage;
            shouldRedrawUsingCoreGraphics = YES;
        }
        
        if (self.shouldSmoothlyScaleOutput)
        {
            // In order to use mipmaps, you need to provide power-of-two textures, so convert to the next largest power of two and stretch to fill
            CGFloat powerClosestToWidth = ceil(log2(pixelSizeOfImage.width));
            CGFloat powerClosestToHeight = ceil(log2(pixelSizeOfImage.height));
            
            pixelSizeToUseForTexture = CGSizeMake(pow(2.0, powerClosestToWidth), pow(2.0, powerClosestToHeight));
            
            shouldRedrawUsingCoreGraphics = YES;
        }
        
        GLubyte *imageData = NULL;
        CFDataRef dataFromImageDataProvider;
        
        //    CFAbsoluteTime elapsedTime, startTime = CFAbsoluteTimeGetCurrent();
        
        if (shouldRedrawUsingCoreGraphics)
        {
            // For resized image, redraw
            imageData = (GLubyte *) calloc(1, (int)pixelSizeToUseForTexture.width * (int)pixelSizeToUseForTexture.height * 4);
            
            CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
            
            CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)pixelSizeToUseForTexture.width, (size_t)pixelSizeToUseForTexture.height, 8, (size_t)pixelSizeToUseForTexture.width * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
            //        CGContextSetBlendMode(imageContext, kCGBlendModeCopy); // From Technical Q&A QA1708: http://developer.apple.com/library/ios/#qa/qa1708/_index.html
            CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, pixelSizeToUseForTexture.width, pixelSizeToUseForTexture.height), newImageSource);
            CGContextRelease(imageContext);
            CGColorSpaceRelease(genericRGBColorspace);
        }
        else
        {
            // Access the raw image bytes directly
            dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(newImageSource));
            imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
        }
        
        //    elapsedTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0;
        //    NSLog(@"Core Graphics drawing time: %f", elapsedTime);
        
        //    CGFloat currentRedTotal = 0.0f, currentGreenTotal = 0.0f, currentBlueTotal = 0.0f, currentAlphaTotal = 0.0f;
        //	NSUInteger totalNumberOfPixels = round(pixelSizeToUseForTexture.width * pixelSizeToUseForTexture.height);
        //
        //    for (NSUInteger currentPixel = 0; currentPixel < totalNumberOfPixels; currentPixel++)
        //    {
        //        currentBlueTotal += (CGFloat)imageData[(currentPixel * 4)] / 255.0f;
        //        currentGreenTotal += (CGFloat)imageData[(currentPixel * 4) + 1] / 255.0f;
        //        currentRedTotal += (CGFloat)imageData[(currentPixel * 4 + 2)] / 255.0f;
        //        currentAlphaTotal += (CGFloat)imageData[(currentPixel * 4) + 3] / 255.0f;
        //    }
        //
        //    NSLog(@"Debug, average input image red: %f, green: %f, blue: %f, alpha: %f", currentRedTotal / (CGFloat)totalNumberOfPixels, currentGreenTotal / (CGFloat)totalNumberOfPixels, currentBlueTotal / (CGFloat)totalNumberOfPixels, currentAlphaTotal / (CGFloat)totalNumberOfPixels);
        
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext useImageProcessingContext];
            
            [self initializeOutputTextureIfNeeded];
            
            glBindTexture(GL_TEXTURE_2D, outputTexture);
            if (self.shouldSmoothlyScaleOutput)
            {
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            }
            // no need to use self.outputTextureOptions here since pictures need this texture formats and type
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)pixelSizeToUseForTexture.width, (int)pixelSizeToUseForTexture.height, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
            
            if (self.shouldSmoothlyScaleOutput)
            {
                glGenerateMipmap(GL_TEXTURE_2D);
            }
            glBindTexture(GL_TEXTURE_2D, 0);
        });
        
        if (shouldRedrawUsingCoreGraphics)
        {
            free(imageData);
        }
        else
        {
            CFRelease(dataFromImageDataProvider);
        }
        
        return self;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
}

// ARC forbids explicit message send of 'release'; since iOS 6 even for dispatch_release() calls: stripping it out in that case is required.
#if ( (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0) || (!defined(__IPHONE_6_0)) )
- (void)dealloc;
{
    if (imageUpdateSemaphore != NULL)
    {
        dispatch_release(imageUpdateSemaphore);
    }
}
#endif

#pragma mark -
#pragma mark Image rendering

- (void)removeAllTargets;
{
    [super removeAllTargets];
    hasProcessedImage = NO;
}

- (void)processImage;
{
    [self processImageWithCompletionHandler:nil];
}

- (BOOL)processImageWithCompletionHandler:(void (^)(void))completion;
{
    @try {
        hasProcessedImage = YES;
        
        //    dispatch_semaphore_wait(imageUpdateSemaphore, DISPATCH_TIME_FOREVER);
        
        if (dispatch_semaphore_wait(imageUpdateSemaphore, DISPATCH_TIME_NOW) != 0)
        {
            return NO;
        }
        
        runAsynchronouslyOnVideoProcessingQueue(^{
            
            if (MAX(pixelSizeOfImage.width, pixelSizeOfImage.height) > 1000.0)
            {
                [self conserveMemoryForNextFrame];
            }
            
            for (id<GPUImageInput> currentTarget in targets)
            {
                NSInteger indexOfObject = [targets indexOfObject:currentTarget];
                NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
                
                [currentTarget setCurrentlyReceivingMonochromeInput:NO];
                [currentTarget setInputSize:pixelSizeOfImage atIndex:textureIndexOfTarget];
                //            [currentTarget setInputTexture:outputTexture atIndex:textureIndexOfTarget];
                [currentTarget newFrameReadyAtTime:kCMTimeIndefinite atIndex:textureIndexOfTarget];
            }
            
            dispatch_semaphore_signal(imageUpdateSemaphore);
            
            if (completion != nil) {
                completion();
            }
        });
        
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
    
    
}

- (CGSize)outputImageSize;
{
    return pixelSizeOfImage;
}

- (void)addTarget:(id<GPUImageInput>)newTarget atTextureLocation:(NSInteger)textureLocation;
{
    [super addTarget:newTarget atTextureLocation:textureLocation];
    
    if (hasProcessedImage)
    {
        [newTarget setInputSize:pixelSizeOfImage atIndex:textureLocation];
        [newTarget newFrameReadyAtTime:kCMTimeIndefinite atIndex:textureLocation];
    }
}

@end