Twitter-Sentiment-Analyzer
==========================

Twitter Sentiment Analysis using Naive Bayes's Classification

This repository contains the source code to build a Twitter Sentiment Analyzer iOS Application that will
soon be available on the App Store. This App has a few main components.

Twitter Sentiment Analyzer
--------------------------
  1. SAAppDelegate
    - Provides background operations for the application including handling the oAuthorization necessary
      for Twitter API calls.
  
  2. SAViewController
    - This is the main interface for the application. It's functions include but are not limited to:
      - Handling the User Interface of the application and all user inputs as well as displaying output
      - Maintaining the Twitter API class
      - Computing tweet sentiment analysis through interaction with scores_list.plist
      
  3. Supporting Files
    - Directory that contains a number of files necessary to run the application
      - scores_list.plist
        - File that interfaces well with a dictionary and allows for easy access to keyword scores
          used for judging tweet sentiment
          
  4. STTwitter
    - Contains the files necessary for interfacing with the Twitter API
    - Code written by Nicolas Seriot and is available on Twitter's website under API's

//
//  Twitter Sentiment Analyzer
//
//  Created by Joe Loftus on 11/14/13.
//  Copyright (c) 2013 Joe Loftus. All rights reserved.
//
