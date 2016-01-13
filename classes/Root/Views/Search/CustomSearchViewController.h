//
// customsearchviewcontroller.h
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
#import "ImageLoader.h"

@class DetailViewController;

@interface CustomSearchViewController : UIViewController <UITableViewDelegate, UISearchBarDelegate> {

	IBOutlet UISearchBar* searchBar;
    IBOutlet UITableView* tableView;

	BOOL searching;
	BOOL letUserSelectRow;

	NSArray *searchResults;
	DetailViewController *rightViewReference;

    NSManagedObjectContext *managedObjectContext;

}

@property (nonatomic, retain) DetailViewController *rightViewReference;

@property (nonatomic, retain) UISearchBar* searchBar;
@property (nonatomic, retain) UITableView* tableView;
@property (nonatomic, retain) NSArray *searchResults;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void) searchCategory;

- (void) doneSearching_Clicked: (id) sender;
- (void) imageLoader:(ImageLoader *)imageLoader didReceieveError:(NSError *)anError;
- (void) imageLoader:(ImageLoader *)imageLoader didLoadImage:(UIImage *)anImage;

@end