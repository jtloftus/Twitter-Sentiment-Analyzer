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
//@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) STTwitterAPI *twitter;

@property (strong, nonatomic) UITextField *activeField;

@end

@implementation SAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    self.activityIndicator.hidesWhenStopped = YES;
    self.approvalLabel.hidden = YES;
    self.tweetTableView.dataSource = self;
    self.queryTextField.delegate = self;
}

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

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    [self.twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@", screenName);
        
        self.handleLabel.text = screenName;
        
    } errorBlock:^(NSError *error) {
        
        self.handleLabel.text = [error localizedDescription];
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}

- (void)queryTweets {
    
    [self.twitter getSearchTweetsWithQuery:self.queryTextField.text geocode:nil lang:@"en" locale:nil resultType:nil count:@"100" until:nil sinceID:nil maxID:nil includeEntities:nil callback:nil
                        successBlock:^(NSDictionary *Searchmetadata, NSArray *statuses) {
        
                            //NSLog(@"-- statuses: %@", statuses);
        
                            NSLog(@"%@",[NSString stringWithFormat:@"%lu statuses", (unsigned long)[statuses count]]);
        
                            self.statuses = statuses;
        
                        } errorBlock:^(NSError *error) {
                            NSLog(@"Error: %@", [error localizedDescription]);
                        }];
    NSMutableArray *tweetsText = [[NSMutableArray alloc] init];
    for (NSDictionary *status in self.statuses) {
        NSString *text = [status valueForKey:@"text"];
        [tweetsText addObject:text];
    }
    
    
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
    NSLog(@"Status: %@", status);
    
    NSString *text = [status valueForKey:@"text"];
    NSString *screenName = [status valueForKeyPath:@"user.screen_name"];
//    NSString *dateString = [status valueForKey:@"created_at"];
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", screenName];
    
    NSString *imageURL = [[status objectForKey:@"user"] objectForKey:@"profile_image_url"];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    cell.imageView.image = [UIImage imageWithData:data];
    
    return cell;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
    NSLog(@"Begin Editing");
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
    NSLog(@"Ended Editing");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Hide the keyboard
    [self hideKeyboard];
    
    [self queryTweets];
    
    return YES;
}

- (void)hideKeyboard {
    [self.activeField resignFirstResponder];
}

@end
