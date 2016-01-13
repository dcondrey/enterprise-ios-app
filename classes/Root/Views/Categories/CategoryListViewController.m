//
// categorylistviewcontroller.m
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

#import "CategoryListViewController.h"
#import "DetailViewController.h"
#import "Group.h"
#import "DataFetcher.h"
#import "Category.h"
#import "iPhoneDetailViewController.h"
#import "DataSource.h"
#import "ImageLoader.h"
#import "SVProgressHUD.h"

@implementation CategoryListViewController

@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize selectedGroup = __selectedGroup;
@synthesize categoryArray = _categoryArray;
@synthesize sectionsArray = _sectionsArray;
@synthesize table;


NSMutableArray *_imageLoaders;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];

	if (self) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
	}
    return self;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(popView)];
	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor,nil] forState:UIControlStateNormal];


    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"darkbackground.png"]];
    self.tableView.backgroundView = view;

    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    NSString *groupID = __selectedGroup.identifier;

    [request setValue:groupID forKey:@"groupID"];

	self.categoryArray = [[DataSource sharedInstance] getCategories:request context:self.managedObjectContext];
    self.sectionsArray = [[NSMutableArray alloc] init];

    NSString *man = nil;
    Category *cat;
    NSMutableDictionary *q;
    for(int i = 0; i < [self.categoryArray count]; i++) {
        cat = (Category *)[self.categoryArray objectAtIndex:i];
        if (man == nil || ![man isEqualToString:cat.sublabel]) {
            man = cat.sublabel;
            q = [[NSMutableDictionary alloc] init];
            [q setValue:[man copy] forKey:@"title"];
            NSString *offset = [[NSString alloc] initWithFormat:@"%d", i];
            [q setValue:offset forKey:@"offset"];

            [self.sectionsArray addObject:q];
        }
    }
    _imageLoaders = [[NSMutableArray alloc] init];

}

- (void) popView {
   [self.navigationController popViewControllerAnimated:YES];

}

- (void) viewDidUnload {
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;

}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    tableView.rowHeight = 65;

    return [self.sectionsArray count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count = 0;
    NSDictionary *q = [self.sectionsArray objectAtIndex:section];
    NSString *man = [q valueForKey:@"title"];
    Category *cat;

    for (int i = 0; i < [self.categoryArray count]; i++) {
        cat = (Category *)[self.categoryArray objectAtIndex:i];
        if ([man isEqualToString:cat.sublabel]) {
            count++;
        }
    }

    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(customActionPressed:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
            button.frame = CGRectMake(275.0f, 15.0f, 25.0f, 25.0f);
            [cell addSubview:button];
        } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(customActionPressed:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
            button.frame = CGRectMake(275.0f, 20.0f, 30.0f, 30.0f);
            [cell addSubview:button];
        }
    }

    [self configureCell:cell atIndexPath:indexPath];

	return cell;
}

- (void) customActionPressed:(id)sender {
    NSLog(@"sender %@",[[sender superview] class]);
    UITableViewCell *owningCell = (UITableViewCell *)[sender superview];

    NSIndexPath *pathToCell = [self.tableView indexPathForCell:owningCell];
    NSLog(@" %d row",pathToCell.row);
    int selectedRow = pathToCell.row;

    if (![[DataSource sharedInstance] isExistActiveProject]) {
        NSString *prod = @"default";

        NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
        [request setValue:prod forKey:@"project"];


        NSInteger rowId = [[DataSource sharedInstance] createProject:request];
        NSLog(@"%i", rowId);
    }

    NSString *count = [NSString stringWithFormat:@"1"];

    NSDictionary *q = [self.sectionsArray objectAtIndex:pathToCell.section];
    NSInteger offset = [[q valueForKey:@"offset"] intValue];

    Category *selectedCategory= [self.categoryArray objectAtIndex:(offset+pathToCell.row)];


    NSString *productId = selectedCategory.identifier;
    NSLog(@"%@", productId);

    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setValue:count forKey:@"count"];
    [request setValue:productId forKey:@"productId"];

    [[DataSource sharedInstance] addToCurrentProject:request];

    NSLog(@"added");

    [SVProgressHUD showSuccessWithStatus:@"Product Added"];
}

- (void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *q = [self.sectionsArray objectAtIndex:indexPath.section];
    NSInteger offset = [[q valueForKey:@"offset"] intValue];

    Category *managedCategory = [self.categoryArray objectAtIndex:(offset+indexPath.row)];

	[cell textLabel].text = [managedCategory label];
    [cell textLabel].font = [UIFont fontWithName:@"Trebuchet-Bold" size:16];

    cell.imageView.image = nil;
    UIImage *theImage;

    if (managedCategory.squareThumbnail == nil || [managedCategory.squareThumbnail isEqualToString:@""]) {
        theImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"missingthumbnail" ofType:@"jpg"]];
        cell.imageView.image = theImage;
    } else {
        theImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[managedCategory.squareThumbnail stringByDeletingPathExtension] ofType:[managedCategory.squareThumbnail pathExtension]]];
        cell.imageView.image = theImage;
    }

}

- (void) imageLoader:(ImageLoader *)imageLoader didReceiveError:(NSError *)anError {
    [_imageLoaders removeObject:imageLoader];
    [imageLoader release];
}

- (void) imageLoader:(ImageLoader *)imageLoader didLoadImage:(UIImage *)anImage {
    if (imageLoader.image != nil) {
        UITableViewCell *cell = [table cellForRowAtIndexPath:imageLoader.indexPath];
        if (cell != nil) {
            [cell.imageView setImage:imageLoader.image];
            [cell setNeedsLayout];
        }
    }

    [_imageLoaders removeObject:imageLoader];
    [imageLoader release];
}

- (NSString *) tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)section {
    NSDictionary *q = [self.sectionsArray objectAtIndex:section];

    return [q valueForKey:@"title"];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 15)] autorelease];

    [headerView setBackgroundColor:[UIColor clearColor]];

    return headerView;
}

// User selected row
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary *q = [self.sectionsArray objectAtIndex:indexPath.section];
    NSInteger offset = [[q valueForKey:@"offset"] intValue];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        iPhoneDetailViewController *searchiPhoneDetailViewController = [[iPhoneDetailViewController alloc] initWithNibName:@"iPhoneDetailViewController" bundle:nil];

        Category *selectedCategory = [[self categoryArray] objectAtIndex:(offset+indexPath.row)];

        searchiPhoneDetailViewController.managedObjectContext = __managedObjectContext;
		searchiPhoneDetailViewController.detailCategory = selectedCategory;
        searchiPhoneDetailViewController.title = selectedCategory.label;

		[self.navigationController pushViewController:searchiPhoneDetailViewController animated:YES];
        [searchiPhoneDetailViewController release];

    } else {
            Category *selectedCategory = [[self categoryArray] objectAtIndex:(offset+indexPath.row)];
       self.detailViewController.detailCategory = selectedCategory;
    }
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

    [_detailViewController release];
    [__fetchedResultsController release];
    [__managedObjectContext release];
    [_categoryArray release];
    [_sectionsArray release];
    self.table = nil;
    [super dealloc];

}

@end
