//
// detailviewcontroller.m
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

#import "DetailViewController.h"
#import "VariableStore.h"
#import "MVPagingScollView.h"
#import "Category.h"
#import "Group.h"
#import "Template.h"
#import "CustomSearchViewController.h"
#import "NewProjectController.h"
#import "DisplayProjectsController.h"
#import "Comment.h"
#import "SubmitController.h"
#import "DataSource.h"
#import "Image.h"

@interface DetailViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void) configureView;

@end

@implementation DetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize titleBarLabel = _titleBarLabel;
@synthesize detailsWebView = _detailsWebView;
@synthesize searchPopoverButton = _searchPopoverButton;

@synthesize imageTextLayoutControl = _imageTextLayoutControl;
@synthesize imageView = _imageView;
@synthesize detailView = _detailView;
@synthesize aboutView = _aboutView;
@synthesize welcomeView = _welcomeView;
@synthesize startButtonView = _startButtonView;
//toolbar properties
@synthesize detailToolbar = _detailToolbar;
@synthesize imageScrollView = _imageScrollView;
@synthesize detailCategory = _detailCategory;
@synthesize currentGroupLabel = _currentGroupLabel;
//startup properties
@synthesize orientationLock = _orientationLock;
@synthesize managedObjectContext = __managedObjectContext;

- (void) setDetailCategory:(Category *)detailCategory {

        _aboutView.hidden = YES;
		_welcomeView.hidden =YES;
        _startButtonView.hidden = YES;//remove tap to begin gesture recogniser

        if (_detailCategory != detailCategory) {
            [_detailCategory release];
            _detailCategory = [detailCategory retain];
			// Update the view.
            [self configureView];

		}

	[self dismissAllPopovers];
}


- (void) dismissAllPopovers {
    if (self.masterPopoverController != nil) {
		//Hide search popover
        [self.masterPopoverController dismissPopoverAnimated:YES];
	}

    if (_searchPopoverController != nil) {
        [_searchPopoverController dismissPopoverAnimated:YES];
    }
}

- (void) configureView {
	// Update the user interface for the detail item.
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setValue:_detailCategory.identifier forKey:@"productID"];

    _detailCategory = [[DataSource sharedInstance] getProductDetails:request context:self.managedObjectContext];
    [_imageScrollView addPanorama:_detailCategory.panorama];
    [_imageScrollView addPromovid:_detailCategory.promovid];
    [_imageScrollView addBracketvid:_detailCategory.bracketvid];
    [_imageScrollView addColorrendvid:_detailCategory.colorrendvid];
    [_imageScrollView addDynamicvid:_detailCategory.dynamicvid];
    [_imageScrollView addGscreenvid:_detailCategory.gscreenvid];

	_titleBarLabel.text = _detailCategory.label;

	//if portrait mode
	if (self.interfaceOrientation== UIInterfaceOrientationPortraitUpsideDown || self.interfaceOrientation == UIInterfaceOrientationPortrait)  {

		UIBarButtonItem *barButtonItem = [[_detailToolbar items] objectAtIndex:0];
		if ([_detailCategory.group.label length] >13) {
			_currentGroupLabel = [_detailCategory.group.label stringByReplacingCharactersInRange:NSMakeRange(10, [_detailCategory.group.label length]-10) withString:@"..."];

        } else {
           _currentGroupLabel  = _detailCategory.group.label;
		}
        barButtonItem.title = _currentGroupLabel;
	}

	//Set Up images controller
    if (_detailCategory.logo_image != nil && [_detailCategory.logo_image isEqualToString:@""] == NO) {
        UIImage *image = [UIImage imageNamed:_detailCategory.logo_image];
        [_imageScrollView logoImageSet:image];
    }

    NSLog(@"imageArrayCount=%i", [_detailCategory.images count]);

    NSMutableArray *imgs = [[NSMutableArray alloc] init];
    for(Image *img in _detailCategory.images) {
        if ([img.order intValue] >= 0) {
            [imgs addObject:img];
        }
    }

	[_imageScrollView newImageSet:imgs];
    _imageScrollView.delegate = (UIViewController *)self;

	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:path];

	_detailsWebView.opaque = NO;
	_detailsWebView.backgroundColor = [UIColor clearColor];

	//Replace template fields in HTML with values.
	NSString *htmlPath;

    NSLog(@"Template File: %@", _detailCategory.template.tabletTemplate);

	if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:[_detailCategory.template.tabletTemplate stringByDeletingPathExtension] ofType:@"html"]]) {

		htmlPath = [[NSBundle mainBundle] pathForResource:[_detailCategory.template.tabletTemplate stringByDeletingPathExtension] ofType:@"html"];

	} else {
        htmlPath = [[NSBundle mainBundle] pathForResource:@"template-ipad" ofType:@"html"];
	}

	NSMutableString *baseHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:htmlPath usedEncoding:nil error:NULL];

    NSMutableString *spec_rowHTMLPath = [[NSMutableString alloc] initWithString:htmlPath];
    NSMutableString *kit_rowHTMLPath = [[NSMutableString alloc] initWithString:htmlPath];

    [spec_rowHTMLPath replaceOccurrencesOfString:@".html" withString:@"-specrow.html" options:0 range:NSMakeRange(0, [spec_rowHTMLPath length])];
    NSMutableString *specrowHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:spec_rowHTMLPath usedEncoding:nil error:NULL];

    [self htmlTemplate:baseHTMLCode keyString:@"label" replaceWith:_detailCategory.label];
	[self htmlTemplate:baseHTMLCode keyString:@"sublabel" replaceWith:_detailCategory.sublabel];
    [self htmlTemplate:baseHTMLCode keyString:@"productsummary" replaceWith:_detailCategory.description];

    NSMutableString *tab = [[NSMutableString alloc] initWithString:@"<"];
    NSString *rowStyle = @"";
    NSLog(@"%@",_detailCategory.details);

    NSArray *keysNormal   = [[_detailCategory.details allKeys] sortedArrayUsingSelector:@selector(compare:)];

    for(NSString *tmpKey in keysNormal) {

        [tab appendString:specrowHTMLCode];
        if ([rowStyle isEqualToString:@""]) rowStyle = @"class=\"even\"";

        else rowStyle = @"";

        [self htmlTemplate:tab keyString:@"row_style" replaceWith:rowStyle];
        [self htmlTemplate:tab keyString:@"spec_key" replaceWith:tmpKey];
        [self htmlTemplate:tab keyString:@"spec_val" replaceWith:[(NSDictionary*)_detailCategory.details objectForKey:tmpKey]];
       NSLog(@"%@",tmpKey);
    }

    [self htmlTemplate:baseHTMLCode keyString:@"spec_tab" replaceWith:tab];

    [kit_rowHTMLPath replaceOccurrencesOfString:@".html" withString:@"-kitrow.html" options:0 range:NSMakeRange(0, [kit_rowHTMLPath length])];
    NSMutableString *kitrowHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:kit_rowHTMLPath usedEncoding:nil error:NULL];
    NSMutableString *kitTab = [[NSMutableString alloc] initWithString:@""];
    rowStyle = @"";

    int kitCount = [_detailCategory.kits count];
    for (int i = 0; i < kitCount; i++) {
        [kitTab appendString:kitrowHTMLCode];
        if ([rowStyle isEqualToString:@""])
            rowStyle = @"class=\"even\"";
        else rowStyle = @"";

        [self htmlTemplate:kitTab keyString:@"row_style" replaceWith:rowStyle];
        NSString *val = [_detailCategory.kits objectAtIndex:i];
        NSArray *chunks = [val componentsSeparatedByString: @","];
        NSString *asset_val = [chunks objectAtIndex:0];
        NSString *qty_val = [chunks objectAtIndex:1];

        [self htmlTemplate:kitTab keyString:@"asset_val" replaceWith:asset_val];
        [self htmlTemplate:kitTab keyString:@"qty_val" replaceWith:qty_val];

    }
    [self htmlTemplate:baseHTMLCode keyString:@"kit_tab" replaceWith:kitTab];

	[_detailsWebView loadHTMLString:baseHTMLCode baseURL:baseURL];
	[baseHTMLCode release];
}

- (void) htmlTemplate:(NSMutableString *)templateString keyString:(NSString *)stringToReplace replaceWith:(NSString *)replacementString {

	if (replacementString != nil && [replacementString length] > 0) {
		[templateString replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@%%>",stringToReplace] withString:replacementString options:0 range:NSMakeRange(0, [templateString length])];
		[templateString	replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@Class%%>",stringToReplace] withString:@" " options:0 range:NSMakeRange(0, [templateString length])];

	} else {
		[templateString replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@%%>",stringToReplace] withString:@"" options:0 range:NSMakeRange(0, [templateString length])];
		[templateString	replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@Class%%>",stringToReplace] withString:@"invisible" options:0 range:NSMakeRange(0, [templateString length])];
    }
}

- (void) viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];

    singleFingerTap.numberOfTapsRequired = 1;
   	[_startButtonView addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];

	_searchViewController = [[CustomSearchViewController alloc] init];
	_searchViewController.rightViewReference = self;
    _searchViewController.managedObjectContext = __managedObjectContext;
	//Setup Popover
	_searchPopoverController = [[UIPopoverController alloc] initWithContentViewController:_searchViewController];
	_searchPopoverController.passthroughViews =[NSArray arrayWithObject:_detailToolbar];

    _commentController = [[Comment alloc] init];
    _cartPopoverController =[[UIPopoverController alloc] initWithContentViewController:_commentController];
    _cartPopoverController.passthroughViews =[NSArray arrayWithObject:_detailToolbar];

	detailsTopLeft = 551;
	detailsViewRaised = NO;
    self.currentGroupLabel = NSLocalizedString(@"Catalog", nil);

   	NSString *aboutPath = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
	NSString *welcomePath = [[NSBundle mainBundle] pathForResource:@"welcome" ofType:@"html"];

    _aboutView.opaque = NO;
	_aboutView.backgroundColor = [UIColor blackColor];

	NSMutableString *aboutHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:aboutPath usedEncoding:nil error:NULL];
  	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:path];

	[_aboutView loadHTMLString:aboutHTMLCode baseURL:baseURL];
    _aboutView.hidden = YES;
	_welcomeView.opaque = NO;
	_welcomeView.backgroundColor = [UIColor blackColor];

    [self showWelcomeView];
	NSMutableString *welcomeHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:welcomePath usedEncoding:nil error:NULL];
	[_welcomeView loadHTMLString:welcomeHTMLCode baseURL:baseURL];

    _imageScrollView = [[MVPagingScollView alloc] initWithNibName:@"MVPagingScollView" bundle:nil];
	CGRect imageViewFrame = self.imageView.frame;

	NSLog(@"FrameSize:%f,%f", imageViewFrame.size.width, imageViewFrame.size.height);
	NSLog(@"OriginSize:%f,%f", imageViewFrame.origin.x, imageViewFrame.origin.y);

	imageViewFrame.origin.x = 0;
	imageViewFrame.origin.y = 0;
	_imageScrollView.view.frame = imageViewFrame;
	_imageScrollView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

	[self.imageView addSubview:_imageScrollView.view];
    [self addChildViewController:_imageScrollView];

	[aboutHTMLCode release];
	[welcomeHTMLCode release];

    [self configureView];
}

- (void) setCategory:(Category*)newCategory {

	if (_detailCategory != newCategory) {
        [_detailCategory release];
		_detailCategory = [newCategory retain];
        NSLog(@"new cat");
		[self configureView];
	}
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
    return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [_detailsWebView reload];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[_imageScrollView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	CGRect currentDetailsRect = _detailView.frame;
	CGRect currentImageRect = _imageView.frame;
	CGRect currentParentViewRect = self.view.frame;

	if (_imageTextLayoutControl.selectedSegmentIndex == 0) {
		currentDetailsRect.origin.y = 44;
		currentDetailsRect.size.height = currentParentViewRect.size.height - 44;

	} else {
		if (_imageTextLayoutControl.selectedSegmentIndex==1) {
			currentDetailsRect.origin.y = detailsTopLeft;
			currentDetailsRect.size.height = currentParentViewRect.size.height - detailsTopLeft;
			currentImageRect.size.height = detailsTopLeft - 44;
		} else {
			currentDetailsRect.origin.y = currentParentViewRect.size.height;
			currentImageRect.size.height = currentParentViewRect.size.height-44;
			currentParentViewRect.origin.x =0;
		}
	}

	_detailView.frame = currentDetailsRect;
	_imageView.frame = currentImageRect;
	self.view.frame = currentParentViewRect;
	[_imageScrollView willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
}

- (void) changeDetailsView:(id)sender {

    CGRect currentDetailsRect = _detailView.frame;
    CGRect currentImageRect = _imageView.frame;
    CGRect currentParentViewRect = self.view.frame;

    if (_imageTextLayoutControl.selectedSegmentIndex == 0) {
        currentDetailsRect.origin.y = 44;
        currentDetailsRect.size.height = currentParentViewRect.size.height - 44;

    } else {
        if (_imageTextLayoutControl.selectedSegmentIndex==1) {
            currentDetailsRect.origin.y = detailsTopLeft;
            currentDetailsRect.size.height = currentParentViewRect.size.height - detailsTopLeft;
            currentImageRect.size.height = detailsTopLeft - 44;

        } else {
            currentDetailsRect.origin.y = currentParentViewRect.size.height;
            currentImageRect.size.height = currentParentViewRect.size.height-44;
        }
    }

    [UIView animateWithDuration:0.1 animations:^ {
        _detailView.frame = currentDetailsRect;
        _imageView.frame = currentImageRect;
        self.view.frame = currentParentViewRect;
    }];
}

- (void) layoutControlChanged:(id)sender {

	[self dismissAllPopovers];
	UISegmentedControl *layoutControl = (UISegmentedControl *)sender;
	CGRect currentDetailsRect = _detailView.frame;
	CGRect currentParentViewRect = self.view.bounds;
	CGRect currentImageRect = _imageView.frame;
	CGRect currentParentFrame = self.view.frame;
	BOOL imageViewWidthChanged;

	if (layoutControl.selectedSegmentIndex == 0) {
		currentDetailsRect.origin.y = 44;
		currentDetailsRect.size.height = currentParentViewRect.size.height - 44;

	} else {
        if (layoutControl.selectedSegmentIndex == 1) {
			currentDetailsRect.origin.y = detailsTopLeft;
			currentDetailsRect.size.height = currentParentViewRect.size.height - detailsTopLeft;
			currentImageRect.size.height = detailsTopLeft - 44;
        } else {
			NSLog(@"Full Screen");
			currentDetailsRect.origin.y = currentParentViewRect.size.height;
			currentImageRect.size.height = currentParentViewRect.size.height-44	;

			if (self.interfaceOrientation== UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {

				imageViewWidthChanged = YES;
			}
		}
	}

	[UIView animateWithDuration:1.0 animations:^ {
		_detailView.frame = currentDetailsRect;
		_imageView.frame = currentImageRect;
		self.view.frame = currentParentFrame;
	}];

	[_imageScrollView refreshLayout];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}

- (void) handleSingleTap:(UIGestureRecognizer *)sender {
	_startButtonView.hidden = YES;
	[_startButtonView removeGestureRecognizer:sender];
	[self touchToBegin:sender];
}

- (void) touchToBegin:(id)sender {
	_startButtonView.hidden = YES;
	UIBarButtonItem *tmpCast = (UIBarButtonItem *) [[_detailToolbar items] objectAtIndex:0];
	[self.masterPopoverController presentPopoverFromBarButtonItem:tmpCast permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) toggleAboutView:(id)sender {
    _startButtonView.hidden = YES;

    if (_aboutView.hidden) {
        _aboutView.hidden = NO;
        _detailDescriptionLabel.text = NSLocalizedString(@"About", @"About");
        _welcomeView.hidden = YES;
    } else {

        if (_detailCategory != nil) {
            _detailDescriptionLabel.text = _detailCategory.label;
            _welcomeView.hidden = YES;
        } else {
            [self showWelcomeView];
        }
        _aboutView.hidden = YES;
    }
}

- (void) showWelcomeView {
    _welcomeView.hidden = NO;
    _detailDescriptionLabel.text = NSLocalizedString(@"Welcome", @"Welcome");
}

- (void) splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {

    self.masterPopoverController = popoverController;
    barButtonItem.title = _currentGroupLabel;

	NSLog(@"CurrentGroupLabel:%@", _currentGroupLabel);

	NSMutableArray *items = [[_detailToolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [_detailToolbar setItems:items animated:YES];

	[items release];
}

- (void) splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {

    NSMutableArray *items = [[_detailToolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [_detailToolbar setItems:items animated:YES];

	[items release];

	self.masterPopoverController = nil;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return NO;
    } else {
        return YES;
    }
}

- (void) showSearch:(id)sender {
   	if (self.masterPopoverController !=nil) {
		[self.masterPopoverController dismissPopoverAnimated:YES];
	}
	if (_cartPopoverController.popoverVisible !=nil) {
		[_cartPopoverController dismissPopoverAnimated:YES];
	}

	UIBarButtonItem *tmpCast = (UIBarButtonItem *)sender;

    if (_searchPopoverController.popoverVisible) {
        [_searchPopoverController dismissPopoverAnimated:YES];
    } else {
        [_searchPopoverController presentPopoverFromBarButtonItem:tmpCast permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (void) cartAction:(id)sender {
   	if (self.masterPopoverController !=nil) {
		[self.masterPopoverController dismissPopoverAnimated:YES];
	}
	if (_searchPopoverController.popoverVisible !=nil) {
		[_searchPopoverController dismissPopoverAnimated:YES];
	}

	UIBarButtonItem *tmpCast = (UIBarButtonItem *)sender;
	_commentController.detailCategory=_detailCategory;

    if (_cartPopoverController.popoverVisible) {
        [_cartPopoverController dismissPopoverAnimated:YES];
    } else {
        [_cartPopoverController presentPopoverFromBarButtonItem:tmpCast permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
    }
    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void) didReceiveMemoryWarning {
	// Release any cached data, images, etc that aren't in use.
	[_detailsWebView release];
	[_searchPopoverButton release];
	[_imageView release];
	[_aboutView release];
	[_welcomeView release];
	[_startButtonView release];
	[_imageScrollView release];
	[_detailItem release];
    [_detailDescriptionLabel release];
    [_masterPopoverController release];
    [_addtocartbtn release];

    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload {
	[_searchPopoverButton release];
	[_addtocartbtn release];
    [super viewDidUnload];
}

- (void) dealloc {
    [_detailItem release];
    [_detailDescriptionLabel release];
    [_masterPopoverController release];
    [_addtocartbtn release];
	[_imageScrollView release];
	[_imageView release];
	[_startButtonView release];
	[_welcomeView release];
	[_aboutView release];
	[_searchPopoverButton release];
	[_detailsWebView release];
	[_detailDescriptionLabel release];

    [super dealloc];
}


@end