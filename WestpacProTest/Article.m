//
//  Article.m
//  WestpacProTest
//
//  Created by Vlad P on 23/09/2014.
//  Copyright (c) 2014 VladSoftware. All rights reserved.
//

#import "Article.h"

@implementation Article
@synthesize articleID;
@synthesize date;
@synthesize type;
@synthesize headLine;
@synthesize slugLine;
@synthesize thumbnailURL;
@synthesize webURL;
@synthesize thumbnailImage;

- (void)dealloc
{
    [date release];
    [type release];
    [headLine release];
    [slugLine release];
    [thumbnailURL release];
    [webURL release];
    [thumbnailImage release];
    [super dealloc];
}


@end
