//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "MainUserDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

@interface MainUserDetailsViewController () <CLLocationManagerDelegate, UIAlertViewDelegate> {
    NSInteger minimumScore;
    PFObject *user;
}

@property (nonatomic, strong) CLLocationManager *locationManager;


@end



@implementation MainUserDetailsViewController

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    user = [PFUser currentUser];
    [super viewDidLoad];
    _sliderValueLabel.adjustsFontSizeToFitWidth = YES;
    _sliderValueLabel.numberOfLines = 1;
    [self.locationManager startUpdatingLocation];
    if (self.isGeolocationAvailable == NO) {
        NSLog(@"Not available");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enable location services" message:@"You previously denied permission for location services. Please enable it in Settings again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        NSLog(@"Available");
    }
    
    // Name, Email
    self.profileInfoArray = [@[@"N/A", @"N/A"] mutableCopy];
    
    // Loads table view
    [self updateProfile];
       
    //fill the rest of the data
    NSMutableArray *movieArray = [[NSMutableArray alloc] init];
    [self names:movieArray andRequestURL:@"/me/movies?limit=100" of:@"movies"];
    NSMutableArray *musicArray = [[NSMutableArray alloc] init];
    [self names:musicArray andRequestURL:@"/me/music?limit=100" of:@"music"];
    NSMutableArray *booksArray = [[NSMutableArray alloc] init];
    [self names:booksArray andRequestURL:@"/me/books?limit=100" of:@"books"];
    NSMutableArray *televisionArray = [[NSMutableArray alloc] init];
    [self names:televisionArray andRequestURL:@"/me/television?limit=100" of:@"television"];
    NSMutableArray *sportsArray = [[NSMutableArray alloc] init];
    [self names:sportsArray andRequestURL:@"/me/sports?limit=100" of:@"sports"];
    NSMutableArray *likesArray = [[NSMutableArray alloc] init];
    [self names:likesArray andRequestURL:@"/me/likes?limit=100" of:@"likes"];

}

- (NSMutableArray *)      names: (NSMutableArray *) array
                  andRequestURL: (NSString *) url
                             of: (NSString *) type{
    
    FBRequest *request = [FBRequest requestForGraphPath:url];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSDictionary *userData = (NSDictionary *)result;
        
        NSArray *dataArray = [userData objectForKey:@"data"];
   
        // Add names to array
        for(id key in dataArray) {
            [array addObject:[key objectForKey:@"name"]];
        }
        
        // Check if more data awaits
        id paging = [userData objectForKey:@"paging"];
        if ([paging objectForKey:@"next"]) {
            NSString* nextURL = [url stringByAppendingString:@"&offset=100"];
            [self names:array andRequestURL:nextURL of:type];
        }
        
    } ];
    
    [user setObject:array forKey:type.capitalizedString];
    [user saveInBackground];

    return array;
}

#pragma mark - NSURLConnectionDataDelegate for Profile Picture

/* Callback delegate methods used for downloading the user's profile picture */

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chuncks of the image are received, we build our data file
    [self.imageData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // All data has been downloaded, now we can set the image in the header image view
    self.profileImageView.image = [UIImage imageWithData:self.imageData];
    // Add a nice corner radius to the image
    self.profileImageView.layer.cornerRadius = 8.0f;
    self.profileImageView.layer.masksToBounds = YES;
}



#pragma mark - UITableViewDataSource for Name, Gender, Birthday

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.profileInfoArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = [_profileInfoArray objectAtIndex:indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.numberOfLines = 1;
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Your Information";
}


#pragma mark - Helper methods

- (IBAction)logoutButtonTouchHandler:(id)sender {
    // Logout user, this automatically clears the cache
    [PFUser logOut];
    
    // Return to login view controller
    UIViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:vc animated:YES completion:nil];
}

// Local method for setting data
- (void)updateProfile {
    
    [self.profileInfoArray replaceObjectAtIndex:0 withObject:[user objectForKey:@"Name"]];
    [self.profileInfoArray replaceObjectAtIndex:1 withObject:[user objectForKey:@"Email"]];
    [self.tableView reloadData];
    
    
    // Download the user's facebook profile picture
    self.imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
    
    if ([user objectForKey:@"ImageURL"]) {
        NSURL *pictureURL = [NSURL URLWithString:[user objectForKey:@"ImageURL"]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                              timeoutInterval:2.0f];
        // Run network request asynchronously
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        if (!urlConnection) {
            NSLog(@"Failed to download picture");
        }
    }
}

#pragma mark - Location Manager
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    
    CLLocation *locationToGeocode = [locations objectAtIndex:0];
    
    [reverseGeocoder reverseGeocodeLocation:locationToGeocode
                          completionHandler:^(NSArray *placemarks, NSError *error){
                              if (!error) {
                                  // Update lat, lon on Parse
                                  NSString *lat = [NSString stringWithFormat:@"%.9f", locationToGeocode.coordinate.latitude];
                                  NSString *lon = [NSString stringWithFormat:@"%.9f", locationToGeocode.coordinate.longitude];
                                  NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:lat, @"lat", lon, @"lon", nil];
                                  [user setObject:dictionary forKey:@"Location"];
                                  [user saveInBackground];
                              }
                          }];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (BOOL)isGeolocationAvailable
{
    if(([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)||(![CLLocationManager locationServicesEnabled])){
        return NO;
    }
    return YES;
}

#pragma mark - Slider
- (IBAction)sliderValueChanged:(id)sender {
    UISlider* slider = (UISlider *) sender;
    minimumScore = slider.value;
    _sliderValueLabel.text = [@(minimumScore) stringValue];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Stores minimum score to parse before view disappears
    [user setObject:[NSNumber numberWithInteger:minimumScore] forKey:@"MinimumScore"];
}

@end
