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
#import "AppDelegate.h"

@interface MapViewController () <CLLocationManagerDelegate> {
    NSMutableArray *peopleArray;
    float regionScore;
    NSInteger regionCount;
}

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (nonatomic, strong) CLLocationManager *locationManager;
-(BOOL)isCoordinate:(CLLocationCoordinate2D)coordinate insideRegion:(MKCoordinateRegion)region;
-(void)findPeopleIn: (MKCoordinateRegion )viewedRegion;

@end

@implementation MapViewController

- (AppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return _appDelegate;
}


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
    // Throw UIAlertView explaining what to do
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tap and hold" message:@"Tap and hold the screen to discover the average ZScore of the region!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    self.mapView.delegate = self;
    peopleArray = [[NSMutableArray alloc] init];
    regionScore = 0;
    // Gesture recognizer
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(mapLongPress:)];
    longPress.minimumPressDuration = 1.0;
    [_mapView addGestureRecognizer:longPress];

    
}

// Selector for gesture recognizer
-(void)mapLongPress:(UIGestureRecognizer*)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan)
        return;
    
    // Clear existing overlays
    [_mapView removeOverlays:self.mapView.overlays];
    
    MKMapRect mapRect = [_mapView visibleMapRect];
    // Get coordinate of four bounding coordinates
    CLLocationCoordinate2D NEcoordinate = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), mapRect.origin.y));
    CLLocationCoordinate2D NWcoordinate = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMinX(mapRect), mapRect.origin.y));
    CLLocationCoordinate2D SEcoordinate = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)));
    CLLocationCoordinate2D SWcoordinate = MKCoordinateForMapPoint(MKMapPointMake(mapRect.origin.x, MKMapRectGetMaxY(mapRect)));
    CLLocationCoordinate2D points[4] = {NEcoordinate, NWcoordinate, SWcoordinate, SEcoordinate};
    
    
    // Draw the overlay
    MKPolygon *polygonOverlay = [MKPolygon polygonWithCoordinates:points count:4];
    [_mapView addOverlay:polygonOverlay];
    
    
    // Compute and display the aggregate ZScore
    regionScore = 0;
    regionCount = 0;
    [self findPeopleIn:MKCoordinateRegionForMapRect(mapRect)];
    
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygon *polygon = overlay;
        MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithOverlay:polygon];
        polygonRenderer.strokeColor = [UIColor blueColor];
        return polygonRenderer;
    }
    else return nil;
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

/*
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    MKMapRect mapRect = [mapView visibleMapRect];
    regionScore = 0;
    [self findPeopleIn:MKCoordinateRegionForMapRect(mapRect)];
}*/

// This isn't working??!?!?!?
-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGRect frame = self.view.frame;
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        NSLog(@"Landscape mode");
        frame.size.width = 568;
        frame.size.height = 320;
        CGRect labelFrame = _aggregateScoreLabel.frame;
        _aggregateScoreLabel.frame = CGRectMake(20, 20, 568, 100);
    } else if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        NSLog(@"Portrait mode");
        frame.size.width = 320;
        frame.size.height = 568;
    }
    [self.view setFrame:frame];
}

-(void)findPeopleIn: (MKCoordinateRegion ) viewedRegion {
    [peopleArray removeAllObjects];
    NSNumber *minScore = [self.appDelegate.globalUser objectForKey:@"MinimumScore"];
    if (minScore == NULL) {
        minScore = [NSNumber numberWithInteger:0];
    }
    NSString *myId = [self.appDelegate.globalUser objectForKey:@"Fbid"];
    NSArray *myLikes = [self.appDelegate.globalUser objectForKey:@"Likes"];
    NSArray *myMovies = [self.appDelegate.globalUser objectForKey:@"Movies"];
    NSArray *myMusic = [self.appDelegate.globalUser objectForKey:@"Music"];
    NSArray *myBooks = [self.appDelegate.globalUser objectForKey:@"Books"];
    NSArray *myTelevision = [self.appDelegate.globalUser objectForKey:@"Television"];
    NSArray *mySports = [self.appDelegate.globalUser objectForKey:@"Sports"];
    if (self.appDelegate.globalUser) {
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
                                     regionScore += [score integerValue];
                                     regionCount++;
                                     // Only proceed when score is greater than minimum
                                     /*
                                     if ([score integerValue] >= [minScore integerValue]) {
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
                                      */
                                 }
                             }
                         }
                         
                     }
                     else {
                         NSLog(@"MapView Background task error: %@", error);
                     }
                     
                     // Remove all pins and drop them again
                     /*
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
                      */
                     if (regionCount == 0) { // prevent NaN
                         regionCount = 1;
                     }
                     NSString *scoreString = [NSString stringWithFormat:@"%.2f", regionScore/regionCount];
                     NSString *scoreText = [@"Average ZScore: " stringByAppendingString:scoreString];
                     _aggregateScoreLabel.text = scoreText;
                     _aggregateScoreLabel.adjustsFontSizeToFitWidth = YES;
                     _aggregateScoreLabel.numberOfLines = 1;
                     
                     
                 }];
            });
        });

    }
    
}
/*
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
*/


@end
