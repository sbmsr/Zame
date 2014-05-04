//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "AppDelegate.h"

#import <Parse/Parse.h>
#import "LoginViewController.h"
#import <Spotify/Spotify.h>

@implementation AppDelegate


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.sliderValueDidChange = NO;
    // ****************************************************************************
    // Fill in with your Parse credentials:
    // ****************************************************************************
    [Parse setApplicationId:@"VjKqF7DZXVtbV2k0KJ26YiCGEEPPofn04iudsRUZ" clientKey:@"fOgilZ0XKJoGaxvcnfpOTq3c40fsxnDhgO9RHZWA"];
    
    // ****************************************************************************
    // Your Facebook application id is configured in Info.plist.
    // ****************************************************************************
    [PFFacebookUtils initializeFacebook];
    
    // Override point for customization after application launch.
    LoginViewController *loginController=[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:loginController];
    self.window.rootViewController=navController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

// ****************************************************************************
// App switching methods to support Facebook Single Sign-On.
// ****************************************************************************
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    if (!([[url absoluteString] rangeOfString:@"spotify"].location == NSNotFound)){
        SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
            // This is the callback that'll be triggered when auth is completed (or fails).
            
            if (error != nil) {
                NSLog(@"Error: %@", error);
                return;
            }
            
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Logged In from Safari"
                                                           message:[NSString stringWithFormat:@"Logged in as user %@", session.canonicalUsername]
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
            [view show];
            
            [self performTestCallWithSession:session];
        };
        
        /*
         STEP 2: Handle the callback from the authentication service. -[SPAuth -canHandleURL:withDeclaredRedirectURL:]
         helps us filter out URLs that aren't authentication URLs (i.e., URLs you use elsewhere in your application).
         
         Make the token swap endpoint URL matches your auth service URL.
         */
        
        if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[NSURL URLWithString:kCallbackURL]]) {
            [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url
                                                tokenSwapServiceEndpointAtURL:[NSURL URLWithString:@"http://localhost:1234/swap"]
                                                                     callback:authCallback];
            return YES;
            
        }
        
        return NO;
    }
    
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}


-(void)performTestCallWithSession:(SPTSession *)session {
    
	/*
	 STEP 3: Execute a simple authenticated API call using our new credentials.
	 */
    
	[SPTRequest playlistsForUser:session.canonicalUsername withSession:session callback:^(NSError *error, SPTPlaylistList *playlists) {
		if (error)
			NSLog(@"%@", error);
		else{
            //Store data in parse
            
            NSMutableArray *playlistCreators = [[NSMutableArray alloc] init];
            
            if ([[playlists valueForKey:(@"items")] count] > 50) {
                for (int iter = 0; iter < 50; iter++) {
                    SPTPartialPlaylist *pl = [playlists valueForKey:(@"items")][iter];
                    
                    NSString *creator = [pl valueForKey:@"_creator"];
                    BOOL isCreatorInArray = [playlistCreators containsObject:creator];
                    
                    if (!isCreatorInArray) {
                        [playlistCreators addObject:creator];
                    }
                }
            }
            
            else
            {
                for (SPTPartialPlaylist *pl in [playlists valueForKey:(@"_items")]) {
                    NSString *creator = [pl valueForKey:@"_creator"];
                    BOOL isCreatorInArray = [playlistCreators containsObject:creator];
                    
                    if (!isCreatorInArray){
                        [playlistCreators addObject:[pl valueForKey:@"_creator"]];
                    }
                    
                }
            }
            
            //Add PlaylistCreators to Parse
            PFUser *myUser= [PFUser currentUser];
            
            [myUser setObject:playlistCreators forKey:@"followingOnSpotify"];
            [myUser saveInBackground];
            
        }
	}];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[PFFacebookUtils session] close];
}

@end
