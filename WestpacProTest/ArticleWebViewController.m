//
//  ArticleWebViewController.m
//  WestpacProTest
//
//  Created by Vlad P on 23/09/2014.
//  Copyright (c) 2014 VladSoftware. All rights reserved.
//

#import "ArticleWebViewController.h"

@interface ArticleWebViewController (){
    UIWebView *_webView;
    Article *_article;
}
@end




@implementation ArticleWebViewController

- (void) loadView
{
    [super loadView];
    _webView = [UIWebView new];
    [_webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:_webView];
    
    NSLayoutConstraint *width =[NSLayoutConstraint
                                constraintWithItem:_webView
                                attribute:NSLayoutAttributeWidth
                                relatedBy:0
                                toItem:self.view
                                attribute:NSLayoutAttributeWidth
                                multiplier:1.0
                                constant:0];
    NSLayoutConstraint *height =[NSLayoutConstraint
                                 constraintWithItem:_webView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:0
                                 toItem:self.view
                                 attribute:NSLayoutAttributeHeight
                                 multiplier:1.0
                                 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:_webView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeTop
                               multiplier:1.0f
                               constant:0.f];
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:_webView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f];
    [self.view addConstraint:width];
    [self.view addConstraint:height];
    [self.view addConstraint:top];
    [self.view addConstraint:leading];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:_article.webURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webView setScalesPageToFit:YES];
    [_webView setDelegate:self];
    [_webView loadRequest:requestObj];
    [self setTitle:@"Loading..."];
    [_webView setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    [_webView release];
    _webView = nil;
    [_article release];
    _article = nil;
    [super dealloc];
}


#pragma mark - Class methods

- (void) loadPageForArticle:(Article*)article {
    _article = [article retain];
}



#pragma mark - Web View Delegate Methods for loading feedback

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self setTitle:@"Loading..."];
    NSLog(@"Webpage loading began...");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self setTitle:_article.headLine];
    [_webView setHidden:NO];
    NSLog(@"Webpage loading finished.");
}

@end
