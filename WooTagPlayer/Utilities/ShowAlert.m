/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "ShowAlert.h"


@implementation ShowAlert

+ (void) showAlert:(NSString *)alertMessage {
	
	//NSLog(@"message: %@",alertMessage);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message: alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	
	[alert show];
	
}

+ (void) showWarning:(NSString *)alertMessage {
	
	//NSLog(@"message: %@",alertMessage);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message: alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	
	[alert show];	
}

+ (void) showError:(NSString *)alertMessage {
	
    if ([alertMessage isKindOfClass:[NSString class]]) {
       // NSLog(@"message: %@",alertMessage);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];	

    }
}

@end
