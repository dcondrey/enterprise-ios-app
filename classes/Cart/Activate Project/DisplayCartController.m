//
// displaycartcontroller.m
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

#import "DisplayCartController.h"
#import "DataSource.h"


@interface DisplayCartController ()

@end

@implementation DisplayCartController

@synthesize titleLabel;
@synthesize tableView;
@synthesize makeActiveButton;
@synthesize closeButton;
@synthesize delegate;
@synthesize itemsArray;
@synthesize ID;

NSDictionary *itemToDelete;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setValue:self.ID forKey:@"id"];

	NSDictionary *project = [[DataSource sharedInstance] getCurrentCart:request];

    self.itemsArray = [project valueForKey:@"cart"];

    titleLabel.text = [project valueForKey:@"project"];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction) makeActiveButtonTapped:(id) sender {
    // set this project as current
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setValue:self.ID forKey:@"id"];

    [[DataSource sharedInstance] setCurrentProject:request];

    DarkAlertView *activateAlert = [[DarkAlertView alloc]initWithTitle:@"" message:@"Project is active" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [activateAlert show];
    [activateAlert release];

}

- (IBAction) closeButtonTapped:(id) sender {
    [self.delegate dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)mytableView {
	mytableView.rowHeight = 30;
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.itemsArray == nil) {
		return 0;
	} else {
        return [self.itemsArray count];
    }

}

- (UITableViewCell *)tableView:(UITableView *)thistableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [thistableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

	if (self.itemsArray != nil){

		NSDictionary *proj = (NSDictionary *)[self.itemsArray objectAtIndex:indexPath.row];
        [cell textLabel].text = [NSString stringWithFormat:@"%@ - %@pcs", [proj valueForKey:@"product"], [proj valueForKey:@"count"]];
        [cell textLabel].font = [UIFont fontWithName:@"Trebuchet-Bold" size:16];
        [cell textLabel].textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        cell.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];
    } else {
        cell.textLabel.text = NSLocalizedString(@"No Items",@"No Items");
	}

	return cell;
}

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSDictionary *proj = (NSDictionary *)[self.itemsArray objectAtIndex:indexPath.row];
    // delete product from cart?
    itemToDelete = proj;

    DarkAlertView *deleteAlert = [[DarkAlertView alloc] initWithTitle:@"Delete item?" message:[NSString stringWithFormat:@"Are you sure you want to delete %@ from your cart?", [proj valueForKey:@"product"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [deleteAlert show];
    [deleteAlert release];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"OK"]) {
        // delete item from the cart
        if (itemToDelete != nil) {
            NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
            [request setValue:[itemToDelete valueForKey:@"rowId"] forKey:@"rowId"];

            [[DataSource sharedInstance] deleteItemFromCart:request];

            [request setValue:self.ID forKey:@"id"];
            NSDictionary *project = [[DataSource sharedInstance] getCurrentCart:request];
            [self.itemsArray release];
            self.itemsArray = [project valueForKey:@"cart"];

            [tableView reloadData];
        }
    }
}

- (void) dealloc {
    itemToDelete = nil;
    [self.itemsArray release];
    [super dealloc];
}

@end