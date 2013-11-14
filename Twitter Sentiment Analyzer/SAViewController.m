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

@end

@implementation SAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.activityIndicator.hidesWhenStopped = YES;
    self.approvalLabel.hidden = YES;
    
    
}

- (IBAction)signIn:(id)sender {
}

- (IBAction)queryTweets:(id)sender {
}


//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

@end
