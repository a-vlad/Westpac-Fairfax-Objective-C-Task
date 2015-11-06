//
//  ArticleTableViewCell.m
//  WestpacProTest
//
//  Created by Vlad P on 23/09/2014.
//  Copyright (c) 2014 VladSoftware. All rights reserved.
//

#import "ArticleTableViewCell.h"
#import "UIColor+Custom.h"


@interface ArticleTableViewCell(){
    UILabel *_title;
    UILabel *_slugLine;
}
@end



@implementation ArticleTableViewCell
@synthesize thumbnailImage = _image;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        // Set cell bounds
        CGRect cellBoundsRect = CGRectMake(0, 0, self.bounds.size.width, CELL_HEIGHT);
        [self setBounds: cellBoundsRect];
        [self setClipsToBounds: YES]; // Set to ensure no overlap in subview outside of bounds
        [self setSelectionStyle: UITableViewCellSelectionStyleGray];
        
        // Init Image in remaining corner a
        _image = [UIImageView new];
        [_image setBackgroundColor:[UIColor clearColor]];
        [_image.layer setCornerRadius:CELL_CORNER_RADIUS];
        [_image setClipsToBounds:YES];
        [_image setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:_image];
        
        // Init Title Labels
        _title = [UILabel new];
        [_title setBackgroundColor:[UIColor clearColor]];
        [_title setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [_title setNumberOfLines:1];
        [_title setTextColor:[UIColor blackColor]];
        [_title setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:_title];

        // Init Slug Label
        _slugLine = [UILabel new];
        [_slugLine setBackgroundColor:[UIColor clearColor]];
        [_slugLine setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [_slugLine setNumberOfLines:3];
        [_slugLine setTextColor:[UIColor darkGrayColor]];
        [_slugLine setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:_slugLine];
                
        // Adds gradient as layer in cell backgroundView
        CAGradientLayer *gradLayer = [CAGradientLayer layer];
        NSArray *colors = [NSArray arrayWithObjects:
                           (id)[UIColor whiteColor].CGColor,
                           (id)[UIColor cellShadeGray].CGColor,
                           nil];
        [gradLayer setColors:colors];
        CGRect bkBounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, 1000, self.bounds.size.height);
        [gradLayer setFrame:bkBounds];
        UIView *bgView = [[UIView alloc] init];
        [bgView.layer insertSublayer:gradLayer atIndex:0];
        [self setBackgroundView:bgView];
        [bgView release];
    }
    
    return self;
}



- (void) populateWithArticle: (Article*) article {
    [_image setImage:nil];      // clear image
    
    if (article != nil) {
        [_title setText:article.headLine];
        [_slugLine setText:article.slugLine];
        
        // Load image
        if (article.thumbnailURL == nil) {
            [_image setHidden:YES];
            [self layoutConstraintsWithImage:NO];
        } else {
            [_image setHidden:NO];
            [self layoutConstraintsWithImage:YES];
        }
    }
}


#pragma mark - Autolayout constraint methods

- (void) layoutConstraintsWithImage:(BOOL)withImage {
    [self removeConstraints:self.constraints];  // Remove all current constraints
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-5-[_image(==90)]"
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(_image)]];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|-5-[_image(==90)]"
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(_image)]];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|-2-[_title(==20)]"
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(_title)]];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|-2-[_title]-10-[_slugLine]-5-|"
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(_title,_slugLine)]];
    
    if (withImage){
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:[_image]-10-[_title]-5-|"
                              options:0
                              metrics:nil
                              views:NSDictionaryOfVariableBindings(_image,_title)]];
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:[_image]-10-[_slugLine]-5-|"
                              options:0
                              metrics:nil
                              views:NSDictionaryOfVariableBindings(_image,_slugLine)]];
    }else {
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|-5-[_title]-5-|"
                              options:0
                              metrics:nil
                              views:NSDictionaryOfVariableBindings(_title)]];
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|-5-[_slugLine]-5-|"
                              options:0
                              metrics:nil
                              views:NSDictionaryOfVariableBindings(_slugLine)]];
    }
}

/*
 - (void)setSelected:(BOOL)selected animated:(BOOL)animated {
 [super setSelected:selected animated:animated];
 
 // Configure the view for the selected state
 }
*/

- (void) dealloc {
    [_title release];
    [_slugLine release];
    [_image release];
    [super dealloc];
}


@end
