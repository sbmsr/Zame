//
//  PeopleNearbyViewController.h
//  Zame
//
//  Created by Leonard Loo on 20/4/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PeopleNearbyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *listOfPeopleByIncreasingDistanceArray;

@end
