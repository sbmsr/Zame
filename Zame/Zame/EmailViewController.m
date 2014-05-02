//
//  EmailViewController.m
//  Zame
//
//  Created by Leonard Loo on 28/4/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import "EmailViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface EmailViewController () <UITextFieldDelegate>
    
-(IBAction)userHitSubmitEmail:(id)sender;
@property (strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation EmailViewController

- (AppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return _appDelegate;
}

- (void)viewDidLoad
{
//    user = [PFUser currentUser];
    [super viewDidLoad];
    self.emailField.delegate = self;
    // Loads the user's information
    if (self.appDelegate.globalUser) {
        FBRequest *request = [FBRequest requestForGraphPath:@"me?fields=political,education,hometown,religion,id,name,gender,birthday,picture"];
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
                [self.appDelegate.globalUser setObject:facebookID forKey:@"Fbid"];
                [self.appDelegate.globalUser setObject:name forKey:@"Name"];
                [self.appDelegate.globalUser setObject:gender forKey:@"Gender"];
                [self.appDelegate.globalUser setObject:birthday forKey:@"Birthday"];
                [self.appDelegate.globalUser setObject:[pictureURL absoluteString] forKey:@"ImageURL"];
                [self.appDelegate.globalUser setObject:politics forKey:@"Politics"];
                [self.appDelegate.globalUser setObject:religion forKey:@"Religion"];
                [self.appDelegate.globalUser setObject:hometown forKey:@"Hometown"];
                // Also set minimum score to 0 for a start
                [self.appDelegate.globalUser setObject:[NSNumber numberWithInteger:0] forKey:@"MinimumScore"];
                [self.appDelegate.globalUser saveInBackground];
                
            } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                        isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
                NSLog(@"The facebook session was invalidated");
                [PFUser logOut];
                
                // Return to login view controller
                UIViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
                [self presentViewController:vc animated:YES completion:nil];
            } else {
                NSLog(@"Some other error: %@", error.localizedDescription);
            }
        }];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)userHitSubmitEmail:(id)sender {
    // Update email in backend
//    PFObject *user = [PFUser currentUser];
    NSString *email = self.emailField.text;
    [self.appDelegate.globalUser setObject:email forKey:@"Email"];
    [self.appDelegate.globalUser saveInBackground];
    // Move to next screen
    [self.emailField resignFirstResponder];
    UIViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"TabBar"];
    [self presentViewController:vc animated:YES completion:nil];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailField) {
        [textField resignFirstResponder];
        
        
        return NO;
    }
    return YES;
}

@end
