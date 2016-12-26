//
//  ParseViewController.h
//  ChatMessageParser
//
//  Created by Mac One on 26/12/2016.
//  Copyright © 2016 spd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParseViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *btnParse;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *textViewJson;

- (IBAction)buttonClicked:(id)sender;

@end
