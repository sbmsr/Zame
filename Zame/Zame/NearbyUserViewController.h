//
//  NearbyUserViewController.h
//  Zame
//
//  Created by Sebastian Messier on 4/22/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface NearbyUserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate> {
     MFMailComposeViewController *mailComposer;
}

@property(nonatomic) NSDictionary *nearbyUser;
@property (weak, nonatomic) IBOutlet UINavigationItem *titleBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

// Message button
- (IBAction)userSendMessage:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;


@end
