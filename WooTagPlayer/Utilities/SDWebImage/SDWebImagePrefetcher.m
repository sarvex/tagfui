/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "SDWebImagePrefetcher.h"

@interface SDWebImagePrefetcher ()

@property (strong, nonatomic) SDWebImageManager *manager;
@property (strong, nonatomic) NSArray *prefetchURLs;
@property (assign, nonatomic) NSUInteger requestedCount;
@property (assign, nonatomic) NSUInteger skippedCount;
@property (assign, nonatomic) NSUInteger finishedCount;
@property (assign, nonatomic) NSTimeInterval startedTime;
@property (copy, nonatomic) void (^completionBlock)(NSUInteger, NSUInteger);
@property (copy, nonatomic) void (^progressBlock)(NSUInteger, NSUInteger);

@end

@implementation SDWebImagePrefetcher

+ (SDWebImagePrefetcher *)sharedImagePrefetcher {
    TCSTART
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
    TCEND
}

- (id)init {
    if ((self = [super init])) {
        _manager = [SDWebImageManager new];
        _options = SDWebImageLowPriority;
        self.maxConcurrentDownloads = 3;
    }
    return self;
}

- (void)setMaxConcurrentDownloads:(NSUInteger)maxConcurrentDownloads {
    self.manager.imageDownloader.maxConcurrentDownloads = maxConcurrentDownloads;
}

- (NSUInteger)maxConcurrentDownloads {
    return self.manager.imageDownloader.maxConcurrentDownloads;
}

- (void)startPrefetchingAtIndex:(NSUInteger)index {
    TCSTART
    if (index >= self.prefetchURLs.count) return;
    self.requestedCount++;
    [self.manager downloadWithURL:self.prefetchURLs[index] options:self.options progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
        if (!finished) return;
        self.finishedCount++;

        if (image) {
            self.progressBlock(self.finishedCount,[self.prefetchURLs count]);
#ifdef SD_VERBOSE
            NSLog(@"Prefetched %d out of %d", self.finishedCount, self.prefetchURLs.count);
#endif
        }
        else {
            self.progressBlock(self.finishedCount,[self.prefetchURLs count]);
#ifdef SD_VERBOSE
            NSLog(@"Prefetched %d out of %d (Failed)", self.finishedCount, [self.prefetchURLs count]);
#endif

            // Add last failed
            self.skippedCount++;
        }
        if ([self.delegate respondsToSelector:@selector(imagePrefetcher:didPrefetchURL:finishedCount:totalCount:)]) {
            [self.delegate imagePrefetcher:self
                            didPrefetchURL:self.prefetchURLs[index]
                             finishedCount:self.finishedCount
                                totalCount:self.prefetchURLs.count
            ];
        }

        if (self.prefetchURLs.count > self.requestedCount) {
            [self startPrefetchingAtIndex:self.requestedCount];
        }
        else if (self.finishedCount + self.skippedCount == self.requestedCount) {
            [self reportStatus];
            if (self.completionBlock) {
                self.completionBlock(self.finishedCount, self.skippedCount);
                self.completionBlock = nil;
            }
        }
    }];
    TCEND
}

- (void)reportStatus {
    TCSTART
    NSUInteger total = [self.prefetchURLs count];
#ifdef SD_VERBOSE
    NSLog(@"Finished prefetching (%d successful, %d skipped, timeElasped %.2f)", total - self.skippedCount, self.skippedCount, CFAbsoluteTimeGetCurrent() - self.startedTime);
#endif
    if ([self.delegate respondsToSelector:@selector(imagePrefetcher:didFinishWithTotalCount:skippedCount:)]) {
        [self.delegate imagePrefetcher:self
               didFinishWithTotalCount:(total - self.skippedCount)
                          skippedCount:self.skippedCount
        ];
    }
    TCEND
}

- (void)prefetchURLs:(NSArray *)urls {
    [self prefetchURLs:urls progress:nil completed:nil];
}

- (void)prefetchURLs:(NSArray *)urls progress:(void (^)(NSUInteger, NSUInteger))progressBlock completed:(void (^)(NSUInteger, NSUInteger))completionBlock {
    TCSTART
    [self cancelPrefetching]; // Prevent duplicate prefetch request
    self.startedTime = CFAbsoluteTimeGetCurrent();
    self.prefetchURLs = urls;
    self.completionBlock = completionBlock;
    self.progressBlock = progressBlock;

    // Starts prefetching from the very first image on the list with the max allowed concurrency
    NSUInteger listCount = self.prefetchURLs.count;
    for (NSUInteger i = 0; i < self.maxConcurrentDownloads && self.requestedCount < listCount; i++) {
        [self startPrefetchingAtIndex:i];
    }
    TCEND
}

- (void)cancelPrefetching {
    self.prefetchURLs = nil;
    self.skippedCount = 0;
    self.requestedCount = 0;
    self.finishedCount = 0;
    [self.manager cancelAll];
}

@end
