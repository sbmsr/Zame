//
//  UserSportsViewController.m
//  Zame
//
//  Created by Leonard Loo on 24/4/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import "UserSportsViewController.h"

@interface UserSportsViewController ()


@end

@implementation UserSportsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Zame Sports";
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
    return [_sportsArray count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"sportsCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [_sportsArray objectAtIndex:indexPath.row];
    return cell;
    
}

@end
