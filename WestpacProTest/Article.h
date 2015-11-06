//
//  Article.h
//  WestpacProTest
//
//  Created by Vlad P on 23/09/2014.
//  Copyright (c) 2014 VladSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Article : NSObject

@property (nonatomic, assign)   int articleID;
@property (nonatomic, copy)     NSDate *date;
@property (nonatomic, copy)     NSString *type;
@property (nonatomic, copy)     NSString *headLine;
@property (nonatomic, copy)     NSString *slugLine;
@property (nonatomic, copy)     NSString *thumbnailURL;
@property (nonatomic, copy)     NSString *webURL;
@property (nonatomic, copy)     UIImage *thumbnailImage;
@end
