//
//  SimilaritiesTableViewController.m
//  Zame
//
//  Created by Sebastian Messier on 5/4/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import "SimilaritiesTableViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface SimilaritiesTableViewController ()


@end

@implementation SimilaritiesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([_criteria isEqualToString:@"likes"]) {
        self.title = @"Zame Likes";
    }else if ([_criteria isEqualToString:@"movies"]) {
        self.title = @"Zame Movies";
    }else if ([_criteria isEqualToString:@"music"]) {
        self.title = @"Zame Music";
    }else if ([_criteria isEqualToString:@"sports"]) {
        self.title = @"Zame Sports";
    }else if ([_criteria isEqualToString:@"television"]) {
        self.title = @"Zame Television";
    }else {
        self.title = @"Zame Books";
    }
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_data count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:@"similarityCell"];
    
    UIImageView *cellImage = (UIImageView *)[cell viewWithTag:1];
    
    NSDictionary *item = (NSDictionary *)[_data objectAtIndex:indexPath.row];
    NSString *text = [item objectForKey:@"name"];
    NSString *fbID = [item objectForKey:@"id"];
    NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", fbID];
    
    [cellImage setImageWithURL:[NSURL URLWithString:url]];
    /*
    if ([_criteria isEqualToString:@"likes"]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"likesCell"];
    }else if ([_criteria isEqualToString:@"movies"]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"moviesCell"];
    }else if ([_criteria isEqualToString:@"music"]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"musicCell"];
    }else if ([_criteria isEqualToString:@"sports"]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"sportsCell"];
    }else if ([_criteria isEqualToString:@"television"]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"televisionCell"];
    }else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"booksCell"];
    }
     */
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //cell.textLabel.text = text;

    
    return cell;
    
    
}

@end
