//
// MVPagingScollView.m
//
// Created by Simon Sherrin
// Copyright (c) 2012 Museum Victoria
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MVPagingScollView.h"
#import "ImageScrollView.h"
#import "PanoramaViewController.h"
#import "GscreenvidViewController.h"
#import "PromovidViewController.h"
#import "ColorrendViewController.h"
#import "DynamicvidViewController.h"
#import "BracketvidViewController.h"
#import "Image.h"
#import "ImageLoader.h"
#import "DataSource.h"

@implementation MVPagingScollView

#define PAD  10

@synthesize images, delegate, pagingScrollView, pageControl;

@synthesize toolbar;
@synthesize panorama;
@synthesize promovid;
@synthesize bracketvid;
@synthesize dynamicvid;
@synthesize colorrendvid;
@synthesize gscreenvid;

NSMutableArray *_imageLoaders;

- (void) viewDidLoad {
    [super viewDidLoad];

	pagingScrollView.contentSize = [self contentSizeForPaging];
	pagingScrollView.delegate = self;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(20.0, 35.0, 75.0, 75.0);

        button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        button2.frame = CGRectMake(95.0, 35.0, 75.0, 75.0);

        button3 = [UIButton buttonWithType:UIButtonTypeCustom];
        button3.frame = CGRectMake(170.0, 35.0, 75.0, 75.0);

        button4 = [UIButton buttonWithType:UIButtonTypeCustom];
        button4.frame = CGRectMake(245.0, 35.0, 75.0, 75.0);

        button5 = [UIButton buttonWithType:UIButtonTypeCustom];
        button5.frame = CGRectMake(320.0, 35.0, 75.0, 75.0);

        button6 = [UIButton buttonWithType:UIButtonTypeCustom];
        button6.frame = CGRectMake(395.0, 35.0, 75.0, 75.0);
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {

        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(40.0, 65.0, 60.0, 60.0);

        button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        button2.frame = CGRectMake(120.0, 65.0, 60.0, 60.0);

        button3 = [UIButton buttonWithType:UIButtonTypeCustom];
        button3.frame = CGRectMake(210.0, 65.0, 60.0, 60.0);

        button4 = [UIButton buttonWithType:UIButtonTypeCustom];
        button4.frame = CGRectMake(40.0, 368.5, 60.0, 60.0);

        button5 = [UIButton buttonWithType:UIButtonTypeCustom];
        button5.frame = CGRectMake(120.0, 368.5, 60.0, 60.0);

        button6 = [UIButton buttonWithType:UIButtonTypeCustom];
        button6.frame = CGRectMake(210.0, 368.5, 60.0, 60.0);
    }

    [button setBackgroundImage:[UIImage imageNamed:@"pano.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(loadPanorama:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    button.hidden = YES;

    [button2 setBackgroundImage:[UIImage imageNamed:@"under.png"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(loadPromo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    button2.hidden = YES;

    [button3 setBackgroundImage:[UIImage imageNamed:@"bracket.png"] forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(loadBracket:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    button3.hidden = YES;

    [button4 setBackgroundImage:[UIImage imageNamed:@"over.png"] forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(loadDynamic:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4];
    button4.hidden = YES;

    [button5 setBackgroundImage:[UIImage imageNamed:@"color.png"] forState:UIControlStateNormal];
    [button5 addTarget:self action:@selector(loadColor:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button5];
    button5.hidden = YES;

    [button6 setBackgroundImage:[UIImage imageNamed:@"composite.png"] forState:UIControlStateNormal];
    [button6 addTarget:self action:@selector(loadGreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button6];
    button6.hidden = YES;

	currentPages = [[NSMutableSet alloc] init];
	queuedPages	= [[NSMutableSet alloc] init];

    isFirst = YES;

	[self tilePages];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
    {
        self.view.frame = CGRectMake(0, 0, 320, 480);
    }

}

- (void) addPanorama:(NSString *)url {

        if (url != nil && [url compare:@""] != 0) {
            button.hidden = NO;
            panorama = url;
        } else {
            button.hidden = YES;
        }
}

- (void) addPromovid:(NSString *)url {

        if (url != nil && [url compare:@""] != 0) {
            button2.hidden = NO;
            promovid = url;
        } else {
            button2.hidden = YES;
        }
}

- (void) addBracketvid:(NSString *)url {

        if (url != nil && [url compare:@""] != 0) {
            button3.hidden = NO;
            bracketvid = url;
        } else {
            button3.hidden = YES;
        }
}

- (void) addDynamicvid:(NSString *)url {

        if (url != nil && [url compare:@""] != 0) {
            button4.hidden = NO;
            dynamicvid = url;
        } else {
            button4.hidden = YES;
        }
}

- (void) addColorrendvid:(NSString *)url {

        if (url != nil && [url compare:@""] != 0) {
            button5.hidden = NO;
            colorrendvid = url;
        } else {
            button5.hidden = YES;
        }
}

- (void) addGscreenvid:(NSString *)url {

        if (url != nil && [url compare:@""] != 0) {
            button6.hidden = NO;
            gscreenvid = url;
        } else {
            button6.hidden = YES;
        }
}

- (void) loadPanorama:(id) sender {
    NSLog(@"call=============================================1");
    PanoramaViewController *panoramaController = [[PanoramaViewController alloc] initWithNibName:@"PanoramaViewController" bundle:nil];
    panoramaController.delegate = (UIViewController *)self;
    panoramaController.panorama = panorama;
    [panoramaController.delegate.parentViewController presentViewController:panoramaController animated:YES completion:nil];
    [panoramaController release];
}

- (void) loadPromo:(id) sender {
     NSLog(@"call=============================================2");
    PromovidViewController *promovidController = [[PromovidViewController alloc] initWithNibName:@"PromovidViewController" bundle:nil];
    promovidController.delegate = (UIViewController *)self;
    promovidController.promovid = promovid;
    [promovidController.delegate.parentViewController presentViewController:promovidController animated:YES completion:nil];
    [promovidController release];

}

- (void) loadBracket:(id) sender {
     NSLog(@"call=============================================3");
    BracketvidViewController *bracketvidController = [[BracketvidViewController alloc] initWithNibName:@"BracketvidViewController" bundle:nil];
    bracketvidController.delegate = (UIViewController *)self;
    bracketvidController.bracketvid = bracketvid;
    [bracketvidController.delegate.parentViewController presentViewController:bracketvidController animated:YES completion:nil];
    [bracketvidController release];

}

- (void) loadDynamic:(id) sender {
     NSLog(@"call=============================================4");
    DynamicvidViewController *dynamicvidController = [[DynamicvidViewController alloc] initWithNibName:@"DynamicvidViewController" bundle:nil ];
    dynamicvidController.delegate = (UIViewController *)self;
    dynamicvidController.dynamicvid = dynamicvid;
    [dynamicvidController.delegate.parentViewController presentViewController:dynamicvidController animated:YES completion:nil];
    [dynamicvidController release];

}

- (void) loadColor:(id) sender {
     NSLog(@"call=============================================5");
    ColorrendViewController *colorrendvidController = [[ColorrendViewController alloc] initWithNibName:@"ColorrendViewController" bundle:nil];
    colorrendvidController.delegate = (UIViewController *)self;
    colorrendvidController.colorrendvid = colorrendvid;
    [colorrendvidController.delegate.parentViewController presentViewController:colorrendvidController animated:YES completion:nil];
    [colorrendvidController release];

}

- (void) loadGreen:(id) sender {
     NSLog(@"call=============================================6");
    GscreenvidViewController *gscreenvidController = [[GscreenvidViewController alloc] initWithNibName:@"GscreenvidViewController" bundle:nil];
    gscreenvidController.delegate = (UIViewController *)self;
    gscreenvidController.gscreenvid = gscreenvid;
    [gscreenvidController.delegate.parentViewController presentViewController:gscreenvidController animated:YES completion:nil];
    [gscreenvidController release];

}

- (void) layoutSubviews { }

- (void) logoImageSet:(UIImage *)logoImage {
    pageControl.numberOfPages = 1;

    CGRect bounds = pagingScrollView.bounds;
	CGSize csize = CGSizeMake(bounds.size.width * 1, bounds.size.height);

    pagingScrollView.contentSize = csize;

    [currentPages minusSet:queuedPages];
	[pagingScrollView scrollRectToVisible:[self frameForPageAtIndex:0] animated:YES];

    for (ImageScrollView *page in currentPages) {

        if (page.index == 0) {
            [page displayImage:logoImage];
            break;
        }
    }
}

- (void) newImageSet:(NSArray *)newImages {

	if (newImages == nil)
        return;

    self.images = newImages;

	pageControl.numberOfPages = [self.images count];
	pagingScrollView.contentSize = [self contentSizeForPaging];

    [_imageLoaders removeAllObjects];
    for(int index = 0; index < [self.images count]; index++) {
        Image *img = [self.images objectAtIndex:index];
        NSString *path = [[[DataSource sharedInstance] imagePath2] stringByAppendingPathComponent:img.filename];

        NSLog(@"%@", path);

        ImageLoader *loader = [[[ImageLoader alloc] initWithURL:[[NSURL alloc] initWithString:path]] retain];
        loader.index = index;
        [loader setDelegate:self];
        [_imageLoaders addObject:loader];
        [loader load];
    }

	[self tilePages];
}

- (void) imageLoader:(ImageLoader *)loader didReceiveError:(NSError *)anError {
    [_imageLoaders removeObject:loader];
    [loader release];
}

- (void) imageLoader:(ImageLoader *)imageLoader didLoadImage:(UIImage *)anImage {
    [imageLoader setDelegate:nil];

    if (imageLoader.image != nil) {
		for (ImageScrollView *page in currentPages) {

            if (page.index == imageLoader.index) {
                [page displayImage:imageLoader.image];
                break;
            }
        }
    }
}

- (CGRect) frameForPageAtIndex:(NSUInteger) index {

    CGRect bounds = self.view.bounds;
	CGRect pageFrame = bounds;
	pageFrame.size.width -= ( 2* PAD);
	pageFrame.origin.x = (bounds.size.width * index) + PAD;
	return pageFrame;
}

- (CGSize) contentSizeForPaging {

    int imageCount = [self.images count];

	CGRect bounds = pagingScrollView.bounds;
	return CGSizeMake(bounds.size.width * imageCount, bounds.size.height);
}

- (CGRect) frameSizeForPaging {
	CGRect parentFrame = self.view.bounds;
	parentFrame.origin.x -= PAD;
	parentFrame.size.width += (2 * PAD );
	return parentFrame;
}

- (UIImage *) imageAtIndex:(NSUInteger)index {

    for(ImageLoader *loader in _imageLoaders) {
        if (loader.index == index) {
            return loader.image;
        }
    }
    return nil;
}

- (void) configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index {
	page.index = index;
	page.frame = [self frameForPageAtIndex:index];

    [page displayImage:[self imageAtIndex:index]];

}

- (IBAction) changePage:(id)sender {
	int page = pageControl.currentPage;
	changedByPageControl = YES;

	[pagingScrollView scrollRectToVisible:[self frameForPageAtIndex:page] animated:YES];
}

- (void) tilePages {

    CGRect visibleBounds = pagingScrollView.bounds;

	int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [self.images count] - 1);

	    for (ImageScrollView *page in currentPages) {

			if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
            [queuedPages addObject:page];
            [page removeFromSuperview];
        }
    }

    [currentPages minusSet:queuedPages];

    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            ImageScrollView *page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[[ImageScrollView alloc] init] autorelease];
            }

            [self configurePage:page forIndex:index];
            [pagingScrollView addSubview:page];
			page.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [currentPages addObject:page];
        }
    }
	if (changedByPageControl) { }

	else {
		CGFloat pageWidth = pagingScrollView.bounds.size.width;
		int currentpage = floor((pagingScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

        if (currentpage >= 0 && currentpage <= ([self.images count]-1)) {

				pageControl.currentPage = currentpage;
        }
    }
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    changedByPageControl = NO;
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    changedByPageControl = NO;
}

- (ImageScrollView *)dequeueRecycledPage {
    ImageScrollView *page = [queuedPages anyObject];

    if (page) {
        [[page retain] autorelease];
        [queuedPages removeObject:page];
    }

	return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    BOOL foundPage = NO;

    for (ImageScrollView *page in currentPages) {

        if (page.index == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self tilePages];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    else
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {

    CGFloat offset = pagingScrollView.contentOffset.x;
    CGFloat pageWidth = pagingScrollView.bounds.size.width;

	if (offset >= 0) {
        firstVisiblePageIndexBeforeRotation = floorf(offset / pageWidth);
        percentScrolledIntoFirstVisiblePage = (offset - (firstVisiblePageIndexBeforeRotation * pageWidth)) / pageWidth;

    } else {

        firstVisiblePageIndexBeforeRotation = 0;
        percentScrolledIntoFirstVisiblePage = offset / pageWidth;
    }
    }
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    pagingScrollView.contentSize = [self contentSizeForPaging];
    NSLog(@"pagingScrollView.contentSize:%f,%f", pagingScrollView.contentSize.width, pagingScrollView.contentSize.height);

    for (ImageScrollView *page in currentPages) {
        CGPoint restorePoint = [page pointToCenterAfterRotation];
        CGFloat restoreScale = [page scaleToRestoreAfterRotation];
        page.frame = [self frameForPageAtIndex:page.index];
        [page setMaxMinZoomScalesForCurrentBounds];
        [page restoreCenterPoint:restorePoint scale:restoreScale];
    }

    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    CGFloat newOffset = (firstVisiblePageIndexBeforeRotation * pageWidth) + (percentScrolledIntoFirstVisiblePage * pageWidth);
    pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
    }
}

- (void) refreshLayout {

	for (ImageScrollView *page in currentPages) {
    CGPoint restorePoint = [page pointToCenterAfterRotation];
    CGFloat restoreScale = [page scaleToRestoreAfterRotation];

	[page setMaxMinZoomScalesForCurrentBounds];
	[page restoreCenterPoint:restorePoint scale:restoreScale];
	[page setZoomScale:(page.minimumZoomScale +0.1) animated:NO];
	[page setZoomScale:page.minimumZoomScale animated:YES];
    }
}

- (void) handleSingleTap:(UIGestureRecognizer *)sender {}

- (void) handleDoubleTap:(UIGestureRecognizer *)sender { }

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload {
    [super viewDidUnload];

	self.delegate = nil;
	self.images = nil;
	self.pagingScrollView = nil;
	self.pageControl = nil;
}


- (void) dealloc {
    for(int i = 0; i < [_imageLoaders count]; i++) {
        ImageLoader *loader = (ImageLoader *)[_imageLoaders objectAtIndex:i];
        [loader cancel];
        [loader setDelegate:nil];
        [loader release];
        loader = nil;
    }
    [_imageLoaders removeAllObjects];
    [_imageLoaders release];


    [pagingScrollView release];
	[pageControl release];
	[images release];
	[currentPages release];
	[queuedPages release];
    [super dealloc];
}

@end