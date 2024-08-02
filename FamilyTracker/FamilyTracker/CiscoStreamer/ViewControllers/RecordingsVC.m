//
//  RecordingsVC.m
//  CiscoIPICSVideoStreamer
//
//  Created by Apple on 09/11/15.
//  Copyright © 2015 AHMLPT0406. All rights reserved.
//

#import "RecordingsVC.h"
#import "StreamRecordedVC.h"
#import "StreamerConfiguration.h"

#import "AppDelegate.h"
#import "Constant.h"

//#import <CFNetwork/CFNetwork.h>

#define kStreamButtonTag 1000
#define kDeleteButtonTag 2000
//#define kUploadButtonTag 3000

//#define kRequestTypeCreateDir   @"create_dir"
//#define kREquestTypeUploadFile  @"upload_file"

@interface RecordingsVC ()
{
    NSMutableArray *recordedVideoStreams;
    /*
    NSArray *selectedFiles;
    
    NSMutableArray *ftpRequests;
    NSMutableArray *uploadedFiles;
    
    BOOL isCancelRequest;
    
    IBOutlet UIBarButtonItem *selectAllBarButton;
    IBOutlet UIBarButtonItem *uploadBarButton;
    
    IBOutlet UIActivityIndicatorView *activityIndicator;
    
    BOOL isAllFileSelected;
    NSString *typeOfRequest;
    */
    
    StreamerConfiguration *streamerConfig;
    

}

@end

@implementation RecordingsVC

@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self restrictRotation:YES];

//    isAllFileSelected = NO;
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    streamerConfig = [StreamerConfiguration sharedInstance];
    
    self.mBProgressHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.mBProgressHUD];
    self.mBProgressHUD.delegate = self;
    self.mBProgressHUD.labelText = @"Connecting To Server...";
    
//    [uploadBarButton setTitle:@"Upload"];
//    [uploadBarButton setAction:@selector(tappedUpload:)];
    
//    selectedFiles = @[];

    //[self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self fetchRecordedFilesData];
}

- (void)fetchRecordedFilesData {
    recordedVideoStreams = (NSMutableArray*)[streamerConfig getAllRecordedFile];
    [self.tableView reloadData];
}

-(void) restrictRotation:(BOOL)restriction
{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    delegate.restrictRotation = restriction;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
//    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [self.navigationController setToolbarHidden:YES animated:YES];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    [self restrictRotation:NO];
    
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    return [recordedVideoStreams count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"recordingFileCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView1 dequeueReusableCellWithIdentifier:CellIdentifier];
////    CustomTableViewCell *cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil){
//        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"recordingFileCell" owner:self options:nil];
//        cell = [nib objectAtIndex:0];
//    }
//    RecordFileData *recordedFile = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDictionary *recordedFile = [recordedVideoStreams objectAtIndex:indexPath.row];
    
    NSString *fileName = [recordedFile valueForKey:@"recordFileName"];
    
    UILabel *fileNameLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *fileSizeLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *fileUploadStatusLabel = (UILabel *)[cell viewWithTag:102];
    
    [fileNameLabel setNumberOfLines:2];
    [fileNameLabel setText:fileName];
    
    long double fileSize = [[recordedFile valueForKey:@"fileSize"] doubleValue];
    NSString *sufix = @"KB";
    NSUInteger loopCount = 0;
    while (fileSize >= 1024) {
        fileSize /= (float)1024;
        loopCount++;
    }
    
    if (loopCount == 1) {
        sufix = @"KB";
    } else if (loopCount == 2) {
        sufix = @"MB";
    } else if (loopCount == 3) {
        sufix = @"GB";
    }
    
    NSString *fileSizeString = [NSString stringWithFormat:@"Size: %.2Lf%@", fileSize, sufix];
    [fileSizeLabel setText:fileSizeString];
    
    NSString *uploadStatus = @"Pendding";
    if ([[recordedFile valueForKey:@"isUploaded"] boolValue]) {
        uploadStatus = @"Done";
    }
    [fileUploadStatusLabel setText:[NSString stringWithFormat:@"Uplaod Stauts: %@",uploadStatus]];
    
    UIButton *streamButton = (UIButton *)[cell viewWithTag:indexPath.row + kStreamButtonTag];
    
    CGFloat minusVal = ( fileNameLabel.frame.origin.x + 65 + (8 * 2));
    CGFloat minimumWidth = self.tableView.frame.size.width - minusVal;
    [fileNameLabel addConstraint:[NSLayoutConstraint constraintWithItem:fileNameLabel
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationLessThanOrEqual
                                                                 toItem:nil
                                                              attribute: NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:minimumWidth]];
    
    if (streamButton == nil) {
        streamButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [streamButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin ];
        streamButton.frame = CGRectMake(fileNameLabel.frame.origin.x + minimumWidth + 8, fileNameLabel.frame.origin.y , 65, 30);
        [streamButton setTag:indexPath.row + kStreamButtonTag];
        [streamButton setTitle:@"Stream" forState:UIControlStateNormal];
        [streamButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [streamButton setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
        [streamButton addTarget:self action:@selector(tappedStream:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:streamButton];
    }
    
    
    UIButton *deleteButton = (UIButton *)[cell viewWithTag:indexPath.row + kDeleteButtonTag];
    
    if (deleteButton == nil) {

        deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [deleteButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin ];
        deleteButton.frame = CGRectMake(streamButton.frame.origin.x, streamButton.frame.origin.y + streamButton.frame.size.height + 7, 65, 30);
        [deleteButton setTag:indexPath.row + kDeleteButtonTag];
        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(tappedDelete:) forControlEvents:UIControlEventTouchUpInside];

        [cell addSubview:deleteButton];
    }
    /*
    NSString *imageName = @"unchecked.png";
    if ([[recordedFile valueForKey:@"isFileSelected"] boolValue]) {
        imageName = @"checked.png";
    }
    UIButton *uploadButton = (UIButton *)[cell viewWithTag:indexPath.row + kUploadButtonTag];
    
    if (uploadButton == nil) {

        uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [uploadButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin ];
        uploadButton.frame = CGRectMake(deleteButton.frame.origin.x - 26, deleteButton.frame.origin.y + deleteButton.frame.size.height + 7, 90, 30);
        [uploadButton setTag:indexPath.row + kUploadButtonTag];
        [[uploadButton titleLabel] setFont:[UIFont systemFontOfSize:15.0]];
        [uploadButton setTitle:@"Upload" forState:UIControlStateNormal];
        [uploadButton setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
        [uploadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [uploadButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
        [uploadButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [uploadButton addTarget:self action:@selector(tappedSelectForUpload:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:uploadButton];
    }
    [uploadButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    */
    //[cell setBackgroundColor:[UIColor clearColor]];
    //[cell.contentView setBackgroundColor:[UIColor clearColor]];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Remove seperator inset
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Button Action

- (IBAction)tappedStream:(id)sender {
    NSLog(@"Stream File");
    
    NSString *errorMessgae = @"";
    if ( (([streamerConfig getWowzaUsername] == nil || [[streamerConfig getWowzaUsername]  length]<=0) ||
         ([streamerConfig getWowzaServerIP] == nil || [[streamerConfig getWowzaServerIP] length]<=0) ||
         ([streamerConfig getWowzaPassword] == nil || [[streamerConfig getWowzaPassword] length]<=0) ||
         ([streamerConfig getWowzaApplication] == nil || [[streamerConfig getWowzaApplication] length]<=0) ||
         ([streamerConfig getWowzaStreamName] == nil || [[streamerConfig getWowzaStreamName] length]<=0)) ) {
            
            errorMessgae = kWowzaServerNotConfigured;
    }
    
    if (errorMessgae.length > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessgae delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        
        return;
    }
    
    NSInteger rowIndex = [sender tag] - kStreamButtonTag;

    NSDictionary *recordedFile = [recordedVideoStreams objectAtIndex:rowIndex];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Record" bundle:nil];
    StreamRecordedVC *streamingVC = [sb instantiateViewControllerWithIdentifier:@"StreamRecordedVC"];
    streamingVC.streamFileDetails = recordedFile;
    [self.navigationController pushViewController:streamingVC animated:YES];
}


- (IBAction)tappedDelete:(id)sender {
    NSLog(@"Delete File");
    
    NSInteger rowIndex = [sender tag] - kDeleteButtonTag;
    NSDictionary *recordedFile = [recordedVideoStreams objectAtIndex:rowIndex];
    
    UIAlertController *alertVC =  [UIAlertController alertControllerWithTitle:@""
                                                                      message:@"Are you sure you want to delete this file?"
                                                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* btnOk = [UIAlertAction
                            actionWithTitle:@"OK"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                //File delete code
                                [alertVC dismissViewControllerAnimated:YES completion:nil];
                                
                                NSString *filePath = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),[recordedFile valueForKey:@"recordFileName"]];
                                NSLog(@"filePath :%@",filePath);
                                NSError *error = nil;
                                [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                                
                                if (error) {
                                    NSLog(@"Error while delete file. Error :%@",error);
                                }
                                else {
                                    [streamerConfig deleteRecordedFile:[recordedFile valueForKey:@"recordFileName"]];
                                    //[RecordFileData deleteFile:recordedFile.recordFileName inContext:_managedObjectContext];
                                    ///
                                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
                                    [recordedVideoStreams removeObjectAtIndex:rowIndex];
                                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationFade];
                                    [self.tableView reloadData];
                                    ///
                                }
                            }];
    
    UIAlertAction* cancelOk = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [alertVC dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alertVC addAction:btnOk];
    [alertVC addAction:cancelOk];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

/*
- (IBAction)tappedSelectForUpload:(id)sender {
    
    NSInteger rowIndex = [sender tag] - kUploadButtonTag;

    NSDictionary *recordedFile = [recordedVideoStreams objectAtIndex:rowIndex];
    
    [streamerConfig updateSelectionForfile:[recordedFile valueForKey:@"recordFileName"]];
    [self fetchRecordedFilesData];
//    [RecordFileData updateSelectionForfile:recordedFile.recordFileName inContext:_managedObjectContext];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"isFileSelected == 1"];
    NSArray *selectedFileArr = [recordedVideoStreams filteredArrayUsingPredicate:pred];
    
    if ([selectedFileArr count] == [recordedVideoStreams count]) {
        isAllFileSelected = YES;
        [selectAllBarButton setTitle:@"UnSelect All"];
    }
    else {
        isAllFileSelected = NO;
        [selectAllBarButton setTitle:@"Select All"];
    }
}
*/

/*
- (IBAction)tappedSelectAll:(id)sender {
    NSLog(@"Select All");
    
    if (!isAllFileSelected) {
        [streamerConfig updateAllFileForSelectFlag:YES];
//        [RecordFileData updateAllFileForSelectFlag:YES inContext:_managedObjectContext];
        [selectAllBarButton setTitle:@"UnSelect All"];
        isAllFileSelected = YES;
    }
    else {
        [streamerConfig updateAllFileForSelectFlag:NO];
//        [RecordFileData updateAllFileForSelectFlag:NO inContext:_managedObjectContext];
        [selectAllBarButton setTitle:@"Select All"];
        isAllFileSelected = NO;
    }
    
    [self fetchRecordedFilesData];
}

- (IBAction)tappedCancel:(id)sender {
    
    self.mBProgressHUD.labelText = @"Upload Canceling...";
    [self.mBProgressHUD show:YES];
    
    isCancelRequest = YES;
    for (FTPRequest *request in ftpRequests) {
        [request cancelRequest];
    }
}

- (IBAction)tappedUpload:(id)sender {
    
    if ( ([streamerConfig getFTPHost] == nil || [[streamerConfig getFTPHost] length]<=0) ||
        ([streamerConfig getFTPUsername] == nil || [[streamerConfig getFTPUsername] length]<=0) ||
        ([streamerConfig getFTPPassword] == nil || [[streamerConfig getFTPPassword] length]<=0) ) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please add FTP setting." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        
        return;
    }
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"isFileSelected == 1"];
    selectedFiles = [recordedVideoStreams filteredArrayUsingPredicate:pred];
    
    if (selectedFiles.count > 0) {
        
        self.mBProgressHUD.labelText = @"File Uploading...";
        [self.mBProgressHUD show:YES];
        
        isCancelRequest = NO;
        uploadedFiles = [NSMutableArray arrayWithCapacity:0];
        ftpRequests = [NSMutableArray arrayWithCapacity:0];
        
        [uploadBarButton setTitle:@"Cancel"];
        [uploadBarButton setAction:@selector(tappedCancel:)];
        
        NSString *serverPath = [streamerConfig getFTPServerPath];
        
        if (serverPath != nil && [serverPath length] > 0) {
            [self listDirectory:serverPath];
        }
        else {
            [self startUploadingSelected:selectedFiles];
        }
    }
}
*/
#pragma mark - User Define Methods

/*
- (void)listDirectory:(NSString *)directoryName {
    
    NSString *ftpServerHost = [self formatedFTPServerURL];
    FTPRequest *ftpRequest = [[FTPRequest alloc] initWithURL:[NSURL URLWithString:ftpServerHost]];
    
    ftpRequest.username = [streamerConfig getFTPUsername];
    ftpRequest.password = [streamerConfig getFTPPassword];
    
    ftpRequest.delegate = self;
    
    [ftpRequest startAsynchronous];
}


- (void)createDirectory:(NSString *)directoryName {
    
    NSString *ftpServerHost = [self formatedFTPServerURL];
    FTPRequest *ftpRequest = [[FTPRequest alloc] initWithURL:[NSURL URLWithString:ftpServerHost]
                                                 toCreateDirectory:directoryName];
    
    ftpRequest.username = [streamerConfig getFTPUsername];
    ftpRequest.password = [streamerConfig getFTPPassword];
    
//    ftpRequest.delegate = self;
    
    [ftpRequest startAsynchronous];
}

- (NSString *)formatedFTPServerURL {
    NSMutableString *serverURL = [NSMutableString stringWithString:[streamerConfig getFTPHost]];
    
    if ([serverURL rangeOfString:@"ftp://"].location == NSNotFound) {
        // Append "ftp://" string, if user not enter
        
        serverURL = [NSMutableString stringWithString:[NSString stringWithFormat:@"ftp://%@",[streamerConfig getFTPHost]]];
    }
    
    [serverURL replaceOccurrencesOfString:@" " withString:@"%20" options:0 range:NSMakeRange(0, [serverURL length])];
    
    return serverURL;
}

- (void)startUploadingSelected:(NSArray *)selectedFileArr {
    
    NSString *serverURL = [self formatedFTPServerURL];
    NSString *serverPath = [streamerConfig getFTPServerPath];
    
    if (serverPath != nil && [serverPath length] > 0) {
        //Append folder path to serverURL
        NSMutableString *dirName = [NSMutableString stringWithString:serverPath];
        
        [dirName replaceOccurrencesOfString:@" " withString:@"%20" options:0 range:NSMakeRange(0, [[streamerConfig getFTPServerPath] length])];
        serverURL = [NSString stringWithFormat:@"%@/%@",serverURL, dirName];
    }
    
    for (NSDictionary *recordedFileData in selectedFileArr) {
        
        NSString *filePath = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),[recordedFileData valueForKey:@"recordFileName"]];
        
        FTPRequest *ftpRequest = [[FTPRequest alloc] initWithURL:[NSURL URLWithString:serverURL]
                                                          toUploadFile:filePath];
        
        ftpRequest.username = [streamerConfig getFTPUsername];
        ftpRequest.password = [streamerConfig getFTPPassword];
        
        // Specify a custom upload file name (optional)
        ftpRequest.customUploadFileName = [filePath lastPathComponent];
        
        // The delegate must implement the FTPRequestDelegate protocol
//        ftpRequest.delegate = self;
        
        [ftpRequests addObject:ftpRequest];
        
        [ftpRequest startAsynchronous];
    }
}
*/

#pragma mark - FTPRequestDelegate Methods
/*
// Required delegate methods
- (void)ftpRequestDidFinish:(FTPRequest *)request {
    
    NSLog(@"Upload finished.");
    
    switch (request.operation) {
        case FTPRequestOperationUpload:
        {
            NSLog(@"Upload finished operation : FTPRequestOperationUpload");
            NSLog(@"Uploaded file name:%@",[request.filePath lastPathComponent]);
            
            [streamerConfig updateUploadFlagForfile:[request.filePath lastPathComponent]];
            [self fetchRecordedFilesData];
//            [RecordFileData updateUploadFlagForfile:[request.filePath lastPathComponent] inContext:appDelegate.managedObjectContext];
            
            [uploadedFiles addObject:[request.filePath lastPathComponent]];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@ file uploaded",[request.filePath lastPathComponent]] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            
            if (selectedFiles.count == uploadedFiles.count) {
                // All File uploaded
                [self.mBProgressHUD hide:YES];
                
                [activityIndicator stopAnimating];
//                [uploadBarButton setTitle:@"Upload"];
//                [uploadBarButton setAction:@selector(tappedUpload:)];
            }
        }
            break;
        case FTPRequestOperationCreateDirectory:
        {
            NSLog(@"Upload finished operation : FTPRequestOperationCreateDirectory");
            [self startUploadingSelected:selectedFiles];
        }
            break;
        case FTPRequestOperationDirectoryListing:
        {
            NSLog(@"Fiished Listing.");
            NSLog(@"Directories:%@",request.listEntries);
            
            NSString *directoryName = [streamerConfig getFTPServerPath];
            BOOL isDirExist = NO;
            for (NSDictionary *dicrectory in request.listEntries) {
                NSLog(@"directory name:%@",[dicrectory objectForKey:(id) kCFFTPResourceName]);
                
                NSString *serverDirName = [dicrectory objectForKey:(id) kCFFTPResourceName];
                if ([directoryName isEqualToString:serverDirName]) {
                    NSLog(@"IN IN IN IN IFFFFFFFFF Found Directory==================");
                    isDirExist = YES;
                    break;
                }
            }
            
            if (!isDirExist) {
                [self createDirectory:directoryName];
            }
            else
            {
                [self startUploadingSelected:selectedFiles];
            }
        }
            break;
        default:
            break;
    }
}

- (void)ftpRequest:(FTPRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Upload failed: %@", [error localizedDescription]);
    
    switch (request.operation) {
        case FTPRequestOperationUpload:
        {
            if (!isCancelRequest) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ failed to upload",[request.filePath lastPathComponent]] message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alert show];
            }else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ failed to upload",[request.filePath lastPathComponent]] message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alert show];
            }
            
            [uploadedFiles addObject:[request.filePath lastPathComponent]];
            
            if (selectedFiles.count == uploadedFiles.count) {
                // All File uploaded
                [self uploadCompleted];
            }
        }
            break;
        case FTPRequestOperationCreateDirectory:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload failed" message:[NSString stringWithFormat:@"Failed to create the directory \"%@\"",[streamerConfig getFTPServerPath]] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            
            [self uploadCompleted];
        }
            break;
        case FTPRequestOperationDirectoryListing:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload failed" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            [self uploadCompleted];
        }
            break;
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload failed" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            [self uploadCompleted];
        }
            break;
    }
}

- (void)uploadCompleted {
    [self.mBProgressHUD hide:YES];
    [activityIndicator stopAnimating];
    
//    [uploadBarButton setTitle:@"Upload"];
//    [uploadBarButton setAction:@selector(tappedUpload:)];
}

// Optional delegate methods
- (void)ftpRequestWillStart:(FTPRequest *)request {
    
    NSLog(@"Will transfer %llu bytes.", request.fileSize);
}

- (void)ftpRequest:(FTPRequest *)request didWriteBytes:(NSUInteger)bytesWritten {
    
    NSLog(@"Transferred: %d", bytesWritten);
}

- (void)ftpRequest:(FTPRequest *)request didChangeStatus:(FTPRequestStatus)status {
    
    switch (status) {
        case FTPRequestStatusOpenNetworkConnection:
            NSLog(@"Opened connection.");
            break;
        case FTPRequestStatusReadingFromStream:
            NSLog(@"Reading from stream...");
            break;
        case FTPRequestStatusWritingToStream:
            NSLog(@"Writing to stream...");
            break;
        case FTPRequestStatusClosedNetworkConnection:
            NSLog(@"Closed connection.");
            break;
        case FTPRequestStatusError:
            NSLog(@"Error occurred.");
            break;
        case FTPRequestStatusNone:
            NSLog(@"Status None.");
            break;
    }
}
*/

@end
