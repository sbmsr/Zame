//
//  EmailViewController.m
//  Zame
//
//  Created by Leonard Loo on 28/4/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import "EmailViewController.h"
#import <Parse/Parse.h>

@interface EmailViewController () <UITextFieldDelegate>
    
-(IBAction)userHitSubmitEmail:(id)sender;

@end

@implementation EmailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.emailField.delegate = self;
    // Loads the user's information
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
            PFObject *user = [PFUser currentUser];
            // Insert information into Parse
            [user setObject:facebookID forKey:@"Fbid"];
            [user setObject:name forKey:@"Name"];
            [user setObject:gender forKey:@"Gender"];
            [user setObject:birthday forKey:@"Birthday"];
            [user setObject:[pictureURL absoluteString] forKey:@"ImageURL"];
            [user setObject:politics forKey:@"Politics"];
            [user setObject:religion forKey:@"Religion"];
            [user setObject:hometown forKey:@"Hometown"];
            // Also set minimum score to 0 for a start
            [user setObject:[NSNumber numberWithInteger:0] forKey:@"MinimumScore"];
            [user saveInBackground];
            
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)userHitSubmitEmail:(id)sender {
    // Update email in backend
    PFObject *user = [PFUser currentUser];
    NSString *email = self.emailField.text;
    [user setObject:email forKey:@"Email"];
    [user saveInBackground];
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
