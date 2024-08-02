//
//  ProfileListVC.h
//  CiscoIPICSVideoStreamer
//
//  Created by Apple on 18/11/15.
//  Copyright © 2015 eInfochips. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileListVC : UITableViewController //<NSFetchedResultsControllerDelegate>
{
    IBOutlet UITableView *tableView;
}
@property (nonatomic, retain) IBOutlet UITableView *tableView;
//
//@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
//@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
