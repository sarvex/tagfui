/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "SBJsonWriter.h"
#import "SBJsonStreamWriter.h"
#import "SBJsonStreamWriterAccumulator.h"


@interface SBJsonWriter ()
@property (copy) NSString *error;
@end

@implementation SBJsonWriter

@synthesize sortKeys;
@synthesize humanReadable;

@synthesize error;
@synthesize maxDepth;

- (id)init {
    self = [super init];
    if (self) {
        self.maxDepth = 32u;        
    }
    return self;
}


- (NSString*)stringWithObject:(id)value {
	NSData *data = [self dataWithObject:value];
	if (data)
		return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return nil;
}	

- (NSString*)stringWithObject:(id)value error:(NSError**)error_ {
    NSString *tmp = [self stringWithObject:value];
    if (tmp)
        return tmp;
    
    if (error_) {
		NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:error, NSLocalizedDescriptionKey, nil];
        *error_ = [NSError errorWithDomain:@"org.brautaset.SBJsonWriter.ErrorDomain" code:0 userInfo:ui];
	}
	
    return nil;
}

- (NSData*)dataWithObject:(id)object {	
    self.error = nil;

    SBJsonStreamWriterAccumulator *accumulator = [[SBJsonStreamWriterAccumulator alloc] init];
    
	SBJsonStreamWriter *streamWriter = [[SBJsonStreamWriter alloc] init];
	streamWriter.sortKeys = self.sortKeys;
	streamWriter.maxDepth = self.maxDepth;
	streamWriter.humanReadable = self.humanReadable;
    streamWriter.delegate = accumulator;
	
	BOOL ok = NO;
	if ([object isKindOfClass:[NSDictionary class]])
		ok = [streamWriter writeObject:object];
	
	else if ([object isKindOfClass:[NSArray class]])
		ok = [streamWriter writeArray:object];
		
	else if ([object respondsToSelector:@selector(proxyForJson)])
		return [self dataWithObject:[object proxyForJson]];
	else {
		self.error = @"Not valid type for JSON";
		return nil;
	}
	
	if (ok)
		return accumulator.data;
	
	self.error = streamWriter.error;
	return nil;	
}
	
	
@end
