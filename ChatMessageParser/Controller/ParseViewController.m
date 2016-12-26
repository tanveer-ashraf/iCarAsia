//
//  ParseViewController.m
//  ChatMessageParser
//
//  Created by Mac One on 26/12/2016.
//  Copyright © 2016 spd. All rights reserved.
//

#import "ParseViewController.h"
#import "ChatMessage.h"
#import "LinkModel.h"
#import "HTMLDocument.h"
#import "HTMLElement.h"
#import "HTMLSelector.h"

@interface ParseViewController ()
{
    ChatMessage *message;
    NSMutableArray *arrayOfURLs;
    int totalUrls;
    int totalTitlesFound;
}
@end

@implementation ParseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.activityIndicator setHidden:YES];
    self.textView.text =  @"This is a sample of phone number +60175570098 and url a https://abc.com/efg.php?EFAei687e3EsA sentence with a URL within it.https://www.carlist.my/used-cars/3300445/2011-toyota-vios-1-5-trd-sportivo-33-000km-full-toyota-serviced-record-like-new-11/ and http://www.example.com/listing10.htm and again https://www.carlist.my/used-cars/3300445/2011-toyota-vios-1-5-trd-sportivo-33-000km-full-toyota-serviced-record-like-new-11/";

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)protectAllPhoneNumbers
{
    NSError *error = NULL;
    NSString *pattern = @"\\+[0-9]{11}"; // Change the value between {} for phoneNumber length
    NSString *string = self.textView.text;
    NSRange range = NSMakeRange(0, string.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
//    NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:range];
//    [self highlightMatches:matches];
    
    NSString *afterText = [regex stringByReplacingMatchesInString:string options:0 range:range withTemplate:@"***********"];
    self.textView.text = afterText;
}

-(void)protectUrls
{
    
    NSError *error = NULL;
    // NSString *pattern = @"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))";
    NSString *pattern = @"(http(s)*?://(?!carlist.my)([-\\w]*\\.)(?!carlist.my)\\S*)";
    NSString *string = self.textView.text;
    NSRange range = NSMakeRange(0, string.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    
    NSString *afterText = [regex stringByReplacingMatchesInString:string options:0 range:range withTemplate:@"*****"];
    self.textView.text = afterText;
    
    message = [ChatMessage new];
    message.message = afterText;
    
    
    NSString *patternTwo = @"(http(s)*?://([-\\w]*\\.)(carlist.my)\\S*)";
    NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:patternTwo options:0 error:&error];
    NSArray *arrayOfAllMatches = [regex2 matchesInString:string options:NSMatchingReportProgress range:range];
    
    
    if (arrayOfAllMatches.count > 0) {
        
        totalUrls = (int)arrayOfAllMatches.count;
        totalTitlesFound = 0;
        arrayOfURLs = [[NSMutableArray alloc] init];
        
        for (NSTextCheckingResult *match in arrayOfAllMatches) {
            NSString* substringForMatch = [string substringWithRange:match.range];
            [self getTitleForUrl:substringForMatch];
            
        }
        
        
    }else{
        
        // return non-mutable version of the array
        message.links = (NSArray <LinkModel> *) [NSArray arrayWithArray:arrayOfURLs];
        
        NSString *json = [message toJSONString];
        NSLog(@"JSON===%@",json);
        [self.activityIndicator  stopAnimating];
        [self.activityIndicator setHidden:YES];
        [self.textViewJson setHidden:NO];
        self.textViewJson.text = json;
        [self.btnParse  setTitle:@"Parse" forState:UIControlStateNormal];
    }
    
}

- (IBAction)buttonClicked:(id)sender
{
    
    
    CGRect bounds = self.btnParse.bounds;
    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:10.0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        self.btnParse.bounds = CGRectMake(bounds.origin.x - 20, bounds.origin.y, bounds.size.width + 60, bounds.size.height);
        self.btnParse.enabled = NO;
        [self.btnParse  setTitle:@"Parsing..." forState:UIControlStateNormal];
        
        
    } completion:^(BOOL finished) {
        
        [self.textView resignFirstResponder];
        [self.activityIndicator setHidden:NO];
        [self.activityIndicator startAnimating];
        [self protectAllPhoneNumbers];
        [self protectUrls];
    }];
    
    
}

-(void)getTitleForUrl:(NSString *)url
{
    NSURL *URL = [NSURL URLWithString:url];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:URL completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          NSString *contentType = nil;
          if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
              NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
              contentType = headers[@"Content-Type"];
          }
          HTMLDocument *home = [HTMLDocument documentWithData:data
                                            contentTypeHeader:contentType];
          NSString *title = [home firstNodeMatchingSelector:@"title"].textContent;
          
          LinkModel *links = [LinkModel new];
          links.url        = url;
          links.title      = title;
          [arrayOfURLs addObject:links];
          
          totalTitlesFound++;
          
          if (totalTitlesFound == totalUrls) {
              
              message.links = (NSArray <LinkModel> *) [NSArray arrayWithArray:arrayOfURLs];
              
              NSString *json = [message toJSONString];
              NSLog(@"JSON===%@",json);
              
               dispatch_async( dispatch_get_main_queue(), ^{
              
                   [self.activityIndicator  stopAnimating];
                   [self.activityIndicator setHidden:YES];
                   [self.textViewJson setHidden:NO];
                   self.textViewJson.text = json;
                   [self.btnParse  setTitle:@"Parse" forState:UIControlStateNormal];
               });
          }
          
          
          
      }] resume];
}


@end
