/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "SBJsonParser.h"
#import "SBJsonStreamParser.h"
#import "SBJsonStreamParserAdapter.h"
#import "SBJsonStreamParserAccumulator.h"

@implementation SBJsonParser

@synthesize maxDepth;
@synthesize error;

- (id)init {
    self = [super init];
    if (self)
        self.maxDepth = 32u;
    return self;
}


#pragma mark Methods

- (id)objectWithData:(NSData *)data {

    if (!data) {
        self.error = @"Input was 'nil'";
        return nil;
    }

	SBJsonStreamParserAccumulator *accumulator = [[SBJsonStreamParserAccumulator alloc] init];
    
    SBJsonStreamParserAdapter *adapter = [[SBJsonStreamParserAdapter alloc] init];
    adapter.delegate = accumulator;
	
	SBJsonStreamParser *parser = [[SBJsonStreamParser alloc] init];
	parser.maxDepth = self.maxDepth;
	parser.delegate = adapter;
	
	switch ([parser parse:data]) {
		case SBJsonStreamParserComplete:
            return accumulator.value;
			break;
			
		case SBJsonStreamParserWaitingForData:
		    self.error = @"Unexpected end of input";
			break;

		case SBJsonStreamParserError:
		    self.error = parser.error;
            NSLog(@"got an error while parsing the json object is %@",self.error);
			break;
	}
	
	return nil;
}

- (id)objectWithString:(NSString *)repr {
	return [self objectWithData:[repr dataUsingEncoding:NSUTF8StringEncoding]];
}

- (id)objectWithString:(NSString*)repr error:(NSError**)error_ {
	id tmp = [self objectWithString:repr];
    if (tmp)
        return tmp;
    
    if (error_) {
		NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:error, NSLocalizedDescriptionKey, nil];
        *error_ = [NSError errorWithDomain:@"org.brautaset.SBJsonParser.ErrorDomain" code:0 userInfo:ui];
	}
	
    return nil;
}

@end
