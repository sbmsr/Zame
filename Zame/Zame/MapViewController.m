//
//  MapViewController.m
//  Zame
//
//  Created by Leonard Loo on 27/4/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import "MapViewController.h"
#import <Parse/Parse.h>
#import "NearbyUserViewController.h"
#import "CustomAnnotation.h"

@interface MapViewController () <CLLocationManagerDelegate> {
    NSMutableArray *peopleArray;
}

// Everytime we shift we will redrop the pins

@property (nonatomic, strong) CLLocationManager *locationManager;
-(BOOL)isCoordinate:(CLLocationCoordinate2D)coordinate insideRegion:(MKCoordinateRegion)region;
-(void)findPeopleIn: (MKCoordinateRegion )viewedRegion;

@end

@implementation MapViewController

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    peopleArray = [[NSMutableArray alloc] init];
    //self.title = @"Discover Zame People";

    
}

// Helper method to efficiently get similar items in two arrays
- (NSArray *) similarItemsIn: (NSArray *) arrayOne
                         and: (NSArray *) arrayTwo {
    NSMutableSet *setOne = [NSMutableSet setWithArray:arrayOne];
    NSSet *setTwo = [NSSet setWithArray:arrayTwo];
    [setOne intersectSet:setTwo];
    return [setOne allObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Sets start on current location
    [self.locationManager startUpdatingLocation];
    CLLocationCoordinate2D zoomLocation = [[self.locationManager location] coordinate];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1500, 1500);
    [_mapView setRegion:viewRegion animated:YES];
    [self findPeopleIn:viewRegion];

    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Helper method that calculates if coordinate is inside region
-(BOOL)isCoordinate:(CLLocationCoordinate2D)coordinate insideRegion:(MKCoordinateRegion)region {
    CLLocationCoordinate2D center   = region.center;
    CLLocationCoordinate2D northWestCorner, southEastCorner;
    
    northWestCorner.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0);
    northWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0);
    southEastCorner.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0);
    southEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0);
    
    return(coordinate.latitude  >= northWestCorner.latitude &&
           coordinate.latitude  <= southEastCorner.latitude &&
           coordinate.longitude >= northWestCorner.longitude &&
           coordinate.longitude <= southEastCorner.longitude
           );
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    MKMapRect mapRect = [mapView visibleMapRect];
    [self findPeopleIn:MKCoordinateRegionForMapRect(mapRect)];
}

-(void)findPeopleIn: (MKCoordinateRegion ) viewedRegion {
    [peopleArray removeAllObjects];
    PFObject *myUser = [PFUser currentUser];
    NSNumber *minScore = [myUser objectForKey:@"MinimumScore"];
    NSString *myId = [myUser objectForKey:@"Fbid"];
    NSString *myName = [myUser objectForKey:@"Name"];
    NSArray *myLikes = [myUser objectForKey:@"Likes"];
    NSArray *myMovies = [myUser objectForKey:@"Movies"];
    NSArray *myMusic = [myUser objectForKey:@"Music"];
    NSArray *myBooks = [myUser objectForKey:@"Books"];
    NSArray *myTelevision = [myUser objectForKey:@"Television"];
    NSArray *mySports = [myUser objectForKey:@"Sports"];
    PFQuery *query = [PFUser query];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
             {
                 if (!error) {
                     for (id object in objects) {
                         NSString *yourId = [object objectForKey:@"Fbid"];
                         if (![myId isEqualToString:yourId]) {
                             NSDictionary *location = [object objectForKey:@"Location"];
                             // Build CLLocationCoordinate2d
                             double lat = [[location objectForKey:@"lat"] doubleValue];
                             double lon = [[location objectForKey:@"lon"] doubleValue];
                             CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(lat, lon);
                             
                             if ([self isCoordinate:coords insideRegion:viewedRegion]) {
                                 // Similarity filtering
                                 // Likes
                                 NSArray *likes = [object objectForKey:@"Likes"];
                                 NSArray *similarLikes = [self similarItemsIn:likes and:myLikes];
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
                                 // Only proceed when score is greater than minimum
                                 if (score >= minScore) {
                                     NSString *name = [object objectForKey:@"Name"];
                                     // Grab first name
                                     NSArray *firstLastStrings = [name componentsSeparatedByString:@" "];
                                     NSString *firstName = [firstLastStrings objectAtIndex:0];
                                     // Grab email
                                     NSString *email = [object objectForKey:@"Email"];
                                     NSDictionary *similarity = [[NSDictionary alloc] initWithObjectsAndKeys:similarLikes, @"Likes", similarMovies, @"Movies", similarMusic, @"Music", similarBooks, @"Books", similarTelevision, @"Television", similarSports, @"Sports", nil];
                                     NSDictionary *personEntry = [[NSDictionary alloc] initWithObjectsAndKeys:myName, @"MyName",firstName, @"Name", location, @"Location", yourId, @"Fbid", similarity, @"Similarity", score, @"Score", email, @"Email", nil];
                                     [peopleArray addObject:personEntry];
                                 }
                             }
                         }
                     }
                     
                 }
                 else {
                     NSLog(@"MapView Background task error: %@", error);
                 }
                 
                 // Remove all pins and drop them again
                 [_mapView removeAnnotations:_mapView.annotations];
                 for (id person in peopleArray) {
                     NSDictionary *personEntry = (NSDictionary *) person;
                     NSDictionary *location = [personEntry objectForKey:@"Location"];
                     // Build CLLocationCoordinate2d
                     double lat = [[location objectForKey:@"lat"] doubleValue];
                     double lon = [[location objectForKey:@"lon"] doubleValue];
                     CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(lat, lon);
                     NSNumber *score = [personEntry objectForKey:@"Score"];
                     NSMutableString *scoreString = [[NSMutableString alloc] initWithString:@"ZScore: "];
                     [scoreString appendString:[score stringValue]];
                     CustomAnnotation *annotation = [[CustomAnnotation alloc] initWithCoordinate:coords AndTitle:[personEntry objectForKey:@"Name"] AndSubtitle:scoreString AndUser:personEntry];
                     [_mapView addAnnotation:(id)annotation];
                 }
                 
                 
             }];
        });
    });
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation {
    
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Whatever"];
    annotationView.pinColor = MKPinAnnotationColorRed;
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
     [self performSegueWithIdentifier:@"mapToUserSegue" sender:view];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"mapToUserSegue"])
    {
        MKAnnotationView *view = sender;
        NearbyUserViewController *vc = segue.destinationViewController;
        // Build user in vc
        CustomAnnotation *annotation = (CustomAnnotation *) view.annotation;
        NSDictionary *user = annotation.user;
        NSNumber *number = [[NSNumber alloc] initWithInt:1]; // whatever number doesn't matter
        NSDictionary *builtUser = [[NSDictionary alloc] initWithObjectsAndKeys:[user objectForKey:@"MyName"], @"MyName", [user objectForKey:@"Name"], @"Name", number, @"Distance", [user objectForKey:@"Fbid"], @"Fbid", [user objectForKey:@"Similarity"], @"Similarity", [user objectForKey:@"Score"], @"Score", [user objectForKey:@"Email"], @"Email", nil];
        vc.nearbyUser = builtUser;
    }
}



@end
