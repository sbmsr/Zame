//
//  UserTelevisionViewController.m
//  Zame
//
//  Created by Leonard Loo on 24/4/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import "UserTelevisionViewController.h"

@interface UserTelevisionViewController ()


@end

@implementation UserTelevisionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Zame TV Shows";
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
    return [_televisionArray count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"televisionCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [_televisionArray objectAtIndex:indexPath.row];
    return cell;
    
}

@end
