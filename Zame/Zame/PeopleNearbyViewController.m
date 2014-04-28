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
// Useful macros
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface PeopleNearbyViewController () {
    NSMutableArray *peopleWithinTwoKm;
    NSMutableArray *peopleWithinTwentyKm;
    NSMutableArray *peopleOnThisEarth;
}

- (double) calculateDistanceFromLat1:(double)lat1
                             AndLon1:(double)lon1
                             AndLat2:(double)lat2
                             AndLon2:(double)lon2;

@end

@implementation PeopleNearbyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //pulltorefresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    peopleWithinTwoKm = [[NSMutableArray alloc] init];
    peopleWithinTwentyKm = [[NSMutableArray alloc] init];
    peopleOnThisEarth = [[NSMutableArray alloc] init];
    
    [self getPeopleByIncreasingDistance];

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
    // Within 2km, Within 20km, On Earth
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0 :
            return [peopleWithinTwoKm count];;
            break;
        case 1:
            return [peopleWithinTwentyKm count];
            break;
        case 2:
            return [peopleOnThisEarth count];
            break;
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"PeopleCell"];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    // This is for custom selection style color
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:(76.0/255.0) green:(161.0/255.0) blue:(255.0/255.0) alpha:1.0];
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;
    
    NSDictionary *person = [[NSDictionary alloc] init];
    switch (indexPath.section) {
        case 0 :
            person = [peopleWithinTwoKm objectAtIndex:indexPath.row];
            break;
        case 1:
            person = [peopleWithinTwentyKm objectAtIndex:indexPath.row];
            break;
        case 2:
            person = [peopleOnThisEarth objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }

    
    NSMutableString *personName = [[person objectForKey:@"Name"] mutableCopy];
    cell.textLabel.text = personName;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.numberOfLines = 1;
    NSNumber *score = [person objectForKey:@"Score"];
    NSMutableString *scoreString = [[NSMutableString alloc] initWithString:@"ZScore: "];
    [scoreString appendString:[score stringValue]];
    cell.detailTextLabel.text = scoreString;

    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0 :
            return @"Within 2km";
            break;
        case 1:
            return @"Within 20km";
            break;
        case 2:
            return @"On this planet";
            break;
        default:
            return @"";
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if user selects row, go to another view
    [self performSegueWithIdentifier: @"viewDetails" sender: self];
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
         NSDictionary *person = [[NSDictionary alloc] init];
         switch (indexPath.section) {
             case 0 :
                 person = [peopleWithinTwoKm objectAtIndex:indexPath.row];
                 break;
             case 1:
                 person = [peopleWithinTwentyKm objectAtIndex:indexPath.row];
                 break;
             case 2:
                 person = [peopleOnThisEarth objectAtIndex:indexPath.row];
                 break;
             default:
                 break;
         }
         
         //Send them
         NearbyUserViewController *vc = (NearbyUserViewController *)segue.destinationViewController;
         vc.nearbyUser = person;
         
     }
 }

#pragma mark - Distance, and Similarity Attributes

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

// Helper method to efficiently get similar items in two arrays
- (NSArray *) similarItemsIn: (NSArray *) arrayOne
                         and: (NSArray *) arrayTwo {
    NSMutableSet *setOne = [NSMutableSet setWithArray:arrayOne];
    NSSet *setTwo = [NSSet setWithArray:arrayTwo];
    [setOne intersectSet:setTwo];
    return [setOne allObjects];
}

// Create background task that pulls all entries in backend and calculate distance between them one by one
- (void) getPeopleByIncreasingDistance
{
    // First get ownself
    PFObject *myUser = [PFUser currentUser];
    NSDictionary *myLocation = [myUser objectForKey:@"Location"];
    NSArray *myLikes = [myUser objectForKey:@"Likes"];
    NSArray *myMovies = [myUser objectForKey:@"Movies"];
    NSArray *myMusic = [myUser objectForKey:@"Music"];
    NSArray *myBooks = [myUser objectForKey:@"Books"];
    NSArray *myTelevision = [myUser objectForKey:@"Television"];
    NSArray *mySports = [myUser objectForKey:@"Sports"];
    NSString *myId = [myUser objectForKey:@"Fbid"];
    NSString *myName = [myUser objectForKey:@"Name"];
    PFQuery *query = [PFUser query];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
             {
                 if (!error) {
                     
                     // Remove all objects and reload
                     [peopleWithinTwoKm removeAllObjects];
                     [peopleWithinTwentyKm removeAllObjects];
                     [peopleOnThisEarth removeAllObjects];
                     
                     // Get each of their lat and lon
                     for (NSDictionary *object in objects) {
                         NSString *yourId = [object objectForKey:@"Fbid"];
                         if (![myId isEqualToString:yourId]) {
                             
                             // Similarity filtering
                             // Likes
                             NSArray *likes = [object objectForKey:@"Likes"];
                             NSArray *similarLikes = [self similarItemsIn:likes and:myLikes];
                             /* REMOVED BECAUSE IT'S TOO LAGGY
                             // Mutual Friends
                             NSString *pathSegment1 = @"/";
                             NSString *pathSegment2 = @"/mutualfriends/";
                             NSString *path = [[[pathSegment1 stringByAppendingString:myId] stringByAppendingString:pathSegment2] stringByAppendingString:yourId];
                             [FBRequestConnection startWithGraphPath:path
                                                          parameters:nil
                                                          HTTPMethod:@"GET"
                                                   completionHandler:^(
                                                                       FBRequestConnection *connection,
                                                                       id result,
                                                                       NSError *error
                                                                       ) {
                                                       mutualFriends = (NSArray *) result;
                                                   }];
                              */
                             // Movies
                             NSArray *movies = [object objectForKey:@"Movies"];
                             NSArray *similarMovies = [self similarItemsIn:movies and:myMovies];
                             // Music
                             NSArray *music = [object objectForKey:@"Music"];
                             NSArray *similarMusic = [self similarItemsIn:music and:myMusic];
                             // Books
                             NSArray *books = [object objectForKey:@"Books"];
                             NSArray *similarBooks = [self similarItemsIn:books and:myBooks];
                             // Television
                             NSArray *television = [object objectForKey:@"Television"];
                             NSArray *similarTelevision = [self similarItemsIn:television and:myTelevision];
                             // Sports
                             NSArray *sports = [object objectForKey:@"Sports"];
                             NSArray *similarSports = [self similarItemsIn:sports and:mySports];
                             // Score
                             NSNumber *score = [[NSNumber alloc] initWithInteger:[similarLikes count] + [similarMovies count] + [similarMusic count] + [similarBooks count] + [similarTelevision count] + [similarSports count] ];
                             
                             
                             // Location filtering
                             NSDictionary *location = [object objectForKey:@"Location"];
                             NSString *name = [object objectForKey:@"Name"];
                             // Grab first name
                             NSArray *firstLastStrings = [name componentsSeparatedByString:@" "];
                             NSString *firstName = [firstLastStrings objectAtIndex:0];
                             // Calculate distance
                             double distance = [self calculateDistanceFromLat1: [[myLocation objectForKey:@"lat"] doubleValue] AndLon1:[[myLocation objectForKey:@"lon"] doubleValue] AndLat2:[[location objectForKey:@"lat"] doubleValue] AndLon2:[[location objectForKey:@"lon"] doubleValue]];
                             // Build list
                             NSNumber *distanceNum = [NSNumber numberWithDouble:distance];
                             NSDictionary *similarity = [[NSDictionary alloc] initWithObjectsAndKeys:similarLikes, @"Likes", similarMovies, @"Movies", similarMusic, @"Music", similarBooks, @"Books", similarTelevision, @"Television", similarSports, @"Sports", nil];
                             NSDictionary *personEntry = [[NSDictionary alloc] initWithObjectsAndKeys:myName, @"MyName",firstName, @"Name", distanceNum, @"Distance", yourId, @"Fbid", similarity, @"Similarity", score, @"Score", nil];
                             
                             if (distance < 2000) {
                                 
                                 [peopleWithinTwoKm addObject:personEntry];
                             } else if (distance < 20000) {
                                 [peopleWithinTwentyKm addObject:personEntry];
                             } else {
                                 [peopleOnThisEarth addObject:personEntry];
                             }
                         }
                     }
                 } else {
                     NSLog(@"From getPeopleByIncreasingDistance: %@", error);
                 }
                 // Sort all three arrays
                 NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Distance"
                                                                                ascending:YES];
                 NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                 peopleWithinTwoKm = [[[peopleWithinTwoKm mutableCopy] sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
                 peopleWithinTwentyKm = [[[peopleWithinTwentyKm mutableCopy]sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
                 peopleOnThisEarth = [[[peopleOnThisEarth mutableCopy] sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
                 [self.tableView reloadData];
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
             }];
        });
    
    });
    
    
}






@end
