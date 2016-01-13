//
// atozcategoryviewcontroller.m
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

#import "AtoZCategoryViewController.h"
#import "Category.h"
#import "DetailViewController.h"
#import "iPhoneDetailViewController.h"
#import "DataFetcher.h"
#import "DataSource.h"
#import "ImageLoader.h"

@implementation AtoZCategoryViewController

@synthesize categoryArray, rightViewReference, sectionsArray, collation, table;
@synthesize managedObjectContext = __managedObjectContext;

- (void) viewDidLoad {
    [super viewDidLoad];

	self.categoryArray = [[DataSource sharedInstance] getCategories:nil context:self.managedObjectContext];
	[self configureSections];

}

- (void) configureSections {

	self.collation = [UILocalizedIndexedCollation currentCollation];

	NSInteger index, sectionTitlesCount = [[collation sectionTitles] count];

	NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];

	for (index = 0; index < sectionTitlesCount; index++) {
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[newSectionsArray addObject:array];
		[array release];
	}

	for (Category *category in categoryArray) {
        NSInteger sectionNumber = [collation sectionForObject:category collationStringSelector:@selector(label)];

		NSMutableArray *sectionCategory = [newSectionsArray objectAtIndex:sectionNumber];

		[sectionCategory addObject:category];
	}

	for (index = 0; index < sectionTitlesCount; index++) {

		NSMutableArray *categoryArrayForSection = [newSectionsArray objectAtIndex:index];
        NSArray *sortedCategoryArrayForSection = [collation sortedArrayFromArray:categoryArrayForSection collationStringSelector:@selector(label)];

		[newSectionsArray replaceObjectAtIndex:index withObject:sortedCategoryArrayForSection];
	}

	self.sectionsArray = newSectionsArray;
	[newSectionsArray release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSArray *objectsInSection = [sectionsArray objectAtIndex:section];

    if ([objectsInSection count] == 0){
        return 0.0;
	} else {
			return 25.0;
    }

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	tableView.rowHeight = 75;
	return [[collation sectionTitles] count];
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *camerasInSection = [sectionsArray objectAtIndex:section];
    return [camerasInSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

	NSArray *categoryInSection = [sectionsArray objectAtIndex:indexPath.section];

    Category *managedCategory = (Category *)[categoryInSection objectAtIndex:indexPath.row] ;

    [cell textLabel].text = [managedCategory label];
    [cell textLabel].font = [UIFont fontWithName:@"Trebuchet-Bold" size:16];
    [cell detailTextLabel].text = [managedCategory sublabel];
	[cell detailTextLabel].font = [UIFont fontWithName:@"Trebuchet-Oblique" size:13];
    cell.imageView.image = nil;

    UIImage *theImage;
    if (managedCategory.squareThumbnail == nil || [managedCategory.squareThumbnail isEqualToString:@""]) {
        theImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"missingthumbnail" ofType:@"jpg"]];
        cell.imageView.image = theImage;

    } else {

        theImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[managedCategory.squareThumbnail stringByDeletingPathExtension] ofType:[managedCategory.squareThumbnail pathExtension]]];
        cell.imageView.image = theImage;
    }

	return cell;
}

- (void) imageLoader:(ImageLoader *)imageLoader didLoadImage:(UIImage *)anImage {

	if (imageLoader.image != nil) {
		UITableViewCell *cell = [table cellForRowAtIndexPath:imageLoader.indexPath];
        if (cell != nil) {
            [cell.imageView setImage:imageLoader.image];
            [cell setNeedsLayout];
        }
    }
    [imageLoader release];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[collation sectionTitles] objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [collation sectionIndexTitles];
}

- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [collation sectionForSectionIndexTitleAtIndex:index];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *categoryInSection = [sectionsArray objectAtIndex:indexPath.section];

	Category *tmpCategory = (Category *)[categoryInSection objectAtIndex:indexPath.row];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		rightViewReference.detailCategory = tmpCategory;

	} else {

		iPhoneDetailViewController *detailViewController = [[iPhoneDetailViewController alloc] initWithNibName:@"iPhoneDetailViewController" bundle:nil];

        detailViewController.managedObjectContext = __managedObjectContext;
		detailViewController.detailCategory = tmpCategory;
		detailViewController.title = tmpCategory.label;

		[self.navigationController pushViewController:detailViewController animated:YES];
		[detailViewController release];
	}
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload {

}


- (void) dealloc {
	[categoryArray release];
	[rightViewReference release];
	[sectionsArray release];
	[collation release];
    [super dealloc];
}

@end
