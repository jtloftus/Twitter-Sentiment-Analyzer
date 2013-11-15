//
//  SAViewController.h
//  Twitter Sentiment Analyzer
//
//  Created by Joe Loftus on 11/14/13.
//  Copyright (c) 2013 Joe Loftus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTwitter.h"

@interface SAViewController : UIViewController <UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) NSArray *statuses;

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier;

@end
