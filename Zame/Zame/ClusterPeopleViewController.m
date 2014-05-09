//
//  ClusterPeopleViewController.m
//  Zame
//
//  Created by Leonard Loo on 5/5/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import "ClusterPeopleViewController.h"
#import "NearbyUserViewController.h"

@interface ClusterPeopleViewController ()

@end

@implementation ClusterPeopleViewController

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
    NSMutableString *title = [[@([_people count]) stringValue] mutableCopy];
    [title appendString:@" people selected"];
    self.title = title;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"food"]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_people count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ClusterPersonCell"];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:(76.0/255.0) green:(161.0/255.0) blue:(255.0/255.0) alpha:1.0];
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;
    NSDictionary *person = [_people objectAtIndex:indexPath.row];
    cell.textLabel.text = [person objectForKey:@"Name"];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.numberOfLines = 1;
    NSNumber *score = [person objectForKey:@"Score"];
    NSMutableString *scoreString = [[NSMutableString alloc] initWithString:@"ZScore: "];
    [scoreString appendString:[score stringValue]];
    cell.detailTextLabel.text = scoreString;
    return cell;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"People in selected cluster";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if user selects row, go to another view
    [self performSegueWithIdentifier: @"viewDetailsFromCluster" sender: self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"viewDetailsFromCluster"]) {
        NSIndexPath *indexPath = [self.tableView
                                  indexPathForSelectedRow];
        
        //get the person
        NSDictionary *person = [_people objectAtIndex:indexPath.row];
        //Send them
        NearbyUserViewController *vc = (NearbyUserViewController *)segue.destinationViewController;
        vc.nearbyUser = person;
    }
}

@end
