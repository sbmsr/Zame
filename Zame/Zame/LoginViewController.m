
//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "LoginViewController.h"
#import "MainUserDetailsViewController.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface LoginViewController ()
@property (strong, nonatomic) AppDelegate *appDelegate;
@end

@implementation LoginViewController

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
    self.title = @"Zame";
    
    [_activityIndicator hidesWhenStopped];
    // Check if user is cached and linked to Facebook, if so, bypass login
    self.appDelegate.globalUser = [PFUser currentUser];
    if (self.appDelegate.globalUser && [PFFacebookUtils isLinkedWithUser:(PFUser*)self.appDelegate.globalUser]) {
//        PFObject *user = [PFUser currentUser];
        if ([self.appDelegate.globalUser objectForKey:@"MinimumScore"] == NULL) {
            [self.appDelegate.globalUser setObject:[NSNumber numberWithInteger:0] forKey:@"MinimumScore"];
        }
        if ([self.appDelegate.globalUser objectForKey:@"Email"] != NULL) {
        UIViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"TabBar"];
        [self presentViewController:vc animated:YES completion:nil];
        } else {
            UIViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"EmailViewController"];
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
    
}


#pragma mark - Login mehtods

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_birthday", @"user_location", @"user_hometown",
                                   @"user_interests",@"user_likes", @"user_photos",
                                   @"user_checkins",@"user_religion_politics"];
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            UIViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"TabBar"];
            [self presentViewController:vc animated:YES completion:nil];
        } else {
            NSLog(@"User with facebook logged in!");
            self.appDelegate.globalUser = [PFUser currentUser];
            NSLog(@"%@", self.appDelegate.globalUser);
            if ([self.appDelegate.globalUser objectForKey:@"Email"] != NULL) {
                UIViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"TabBar"];
                [self presentViewController:vc animated:YES completion:nil];
            }
            else {
                UIViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"EmailViewController"];
                [self presentViewController:vc animated:YES completion:nil];
            }
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

@end
