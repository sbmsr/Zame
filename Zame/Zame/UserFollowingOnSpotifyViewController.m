//
//  UserFollowingOnSpotifyViewController.m
//  Zame
//
//  Created by Sebastian Messier on 5/2/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//


#import "UserFollowingOnSpotifyViewController.h"

@interface UserFollowingOnSpotifyViewController ()


@end

@implementation UserFollowingOnSpotifyViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Zame Spotify Playist Creators";
    // Do any additional setup after loading the view.
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
    return [_followingArray count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"followingCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [_followingArray objectAtIndex:indexPath.row];
    return cell;
    
}

@end
