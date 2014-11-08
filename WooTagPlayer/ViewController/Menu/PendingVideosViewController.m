/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "PendingVideosViewController.h"
#import "ListOfVideoUploadsCell.h"

@interface PendingVideosViewController ()

@end

@implementation PendingVideosViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    self.view.backgroundColor = [appDelegate colorWithHexString:@"f8f8f8"];
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    
    [videosTableView registerNib:[UINib nibWithNibName:@"ListOfVideoUploadsCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ListOfVideoUploadsCellID"];
    videosTableView.backgroundColor = [UIColor clearColor];
    videosTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    videosTableView.separatorColor = [appDelegate colorWithHexString:@"11a3e7"];
    
    refreshView = [[RefreshView alloc] initWithFrame:
                   CGRectMake(videosTableView.frame.origin.x,- videosTableView.bounds.size.height,
                              videosTableView.frame.size.width, videosTableView.bounds.size.height)];
    [videosTableView addSubview:refreshView];
    
    
    TCEND
}

- (void)viewWillAppear:(BOOL)animated {
   [self refreshScreenByFetchingPendingVideos]; 
}
- (void)refreshScreenByFetchingPendingVideos {
    TCSTART
    NSLog(@"Refresh called");
    [pendingVideosArray removeAllObjects];
    pendingVideosArray = nil;
    pendingVideosArray = [[NSMutableArray alloc] initWithArray:[appDelegate.managedObjectContext fetchObjectsForEntityName:@"Video" withPredicate:[NSPredicate predicateWithFormat:@"waitingToUpload == %d && userId == %@",TRUE,appDelegate.loggedInUser.userId]]];
    [videosTableView reloadData];
    [self dataSourceDidFinishLoadingNewData];
    TCEND
}

- (void)uploadPercentage:(NSInteger)percent ofVideo:(NSString *)clientVideoId completed:(BOOL)completed {
    TCSTART
    for (Video *video in pendingVideosArray) {
        if ([video.clientId isEqualToString:clientVideoId]) {
            video.uploadPercent = [NSNumber numberWithInt:percent];
            NSInteger index = [pendingVideosArray indexOfObject:video];
            if (percent == 100 && !completed) {
            } else if (percent == 100 && completed) {
                video.isUploaded = [NSNumber numberWithBool:YES];
                
            }
            
            ListOfVideoUploadsCell *cell = (ListOfVideoUploadsCell *)[videosTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];

            [self setStatusLabelOfCell:cell andVideo:video];
        
            break;
        }
    }
    TCEND
}

- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0  && self.view.frame.size.height == appDelegate.window.frame.size.height) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.size.height = viewBounds.size.height - topBarOffset;
        self.view.frame = CGRectMake(viewBounds.origin.x, topBarOffset, viewBounds.size.width, viewBounds.size.height);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (IBAction)onClickOfBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return pendingVideosArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    static NSString *cellIdentifier = @"ListOfVideoUploadsCellID";
    
    ListOfVideoUploadsCell *cell = (ListOfVideoUploadsCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[ListOfVideoUploadsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Video *video = [pendingVideosArray objectAtIndex:indexPath.row];
   
    cell.videoTitleLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
    cell.videoCreatedTimeLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
    cell.uploadingLbl.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    [self setStatusLabelOfCell:cell andVideo:video];

    cell.percentageLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setWidthOfTitleViewOfTableViewCell:cell andVideo:video];
    return cell;
    TCEND
}

- (void)setStatusLabelOfCell:(ListOfVideoUploadsCell *)cell andVideo:(Video *)video {
    TCSTART
    cell.deleteBtn.hidden = YES;
    cell.deleteBtn.frame = CGRectMake(209, 35, 81, 20);
    cell.retryBtn.hidden = YES;
    if ([video.isUploaded boolValue]) {
        cell.percentageLbl.text = @"100 %";
        cell.uploadingLbl.text = @"UPLOADED";
        cell.percentageLbl.frame = CGRectMake(95, 35, 41, 21);
        cell.uploadingLbl.frame = CGRectMake(145, 35, 81, 20);
    } else {
        cell.percentageLbl.text = [NSString stringWithFormat:@"%d %%",[video.uploadPercent intValue]];
        if (([video.fileUploadCompleted boolValue] || [video.uploadPercent intValue] == 100) && [video.uploadPercent integerValue] != 0) {
            if (!video.videoPublishingFailed.boolValue) {
                cell.uploadingLbl.text = @"UPLOADED. WAITING TO PUBLISH";
                cell.percentageLbl.frame = CGRectMake(43, 35, 41, 21);
                cell.uploadingLbl.frame = CGRectMake(87, 35, 196, 20);
                cell.deleteBtn.hidden = YES;
            } else {
                [self setFramesForAllUIObjectsOfFailedVideos:cell isCheckSumFailed:NO];
            }
        } else {
            if (video.checkSumFailed.boolValue) {
                [self setFramesForAllUIObjectsOfFailedVideos:cell isCheckSumFailed:YES];
            } else {
                if ([video.uploadPercent intValue] != 0) {
                    cell.uploadingLbl.text = @"UPLOADING";
                    cell.deleteBtn.hidden = YES;
                } else {
                    cell.uploadingLbl.text = @"WAITING TO UPLOAD";
                    cell.deleteBtn.hidden = NO;
                    [cell.deleteBtn removeTarget:self action:@selector(onClickOfFailedVideoDeleteBtn: withEvent:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.deleteBtn addTarget:self action:@selector(onClickOfVideoDeleteBtn: withEvent:) forControlEvents:UIControlEventTouchUpInside];
                }
                
                cell.percentageLbl.frame = CGRectMake(31, 35, 41, 21);
                cell.uploadingLbl.frame = CGRectMake(81, 35, 120, 20);
            }
        }
    }
    TCEND
}

- (void)setFramesForAllUIObjectsOfFailedVideos:(ListOfVideoUploadsCell *)cell isCheckSumFailed:(BOOL)checkSumFailed {
    TCSTART
    [cell.deleteBtn removeTarget:self action:@selector(onClickOfVideoDeleteBtn: withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteBtn addTarget:self action:@selector(onClickOfFailedVideoDeleteBtn: withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [cell.retryBtn addTarget:self action:@selector(onClickOfFailedVideoRetryBtn: withEvent:) forControlEvents:UIControlEventTouchUpInside];
    if (checkSumFailed) {
        cell.uploadingLbl.text = @"UPLOAD FAILED";
        cell.percentageLbl.frame = CGRectMake(2, 35, 41, 21);
        cell.uploadingLbl.frame = CGRectMake(48, 35, 110, 20);
        cell.retryBtn.frame = CGRectMake(164, 35, 72, 20);
        cell.deleteBtn.frame = CGRectMake(242, 35, 72, 20);
        cell.deleteBtn.hidden = NO;
        cell.retryBtn.hidden = NO;
    } else {
        cell.uploadingLbl.text = @"PUBLISHING FAILED";
        cell.percentageLbl.frame = CGRectMake(2, 35, 41, 21);
        cell.uploadingLbl.frame = CGRectMake(48, 35, 110, 20);
        cell.retryBtn.frame = CGRectMake(164, 35, 72, 20);
        cell.deleteBtn.frame = CGRectMake(242, 35, 72, 20);
        cell.deleteBtn.hidden = NO;
        cell.retryBtn.hidden = NO;
    }
    TCEND
}

#pragma mark Delete video before trying to uplaod
- (void)onClickOfVideoDeleteBtn:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
    if ([self isNotNull:indexPath]) {
        Video *video = [pendingVideosArray objectAtIndex:indexPath.row];
        [self removeVideofileAndCompressedVideofileFromDocuments:video];
    }
    TCEND
}

- (void)removeVideofileAndCompressedVideofileFromDocuments:(Video *)video {
    TCSTART
    NSString *documentsPath = [appDelegate getApplicationDocumentsDirectoryAsString];
    documentsPath = [NSString stringWithFormat:@"%@/mediumQualityVideo%@.mov",documentsPath,video.clientId];
    
    // Remove file at path from filemanager
    if ([[NSFileManager defaultManager] fileExistsAtPath:video.path]) {
        [[NSFileManager defaultManager] removeItemAtPath:video.path error:Nil];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:documentsPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:documentsPath error:Nil];
    }
    [pendingVideosArray removeObject:video];
    
    if ([self isNotNull:video]) {
        [[DataManager sharedDataManager] deleteVideo:video];
        [[DataManager sharedDataManager] deleteAllTagsWhereClientVideoId:[NSNumber numberWithInt:video.clientId.intValue]];
    }
    [self refreshScreenByFetchingPendingVideos];
    TCEND
}

#pragma mark Delete video After fail to upload
- (void)onClickOfFailedVideoDeleteBtn:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
    if ([self isNotNull:indexPath]) {
        Video *video = [pendingVideosArray objectAtIndex:indexPath.row];
        if ([self isNotNull:video] && ((video.isLibraryVideo.boolValue && video.filterNumber.intValue != 1) || !video.isLibraryVideo.boolValue)) {
            library = [[ALAssetsLibrary alloc] init];
            __block ALAssetsGroup* groupToAddTo;
            __unsafe_unretained typeof(self) weakSelf = self;
            __unsafe_unretained typeof(library) weakLibrary = library;
            [library addAssetsGroupAlbumWithName:@"Wootag" resultBlock:^(ALAssetsGroup *group)
             {
                 if (group) {
                     groupToAddTo = group;
                     [weakSelf saveVideoToLibraryWithvideo:video groupName:groupToAddTo];
                 } else {
                     [weakLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                            usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Wootag"]) {
                                                    groupToAddTo = group;
                                                    [weakSelf saveVideoToLibraryWithvideo:video groupName:groupToAddTo];
                                                }
                                            }
                                          failureBlock:^(NSError* error) {
                                              [weakSelf saveVideoToLibraryWithvideo:video groupName:nil];
                                          }];
                 }
                 
             } failureBlock:^(NSError *error) {
                 NSLog(@"Error: Adding on Folder");
                 [weakSelf saveVideoToLibraryWithvideo:video groupName:nil];
             }];

        } else if ([self isNotNull:video]) {
            [self removeVideofileAndCompressedVideofileFromDocuments:video];
        }
    }
    TCEND
}

- (void)saveVideoToLibraryWithvideo:(Video *)video groupName:(ALAssetsGroup *)groupToAddTo {
    TCSTART
    NSURL *filePathURL = [NSURL fileURLWithPath:video.path isDirectory:NO];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:filePathURL]) {
        [ShowAlert showAlert:@"Dont worry your video will save phone library"];
        appDelegate.isVideoRecording = YES;
        if (appDelegate.isVideoExporting) {
            isExporting = appDelegate.isVideoExporting;
            [appDelegate cancelExport];
        }
        [library writeVideoAtPathToSavedPhotosAlbum:filePathURL completionBlock:^(NSURL *assetURL, NSError *error) {
            
            if (error) {
                NSLog(@"file saving error :%@",error);
            } else {
                // try to get the asset
                if ([self isNotNull:groupToAddTo]) {
                    [library assetForURL:assetURL
                             resultBlock:^(ALAsset *asset) {
                                 // assign the photo to the album
                                 [groupToAddTo addAsset:asset];
                                 NSLog(@"Added %@ to %@", [[asset defaultRepresentation] filename], groupToAddTo);
                             }
                            failureBlock:^(NSError* error) {
                                NSLog(@"failed to retrieve image asset:\nError: %@ ", [error localizedDescription]);
                            }];
                }
                
                [self removeVideofileAndCompressedVideofileFromDocuments:video];
            }
            
            appDelegate.isVideoRecording = NO;
            if (isExporting) {
                isExporting = NO;
                [appDelegate uploadVideo];
            }
            library = nil;
        }];
    }
    TCEND
}
#pragma mark video retry
- (void)onClickOfFailedVideoRetryBtn:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
    if ([self isNotNull:indexPath]) {
        Video *video = [pendingVideosArray objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            if (video.checkSumFailed.boolValue) {
                video.checkSumFailed = [NSNumber numberWithBool:NO];
            } else {
                video.hitCount = [NSNumber numberWithInt:1];
                video.videoPublishingFailed = [NSNumber numberWithBool:NO];
            }
            video.loadingViewHidden = [NSNumber numberWithBool:NO];
            [[DataManager sharedDataManager] saveChanges];
//            [pendingVideosArray replaceObjectAtIndex:indexPath.row withObject:video];
            [self refreshScreenByFetchingPendingVideos];
            [appDelegate uploadVideo];
        }
    }
    TCEND
}

- (void)setWidthOfTitleViewOfTableViewCell:(ListOfVideoUploadsCell *)cell andVideo:(Video *)video {
    TCSTART
    cell.titleView.backgroundColor = [UIColor clearColor];
    CGFloat titleWidth;
    CGFloat dateWidth;
    CGSize titleSize = [video.title sizeWithFont:[UIFont fontWithName:titleFontName size:14] constrainedToSize:CGSizeMake(210, 21) lineBreakMode:NSLineBreakByWordWrapping];
//    titleWidth = titleSize.width;
    titleWidth = ((titleSize.width<210)?(titleSize.width + 10):titleSize.width);
    NSString *dateStr;
    if ([self isNotNull:video.creationTime]) {
        dateStr = [NSString stringWithFormat:@"| %@",[appDelegate relativeVideoCreatedDateString:video.creationTime]];
    }
    
    CGSize dateSize;
    if ([self isNotNull:dateStr]) {
       dateSize = [dateStr sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:12] constrainedToSize:CGSizeMake(95, 21) lineBreakMode:NSLineBreakByWordWrapping];
    }
//    dateWidth = dateSize.width;
    dateWidth = ((dateSize.width<95)?(dateSize.width + 5) : dateSize.width);
    
    NSLog(@"Date Size :%f TitleSize :%f", dateWidth, titleWidth);
   
    cell.titleView.frame = CGRectMake((320 - (titleWidth + dateWidth))/2, 10, (titleWidth + dateWidth), 21);
    cell.videoTitleLbl.frame = CGRectMake(0, 0, titleWidth, 21);
    cell.videoTitleLbl.text = video.title;
    cell.videoCreatedTimeLbl.frame = CGRectMake(cell.videoTitleLbl.frame.origin.x + cell.videoTitleLbl.frame.size.width, 0, dateWidth, 21);
    cell.videoCreatedTimeLbl.text = dateStr;
    TCEND
}

//- (NSMutableAttributedString *)formatTitleMessageText:(Video *)video {
//    TCSTART
//    if ([self isNotNull:video.title]) {
//        NSMutableAttributedString *commentAttributedString = nil;
//        
//        NSRange boldStrRange  = NSMakeRange(0, 0);
//        NSString *dateStr;
//        if ([self isNotNull:video.creationTime]) {
//            dateStr = [NSString stringWithFormat:@" | %@",[appDelegate relativeDateString:video.creationTime]];
//        }
//        
//        NSMutableString *rowString = [[NSMutableString alloc]init];
//        [rowString appendString:video.title];
//        [rowString appendString:dateStr?:@""];
//        commentAttributedString = [[NSMutableAttributedString alloc] initWithString:rowString];
//        [commentAttributedString addAttribute:(id)kCTForegroundColorAttributeName
//                                  value:(__bridge id)[appDelegate colorWithHexString:@"11a3e7"].CGColor
//                                  range:[rowString rangeOfString:rowString]];
//        CFStringRef _boldFontName = (__bridge_retained CFStringRef) titleFontName;
//        CFStringRef _normalFontName = (__bridge_retained CFStringRef) descriptionTextFontName;
//        CTFontRef HeliveticaBold = CTFontCreateWithName(_boldFontName, 14, NULL);
//        CTFontRef HeliveticaRegular = CTFontCreateWithName(_normalFontName, 12, NULL);
//        
//        [commentAttributedString addAttribute:(id)kCTFontAttributeName
//                               value:(__bridge id)HeliveticaRegular
//                               range:[rowString rangeOfString:rowString]];
//        
//        boldStrRange = [rowString rangeOfString:video.title];
//
//        if(boldStrRange.location != NSNotFound && boldStrRange.length > 0) {
//            [commentAttributedString addAttribute:(id)kCTFontAttributeName
//                                            value:(__bridge id)HeliveticaBold
//                                            range:boldStrRange];
//        }
//        CFRelease(HeliveticaBold);
//        CFRelease(HeliveticaRegular);
//        
//        return commentAttributedString;
//    } else {
//        return nil;
//    }
//    
//    TCEND
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    @try {
        // NSLog(@"scrollViewDidScroll with offset %f",scrollView.contentOffset.y);
        if (reloading) return;
        
        if (checkForRefresh ) {
            if (refreshView.isFlipped && scrollView.contentOffset.y > -45.0f && scrollView.contentOffset.y < 0.0f && !reloading) {
                [refreshView flipImageAnimated:YES];
                [refreshView setStatus:kPullToReloadStatus];
                
            } else if (!refreshView.isFlipped && scrollView.contentOffset.y < -45.0f) {
                [refreshView flipImageAnimated:YES];
                [refreshView setStatus:kReleaseToReloadStatus];
            }
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    @try {
        if (reloading) return;
        
        if (scrollView.contentOffset.y <= -45.0f) {
            [self showReloadAnimationAnimated:YES];
            [self refreshUploadVideos];
        }
            checkForRefresh = NO;
      
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}



- (void) showReloadAnimationAnimated:(BOOL)animated
{
    @try {
        reloading = YES;
        [refreshView toggleActivityView:YES];
        
        if (animated ) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
            videosTableView.contentInset = UIEdgeInsetsMake(40.0f, 0.0f, 0.0f, 0.0f);
            [UIView commitAnimations];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}

- (void)dataSourceDidFinishLoadingNewData {
    @try {
        reloading = NO;
        [refreshView flipImageAnimated:NO];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        [videosTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [refreshView setStatus:kPullToReloadStatus];
        [refreshView toggleActivityView:NO];
        [UIView commitAnimations];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)refreshUploadVideos {
    [self performSelector:@selector(refreshScreenByFetchingPendingVideos) withObject:nil afterDelay:0.3];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
