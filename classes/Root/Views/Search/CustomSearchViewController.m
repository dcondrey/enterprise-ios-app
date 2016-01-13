//
// customsearchviewcontroller.m
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

#import "DataFetcher.h"
#import "Group.h"
#import "Category.h"
#import "Image.h"
#import "CustomSearchViewController.h"
#import "DetailViewController.h"
#import "iPhoneDetailViewController.h"
#import "DataSource.h"
#import "ImageLoader.h"


@implementation CustomSearchViewController

@synthesize searchBar;
@synthesize tableView;
@synthesize searchResults;
@synthesize rightViewReference;
@synthesize managedObjectContext = __managedObjectContext;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad {
	[super viewDidLoad];

	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.placeholder = NSLocalizedString(@"Search for an item", @"Search for an item");


}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.navigationController.navigationBar.translucent	= NO;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	self.navigationController.navigationBar.translucent	= NO;
}

// Return the number of sections.
- (NSInteger) numberOfSectionsInTableView:(UITableView *)mytableView {
    // Return the number of sections
	mytableView.rowHeight = 75;
    return 1;
}

// Return the number of rows in the section.
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.

	if (self.searchResults == nil) {
		return 0;

	} else {
		return [self.searchResults count];
	}
}

// Customized tableview cell - CellStyleSubtitle
- (UITableViewCell *)tableView:(UITableView *)thistableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [thistableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

	if (self.searchResults != nil) {

		Category *managedCategory = (Category *)[self.searchResults objectAtIndex:indexPath.row];
		// Label Style is Helvetical-Bold
            [cell textLabel].text = [managedCategory label];
            [cell textLabel].font = [UIFont fontWithName:@"Trebuchet-Bold" size:16];
            //[cell textLabel].textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
            [cell detailTextLabel].text = [managedCategory sublabel];

			// Change Style to Italic if labelStyle key states
			if ([managedCategory.labelStyle isEqualToString:@"italic"]) {
					[cell textLabel].font = [UIFont fontWithName:@"Trebuchet-Bold" size:16];
				}

		// Sublabel Style is Italic
            if ([managedCategory.sublabelStyle isEqualToString:@"italic"]) {
				[cell detailTextLabel].font = [UIFont fontWithName:@"Trebuchet-Oblique" size:13];

			} else {
				[cell detailTextLabel].font = [UIFont fontWithName:@"Trebuchet" size:13];
				[cell detailTextLabel].textColor = [UIColor colorWithRed:0.258 green:.258 blue:.258 alpha:1];
            }

        cell.imageView.image = nil;

        UIImage *theImage;
        if (managedCategory.squareThumbnail == nil || [managedCategory.squareThumbnail isEqualToString:@""]) {
            theImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"missingthumbnail" ofType:@"jpg"]];
            cell.imageView.image = theImage;

        } else {
            theImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[managedCategory.squareThumbnail stringByDeletingPathExtension] ofType:[managedCategory.squareThumbnail pathExtension]]];
            cell.imageView.image = theImage;
        }

	} else {
         cell.textLabel.text = NSLocalizedString(@"Search for items",@"Search for items");
	}

	return cell;
}

- (void) imageLoader:(ImageLoader *)imageLoader didReceieveError:(NSError *)anError{}

- (void) imageLoader:(ImageLoader *)imageLoader didLoadImage:(UIImage *)anImage {
    if (imageLoader.image != nil /*&& imageLoader.cell != nil*/) {
        //imageLoader.imageView = nil;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:imageLoader.indexPath];
        if (cell != nil)
        {
            [cell.imageView setImage:imageLoader.image];
            [cell setNeedsLayout];
        }
    }
    [imageLoader release];
}

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{

	if (letUserSelectRow) {
		return indexPath;
	} else {
		return nil;
	}

}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	//This Controller used by iPad and iPhone interfaces -
    //iPhone Pops on the Navigation Controller, iPad puts the Product into the right view reference.
	Category *tmpCategory  = (Category *)[self.searchResults objectAtIndex:indexPath.row];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

		rightViewReference.detailCategory = tmpCategory;

	} else {

		//New iPhone View
		iPhoneDetailViewController *detailViewController = [[iPhoneDetailViewController alloc] initWithNibName:@"iPhoneDetailViewController" bundle:nil];

        detailViewController.managedObjectContext = self.managedObjectContext;
		detailViewController.detailCategory = tmpCategory;
		detailViewController.title = tmpCategory.label;

			[self.navigationController pushViewController:detailViewController animated:YES];

			[detailViewController release];
	}

}

- (void) searchBarTextDidBeginEditing: (UISearchBar *) theSearchBar {
	searching = YES;
	letUserSelectRow = YES;

	self.tableView.scrollEnabled = YES;

	[self.searchBar setShowsCancelButton:YES animated:YES];
}




- (void) searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {

	if ([searchText length] > 0) {
		searching = YES;
		letUserSelectRow = YES;
		[self searchCategory];

	} else {

		searching = NO;
		letUserSelectRow = NO;
		self.tableView.scrollEnabled = YES;
		self.searchResults = [NSArray array];
	}

	[self.tableView reloadData];
}


// Search button action
- (void) searchBarSearchButtonClicked:(UISearchBar *) theSearchBar {

	[theSearchBar setShowsCancelButton:NO animated:YES];
	[searchBar resignFirstResponder];
	letUserSelectRow = YES;
	searching = NO;

    //[self searchCategory];

	self.tableView.scrollEnabled = YES;

	//[self.tableView reloadData];

}

// Cancel Search button action
- (void) searchBarCancelButtonClicked:(UISearchBar *) theSearchBar {

	[theSearchBar setShowsCancelButton:NO animated:YES];
	[searchBar resignFirstResponder];
	letUserSelectRow = YES;
	searching = NO;

	self.tableView.scrollEnabled = YES;

}

- (void) searchCategory {

	NSArray *searchTerms = [[searchBar.text stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@" "]] componentsSeparatedByString:@" "];
	//NSMutableString *searchString = [NSMutableString stringWithCapacity:1];

    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setValue:searchTerms forKey:@"searchTerms"];

	self.searchResults = [[DataSource sharedInstance] searchProducts:request context:self.managedObjectContext];

    //Potentially better search can be constructed. Need to search across Name, Categories, Sublabel, Subgroup, Details
    //Searches is always "AND" for words in the search list.
/*
    [searchString appendString: [NSString stringWithFormat:@"(searchText MATCHES[c] '(.* )?%@.*'", [searchTerms objectAtIndex:0]]];

	if ([searchTerms count] > 1)
	{
		//build or statements
		for (int i = 1; i < [searchTerms count]; i++) {
				[searchString appendString: [NSString stringWithFormat:@" AND searchText MATCHES[c] '(.* )?%@.*'", [searchTerms objectAtIndex:i]]];
		}
	}

	[searchString appendString:@")"];



	NSString *searchTerm = [NSString stringWithString:searchString];
	NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:searchTerm];

	self.searchResults = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"Category" withPredicate:searchPredicate withSortField:@"label"];
*/
}



- (void) doneSearching_Clicked:(id) sender {

	[searchBar resignFirstResponder];
	letUserSelectRow = YES;
	searching = NO;

	self.tableView.scrollEnabled = YES;
}


- (CGSize)contentSizeForViewInPopover{
	return CGSizeMake(320,480);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc. that aren't in use.
}

- (void) viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) dealloc {
    [super dealloc];
}

@end