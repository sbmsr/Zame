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

@interface EmailViewController () <UITextFieldDelegate> {
    NSInteger offset; // Used for getting pagination of current user's FB details
    NSMutableArray *moviesHolderArray;
    NSMutableArray *musicHolderArray;
    NSMutableArray *booksHolderArray;
    NSMutableArray *televisionHolderArray;
    NSMutableArray *sportsHolderArray;
    NSMutableArray *likesHolderArray;
    NSMutableArray *followingOnSpotifyHolderArray;
}

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
        
        // Loads the user's similarity items
        moviesHolderArray = [[NSMutableArray alloc] init];
        musicHolderArray = [[NSMutableArray alloc] init];
        booksHolderArray = [[NSMutableArray alloc] init];
        televisionHolderArray = [[NSMutableArray alloc] init];
        sportsHolderArray = [[NSMutableArray alloc] init];
        likesHolderArray = [[NSMutableArray alloc] init];
        [self namesWithRequestURL:@"/me/movies?limit=99999" of:@"movies"];
        [self namesWithRequestURL:@"/me/music?limit=99999" of:@"music"];
        [self namesWithRequestURL:@"/me/books?limit=99999" of:@"books"];
        [self namesWithRequestURL:@"/me/television?limit=99999" of:@"television"];
        [self namesWithRequestURL:@"/me/sports?limit=99999" of:@"sports"];
        [self namesWithRequestURL:@"/me/likes?limit=99999" of:@"likes"];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Stores Likes, Movies, etc. in Parse

- (void) namesWithRequestURL: (NSString *) url
                          of: (NSString *) type{
    FBRequest *request = [FBRequest requestForGraphPath:url];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        NSDictionary *userData = (NSDictionary *)result;
        NSArray *dataArray = [userData objectForKey:@"data"];
        
        if ([type isEqualToString:@"likes"]) {
            NSLog(@"%@", userData);
        }
        
        // Keep building instance array
        for(id key in dataArray) {
            // Array consists of Dictionary objects, with its name and id
            NSDictionary *entry = [[NSDictionary alloc] initWithObjectsAndKeys:[key objectForKey:@"id"], @"id", [key objectForKey:@"name"], @"name", nil];
            [[self getHolderArrayOfType:type] addObject:entry];
        }
        // Check if more data awaits - JUST IN CASE, THOUGH NO ONE WILL HAVE 99999 LIKES
        NSDictionary *paging = (NSDictionary *)[userData objectForKey:@"paging"];
        if ([paging objectForKey:@"next"]) {
            offset += 99999;
            NSString *nextURL = [[[@"/me/" stringByAppendingString:type] stringByAppendingString:@"?limit=99999&offset="] stringByAppendingString:[@(offset) stringValue]];
            [self namesWithRequestURL:nextURL of:type];
        }
        [self.appDelegate.globalUser setObject:[self getHolderArrayOfType:type] forKey:type.capitalizedString];
        [self.appDelegate.globalUser saveInBackground];
        
    } ];
    
    
}

// Helper method for getting holder array of type in NSString

- (NSMutableArray *) getHolderArrayOfType: (NSString *)type {
    if ([type isEqualToString:@"movies"]) {
        return moviesHolderArray;
    } else if ([type isEqualToString:@"music"]) {
        return musicHolderArray;
    } else if ([type isEqualToString:@"books"]) {
        return booksHolderArray;
    } else if ([type isEqualToString:@"television"]) {
        return televisionHolderArray;
    } else if ([type isEqualToString:@"sports"]) {
        return sportsHolderArray;
    } else if ([type isEqualToString:@"likes"]) {
        return likesHolderArray;
    }else if ([type isEqualToString:@"followingOnSpotify"]) {
        return followingOnSpotifyHolderArray;
    } else {
        return NULL;
    }
}


-(IBAction)userHitSubmitEmail:(id)sender {
    // Update email in backend
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