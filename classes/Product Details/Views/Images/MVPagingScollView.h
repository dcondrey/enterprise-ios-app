//
// MVPagingScollView.h
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

#import <UIKit/UIKit.h>
#import "ImageLoader.h"

@class ImageScrollView;
@class Image;

@interface MVPagingScollView : UIViewController <UIScrollViewDelegate, ImageLoaderProtocol> {

	UIScrollView *pagingScrollView;
	NSArray *images;
	UIPageControl *pageControl;

	BOOL changedByPageControl;
	NSMutableSet *currentPages;
	NSMutableSet *queuedPages;

	int firstVisiblePageIndexBeforeRotation;
	CGFloat percentScrolledIntoFirstVisiblePage;

    UIButton *button;
    UIButton *button2;
    UIButton *button3;
    UIButton *button4;
    UIButton *button5;
    UIButton *button6;

    BOOL isFirst;

	id delegate;

}

@property (retain, nonatomic) IBOutlet UIScrollView *pagingScrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) NSArray *images;
@property (retain, nonatomic) NSString *panorama;
@property (retain, nonatomic) NSString *promovid;
@property (retain, nonatomic) NSString *bracketvid;
@property (retain, nonatomic) NSString *dynamicvid;
@property (retain, nonatomic) NSString *colorrendvid;
@property (retain, nonatomic) NSString *gscreenvid;

@property (nonatomic, assign) id delegate;

- (CGSize) contentSizeForPaging;
- (CGRect) frameSizeForPaging;
- (CGRect) frameForPageAtIndex:(NSUInteger) index;
- (void) newImageSet:(NSArray *)newImages;
- (void) logoImageSet:(UIImage *)logoImage;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (ImageScrollView *)dequeueRecycledPage;
- (IBAction) changePage:(id)sender;
- (void) refreshLayout;
- (void) handleSingleTap:(UIGestureRecognizer *)sender;
- (void) tilePages;
- (void) addPanorama:(NSString *)url;
- (void) addPromovid:(NSString *)url;
- (void) addBracketvid:(NSString *)url;
- (void) addDynamicvid:(NSString *)url;
- (void) addColorrendvid:(NSString *)url;
- (void) addGscreenvid:(NSString *)url;

@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;

@end
