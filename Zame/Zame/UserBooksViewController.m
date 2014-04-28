//
//  UserBooksViewController.m
//  Zame
//
//  Created by Leonard Loo on 24/4/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import "UserBooksViewController.h"

@interface UserBooksViewController ()

@end

@implementation UserBooksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Similar Books";
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
    return [_booksArray count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"booksCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [_booksArray objectAtIndex:indexPath.row];
    return cell;
    
}

@end
