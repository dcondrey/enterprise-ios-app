//
// group.h
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
#import <CoreData/CoreData.h>

@class Category;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * highlightedImage;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * standardImage;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSSet *objects;

@end

@interface Group (CoreDataGeneratedAccessors)

- (void) addObjectsObject:(Category *)value;
- (void) removeObjectsObject:(Category *)value;
- (void) addObjects:(NSSet *)values;
- (void) removeObjects:(NSSet *)values;

@end