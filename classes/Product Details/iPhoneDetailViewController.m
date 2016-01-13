//
// iphonedetailviewcontroller.m
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

#import "iPhoneDetailViewController.h"
#import "MVPagingScollView.h"
#import "Category.h"
#import "Template.h"
#import "TemplateTab.h"
#import "DataSource.h"
#import "AppDelegate.h"
#import "MasterViewController.h"

#import "NewProjectController.h"
#import "Comment.h"
#import "DisplayProjectsController.h"
#import "SubmitController.h"
#import "Image.h"

@implementation iPhoneDetailViewController

@synthesize delegate = _delegate;
@synthesize detailCategory = _detailCategory;
@synthesize selectTabButton = _selectTabButton;
@synthesize detailTab2 = _detailTab2;
@synthesize detailTab3 = _detailTab3;
@synthesize detailWebView1 = _detailWebView1;
@synthesize detailWebView2 = _detailWebView2;
@synthesize detailWebView3 = _detailWebView3;
@synthesize imageTab = _imageTab;
@synthesize tabBar = _tabBar;
@synthesize imageView = _imageView;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize image360WebView;

UIWebView *webView360 = nil;
UIWebView *webViewPromo = nil;
UIWebView *webViewBracketing = nil;
UIWebView *webViewDynamic = nil;
UIWebView *webViewColor = nil;
UIWebView *webViewGreen = nil;

- (BOOL)hidesBottomBarWhenPushed { return TRUE; }

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.toolbar setBarStyle:UIBarStyleBlackTranslucent];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Jump to.." style:UIBarButtonItemStyleBordered target:self action:@selector(showMenu)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Projects" style:UIBarMetricsDefault  target:self action:@selector(showProjects)];

    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setValue:_detailCategory.identifier forKey:@"productID"];

    _detailCategory = [[DataSource sharedInstance] getProductDetails:request context:self.managedObjectContext];

    NSLog(@"TabOne:%@",_detailCategory.template.tabOne.tabName );
    NSLog(@"TabThree:%@",_detailCategory.template.tabThree.tabName );
    NSLog(@"TabFour:%@",_detailCategory.template.tabFour.tabName );


	self.navigationController.navigationBar.translucent = YES;

	pagingScrollView = [[MVPagingScollView alloc] initWithNibName:@"MVPagingScollView" bundle:nil];
	CGRect imageViewFrame = _imageView.frame;
	[_imageView insertSubview:pagingScrollView.view atIndex:0];
    pagingScrollView.view.frame = imageViewFrame;
	pagingScrollView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

    [pagingScrollView addPanorama:_detailCategory.panorama];
    [pagingScrollView addPromovid:_detailCategory.promovid];
    [pagingScrollView addBracketvid:_detailCategory.bracketvid];
    [pagingScrollView addColorrendvid:_detailCategory.colorrendvid];
    [pagingScrollView addDynamicvid:_detailCategory.dynamicvid];
    [pagingScrollView addGscreenvid:_detailCategory.gscreenvid];

    [self addChildViewController:pagingScrollView];

    if (_detailCategory.logo_image != nil && [_detailCategory.logo_image isEqualToString:@""] == NO) {
        UIImage *image = [UIImage imageNamed:_detailCategory.logo_image];
        [pagingScrollView logoImageSet:image];
    }

    NSMutableArray *imgs = [[NSMutableArray alloc] init];

    for(Image *img in _detailCategory.images) {

        if ([img.order intValue] >= 0) {
            [imgs addObject:img];
        }
    }
    [pagingScrollView newImageSet:imgs];
	pagingScrollView.delegate = self;

	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:path];

	_detailWebView1.opaque = NO;
	_detailWebView1.backgroundColor = [UIColor clearColor];

	_detailWebView2.opaque = NO;
	_detailWebView2.backgroundColor = [UIColor clearColor];

	_detailWebView3.opaque = NO;
	_detailWebView3.backgroundColor = [UIColor clearColor];

    NSString *htmlPath2;
    NSString *htmlPath3;

    BOOL html2Assigned = NO;
    BOOL html3Assigned = NO;

    NSMutableArray *tabBarSorted = [[_tabBar items] mutableCopy];
    [tabBarSorted removeAllObjects];

    NSLog(@"TabOne:%@",_detailCategory.template.tabOne.tabName );

    if ([_detailCategory.template.tabOne.tabName isEqualToString:@"specs"]) {
        [tabBarSorted insertObject:_imageTab atIndex:0];

    } else if (_detailCategory.template.tabOne.tabName != nil) {

        if (!html2Assigned) {
			htmlPath2 = [[NSBundle mainBundle] pathForResource:[_detailCategory.template.tabOne.tabTemplate stringByDeletingPathExtension] ofType:@"html"];
            html2Assigned =YES;

            [tabBarSorted insertObject:_detailTab2 atIndex:0];

        } else if (!html3Assigned) {
            htmlPath3 =[[NSBundle mainBundle] pathForResource:[_detailCategory.template.tabOne.tabTemplate stringByDeletingPathExtension] ofType:@"html"];
            html3Assigned = YES;

            [tabBarSorted insertObject:_detailTab3 atIndex:0];
        }
    }

    if ([_detailCategory.template.tabOne.tabName isEqualToString:@"specs"]) {
 		if (!html2Assigned) {
			htmlPath2 = [[NSBundle mainBundle] pathForResource:[_detailCategory.template.tabOne.tabTemplate stringByDeletingPathExtension] ofType:@"html"];
            html2Assigned =YES;

            [tabBarSorted insertObject:_detailTab2 atIndex:1];

        } else if (!html3Assigned) {
            htmlPath3 =[[NSBundle mainBundle] pathForResource:[_detailCategory.template.tabOne.tabTemplate stringByDeletingPathExtension] ofType:@"html"];
            html3Assigned = YES;

            [tabBarSorted insertObject:_detailTab3 atIndex:1];
        }
    }

    NSLog(@"TabThree:%@",_detailCategory.template.tabThree.tabName );

    if ([_detailCategory.template.tabThree.tabName isEqualToString:@"images"]) {
        [tabBarSorted insertObject:_imageTab atIndex:2];

    } else if (_detailCategory.template.tabThree.tabName != nil) {

        if (!html2Assigned) {
			htmlPath2 = [[NSBundle mainBundle] pathForResource:[_detailCategory.template.tabThree.tabTemplate stringByDeletingPathExtension] ofType:@"html"];
            html2Assigned =YES;

            [tabBarSorted insertObject:_detailTab2 atIndex:2];

        } else if (!html3Assigned) {
            htmlPath3 =[[NSBundle mainBundle] pathForResource:[_detailCategory.template.tabThree.tabTemplate stringByDeletingPathExtension] ofType:@"html"];
            html3Assigned = YES;

            [tabBarSorted insertObject:_detailTab3 atIndex:2];
        }
    }

    NSLog(@"TabFour:%@",_detailCategory.template.tabFour.tabName );

    if ([_detailCategory.template.tabFour.tabName isEqualToString:@"images"]) {
        [tabBarSorted insertObject:_imageTab atIndex:3];

    } else if (_detailCategory.template.tabFour.tabName != nil) {

        if (!html2Assigned) {
			htmlPath2 = [[NSBundle mainBundle] pathForResource:[_detailCategory.template.tabFour.tabTemplate stringByDeletingPathExtension] ofType:@"html"];
            html2Assigned =YES;

            [tabBarSorted insertObject:_detailTab2 atIndex:3];

        } else if (!html3Assigned) {
            htmlPath3 =[[NSBundle mainBundle] pathForResource:[_detailCategory.template.tabFour.tabTemplate stringByDeletingPathExtension] ofType:@"html"];
            html3Assigned = YES;

            [tabBarSorted insertObject:_detailTab3 atIndex:3];
        }
    }

    NSMutableString *rowHTMLCode, *kitRowHTMLCode;
	if (html2Assigned) {
        details2HTMLCode = [[NSMutableString alloc] initWithContentsOfFile:htmlPath2 usedEncoding:nil error:NULL];
        NSMutableString *rowHTMLPath = [[NSMutableString alloc] initWithString:htmlPath2];
        [rowHTMLPath replaceOccurrencesOfString:@".html" withString:@"_row.html" options:0 range:NSMakeRange(0, [rowHTMLPath length])];
        rowHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:rowHTMLPath usedEncoding:nil error:NULL];

    }

	if (html3Assigned) {
        details3HTMLCode = [[NSMutableString alloc] initWithContentsOfFile:htmlPath3 usedEncoding:nil error:NULL];

        NSMutableString *rowHTMLPath = [[NSMutableString alloc] initWithString:htmlPath3];
        [rowHTMLPath replaceOccurrencesOfString:@".html" withString:@"_row.html" options:0 range:NSMakeRange(0, [rowHTMLPath length])];
        kitRowHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:rowHTMLPath usedEncoding:nil error:NULL];

    }

    [self htmlTemplate:details2HTMLCode keyString:@"label" replaceWith:_detailCategory.label];
    [self htmlTemplate:details3HTMLCode keyString:@"label" replaceWith:_detailCategory.label];
 	[self htmlTemplate:details2HTMLCode keyString:@"sublabel" replaceWith:_detailCategory.sublabel];
    [self htmlTemplate:details3HTMLCode keyString:@"sublabel" replaceWith:_detailCategory.sublabel];

    for (NSString *tmpKey in (NSDictionary *) _detailCategory.details) {
        [self htmlTemplate:details2HTMLCode keyString:tmpKey replaceWith:[(NSDictionary*)_detailCategory.details objectForKey:tmpKey]];
        [self htmlTemplate:details3HTMLCode keyString:tmpKey replaceWith:[(NSDictionary*)_detailCategory.details objectForKey:tmpKey]];

    }

    NSMutableString *tab = [[NSMutableString alloc] initWithString:@""];
    NSString *rowStyle = @"";
    NSArray *keysNormal   = [[_detailCategory.details allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *tmpKey in keysNormal) {

        [tab appendString:rowHTMLCode];
        if ([rowStyle isEqualToString:@""]) {
            rowStyle = @"class=\"even\"";
        } else {
            rowStyle = @"";
        }
        [self htmlTemplate:tab keyString:@"row_style" replaceWith:rowStyle];
        [self htmlTemplate:tab keyString:@"spec_key" replaceWith:tmpKey];
        [self htmlTemplate:tab keyString:@"spec_val" replaceWith:[(NSDictionary*)_detailCategory.details objectForKey:tmpKey]];
    }
    [self htmlTemplate:details2HTMLCode keyString:@"spec_tab" replaceWith:tab];

    NSMutableString *kitTab = [[NSMutableString alloc] initWithString:@""];
    rowStyle = @"";
    int kitCount = [_detailCategory.kits count];
    for (int i = 0; i < kitCount; i++) {
        [kitTab appendString:kitRowHTMLCode];
        if ([rowStyle isEqualToString:@""]) {
            rowStyle = @"class=\"even\"";
        } else {
            rowStyle = @"";
        }

        [self htmlTemplate:kitTab keyString:@"row_style" replaceWith:rowStyle];
        NSString *val = [_detailCategory.kits objectAtIndex:i];
        NSArray *chunks = [val componentsSeparatedByString: @","];
        NSString *asset_val = [chunks objectAtIndex:0];
        NSString *qty_val = [chunks objectAtIndex:1];

        [self htmlTemplate:kitTab keyString:@"asset_val" replaceWith:asset_val];
        [self htmlTemplate:kitTab keyString:@"qty_val" replaceWith:qty_val];
    }

    [self htmlTemplate:details3HTMLCode keyString:@"kit_tab" replaceWith:kitTab];

    [_detailWebView2  loadHTMLString:details2HTMLCode baseURL:baseURL];
	[_detailWebView3  loadHTMLString:details3HTMLCode baseURL:baseURL];

    self.navigationController.navigationBar.translucent = NO;
    pagingScrollView.view.hidden = YES;
    _detailWebView1.hidden = YES;
	_detailWebView2.hidden = NO;
	_detailWebView3.hidden = YES;

	_tabBar.selectedItem = _detailTab2;

    [_tabBar setItems:tabBarSorted];
    [tabBarSorted release];

    Image *image360;
    for(Image *img in self.detailCategory.images) {
        if ([img.order intValue] < 0) {
            image360 = img;
        }
    }

    webView360 = nil;

    if (image360 != nil && ![image360.filename isEqualToString:@""]) {

        NSString *urlAddress = [image360 filename];

        NSLog(@"\n%@\n", urlAddress);


        CGRect webFrame = CGRectMake(-80.0, 80.0, 480.0, 320.0);
        webView360 = [[UIWebView alloc] initWithFrame:webFrame];

        NSURL *url = [NSURL URLWithString:urlAddress];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];

        [webView360 loadRequest:requestObj];
        [webView360 setHidden:YES];
        [self.view addSubview:webView360];
        [webView360 release];
	}
}

- (void) showMenu {
    if (_menu.isOpen) {
        return [_menu close];
    }

    REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:@"Return to Main Menu" subtitle:@"" image:[UIImage imageNamed:@"Icon_Home"] highlightedImage:nil action:^(REMenuItem *item) {

        MasterViewController *homeview = [[MasterViewController alloc] initWithNibName:@"RootView" bundle:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [homeview release];
    }];


    REMenuItem *backItem = [[REMenuItem alloc] initWithTitle:@"Previous Menu" subtitle:@"" image:[UIImage imageNamed:@"Icon_Explore"] highlightedImage:nil action:^(REMenuItem *item) {

        [self.navigationController popViewControllerAnimated:YES];
    }];

    REMenuItem *webItem = [[REMenuItem alloc] initWithTitle:@"Go to RadiantImages.com" subtitle:@"" image:[UIImage imageNamed:@"Icon_Explore"] highlightedImage:nil action:^(REMenuItem *item) {

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.radiantimages.com"]];
    }];

    REMenuItem *callItem = [[REMenuItem alloc] initWithTitle:@"Call Radiant Images" subtitle:@"Mon-Fri 9am to 6pm PST" image:[UIImage imageNamed:@"Icon_Explore"] highlightedImage:nil action:^(REMenuItem *item) {

        NSString *deviceName = [UIDevice currentDevice].model;

        if ([deviceName isEqualToString:@"iPhone"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://3237371314"]];

        } else { }

    }];

    homeItem.tag = 0;
    backItem.tag = 1;
    webItem.tag = 2;
    callItem.tag = 3;

    _menu = [[REMenu alloc] initWithItems:@[homeItem, backItem, webItem, callItem]];
    _menu.cornerRadius = 4;
    _menu.shadowColor = [UIColor blackColor];
    _menu.shadowOffset = CGSizeMake(0, 1);
    _menu.shadowOpacity = 1;
    _menu.imageOffset = CGSizeMake(5, -1);

    [_menu showFromNavigationController:self.navigationController];
}

- (void) showProjects {
    if (_menu.isOpen) {
        return [_menu close];
    }

    REMenuItem *cartNew = [[REMenuItem alloc] initWithTitle:@"Setup A New Project" subtitle:@"Enter your contact and project details." image:[UIImage imageNamed:@"Icon_Home"] highlightedImage:nil action:^(REMenuItem *item) {
        NewProjectController *newProjectController = [[NewProjectController alloc] init];

        newProjectController.delegate = (UIViewController *)self;
        [newProjectController.delegate.navigationController presentViewController:newProjectController animated:YES completion:nil];

        [newProjectController release];

    }];

    REMenuItem *cartList = [[REMenuItem alloc] initWithTitle:@"Display Your Projects" subtitle:@"Switch between projects to add gear." image:[UIImage imageNamed:@"Icon_Explore"] highlightedImage:nil action:^(REMenuItem *item) {
        DisplayProjectsController *displayProjectsController = [[DisplayProjectsController alloc] init];

        displayProjectsController.delegate = (UIViewController *)self;
        [displayProjectsController.delegate.navigationController presentViewController:displayProjectsController animated:YES completion:nil];

    }];

    REMenuItem *cartAdd = [[REMenuItem alloc] initWithTitle:@"Add to Cart" subtitle:@"" image:[UIImage imageNamed:@"Icon_Explore"] highlightedImage:nil action:^(REMenuItem *item) {

        Comment *commentController = [[Comment alloc] init];

        commentController.delegate = (UIViewController *)self;
        commentController.detailCategory = self.detailCategory;
        [commentController.delegate.navigationController presentViewController:commentController animated:YES completion:nil];

        [commentController release];
    }];

    REMenuItem *cartSend = [[REMenuItem alloc] initWithTitle:@"Submit Quote" subtitle:@"Send in your request to receive a quote." image:[UIImage imageNamed:@"Icon_Explore"] highlightedImage:nil action:^(REMenuItem *item) {

        SubmitController *submitController = [[SubmitController alloc] init];

        submitController.delegate = (UIViewController *)self;
        [submitController.delegate.navigationController presentViewController:submitController animated:YES completion:nil];
    }];
    cartAdd.tag = 0;
    cartList.tag = 1;
    cartNew.tag = 2;
    cartSend.tag = 3;

    _menu = [[REMenu alloc] initWithItems:@[cartAdd, cartList, cartNew, cartSend]];
    _menu.cornerRadius = 4;
    _menu.shadowColor = [UIColor blackColor];
    _menu.shadowOffset = CGSizeMake(0, 1);
    _menu.shadowOpacity = 1;
    _menu.imageOffset = CGSizeMake(5, -1);

    [_menu showFromNavigationController:self.navigationController];


}

- (void) viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) handleSingleTap:(UIGestureRecognizer *)sender {

	if (self.navigationController.navigationBarHidden == YES) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
		_tabBar.hidden = NO;
		CGRect imageViewFrame = pagingScrollView.view.frame;
		imageViewFrame.origin.x = 0;
		imageViewFrame.origin.y = 0;
		imageViewFrame.size.height = imageViewFrame.size.height - 49;
		pagingScrollView.view.frame = imageViewFrame;

	} else {

		[self.navigationController setNavigationBarHidden:YES animated:YES];
		_tabBar.hidden = YES;

		CGRect imageViewFrame = pagingScrollView.view.frame;
		imageViewFrame.origin.x = 0;
		imageViewFrame.origin.y = 0;
		imageViewFrame.size.height = imageViewFrame.size.height + 49;
		pagingScrollView.view.frame = imageViewFrame;
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:[request mainDocumentURL]];

        return NO;
	}
	return YES;
}

- (IBAction) itemAddButton:(id)sender {
    NSLog(@"ADD tapped");

    if (![[DataSource sharedInstance] isExistActiveProject]) {
        NSString *prod = @"default";
        NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
        [request setValue:prod forKey:@"project"];
        NSInteger rowId = [[DataSource sharedInstance] createProject:request];
    }

    NSString *count = [NSString stringWithFormat:@"1"];
    NSString *productId = _detailCategory.identifier;

    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setValue:count forKey:@"count"];
    [request setValue:productId forKey:@"productId"];

    [[DataSource sharedInstance] addToCurrentProject:request];

    DarkAlertView *confirmationAlert = [[DarkAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"Add %@ to your quote?", _detailCategory.label] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    [confirmationAlert show];
    [confirmationAlert release];
}

- (void) htmlTemplate:(NSMutableString *)templateString keyString:(NSString *)stringToReplace replaceWith:(NSString *)replacementString {

    if (replacementString != nil && [replacementString length] > 0) {
		[templateString replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@%%>",stringToReplace] withString:replacementString options:0 range:NSMakeRange(0, [templateString length])];
		[templateString	replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@Class%%>",stringToReplace] withString:@" " options:0 range:NSMakeRange(0, [templateString length])];

    } else {

		NSLog(@"keystring %@ is nil", stringToReplace);
		[templateString replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@%%>",stringToReplace] withString:@"" options:0 range:NSMakeRange(0, [templateString length])];
		[templateString	replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@Class%%>",stringToReplace] withString:@"invisible" options:0 range:NSMakeRange(0, [templateString length])];
	}
}

- (void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {

	if (item == _selectTabButton) {
        self.navigationController.navigationBar.translucent = NO;

	} else if (item == _imageTab) {
		self.navigationController.navigationBar.translucent = YES;

		pagingScrollView.view.hidden = NO;
		_detailWebView2.hidden = YES;
		_detailWebView3.hidden = YES;
		_detailWebView1.hidden = YES;

	} else if (item == _detailTab2) {
        self.navigationController.navigationBar.translucent = NO;

		pagingScrollView.view.hidden = YES;
		_detailWebView2.hidden = NO;
		_detailWebView3.hidden = YES;
		_detailWebView1.hidden = YES;

	} else if (item == _detailTab3) {
        self.navigationController.navigationBar.translucent = NO;

		pagingScrollView.view.hidden = YES;
		_detailWebView2.hidden = YES;
		_detailWebView3.hidden = NO;
		_detailWebView1.hidden = YES;
	}
}

- (void) dealloc {
    [super dealloc];
}

@end