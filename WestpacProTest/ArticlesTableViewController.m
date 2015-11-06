//
//  ArticlesTableViewController.m
//  WestpacProTest
//
//  Created by Vlad P on 23/09/2014.
//  Copyright (c) 2014 VladSoftware. All rights reserved.
//

#import "ArticlesTableViewController.h"
#import "ArticleTableViewCell.h"
#import "ImageDownloader.h"
#import "ArticleWebViewController.h"



@interface ArticlesTableViewController () {
    JSONFetcher *_jsonFetcher;
    NSMutableArray *_articleList;
    UIBarButtonItem *btnRefresh;
    
    NSMutableDictionary *_imageDownloaders;
}

@end




@implementation ArticlesTableViewController


#pragma mark - delegate methods
- (void) loadView {
    [super loadView];
    
    // Set own view title & Style
    [self setTitle:NSLocalizedString(@"NAV_ARTICLE_LIST_TITLE", nil)];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    // Set up Refresh Server Button
    btnRefresh = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"NAV_ARTICLE_LIST_REFRESH", nil)
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(refreshListAction)];
    self.navigationItem.leftBarButtonItem = btnRefresh;
    [btnRefresh release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _jsonFetcher = [JSONFetcher new];
    [_jsonFetcher setDelegate:self];
    [_jsonFetcher fetchJSONArticlesFrom:JSON_ARTICLE_URL];
    
    _imageDownloaders = [NSMutableDictionary new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // Cancel all image downloads
    #warning - TODO: Cancel all pending downloads in _imageDownloads dictionary
}


- (void)dealloc {
    [_articleList release];
    [_jsonFetcher release];
    [_imageDownloaders release];
    [super dealloc];
}



#pragma mark - Action methods
-(void) refreshListAction
{
    NSLog(@"Refreshing article list...");
    
    [btnRefresh setEnabled:NO];
    [btnRefresh setTitle:NSLocalizedString(@"NAV_ARTICLE_LIST_REFRESHING", nil)];
    
    [_articleList removeAllObjects];
    [_articleList release];
    _articleList = nil;
    
    [self.tableView reloadData];

    [_jsonFetcher fetchJSONArticlesFrom:JSON_ARTICLE_URL];
}



#pragma mark - JSON Fetcher delegate
- (void)gotJSONResponse:(NSMutableArray *)jsonDictionary response:(JSONFetcherServerResponse)response
{
    NSLog(@"JSON delegate callback to UI");
    [btnRefresh setEnabled:YES];
    [btnRefresh setTitle:NSLocalizedString(@"NAV_ARTICLE_LIST_REFRESH", nil)];
    
    if (response == FetcherDownloadOk){
        if (_articleList){
            [_articleList release];
            _articleList = nil;
        }
        _articleList = [jsonDictionary retain];
        
        [self.tableView reloadData];
    } else {
        [_articleList release];
        _articleList = nil;
        [self.tableView reloadData];
        
        // Show alert to user informing of error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                        message:NSLocalizedString(@"LOAD_ERROR_CONTENT", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (!_articleList)
        return 0;
    else
        return [_articleList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Adjust cell height based on space required
    return CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    ArticleTableViewCell *cell =  (ArticleTableViewCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Article *curArticle = [_articleList objectAtIndex:indexPath.row];
    [cell populateWithArticle:curArticle];  // Populate cell text and layout
    
    // If image already downloaded then load from memory else start downloader for cell
    if (curArticle.thumbnailImage) {
        cell.thumbnailImage.image = curArticle.thumbnailImage;
    } else {
        cell.thumbnailImage.image = [UIImage imageNamed:@"placeholder"];
        
        // Download image when user stops dragging
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
            [self startImageDownload:curArticle forIndexPath:indexPath];
        }
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create and Push web view controller
    ArticleWebViewController *articleWebView = [[ArticleWebViewController new] autorelease];
    
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:articleWebView animated:YES];
    
    [articleWebView loadPageForArticle:[_articleList objectAtIndex:indexPath.row]];
}



#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) {
        [self loadVisableCellImages];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadVisableCellImages];
}


#pragma mark - Image download methods

- (void)startImageDownload:(Article*)article forIndexPath:(NSIndexPath *)indexPath {
    
    if (!article.thumbnailURL) return;  // Skip imageless articles
    
    ImageDownloader *imgDownloader = [_imageDownloaders objectForKey:indexPath];
    if (imgDownloader == nil) {
        imgDownloader = [ImageDownloader new];
        [imgDownloader downloadImageFromUrl:article.thumbnailURL withCompletionHandler:^(UIImage *downloadedImage)
        {
            article.thumbnailImage = downloadedImage;

            ArticleTableViewCell *cell = (ArticleTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.thumbnailImage.image = article.thumbnailImage;
            
            [_imageDownloaders removeObjectForKey:indexPath];
        }];

        [_imageDownloaders setObject:imgDownloader forKey:indexPath];
        [imgDownloader release];
    }
}


- (void)loadVisableCellImages {
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths) {
        Article *visArticle = [_articleList objectAtIndex:indexPath.row];
        
        if (!visArticle.thumbnailImage) // Do not download if already has image
            [self startImageDownload:visArticle forIndexPath:indexPath];
    }
}



@end
