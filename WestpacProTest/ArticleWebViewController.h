//
//  ArticleWebViewController.h
//  WestpacProTest
//
//  Created by Vlad P on 23/09/2014.
//  Copyright (c) 2014 VladSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface ArticleWebViewController : UIViewController <UIWebViewDelegate>

- (void) loadPageForArticle:(Article*)article;

@end
