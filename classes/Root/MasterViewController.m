//
// masterviewcontroller.m
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

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "CategoryListViewController.h"
#import "Group.h"
#import "DataSource.h"
#import "NewProjectController.h"
#import "SubmitController.h"
#import "DisplayProjectsController.h"

@interface MasterViewController ()

- (void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize groupsArray = _groupsArray;
@synthesize parentId = _parentId;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Radiant Images", @"Radiant Images");

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}

- (void) dealloc {
    [_detailViewController release];
    [_groupsArray release];
    [__managedObjectContext release];
    [super dealloc];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Projects" style:UIBarButtonItemStyleBordered target:self action:@selector(showProjects)];
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"darkbackground.png"]];
    self.tableView.backgroundView = view;

    if (_parentId == nil) _parentId = [NSNumber numberWithInt:0];

    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setValue:_parentId forKey:@"parentId"];

   	self.groupsArray = [[DataSource sharedInstance] getGroups:request context:self.managedObjectContext];
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
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
    }

    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
    return YES;
}

// Customize the number of sections in the table view.
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.groupsArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        }

    }
    cell.textLabel.textColor = [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0];

    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    [[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];

    cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]] autorelease];

    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableviewcell.png"]];

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	// The table view should not be re-orderable.
    return NO;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    Group *selectedGroup =[self.groupsArray objectAtIndex:indexPath.row];

    if (selectedGroup.order.intValue > 0)
    {
        MasterViewController *nextLevel;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            nextLevel = [[MasterViewController alloc] initWithNibName:@"MasterViewController_iPad" bundle:nil];
        }
        else
        {
            nextLevel = [[MasterViewController alloc] initWithNibName:@"MasterViewController_iPhone" bundle:nil];
        }
        nextLevel.managedObjectContext = [self managedObjectContext];
        nextLevel.parentId = [NSNumber numberWithInt:[selectedGroup.identifier intValue]];
        nextLevel.title = [NSString stringWithFormat:@"%@", selectedGroup.label];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            nextLevel.detailViewController = self.detailViewController;
        }
        [self.navigationController pushViewController:nextLevel animated:YES];
        [nextLevel release];
    } else {
        CategoryListViewController *newCategoryList = [[CategoryListViewController alloc] initWithNibName:@"CategoryListViewController" bundle:nil];
        newCategoryList.managedObjectContext = [self managedObjectContext];
        newCategoryList.selectedGroup = selectedGroup;
        newCategoryList.title = [NSString stringWithFormat:@"%@", newCategoryList.selectedGroup.label];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            newCategoryList.detailViewController = self.detailViewController;
        }

        [self.navigationController pushViewController:newCategoryList animated:YES];
        [newCategoryList release];
    }

}

- (void) popView {
    [self.navigationController popViewControllerAnimated:YES];

}

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// Update the fetched results controller.
    [self.tableView beginUpdates];
}

- (void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	Group *managedGroup = [self.groupsArray  objectAtIndex:indexPath.row];
	[cell textLabel].text = [managedGroup label];

	// Cell images in tableview
    if (managedGroup.standardImage != nil && ![managedGroup.standardImage isEqualToString:@""]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[managedGroup.standardImage stringByDeletingPathExtension] ofType:@"png"];

        UIImage *theImage;

        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            theImage = [UIImage imageWithContentsOfFile:path];
        }
        else

        {
            // No image in database
            theImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"missingthumbnail" ofType:@"jpg"]];
        }
        cell.imageView.image = theImage;
    }
    if (managedGroup.highlightedImage != nil && ![managedGroup.highlightedImage isEqualToString:@""]) {
        NSString *highlightpath = [[NSBundle mainBundle] pathForResource:[managedGroup.highlightedImage stringByDeletingPathExtension] ofType:@"png"];

        UIImage *theHighlightedImage;
        if ([[NSFileManager defaultManager] fileExistsAtPath:highlightpath]) {
            theHighlightedImage = [UIImage imageWithContentsOfFile:highlightpath];
        } else {
            theHighlightedImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"missingthumbnail" ofType:@"jpg"]];
        }

        cell.imageView.highlightedImage = theHighlightedImage;
    }

}

- (void) showProjects {
    if (_menu.isOpen)
        return [_menu close];
    REMenuItem *cartNew = [[REMenuItem alloc] initWithTitle:@"Setup A New Project" subtitle:@"Start with your project name and contact details." image:[UIImage imageNamed:@"Icon_Home"] highlightedImage:nil action:^(REMenuItem *item) {
        NewProjectController *newProjectController = [[NewProjectController alloc] init];

        newProjectController.delegate = (UIViewController *)self;
        [newProjectController.delegate.navigationController presentViewController:newProjectController animated:YES completion:nil];

        [newProjectController release];

    }];

    REMenuItem *cartList = [[REMenuItem alloc] initWithTitle:@"Display Your Projects" subtitle:@"Save and switch between as many pending projects as you like." image:[UIImage imageNamed:@"Icon_Explore"] highlightedImage:nil action:^(REMenuItem *item) {

        DisplayProjectsController *displayProjectsController = [[DisplayProjectsController alloc] init];

        displayProjectsController.delegate = (UIViewController *)self;
        [displayProjectsController.delegate.navigationController presentViewController:displayProjectsController animated:YES completion:nil];

    }];


    REMenuItem *cartSend = [[REMenuItem alloc] initWithTitle:@"Send Quote Request" subtitle:@"A rental agent will follow up with your request using the contact information you provided." image:[UIImage imageNamed:@"Icon_Explore"] highlightedImage:nil action:^(REMenuItem *item) {

        SubmitController *submitController = [[SubmitController alloc] init];

        submitController.delegate = (UIViewController *)self;
        [submitController.delegate.navigationController presentViewController:submitController animated:YES completion:nil];
    }];


    REMenuItem *callItem = [[REMenuItem alloc] initWithTitle:@"Call Radiant Images" subtitle:@"Rental Agents are available to answer your questions." image:[UIImage imageNamed:@"Icon_Explore"] highlightedImage:nil action:^(REMenuItem *item) {

        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:+11111"]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://3237371314"]];
        } else {
            DarkAlertView *featureUnavailable = [[DarkAlertView alloc]initWithTitle:@"Feature Unavailable" message:@"Your device does not support outbound calling, or your cellular network is currently unavailable.  You may give us a call at (323) 737-1314 from another device." delegate:self cancelButtonTitle:@"Return" otherButtonTitles:nil];
            [featureUnavailable show];
            [featureUnavailable release];
        }
    }];

    REMenuItem *webItem = [[REMenuItem alloc] initWithTitle:@"Visit RadiantImages.com" subtitle:@"" image:[UIImage imageNamed:@"Icon_Explore"] highlightedImage:nil action:^(REMenuItem *item) {

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.radiantimages.com"]];
    }];

    cartNew.tag = 0;
    cartList.tag = 1;
    cartSend.tag = 2;
    callItem.tag = 3;
    webItem.tag = 4;


    _menu = [[REMenu alloc] initWithItems:@[cartNew, cartList, cartSend, callItem, webItem]];
    _menu.cornerRadius = 4;
    _menu.shadowColor = [UIColor blackColor];
    _menu.shadowOffset = CGSizeMake(0, 1);
    _menu.shadowOpacity = 1;
    _menu.imageOffset = CGSizeMake(5, -1);

    [_menu showFromNavigationController:self.navigationController];
}

@end
