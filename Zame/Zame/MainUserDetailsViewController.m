//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "MainUserDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

@interface MainUserDetailsViewController () <CLLocationManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

- (NSMutableArray*) getNextRequest: (NSMutableArray *)array
                    andRequestURL: (NSString *) url;


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
    
    FBRequest *request = [FBRequest requestForGraphPath:@"me?fields=political,education,hometown,religion,id,name,gender,birthday,picture, music, movies, likes, sports,"];
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
            NSString *politics = userData[@"political"];
            NSString *religion = userData[@"religion"];
            NSString *hometown = userData[@"hometown"][@"name"];
            
            // Insert information into Parse
            [[PFUser currentUser] setObject:facebookID forKey:@"Fbid"];
            [[PFUser currentUser] setObject:name forKey:@"Name"];
            [[PFUser currentUser] setObject:gender forKey:@"Gender"];
            [[PFUser currentUser] setObject:birthday forKey:@"Birthday"];
            [[PFUser currentUser] setObject:[pictureURL absoluteString] forKey:@"ImageURL"];
            [[PFUser currentUser] setObject:politics forKey:@"Politics"];
            [[PFUser currentUser] setObject:religion forKey:@"Religion"];
            [[PFUser currentUser] setObject:hometown forKey:@"Hometown"];
            [[PFUser currentUser] saveInBackground];
            [self updateProfile];
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            [self logoutButtonTouchHandler:nil];
        } else {
            NSLog(@"Some other error: %@", error.localizedDescription);
        }
    }];
    
    //fill the rest of the data
    NSMutableArray *movieArray = [[NSMutableArray alloc] init];
    [self names:movieArray andRequestURL:nil of:@"movies"];
    NSMutableArray *musicArray = [[NSMutableArray alloc] init];
    [self names:musicArray andRequestURL:nil of:@"music"];
    NSMutableArray *booksArray = [[NSMutableArray alloc] init];
    [self names:booksArray andRequestURL:nil of:@"books"];
    NSMutableArray *televisionArray = [[NSMutableArray alloc] init];
    [self names:televisionArray andRequestURL:nil of:@"television"];
    NSMutableArray *sportsArray = [[NSMutableArray alloc] init];
    [self names:sportsArray andRequestURL:nil of:@"sports"];
    NSMutableArray *likesArray = [[NSMutableArray alloc] init];
    [self names:likesArray andRequestURL:nil of:@"likes"];

}

- (NSMutableArray *)      names: (NSMutableArray *) array
                  andRequestURL: (NSString *) url
                             of: (NSString *) type{

    //if we are at the first page
    if (!url){
        if ([type isEqualToString:@"movies"]) {
            url = @"me?fields=movies";
        }
        else if ([type isEqualToString:@"music"]) {
            url = @"me?fields=music";
        }
        else if ([type isEqualToString:@"books"]) {
            url = @"me?fields=books";
        }
        else if ([type isEqualToString:@"television"]) {
            url = @"me?fields=television";
        }
        else if ([type isEqualToString:@"sports"]) {
            url = @"me?fields=sports";
        }
        else if ([type isEqualToString:@"likes"]) {
            url = @"me?fields=likes";
        }
    }
    
    __block BOOL moreData = NO;//bool used to know if another request should be made - avoids recursive calls within a request
    __block NSString* nextURL;
    
    FBRequest *request = [FBRequest requestForGraphPath:url];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSDictionary *userData = (NSDictionary *)result;
        NSDictionary *specificData = userData[type];
        
        NSMutableArray *dataArray = [specificData objectForKey:@"data"];
        
        //add names to array
        for(id key in dataArray) {
            [array addObject:[key objectForKey:@"name"]];
        }
        
        //check if more data awaits
        id paging = [specificData objectForKey:@"paging"];
        if ([paging objectForKey:@"next"]) {
            moreData = YES;
            nextURL = [paging objectForKey:@"next"];
        }
    } ];

    if (moreData){
        [self names:array andRequestURL:nextURL of:type];
    }
    
    [[PFUser currentUser] setObject:array forKey:type.capitalizedString];
    [[PFUser currentUser] saveInBackground];

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
