/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FirstTimeUserExperience : NSManagedObject

@property (nonatomic, retain) NSNumber * videoUploaded;
@property (nonatomic, retain) NSNumber * startRecord;
@property (nonatomic, retain) NSNumber * recording;
@property (nonatomic, retain) NSNumber * pause;
@property (nonatomic, retain) NSNumber * selectFilter;
@property (nonatomic, retain) NSNumber * selectedFilter;
@property (nonatomic, retain) NSNumber * tagged;
@property (nonatomic, retain) NSNumber * selectedTagBtn;
@property (nonatomic, retain) NSNumber * placeTagMarker;
@property (nonatomic, retain) NSNumber * enteredTagExp;
@property (nonatomic, retain) NSNumber * tagLinked;
@property (nonatomic, retain) NSNumber * selectedColorNTime;
@property (nonatomic, retain) NSNumber * selectedConnections;
@property (nonatomic, retain) NSNumber * tagCreationDone;
@property (nonatomic, retain) NSNumber * firstTimePlaysOthersVideo;
@property (nonatomic, retain) NSNumber * tagOnOthersVideo;
@property (nonatomic, retain) NSNumber * tagOrLater;
@property (nonatomic, retain) NSNumber * openOthersVideo;
@end
