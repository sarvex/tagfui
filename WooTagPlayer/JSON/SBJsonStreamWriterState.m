/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "SBJsonStreamWriterState.h"
#import "SBJsonStreamWriter.h"

#define SINGLETON \
+ (id)sharedInstance { \
    static id state; \
    if (!state) state = [[self alloc] init]; \
    return state; \
}


@implementation SBJsonStreamWriterState
+ (id)sharedInstance { return nil; }
- (BOOL)isInvalidState:(SBJsonStreamWriter*)writer { return NO; }
- (void)appendSeparator:(SBJsonStreamWriter*)writer {}
- (BOOL)expectingKey:(SBJsonStreamWriter*)writer { return NO; }
- (void)transitionState:(SBJsonStreamWriter *)writer {}
- (void)appendWhitespace:(SBJsonStreamWriter*)writer {
	[writer appendBytes:"\n" length:1];
	for (NSUInteger i = 0; i < writer.stateStack.count; i++)
	    [writer appendBytes:"  " length:2];
}
@end

@implementation SBJsonStreamWriterStateObjectStart

SINGLETON

- (void)transitionState:(SBJsonStreamWriter *)writer {
	writer.state = [SBJsonStreamWriterStateObjectValue sharedInstance];
}
- (BOOL)expectingKey:(SBJsonStreamWriter *)writer {
	writer.error = @"JSON object key must be string";
	return YES;
}
@end

@implementation SBJsonStreamWriterStateObjectKey

SINGLETON

- (void)appendSeparator:(SBJsonStreamWriter *)writer {
	[writer appendBytes:"," length:1];
}
@end

@implementation SBJsonStreamWriterStateObjectValue

SINGLETON

- (void)appendSeparator:(SBJsonStreamWriter *)writer {
	[writer appendBytes:":" length:1];
}
- (void)transitionState:(SBJsonStreamWriter *)writer {
    writer.state = [SBJsonStreamWriterStateObjectKey sharedInstance];
}
- (void)appendWhitespace:(SBJsonStreamWriter *)writer {
	[writer appendBytes:" " length:1];
}
@end

@implementation SBJsonStreamWriterStateArrayStart

SINGLETON

- (void)transitionState:(SBJsonStreamWriter *)writer {
    writer.state = [SBJsonStreamWriterStateArrayValue sharedInstance];
}
@end

@implementation SBJsonStreamWriterStateArrayValue

SINGLETON

- (void)appendSeparator:(SBJsonStreamWriter *)writer {
	[writer appendBytes:"," length:1];
}
@end

@implementation SBJsonStreamWriterStateStart

SINGLETON


- (void)transitionState:(SBJsonStreamWriter *)writer {
    writer.state = [SBJsonStreamWriterStateComplete sharedInstance];
}
- (void)appendSeparator:(SBJsonStreamWriter *)writer {
}
@end

@implementation SBJsonStreamWriterStateComplete

SINGLETON

- (BOOL)isInvalidState:(SBJsonStreamWriter*)writer {
	writer.error = @"Stream is closed";
	return YES;
}
@end

@implementation SBJsonStreamWriterStateError

SINGLETON

@end

