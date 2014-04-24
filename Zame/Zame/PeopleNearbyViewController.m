//
//  PeopleNearbyViewController.m
//  Zame
//
//  Created by Leonard Loo on 20/4/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import "PeopleNearbyViewController.h"
#import "NearbyUserViewController.h"
#import "MBProgressHUD.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface PeopleNearbyViewController ()

- (double) calculateDistanceFromLat1:(double)lat1
                             AndLon1:(double)lon1
                             AndLat2:(double)lat2
                             AndLon2:(double)lon2;

@end

@implementation PeopleNearbyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //pulltorefresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    _listOfPeopleByIncreasingDistanceArray = [[NSMutableArray alloc] init];
    [self getPeopleByIncreasingDistance];
    self.tableView.layer.borderWidth = 2;
    self.tableView.layer.borderColor = [UIColorFromRGB(0x3B5998) CGColor];
    [self.tableView.layer  setCornerRadius:6.0f];
    [self.tableView.layer setMasksToBounds:YES];
    [self.tableView.layer setBorderWidth:2.0f];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self getPeopleByIncreasingDistance];
    [refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_listOfPeopleByIncreasingDistanceArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PeopleCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *person = [_listOfPeopleByIncreasingDistanceArray objectAtIndex:indexPath.row];
    NSMutableString *personName = [[person objectForKey:@"name"] mutableCopy];
    double personDist = [[person objectForKey:@"distance"] doubleValue];
    NSMutableString *personDistance = [NSMutableString stringWithFormat:@"%.2f", personDist / 1000];
    [personDistance appendString:@"km away"];
    cell.textLabel.text = personName;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.numberOfLines = 1;
    cell.detailTextLabel.text = personDistance;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.numberOfLines = 1;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if user selects row, go to another view
    [self performSegueWithIdentifier: @"viewDetails" sender: self];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // Add your Colour.
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:[UIColor colorWithWhite:0.888 alpha:1.000] ForCell:cell];  //highlight colour
}


- (void)setCellColor:(UIColor *)color ForCell:(UITableViewCell *)cell {
    cell.contentView.backgroundColor = color;
    cell.backgroundColor = color;
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     
     if ([[segue identifier] isEqualToString:@"viewDetails"]) {
         NSIndexPath *indexPath = [self.tableView
                                   indexPathForSelectedRow];
         
         //get the person
         NSDictionary *person = [_listOfPeopleByIncreasingDistanceArray objectAtIndex:indexPath.row];
         
         //Send them
         NearbyUserViewController *vc = (NearbyUserViewController *)segue.destinationViewController;
         vc.nearbyUser = person;
         
     }
 }

#pragma mark - Distance
// Helper method that calculates distance from 2 pairs of lat,lon
- (double) calculateDistanceFromLat1:(double)lat1
                             AndLon1:(double)lon1
                             AndLat2:(double)lat2
                             AndLon2:(double)lon2
{
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:lat1 longitude:lon1];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:lat2 longitude:lon2];
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    return distance;
}

// Create background task that pulls all entries in backend and calculate distance between them one by one
- (void) getPeopleByIncreasingDistance
{
    // First get ownself
    PFObject *myUser = [PFUser currentUser];
    NSDictionary *myLocation = [myUser objectForKey:@"Location"];
    NSString *myId = [myUser objectForKey:@"Fbid"];
    PFQuery *query = [PFUser query];
    
    BOOL isFirstTime = NO;
    
    if([_listOfPeopleByIncreasingDistanceArray count] == 0)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        isFirstTime = YES;
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
             {
                 if (!error) {
                     // Get each of their lat and lon
                     for (NSDictionary *object in objects) {
                         if (![myId isEqualToString:[object objectForKey:@"Fbid"]]) {
                             
                             BOOL isUserNew = YES;
                             
                             NSDictionary *location = [object objectForKey:@"Location"];
                             NSString *name = [object objectForKey:@"Name"];
                             // Calculate distance
                             double distance = [self calculateDistanceFromLat1: [[myLocation objectForKey:@"lat"] doubleValue] AndLon1:[[myLocation objectForKey:@"lon"] doubleValue] AndLat2:[[location objectForKey:@"lat"] doubleValue] AndLon2:[[location objectForKey:@"lon"] doubleValue]];
                             // Build list
                             NSNumber *distanceNum = [NSNumber numberWithDouble:distance];
                             NSString *fbid = [object objectForKey:@"Fbid"];
                             NSDictionary *personEntry = [[NSDictionary alloc] initWithObjectsAndKeys:name, @"name", distanceNum, @"distance", fbid, @"Fbid", nil];
                             
                             for (NSDictionary *Person in _listOfPeopleByIncreasingDistanceArray) {
                                 if ([[Person objectForKey:@"Fbid"] isEqualToString: fbid]){
                                     isUserNew = NO;
                                     break;
                                 }
                             }
                             
                             if (isUserNew){
                                 [_listOfPeopleByIncreasingDistanceArray addObject:personEntry];
                             }
                         }
                     }
                 } else {
                     NSLog(@"From getPeopleByIncreasingDistance: %@", error);
                 }
                 // Sort list
                 NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance"
                                                                                ascending:YES];
                 NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                 NSArray *tempArray = [_listOfPeopleByIncreasingDistanceArray mutableCopy];
                 _listOfPeopleByIncreasingDistanceArray = [[tempArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
                 [self.tableView reloadData];
             }];
        });
        
        if(isFirstTime){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    
    });
    
    
}






@end
