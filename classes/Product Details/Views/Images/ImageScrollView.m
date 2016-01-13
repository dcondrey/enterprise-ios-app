//
// ImageScrollView.m
//
// Abstract: Centers image within the scroll view and configures image sizing and display.
// Based on ImageScollView Version: 1.1 by Apple
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

#import "ImageScrollView.h"

@implementation ImageScrollView
@synthesize index;
@synthesize imageView;


- (id)initWithFrame:(CGRect)frame {

	if ((self = [super initWithFrame:frame])) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;

        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;

    }

	UITapGestureRecognizer *singleFingerDTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleDoubleTap:)];

	singleFingerDTap.numberOfTapsRequired = 2;

    [self addGestureRecognizer:singleFingerDTap];
    [singleFingerDTap release];

	return self;
}

- (void) dealloc {
	self.delegate = nil;

	[imageView release];

	[super dealloc];
}

- (void) handleSingleDoubleTap:(UIGestureRecognizer *)sender{

	if (self.zoomScale == self.maximumZoomScale) {
		[self setZoomScale:self.minimumZoomScale animated:YES];

	} else {

		[self setZoomScale:self.maximumZoomScale animated:YES];
	}


}

- (void) handleSingleTap:(UIGestureRecognizer *)sender  { }

- (void) layoutSubviews {
    [super layoutSubviews];

	CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = imageView.frame;

    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;

    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;

    imageView.frame = frameToCenter;


}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

- (void) displayImage:(UIImage *)image {
    // clear the previous imageView
    [imageView removeFromSuperview];
    [imageView release];
    imageView = nil;

    // reset zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;

    // make a new UIImageView for the new image
    imageView = [[UIImageView alloc] initWithImage:image];

	[self addSubview:imageView];

    self.contentSize = [image size];
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;

}

- (void) setMaxMinZoomScalesForCurrentBounds {
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = imageView.bounds.size;

    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];

    if (minScale > maxScale) {
        minScale = maxScale;
    }

    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
}

- (CGPoint)pointToCenterAfterRotation {
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    return [self convertPoint:boundsCenter toView:imageView];
}

- (CGFloat)scaleToRestoreAfterRotation {
    CGFloat contentScale = self.zoomScale;

    if (contentScale <= self.minimumZoomScale + FLT_EPSILON)
        contentScale = 0;

    return contentScale;
}

- (CGPoint)maximumContentOffset {
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset {
    return CGPointZero;
}

- (void) restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale {
    self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, oldScale));
    CGPoint boundsCenter = [self convertPoint:oldCenter fromView:imageView];
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0, boundsCenter.y - self.bounds.size.height / 2.0);
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
    offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
    self.contentOffset = offset;
}

@end
