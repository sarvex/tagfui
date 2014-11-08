/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#ifndef BeefOBrady_Header_h
#define BeefOBrady_Header_h

#ifndef informationToSend
#define informationToSend [NSString stringWithFormat:@"screen: %s in method : %s",strrchr(__FILE__,'/'),__PRETTY_FUNCTION__]
#endif

#ifndef GoogleAnalyticsInformation
#define GoogleAnalyticsInformation 	NSError *err_;\
if (![[GANTracker sharedTracker] trackPageview:informationToSend withError:&err_])\
{\
	NSLog(@"Error: %@", err_);\
}
#endif



/////////////////////MACROS TO BE VISIBLE THROUGHT THE APPLICATION//////////////////////////////


#ifndef UseTryCatch
#define UseTryCatch 1//use 0 to disable and 1 to enable the try catch throughout the application


//Warning:Do not Enable this Macro for general purpose...use it if u are intentionally dubbugging for some unexpected method calls
#ifndef UsePTMName
#define UsePTMName 0//use 0 to disable and 1 to enable printing the method name throughout the application


#if UseTryCatch


#if UsePTMName
#define TCSTART @try{NSLog(@"\n%s\n",__PRETTY_FUNCTION__);
#else
#define TCSTART @try{
#endif

#define TCEND  }@catch(NSException *e){NSLog(@"\n\n\n\n\n\n\
\n\n|EXCEPTION FOUND HERE...PLEASE DO NOT IGNORE\
\n\n|FILE NAME         %s\
\n\n|LINE NUMBER       %d\
\n\n|METHOD NAME       %s\
\n\n|EXCEPTION REASON  %@\
\n\n\n\n\n\n\n",strrchr(__FILE__,'/'),__LINE__, __PRETTY_FUNCTION__,e);};


#else

#define TCSTART
#define TCEND

#endif
#endif


#endif

/////////////////////MACROS TO BE VISIBLE THROUGHT THE APPLICATION//////////////////////////////

#define CURRENT_DEVICE_VERSION [[UIDevice currentDevice]systemVersion].floatValue

#define UITextAlignmentCenter (CURRENT_DEVICE_VERSION<6.0)?(UITextAlignmentCenter):(NSTextAlignmentCenter)
#define UITextAlignmentLeft (CURRENT_DEVICE_VERSION<6.0)?(UITextAlignmentLeft):(NSTextAlignmentLeft)
#define UITextAlignmentRight (CURRENT_DEVICE_VERSION<6.0)?(UITextAlignmentRight):(NSTextAlignmentRight)

#define UILineBreakModeWordWrap ((CURRENT_DEVICE_VERSION<6.0)?(UILineBreakModeWordWrap):(NSLineBreakByWordWrapping))
#define UILineBreakModeTailTruncation ((CURRENT_DEVICE_VERSION<6.0)?(UILineBreakModeTailTruncation):(NSLineBreakByTruncatingTail))

#define tabTitlesFontName @"Helvetica-Bold"
#define titleFontName   @"Helvetica-Bold"
#define descriptionTextFontName @"Helvetica"
#define headerTitleFontName @"FetteEngD"
#define dateFontName    @"Helvetica-Oblique"

#define titleFontSize   20.0f
#define descriptionTextFontSize 10.0f

#define SeeallCMTsSize 15.0f
#define CMNTSize 14.0f
#define CELL_CONTENT_WIDTH 300.0f
#define CELL_CONTENT_MARGIN 5.0f


#define HEADER_WIDTH 310.0f
#define HEADER_MARGIN 5.0f

#define HEADER_MARGIN_WIDTH 5
#define HEADER_MARGIN_HEIGHT 5


//Refresh the table on pull of table
#define kReleaseToReloadStatus	0
#define kPullToReloadStatus		1
#define kLoadingStatus			2

//for Zoom in and out the map
#define TIME_FOR_SHRINKING 0.61f // Has to be different from SPEED_OF_EXPANDING and has to end in 'f'
#define TIME_FOR_EXPANDING 0.60f // Has to be different from SPEED_OF_SHRINKING and has to end in 'f'
#define SCALED_DOWN_AMOUNT 0.01  // For example, 0.01 is one hundredth of the normal size

#define APP_URL @"http://www.wootag.com/mobile.php/wings"
#define AYANLYTICS_URL @"http://www.wootag.com"

#define kOAuthTwitterConsumerKey @"THd3F8kvBqtTDlbG93Cy2Q"
#define kOAuthTwitterConsumerSecret @"lFLkOqXU4rE4oiANshILirkxA39WIPa8A1AI9OYCQ1A"

#define kGooglePlusClientId @"436353461628-fcp1mfisjfv0mbp05bl8sbphhdvp4jsa.apps.googleusercontent.com"
#define FBID @"fb1402356783355746"

#endif
