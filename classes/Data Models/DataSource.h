//
// datasource.h
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

#import <Foundation/Foundation.h>
#import "Category.h"

@interface DataSource : NSObject<UIAlertViewDelegate> {

    NSDateFormatter *dateFormatter;
    NSString *serverLastUpdate;
    BOOL synchronizationStep;
}

//@property (readonly) NSString *imagePath;
@property (readonly) NSString *imagePath2;

// Returns the 'singleton' instance of this class
+ (id)sharedInstance;

- (NSArray *) getGroups: (NSDictionary *)request context:(NSManagedObjectContext *)managedObjectContext;
- (NSArray *) getCategories: (NSDictionary *)request context:(NSManagedObjectContext *)managedObjectContext;
- (NSArray *) searchProducts: (NSDictionary *)request context:(NSManagedObjectContext *)managedObjectContext;

- (Category *) getProductDetails: (NSDictionary *)request context:(NSManagedObjectContext *)managedObjectContext;

- (NSInteger) createProject: (NSDictionary *)request;
- (NSArray *) getProjects: (NSDictionary *)request;
- (NSInteger) setCurrentProject: (NSDictionary *)request;
- (NSDictionary *) getCurrentCart: (NSDictionary *)request;

- (void) addToCurrentProject: (NSDictionary *)request;
- (void) deleteItemFromCart: (NSDictionary *)request;
- (BOOL) isExistActiveProject;

@end