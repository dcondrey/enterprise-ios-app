//
// iphonedetailviewcontroller.h
//
// Copyright (c) 2013 David Condrey
//
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
//

#import <UIKit/UIKit.h>
#import "REMenu.h"
#import "DarkAlertView.h"

@class Category;
@class MVPagingScollView;

@interface iPhoneDetailViewController : UIViewController <UIAlertViewDelegate,UITabBarControllerDelegate,UITabBarDelegate> {

	MVPagingScollView *pagingScrollView;

	NSMutableString *details1HTMLCode;
	NSMutableString *details2HTMLCode;
	NSMutableString *details3HTMLCode;

}

@property (strong, nonatomic) REMenu *menu;

@property (strong, nonatomic) Category *detailCategory;
@property (retain, nonatomic) IBOutlet UIWebView *detailWebView1;
@property (retain, nonatomic) IBOutlet UIWebView *detailWebView2;
@property (retain, nonatomic) IBOutlet UIWebView *detailWebView3;

@property (retain, nonatomic) IBOutlet UIView *imageView;
@property (nonatomic, retain) UIButton *itemAddButton;

@property (retain, nonatomic) IBOutlet UIWebView *image360WebView;

@property (retain, nonatomic) IBOutlet UITabBar *tabBar;
@property (retain, nonatomic) IBOutlet UITabBarItem *imageTab;
@property (retain, nonatomic) IBOutlet UITabBarItem *selectTabButton;
@property (retain, nonatomic) IBOutlet UITabBarItem *detailTab2;
@property (retain, nonatomic) IBOutlet UITabBarItem *detailTab3;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong) NSObject *delegate;

- (IBAction) itemAddButton:(id)sender;

- (void) htmlTemplate:(NSMutableString *)templateString keyString:(NSString *)stringToReplace replaceWith:(NSString *)replacementString;

- (BOOL) hidesBottomBarWhenPushed;

@end


