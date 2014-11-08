/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "UIImageView+WebCache.h"
#import "objc/runtime.h"

static char operationKey;
static char operationArrayKey;

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)url {
    TCSTART
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
    TCEND
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    TCSTART
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
    TCEND
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options {
    TCSTART
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
    TCEND
}

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletedBlock)completedBlock {
    TCSTART
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
    TCEND
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletedBlock)completedBlock {
    TCSTART
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
    TCEND
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock {
    TCSTART
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
    TCEND
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock {
    TCSTART
    [self cancelCurrentImageLoad];

    self.image = placeholder;

    if (url) {
        __weak UIImageView *wself = self;
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                if (image) {
                    wself.image = image;
                    [wself setNeedsLayout];
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType);
                }
            });
        }];
        objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    TCEND
}

- (void)setAnimationImagesWithURLs:(NSArray *)arrayOfURLs {
    TCSTART
    [self cancelCurrentArrayLoad];
    __weak UIImageView *wself = self;

    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];

    for (NSURL *logoImageURL in arrayOfURLs) {
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadWithURL:logoImageURL options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                __strong UIImageView *sself = wself;
                [sself stopAnimating];
                if (sself && image) {
                    NSMutableArray *currentImages = [[sself animationImages] mutableCopy];
                    if (!currentImages) {
                        currentImages = [[NSMutableArray alloc] init];
                    }
                    [currentImages addObject:image];

                    sself.animationImages = currentImages;
                    [sself setNeedsLayout];
                }
                [sself startAnimating];
            });
        }];
        [operationsArray addObject:operation];
    }

    objc_setAssociatedObject(self, &operationArrayKey, [NSArray arrayWithArray:operationsArray], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    TCEND
}

- (void)cancelCurrentImageLoad {
    TCSTART
    // Cancel in progress downloader from queue
    id <SDWebImageOperation> operation = objc_getAssociatedObject(self, &operationKey);
    if (operation) {
        [operation cancel];
        objc_setAssociatedObject(self, &operationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    TCEND
}

- (void)cancelCurrentArrayLoad {
    TCSTART
    // Cancel in progress downloader from queue
    NSArray *operations = objc_getAssociatedObject(self, &operationArrayKey);
    for (id <SDWebImageOperation> operation in operations) {
        if (operation) {
            [operation cancel];
        }
    }
    objc_setAssociatedObject(self, &operationArrayKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    TCEND
}

@end
