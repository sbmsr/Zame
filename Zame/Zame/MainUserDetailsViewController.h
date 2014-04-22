//
//  Copyright (c) 2013 Parse. All rights reserved.

#import <Parse/Parse.h>

@interface MainUserDetailsViewController : UIViewController <NSURLConnectionDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIImageView *profileImageView;
@property (nonatomic, strong) NSMutableArray *profileInfoArray;

@property (nonatomic, strong) NSString * name;

// UITableView row data properties
//@property (nonatomic, strong) NSArray *rowTitleArray;
//@property (nonatomic, strong) NSMutableArray *rowDataArray;
@property (nonatomic, strong) NSMutableData *imageData;

// UINavigationBar button touch handler
- (IBAction)logoutButtonTouchHandler:(id)sender;

@end
