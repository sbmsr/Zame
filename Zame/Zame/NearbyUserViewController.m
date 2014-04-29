//
//  NearbyUserViewController.m
//  Zame
//
//  Created by Sebastian Messier on 4/22/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import "NearbyUserViewController.h"
#import "UserLikesViewController.h"
#import "UserMoviesViewController.h"
#import "UserMusicViewController.h"
#import "UserBooksViewController.h"
#import "UserTelevisionViewController.h"
#import "UserSportsViewController.h"

@interface NearbyUserViewController () <UIAlertViewDelegate> {
    UserLikesViewController *likesVC;
    UserMoviesViewController *moviesVC;
    UserMusicViewController *musicVC;
    UserBooksViewController *booksVC;
    UserTelevisionViewController *televisionVC;
    UserSportsViewController *sportsVC;
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
        if ([categoryArray count] != 0) {
            NSArray *entry = [[NSArray alloc] initWithObjects:key, categoryArray, nil];
           [similarityAttributes addObject:entry];
        }
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
    // Within 2km, Within 20km, On Earth
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [similarityAttributes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"similarityCell"];
    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
    // This is for custom selection style color
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:(76.0/255.0) green:(161.0/255.0) blue:(255.0/255.0) alpha:1.0];
    bgColorView.layer.masksToBounds = YES;
    
    cell.selectedBackgroundView = bgColorView;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.numberOfLines = 1;
    NSArray *item = [similarityAttributes objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectAtIndex:0];
    cell.detailTextLabel.text = [@([[item objectAtIndex:1] count]) stringValue];

    /*
    switch (indexPath.row) {
        case 0 :
            cell.textLabel.text = @"Likes";
            cell.detailTextLabel.text = [@([[[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"SimilarLikes"] count]) stringValue];
            break;
        case 1 :
            cell.textLabel.text = @"Movies";
            cell.detailTextLabel.text = [@([[[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"SimilarMovies"] count]) stringValue];
            break;
        case 2 :
            cell.textLabel.text = @"Music";
            cell.detailTextLabel.text = [@([[[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"SimilarMusic" ] count]) stringValue];
            break;
        case 3 :
            cell.textLabel.text = @"Books";
            cell.detailTextLabel.text = [@([[[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"SimilarBooks"] count]) stringValue];
            break;
        case 4 :
            cell.textLabel.text = @"Television";
            cell.detailTextLabel.text = [@([[[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"SimilarTelevision" ] count]) stringValue];
            break;
        case 5 :
            cell.textLabel.text = @"Sports";
            cell.detailTextLabel.text = [@([[[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"SimilarSports" ] count]) stringValue];
            break;
        default:
            break;
    }
    
    */
    
    

    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Number of Zame Stuff";
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:@"Likes"]) {
        likesVC = [[UserLikesViewController alloc] init];
        likesVC.likesArray = [[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"Likes"];
        [self.navigationController pushViewController:likesVC animated:YES];
    } else if ([cell.textLabel.text isEqualToString:@"Movies"]) {
        moviesVC = [[UserMoviesViewController alloc] init];
        moviesVC.moviesArray = [[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"Movies"];
        [self.navigationController pushViewController:moviesVC animated:YES];
    } else if ([cell.textLabel.text isEqualToString:@"Music"]) {
        musicVC = [[UserMusicViewController alloc] init];
        musicVC.musicArray = [[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"Music"];
        [self.navigationController pushViewController:musicVC animated:YES];
    } else if ([cell.textLabel.text isEqualToString:@"Books"]) {
        booksVC = [[UserBooksViewController alloc] init];
        booksVC.booksArray = [[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"Books"];
        [self.navigationController pushViewController:booksVC animated:YES];
    } else if ([cell.textLabel.text isEqualToString:@"Television"]) {
        televisionVC = [[UserTelevisionViewController alloc] init];
        televisionVC.televisionArray = [[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"Television"];
        [self.navigationController pushViewController:televisionVC animated:YES];
    } else if ([cell.textLabel.text isEqualToString:@"Sports"]) {
        sportsVC = [[UserSportsViewController alloc] init];
        sportsVC.sportsArray = [[self.nearbyUser objectForKey:@"Similarity"] objectForKey:@"Sports"];
        [self.navigationController pushViewController:sportsVC animated:YES];
    }
  
}

- (IBAction)userSendMessage:(id)sender {
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
