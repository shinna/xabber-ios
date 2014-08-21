//
//  XBMasterViewController.h
//  xabber
//
//  Created by Dmitry Sobolev on 15/08/14.
//  Copyright (c) 2014 Redsolution LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XBDetailViewController;

#import <CoreData/CoreData.h>

@interface XBMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) XBDetailViewController *detailViewController;

@end
