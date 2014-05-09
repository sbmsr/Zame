//
//  Copyright (c) 2013 Parse. All rights reserved.

#import <Parse/Parse.h>
#import "AppDelegate.h"
#import <Spotify/Spotify.h>

@interface MainUserDetailsViewController : UIViewController <NSURLConnectionDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (nonatomic, strong) NSMutableArray *profileInfoArray;

@property (nonatomic, strong) NSString * name;

// UITableView row data properties
@property (nonatomic, strong) NSMutableData *imageData;

// UINavigationBar button touch handler
- (IBAction)logoutButtonTouchHandler:(id)sender;

// UISlider
@property (weak, nonatomic) IBOutlet UISlider* slider;
@property (weak, nonatomic) IBOutlet UILabel* sliderValueLabel;
- (IBAction)sliderValueChanged:(id)sender;

@end
