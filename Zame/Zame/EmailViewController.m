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
    // Do any additional setup after loading the view.
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
