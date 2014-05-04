//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "MainUserDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

@interface MainUserDetailsViewController () <UIAlertViewDelegate> {
    NSInteger minimumScore;
}
@property (strong, nonatomic) AppDelegate *appDelegate;
@end

@implementation MainUserDetailsViewController

- (AppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return _appDelegate;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _sliderValueLabel.adjustsFontSizeToFitWidth = YES;
    _sliderValueLabel.numberOfLines = 1;
    NSNumber *minScore = [self.appDelegate.globalUser objectForKey:@"MinimumScore"];
    if (minScore != NULL) {
        NSString *minScoreString = [minScore stringValue];
        _sliderValueLabel.text = minScoreString;
        _slider.value = [minScore floatValue];
    }
    // Name, Email
    self.profileInfoArray = [@[@"N/A", @"N/A"] mutableCopy];
    
    // Loads table view
    if (self.appDelegate.globalUser) {
        [self updateProfile];
    }

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


#pragma mark - Helper methods

- (IBAction)logoutButtonTouchHandler:(id)sender {
    // Pass slider value first
    NSNumber *sliderValue = [NSNumber numberWithFloat:[_sliderValueLabel.text floatValue]];
    [self.appDelegate.globalUser setObject:sliderValue forKey:@"MinimumScore"];
    [self.appDelegate.globalUser save];
    [PFUser logOut];
    // Return to login view controller
    UIViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:vc animated:YES completion:nil];
}

// Local method for setting data
- (void)updateProfile {
    
    [self.profileInfoArray replaceObjectAtIndex:0 withObject:[self.appDelegate.globalUser objectForKey:@"Name"]];
    [self.profileInfoArray replaceObjectAtIndex:1 withObject:[self.appDelegate.globalUser objectForKey:@"Email"]];
    [self.tableView reloadData];
    
    
    // Download the user's facebook profile picture
    self.imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
    
    if ([self.appDelegate.globalUser objectForKey:@"ImageURL"]) {
        NSURL *pictureURL = [NSURL URLWithString:[self.appDelegate.globalUser objectForKey:@"ImageURL"]];
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

#pragma mark - Slider
- (IBAction)sliderValueChanged:(id)sender {
    UISlider* slider = (UISlider *) sender;
    minimumScore = slider.value;
    _sliderValueLabel.text = [@(minimumScore) stringValue];
    self.appDelegate.sliderValueDidChange = YES;

}

-(void)viewWillDisappear:(BOOL)animated {
    NSNumber *sliderValue = [NSNumber numberWithFloat:[_sliderValueLabel.text floatValue]];
    if (self.appDelegate.globalUser) {
        [self.appDelegate.globalUser setObject:sliderValue forKey:@"MinimumScore"];
        [self.appDelegate.globalUser saveInBackground];
    }
}

#pragma mark - Spotify

- (IBAction)sync:(id)sender {
    
	/*
	 STEP 1: Get a login URL from SPAuth and open it in Safari. Note that you must open
	 this URL using -[UIApplication openURL:].
	 */
    
	NSURL *loginPageURL = [[SPTAuth defaultInstance] loginURLForClientId:kClientId
													 declaredRedirectURL:[NSURL URLWithString:kCallbackURL]
																  scopes:@[@"login"]];
    

	[[UIApplication sharedApplication] openURL:loginPageURL];
    
}

@end
