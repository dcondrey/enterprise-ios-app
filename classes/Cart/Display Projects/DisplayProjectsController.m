//
// displayprojectscontroller.m
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

#import "DisplayProjectsController.h"
#import "DataSource.h"
#import "DisplayCartController.h"
#import "NewProjectController.h"

@interface DisplayProjectsController ()

@end

@implementation DisplayProjectsController

@synthesize cancelButton;
@synthesize delegate;
@synthesize tableView;
@synthesize projectsArray = _projectsArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
	self.projectsArray = [[DataSource sharedInstance] getProjects:nil];

}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction) cancelButtonTapped:(id) sender {
    [self.delegate dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)mytableView {
	mytableView.rowHeight = 30;
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.projectsArray == nil) {
		return 0;
	} else {
        return [self.projectsArray count];
    }

}

- (UITableViewCell *)tableView:(UITableView *)thistableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [thistableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

	if (self.projectsArray != nil){

		NSDictionary *proj = (NSDictionary *)[self.projectsArray objectAtIndex:indexPath.row];
        [cell textLabel].text = [proj valueForKey:@"project"];
        [cell textLabel].font = [UIFont fontWithName:@"Trebuchet-Bold" size:16];

        if ([[proj valueForKey:@"is_current"] isEqualToString:@"1"]) {
            cell.backgroundColor = [UIColor colorWithRed:120 green:120 blue:255 alpha:1];
        } else {
            cell.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];
        }
    } else {
        cell.textLabel.text = NSLocalizedString(@"No Projects",@"No Projects");
	}

	return cell;
}

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSDictionary *proj = (NSDictionary *)[self.projectsArray objectAtIndex:indexPath.row];

    DisplayCartController *displayCartController = [[DisplayCartController alloc] init];

    displayCartController.delegate = (UIViewController *)self.delegate;
    displayCartController.ID = [proj valueForKey:@"id"];

    [self.delegate dismissViewControllerAnimated:NO completion:nil];

    [displayCartController.delegate.navigationController presentViewController:displayCartController animated:YES completion:nil];

    [displayCartController release];

}

- (void) dealloc {
    [self.projectsArray release];
    [super dealloc];
}

@end