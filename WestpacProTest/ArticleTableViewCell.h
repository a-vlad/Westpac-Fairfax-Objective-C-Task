//
//  ArticleTableViewCell.h
//  WestpacProTest
//
//  Created by Vlad P on 23/09/2014.
//  Copyright (c) 2014 VladSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface ArticleTableViewCell : UITableViewCell

@property (nonatomic, retain) UIImageView *thumbnailImage;

- (void) populateWithArticle: (Article*) article;

@end
