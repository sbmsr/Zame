//
//  UserLikesViewController.m
//  Zame
//
//  Created by Leonard Loo on 24/4/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import "UserLikesViewController.h"

@interface UserLikesViewController () 



@end

@implementation UserLikesViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Similar Likes";
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
    return [_likesArray count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"likesCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [_likesArray objectAtIndex:indexPath.row];
    return cell;
    
}




@end
