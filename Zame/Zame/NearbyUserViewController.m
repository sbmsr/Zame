//
//  NearbyUserViewController.m
//  Zame
//
//  Created by Sebastian Messier on 4/22/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import "NearbyUserViewController.h"

#import "SimilaritiesTableViewController.h"
// #import <QuartzCore/QuartzCore.h> // Style message button

@interface NearbyUserViewController () <UIAlertViewDelegate> {
    
    SimilaritiesTableViewController *nextVC;
    NSMutableArray *similarityAttributes;
    NSMutableString *zscoreMailHeader;
}

@end

@implementation NearbyUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.titleBar setTitle:[_nearbyUser objectForKey:@"Name"]];
    similarityAttributes = [[NSMutableArray alloc] init];
    // Retrieve score
    NSNumber *score = [_nearbyUser objectForKey:@"Score"];
    NSMutableString *scoreString = [[NSMutableString alloc] initWithString:@"ZScore: "];
    [scoreString appendString:[score stringValue]];
    // Padding
    [scoreString appendString:@" "];
    // Assign instance mail header
    zscoreMailHeader = [[NSMutableString alloc] initWithString:@"[Zame] We have a ZScore of "];
    [zscoreMailHeader appendString:[score stringValue]];
    _scoreLabel.text = scoreString;
    _scoreLabel.adjustsFontSizeToFitWidth = YES;
    _scoreLabel.numberOfLines = 1;
    // Assemble similarity attributes
    NSDictionary *similarity = [self.nearbyUser objectForKey:@"Similarity"];
    for (id key in similarity) {
        NSArray *categoryArray = [similarity objectForKey:key];
        //if ([categoryArray count] != 0) {
            NSArray *entry = [[NSArray alloc] initWithObjects:key, categoryArray, nil];
           [similarityAttributes addObject:entry];
        //}
    }
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
    // Likes, Music, Sports, Television, Movies, Books
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    //Check if > 0 and < 4 : present all of them
    //      if > 0 and > 4 : present only 3 and a "next" cell
    //      if <= 0 : present "No similar attributes" cell

    if([similarityAttributes[section][1] count] > 3) {
        return 4;
    }else if ([similarityAttributes[section][1] count] > 0){
        return [similarityAttributes[section][1] count];
    }
    else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"similarityCell"];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    // This is for custom selection style color
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:(76.0/255.0) green:(161.0/255.0) blue:(255.0/255.0) alpha:1.0];
    bgColorView.layer.masksToBounds = YES;
    
    cell.selectedBackgroundView = bgColorView;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.numberOfLines = 1;
    NSArray *item = similarityAttributes[indexPath.section][1];
    cell.detailTextLabel.text = similarityAttributes[indexPath.section][0]; //store type of cell (movie,like,etc...)
    cell.detailTextLabel.hidden = YES;

    if (indexPath.row > 2){
        cell.textLabel.text = @"click here to see all...";
    }
    
    else {
        if ([item count] > 0){
            NSDictionary *storedItem = (NSDictionary *)item[indexPath.row];
            cell.textLabel.text = [storedItem objectForKey:@"name"];
            
        }
        else {
            cell.textLabel.text = @"No Similarities Found";
            cell.backgroundColor = [UIColor grayColor];
        }
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return similarityAttributes[section][0];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:@"click here to see all..."]) {
        nextVC = [[SimilaritiesTableViewController alloc] init];
        
        if ([cell.detailTextLabel.text isEqualToString:@"Likes"]) {
            nextVC.data =[[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"Likes"];
            nextVC.criteria = @"likes";
        } else if ([cell.detailTextLabel.text isEqualToString:@"Movies"]) {
            nextVC.data =[[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"Movies"];
            nextVC.criteria = @"movies";
        } else if ([cell.detailTextLabel.text isEqualToString:@"Music"]) {
            nextVC.data =[[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"Music"];
            nextVC.criteria = @"music";
        } else if ([cell.detailTextLabel.text isEqualToString:@"Books"]) {
            nextVC.data =[[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"Books"];
            nextVC.criteria = @"sports";
        } else if ([cell.detailTextLabel.text isEqualToString:@"Television"]) {
            nextVC.data =[[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"Television"];
            nextVC.criteria = @"television";
        } else if ([cell.detailTextLabel.text isEqualToString:@"Sports"]) {
            nextVC.data =[[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"Sports"];
            nextVC.criteria = @"books";
        }
        
        [self.navigationController pushViewController:nextVC animated:YES];

    }
}

#pragma mark - Message

- (IBAction)userSendMessage:(id)sender {
    // Can only send when ZScore is above 10
    NSNumber *zscore = [_nearbyUser objectForKey:@"Score"];
    // TODO: Change this to 10
    if ([zscore integerValue] >= 10) {
        mailComposer = [[MFMailComposeViewController alloc]init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setSubject:zscoreMailHeader];
        NSMutableString *messageBody = [[NSMutableString alloc] initWithString:@"Hey,\nWe have quite a high ZScore! It seems we have some interesting things in common. Let's chat. :)\n\nBest,\n"];
        [messageBody appendString:[_nearbyUser objectForKey:@"MyName"]];
        NSString *emailAddress = [_nearbyUser objectForKey:@"Email"];

        if (emailAddress == NULL) {
            // Throw a UIAlertView
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User has yet to register email" message:@"This user has yet to set his or her email. Check back soon!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            [mailComposer setToRecipients:[NSArray arrayWithObject:emailAddress]];
            [mailComposer setMessageBody:messageBody isHTML:NO];
            [self presentViewController:mailComposer animated:YES completion:nil];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not zame enough" message:@"We're sorry. You need a ZScore of at least 10 to send someone a message." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (result) {
        NSLog(@"Result : %d",result);
    }
    if (error) {
        NSLog(@"Error : %@",error);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



@end
