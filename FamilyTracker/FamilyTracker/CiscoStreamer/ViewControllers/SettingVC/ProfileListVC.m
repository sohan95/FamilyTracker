//
//  ProfileListVC.m
//  CiscoIPICSVideoStreamer
//
//  Created by Apple on 18/11/15.
//  Copyright © 2015 eInfochips. All rights reserved.
//

#import "ProfileListVC.h"
#import "AddProfileVC.h"
#import "Constant.h"

#import "StreamerConfiguration.h"

//#import "AppDelegate.h"

//#import "MediaProfiles+Additional.h"

//#import "MediaProfiles+CoreDataProperties.h"

#define kEditProfileButtonTag   1000
#define kDeleteProfileButtonTag 1001

@interface ProfileListVC ()
{
    NSArray *profileList;
    
    StreamerConfiguration *streamerConfig;
}
@end

@implementation ProfileListVC

@synthesize tableView;
//@synthesize fetchedResultsController = _fetchedResultsController;
//@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
    streamerConfig = [StreamerConfiguration sharedInstance];
    
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    NSError *error;
//    if (![[self fetchedResultsController] performFetch:&error]) {
//        // Update to handle the error appropriately.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        exit(-1);  // Fail
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    profileList = [streamerConfig getProfiles:nil forProfileName:@""];
    [self.tableView reloadData];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSFetchedResultsController
/*
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MediaProfiles" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"profile_id" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    //    [self.tableView reloadData];
    return _fetchedResultsController;
    
}*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    id sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
//    return [sectionInfo numberOfObjects];
    
    return [profileList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:@"profileCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *profileData = [profileList objectAtIndex:indexPath.row];
    
    UILabel *profileNameLabel = (UILabel *)[cell viewWithTag:100];
//    [profileNameLabel setBackgroundColor:[UIColor magentaColor]];
    [profileNameLabel setText:[NSString stringWithFormat:@"Name: %@",[profileData valueForKey:@"name"]]];
    
    UILabel *profileResolutionLabel = (UILabel *)[cell viewWithTag:101];
//    [profileResolutionLabel setBackgroundColor:[UIColor blueColor]];
    [profileResolutionLabel setText:[NSString stringWithFormat:@"Resolution: %@x%@",[profileData valueForKey:@"width"], [profileData valueForKey:@"height"]]];
    
    UILabel *profileFramerateLabel = (UILabel *)[cell viewWithTag:102];
//    [profileFramerateLabel setBackgroundColor:[UIColor yellowColor]];
    [profileFramerateLabel setText:[NSString stringWithFormat:@"Framerate: %@",[profileData valueForKey:@"framerate"]]];
    
    UILabel *profileBitrateLabel = (UILabel *)[cell viewWithTag:103];
//    [profileBitrateLabel setBackgroundColor:[UIColor greenColor]];
    [profileBitrateLabel setText:[NSString stringWithFormat:@"Bitrate: %@",[profileData valueForKey:@"bitrate"]]];
    
//    CGFloat minusVal = ( profileNameLabel.frame.origin.x + 65 + (8 * 2));
    CGFloat minimumWidth = cell.frame.size.width;
    CGFloat minimumHeight = cell.frame.size.height;
    
    UIButton *editButton = (UIButton *)[cell viewWithTag:indexPath.row + kEditProfileButtonTag];
    
    if (editButton == nil) {
        
        editButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [editButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin ];
        editButton.frame = CGRectMake(minimumWidth - 65 - 8, minimumHeight - (30*2) - 35, 65, 30);//profileResolutionLabel.frame.origin.x + profileResolutionLabel.frame.size.width + 8
        //CGRectMake(227, 46, 65, 30);
        //= (UIButton *)[cell.contentView.subviews objectAtIndex:1];
        //        [deleteButton setBackgroundColor:[UIColor greenColor]];
        [editButton setTag:indexPath.row + kEditProfileButtonTag];
        [editButton setTitle:@"Edit" forState:UIControlStateNormal];
        [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [editButton setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(tappedEditProfile:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:editButton];
    }
    
    UIButton *deleteButton = (UIButton *)[cell viewWithTag:indexPath.row + kDeleteProfileButtonTag];
    
    if (deleteButton == nil) {
        
        deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [deleteButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin ];
        deleteButton.frame = CGRectMake(editButton.frame.origin.x, editButton.frame.origin.y + editButton.frame.size.height + 10, 65, 30);
        //CGRectMake(227, 46, 65, 30);
        //= (UIButton *)[cell.contentView.subviews objectAtIndex:1];
        //        [deleteButton setBackgroundColor:[UIColor greenColor]];
        [deleteButton setTag:indexPath.row + kDeleteProfileButtonTag];
        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(tappedDeleteProfile:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:deleteButton];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button Action

- (IBAction)tappedAppProfile:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SettingScreens" bundle:nil];
    AddProfileVC *addProfileVC = [sb instantiateViewControllerWithIdentifier:@"AddProfileVC"];
    addProfileVC.savedProfileDetail = nil;
    [self.navigationController pushViewController:addProfileVC animated:YES];
}

- (IBAction)tappedEditProfile:(id)sender {
//    UIView *contentView = [sender superview];
//    UITableViewCell *cell = [contentView superview];
    
    NSInteger rowIndex = [sender tag] - kEditProfileButtonTag;
    NSDictionary *profile = [profileList objectAtIndex:rowIndex];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SettingScreens" bundle:nil];
    AddProfileVC *addProfileVC = [sb instantiateViewControllerWithIdentifier:@"AddProfileVC"];
    addProfileVC.savedProfileDetail = profile;
    [self.navigationController pushViewController:addProfileVC animated:YES];
}

- (IBAction)tappedDeleteProfile:(id)sender {
    
    NSInteger rowIndex = [sender tag] - kEditProfileButtonTag;
    NSDictionary *profile = [profileList objectAtIndex:rowIndex];
    
    [streamerConfig deleteONVIFMediaProfileDetail:[profile valueForKey:@"profile_id"]];

    [tableView reloadData];
}

@end
