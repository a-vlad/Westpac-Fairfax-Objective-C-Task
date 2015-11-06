//
//  JSONFetcher.h
//  WestpacProTest
//
//  Created by Vlad P on 23/09/2014.
//  Copyright (c) 2014 VladSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum  {
    FetcherDownloadOk = 0,
    FetcherDownloadFailed = 1
} JSONFetcherServerResponse;


/* Define delegate callback method with server response */
@protocol JSONFetcherDelegate <NSObject>
@required
// JSON dictionary with articles or nil if error
- (void)gotJSONResponse:(NSMutableArray *)jsonDictionary response:(JSONFetcherServerResponse)response;
@end



@interface JSONFetcher : NSObject

@property (nonatomic, assign) id <JSONFetcherDelegate> delegate;

- (void) fetchJSONArticlesFrom:(NSString *) urlPath;
- (void) closeConnection;

@end
