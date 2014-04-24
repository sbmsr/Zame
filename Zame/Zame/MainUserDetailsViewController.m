//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "MainUserDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

@interface MainUserDetailsViewController () <CLLocationManagerDelegate, UIAlertViewDelegate>

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
    [super viewDidLoad];
    
    [self.locationManager startUpdatingLocation];
    if (self.isGeolocationAvailable == NO) {
        NSLog(@"Not available");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enable location services" message:@"You previously denied permission for location services. Please enable it in Settings again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        NSLog(@"Available");
    }
    
    // Name, Gender, Birthday
    self.profileInfoArray = [@[@"N/A", @"N/A"] mutableCopy];
    
    
    // If the user is already logged in, display any previously cached values before we get the latest from Facebook.
    
    if ([PFUser currentUser]) {
        [self updateProfile];
    }
    
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *gender = userData[@"gender"];
            NSString *birthday = userData[@"birthday"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            FBRequest *d = [FBRequest requestForGraphPath:@"me?fields=political,education,hometown,movies,music,books,television,sports,religion"];
            NSDictionary *Data = (NSDictionary *)d;
            
            NSString *politics = Data[@"political"];
            NSString *religion = Data[@"religion"];
            
            NSDictionary *education = Data[@"education"];
            
            NSDictionary *hometown = Data[@"movies"];
            NSDictionary *movies = Data[@"political"];
            NSDictionary *music = Data[@"music"];
            
            NSDictionary *television = Data[@"television"];
            television = television[@"data"];
            
            NSDictionary *sports = Data[@"sports"];
            
            // Insert information into Parse
            [[PFUser currentUser] setObject:facebookID forKey:@"Fbid"];
            [[PFUser currentUser] setObject:name forKey:@"Name"];
            [[PFUser currentUser] setObject:gender forKey:@"Gender"];
            [[PFUser currentUser] setObject:birthday forKey:@"Birthday"];
            [[PFUser currentUser] setObject:[pictureURL absoluteString] forKey:@"ImageURL"];
            [[PFUser currentUser] saveInBackground];
            [self updateProfile];

            
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            [self logoutButtonTouchHandler:nil];
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.profileInfoArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = [_profileInfoArray objectAtIndex:indexPath.row];
    return cell;
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
    if ([[PFUser currentUser] objectForKey:@"Name"]) {
        [self.profileInfoArray replaceObjectAtIndex:0 withObject:[[PFUser currentUser] objectForKey:@"Name"]];
    }
    
    if ([[PFUser currentUser] objectForKey:@"Gender"]) {
        [self.profileInfoArray replaceObjectAtIndex:1 withObject:[[PFUser currentUser] objectForKey:@"Gender"]];
    }

    [self.tableView reloadData];
    
    
    // Download the user's facebook profile picture
    self.imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
    
    if ([[PFUser currentUser] objectForKey:@"ImageURL"]) {
        NSURL *pictureURL = [NSURL URLWithString:[[PFUser currentUser] objectForKey:@"ImageURL"]];
        
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
                                  [[PFUser currentUser] setObject:dictionary forKey:@"Location"];
                                  [[PFUser currentUser] saveInBackground];
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

@end
