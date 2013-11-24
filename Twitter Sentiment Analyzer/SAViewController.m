//
//  SAViewController.m
//  Twitter Sentiment Analyzer
//
//  Created by Joe Loftus on 11/14/13.
//  Copyright (c) 2013 Joe Loftus. All rights reserved.
//

#import "SAViewController.h"

@interface SAViewController ()

@property (strong, nonatomic) IBOutlet UILabel *handleLabel;
@property (strong, nonatomic) IBOutlet UILabel *approvalLabel;
@property (strong, nonatomic) IBOutlet UITextField *queryTextField;
@property (strong, nonatomic) IBOutlet UITableView *tweetTableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) STTwitterAPI *twitter;
@property (strong, nonatomic) NSDictionary *wordScores;

@property (strong, nonatomic) UITextField *activeField;

@end

@implementation SAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.activityIndicator.hidesWhenStopped = YES;
    self.approvalLabel.hidden = YES;
    self.tweetTableView.dataSource = self;
    self.queryTextField.delegate = self;
    
    // Load the plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"scores_list" ofType:@"plist"];
    self.wordScores = [[NSDictionary alloc] initWithContentsOfFile:path];
}

// Sign the user into twitter. If a twitter profile isn't already stored on a device,
// Then we must use oAuth via Safari
- (IBAction)signIn:(id)sender {
    self.twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
    
    self.handleLabel.text = @"Trying to login with iOS...";
    
    [self.twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
        self.handleLabel.text = username;
        
    } errorBlock:^(NSError *error) {
        self.handleLabel.text = [error localizedDescription];
        
        [self signInWithSafari];
    }];
}

// Action received by search button
- (IBAction)search:(id)sender {
    [self queryTweets];
    [self hideKeyboard];
}

// Sign in using oAuth and Safari
- (void)signInWithSafari {
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:CONSUMER_KEY
                                                 consumerSecret:CONSUMER_SECRET];
    
    self.handleLabel.text = @"Trying to login with Safari...";
    
    [self.twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        NSLog(@"-- url: %@", url);
        NSLog(@"-- oauthToken: %@", oauthToken);
        
        [[UIApplication sharedApplication] openURL:url];
        
    } oauthCallback:@"thisapp://twitter_access_tokens/"
                    errorBlock:^(NSError *error) {
                        NSLog(@"-- error: %@", error);
                        self.handleLabel.text = [error localizedDescription];
                    }];
}

// Set up tokens in order to interface with Twitter API
- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    [self.twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@", screenName);
        
        self.handleLabel.text = screenName;
        
    } errorBlock:^(NSError *error) {
        
        self.handleLabel.text = [error localizedDescription];
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}

// Query the tweets and determine sentiment
- (void)queryTweets {
    if (![self.handleLabel.text isEqualToString:@"Logged Out"]) {
        [self.activityIndicator startAnimating];
    }
    
    // Make the API call
    [self.twitter getSearchTweetsWithQuery:self.queryTextField.text geocode:nil lang:@"en" locale:nil resultType:nil count:@"100" until:nil sinceID:nil maxID:nil includeEntities:nil callback:nil
                        successBlock:^(NSDictionary *Searchmetadata, NSArray *statuses) {
        
//                            NSLog(@"-- statuses: %@", statuses);
//                            NSLog(@"%@",[NSString stringWithFormat:@"%lu statuses", (unsigned long)[statuses count]]);
        
                            self.statuses = statuses;
                            
                            [self.tweetTableView reloadData];
                            
                            // Create an array of all tweets
                            NSMutableArray *tweetsText = [[NSMutableArray alloc] init];
                            for (NSDictionary *status in self.statuses) {
                                NSString *text = [status valueForKey:@"text"];
                                [tweetsText addObject:text];
//                                NSLog(@"%@", text);
                            }
                            
                            // Determine how many show positive sentiment
                            float numPositive = 0;
                            for (NSString *tweet in tweetsText) {
                                float tweetScore = 0;
                                NSArray *tokens = [tweet componentsSeparatedByString:@" "];
                                for (NSString *key in self.wordScores) {
                                    for (NSString *token in tokens) {
                                        if (!([key compare:token options:NSCaseInsensitiveSearch])) {
//                                            NSLog(@"%@ %@", key, [self.wordScores objectForKey:key]);
                                            tweetScore += [[self.wordScores objectForKey:key] floatValue];
                                        }
                                    }
                                }
                                if (tweetScore > 0) {
                                    numPositive++;
                                }
                                else if (tweetScore == 0) {
                                    numPositive += .5;
                                }
                            }
                            float percentage = (100 * numPositive) / [tweetsText count];
                            self.approvalLabel.hidden = NO;
                            self.approvalLabel.text = [NSString stringWithFormat:@"%0.1f%%", percentage];
                            
                            // Adjust the color of the label
                            if (percentage < 40) {
                                self.approvalLabel.textColor = [UIColor redColor];
                            }
                            else if (percentage < 60) {
                                self.approvalLabel.textColor = [UIColor darkGrayColor];
                            }
                            else {
                                self.approvalLabel.textColor = [UIColor greenColor];
                            }
                            
                            [self.activityIndicator stopAnimating];
        
                        } errorBlock:^(NSError *error) {
                            NSLog(@"Error: %@", [error localizedDescription]);
                            [self.activityIndicator stopAnimating];
                        }];
}


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.statuses count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"STTwitterTVCellIdentifier"];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"STTwitterTVCellIdentifier"];
    }
    
    NSDictionary *status = [self.statuses objectAtIndex:indexPath.row];
//    NSLog(@"Status: %@", status);
    
    NSString *text = [status valueForKey:@"text"];
    NSString *screenName = [status valueForKeyPath:@"user.screen_name"];
//    NSString *dateString = [status valueForKey:@"created_at"];
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", screenName];
    
    NSString *imageURL = [[status objectForKey:@"user"] objectForKey:@"profile_image_url"];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    cell.imageView.image = [UIImage imageWithData:data];
    
    cell.textLabel.font=[UIFont systemFontOfSize:14.0];
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    
    return cell;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
    // NSLog(@"Begin Editing");
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
    // NSLog(@"Ended Editing");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Hide the keyboard
    [self hideKeyboard];
    
    [self queryTweets];
    
    return YES;
}

- (IBAction)backgroundTapped:(id)sender {
    if (self.activeField) {
        [self.activeField resignFirstResponder];
    }
}

- (void)hideKeyboard {
    [self.activeField resignFirstResponder];
}

@end
