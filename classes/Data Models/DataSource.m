//
// datasource.m
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

#import "DataSource.h"
#import "Sqlite.h"
#import "Category.h"
#import "Group.h"
#import "Template.h"
#import "TemplateTab.h"
#import "Image.h"

@implementation DataSource
@synthesize imagePath2 = _imagePath2;

+ (id)sharedInstance {
	static id master = nil;

	@synchronized(self) {
		if (master == nil)
			master = [self new];
	}

    return master;
}

- (void) dealloc {
    [super dealloc];
}

- (id) init {
	self = [super init];
	if (self != nil) {

		BOOL success;
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error;
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"radical_v2-506.sqlite"];

		success = [fileManager fileExistsAtPath:writableDBPath];
		if (!success) {
			NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"radical_v2-506.sqlite"];

			success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
			if (!success) {
				NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
			}
		}
        NSLog(@"DB path: %@", writableDBPath);
	}

    _imagePath2 = @"http://www.radiantimages.com/ios/images/";

	return self;
}

- (NSString *) databasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"radical_v2-506.sqlite"];
	return writableDBPath;
}

- (NSArray *) getGroups: (NSDictionary *)request context:(NSManagedObjectContext *)managedObjectContext {

	Sqlite *localDB = [[Sqlite alloc] init];
	BOOL success = [localDB open:[self databasePath]];
	NSAssert(success, @"Cannot open local database");

    NSNumber *parentId = [NSNumber numberWithInt:0];

    if (request != nil) {
        parentId = [request valueForKey:@"parentId"];
    }

    if (parentId == nil || parentId.intValue < 1) parentId = [NSNumber numberWithInt:0];

    NSArray *answerrowset;
    answerrowset = [localDB executeQuery:@"SELECT h.*, COUNT(c.id) AS cnt FROM hierarchy AS h LEFT OUTER JOIN hierarchy AS c ON c.parent = h.id WHERE h.parent = ? GROUP BY h.id ORDER BY h.id ASC", parentId];

    NSMutableArray *res = [NSMutableArray array];

    for (NSDictionary *row in answerrowset) {

        NSString *label = [row valueForKey:@"menu_title"];
        NSString *identifier = [row valueForKey:@"id"];
        NSString *thumb = [row valueForKey:@"menu_icon"];
        NSNumber *cnt = [NSNumber numberWithInt:[[row valueForKey:@"cnt"] intValue]];

        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:managedObjectContext];

        Group *group = (Group *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];

        group.identifier = identifier;
        group.label = label;
        group.highlightedImage = thumb;
        group.standardImage = thumb;
        group.order = cnt;

        [res addObject:group];
    }

	[answerrowset release];
	[localDB release];
    return res;
}

- (NSArray *) getCategories: (NSDictionary *)request context:(NSManagedObjectContext *)managedObjectContext  {

    NSString *groupID = @"";

    if (request != nil) {
        groupID = [request valueForKey:@"groupID"];
    }

	Sqlite *localDB = [[Sqlite alloc] init];
	BOOL success = [localDB open:[self databasePath]];
	NSAssert(success, @"Cannot open local database");

    NSArray *answerrowset;
    if (![groupID isEqualToString: @""]) {
        answerrowset = [localDB executeQuery:@"SELECT * FROM Product_Catalog WHERE cat = ? ORDER BY Manufacturer ASC, displayorder ASC", groupID];

    } else {
        answerrowset = [localDB executeQuery:@"SELECT * FROM Product_Catalog ORDER BY Product ASC"];
    }

    NSMutableArray *res = [NSMutableArray array];

    for (NSDictionary *row in answerrowset) {
        NSString *product = [row valueForKey:@"Product"];
        NSString *productID = [row valueForKey:@"product_ID"];
        NSString *thumb = [row valueForKey:@"display_Thumbnail"];
        NSString *manufacturer = [row valueForKey:@"Manufacturer"];

        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:managedObjectContext];

        Category *category = (Category *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];

        category.identifier = productID;
        category.label = product;
        category.squareThumbnail = thumb;
        category.sublabel = manufacturer;
        category.subgroup = manufacturer;

        [res addObject:category];
    }

	[answerrowset release];
	[localDB release];
    return res;
}

- (NSArray *) searchProducts: (NSDictionary *)request context:(NSManagedObjectContext *)managedObjectContext {

    NSArray *searchTerms = nil;

    if (request != nil) {
        searchTerms = [request valueForKey:@"searchTerms"];
    }

    NSMutableString *whereClause = [[NSMutableString alloc] initWithString:@""];
    if (searchTerms != nil && [searchTerms count] > 0)
	{
		for (int i = 0; i < [searchTerms count]; i++) {
            if (i == 0) [whereClause appendString:@"WHERE "];
            else [whereClause appendString:@" AND "];
            [whereClause appendString: [NSString stringWithFormat:@"(Product LIKE '%%%@%%' OR description  LIKE '%%%@%%' OR Manufacturer  LIKE '%%%@%%')", [searchTerms objectAtIndex:i],[searchTerms objectAtIndex:i], [searchTerms objectAtIndex:i]]];
		}
	}

	Sqlite *localDB = [[Sqlite alloc] init];
	BOOL success = [localDB open:[self databasePath]];
	NSAssert(success, @"Cannot open local database");

    NSArray *answerrowset;
    answerrowset = [localDB executeQuery:[NSString stringWithFormat:@"SELECT * FROM Product_Catalog %@ ORDER BY Product ASC", whereClause]];
    NSMutableArray *res = [NSMutableArray array];

    for (NSDictionary *row in answerrowset) {
        NSString *product = [row valueForKey:@"Product"];
        NSString *productID = [row valueForKey:@"product_ID"];
        NSString *thumb = [row valueForKey:@"display_Thumbnail"];
        NSString *manufacturer = [row valueForKey:@"Manufacturer"];

        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:managedObjectContext];

        Category *category = (Category *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];

        category.identifier = productID;
        category.label = product;
        category.squareThumbnail = thumb;
        category.sublabel = manufacturer;

        [res addObject:category];
    }

	[answerrowset release];
	[localDB release];
    return res;
}


- (Category *) getProductDetails: (NSDictionary *)request context:(NSManagedObjectContext *)managedObjectContext {

    NSString *productID = @"";

    if (request != nil) {
        productID = [request valueForKey:@"productID"];
    }
    if (productID == nil) productID = @"";

	Sqlite *localDB = [[Sqlite alloc] init];
	BOOL success = [localDB open:[self databasePath]];
	NSAssert(success, @"Cannot open local database");

    NSArray *kitrowset;
    NSArray *answerrowset;
    NSArray *mfgrowset;

    if (![productID isEqualToString: @""]) {
        answerrowset = [localDB executeQuery:@"SELECT Product_Catalog.*, DetailsKeyValues.* FROM Product_Catalog LEFT OUTER JOIN DetailsKeyValues ON DetailsKeyValues.DetailsKey = Product_Catalog.info_DetailsKey WHERE Product_ID = ? ORDER BY DetailsKeyValues.DetailsKey ASC", productID];
    //5-18 %@ ORDER BY DetailsKeyValues ASC


        kitrowset = [localDB executeQuery:@"SELECT * FROM Product_Assets WHERE kitID = ?", productID];

    } else {
        return nil;
    }

    Category *category = nil;
    if ([answerrowset count] > 0) {

        NSDictionary *row = [answerrowset objectAtIndex:0];
        NSString *product = [row valueForKey:@"Product"];
        NSString *productID = [row valueForKey:@"product_ID"];
        NSString *thumb = [row valueForKey:@"display_Thumbnail"];
        NSString *manufacturer = [row valueForKey:@"Manufacturer"];
        NSString *description = [row valueForKey:@"description"];
        NSString *panorama = [row valueForKey:@"panorama"];
        NSString *promovid = [row valueForKey:@"promovid"];
        NSString *bracketvid = [row valueForKey:@"bracketvid"];
        NSString *dynamicvid = [row valueForKey:@"dynamicvid"];
        NSString *colorrendvid = [row valueForKey:@"colorrendvid"];
        NSString *gscreenvid = [row valueForKey:@"gscreenvid"];

        NSMutableArray *imgArr = [[NSMutableArray alloc] init];

        mfgrowset = [localDB executeQuery:@"SELECT * FROM mfg WHERE manufacturer = ?", manufacturer];

        NSString *logo = @"";
        if ([mfgrowset count] > 0) {
            NSDictionary *mfg = [mfgrowset objectAtIndex:0];
            logo = [mfg valueForKey:@"logo"];
        }


        NSString *img = @"";

        for(int i = 1; i <= 5; i++) {
            img = [row valueForKey:[NSString stringWithFormat:@"display_Image0%i", i]];
            if (img != nil && ![img isEqualToString:@""])
                [imgArr addObject:img];
        }
        if ([imgArr count] < 1)
            [imgArr addObject:@""];

        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:managedObjectContext];

        category = (Category *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];

        category.identifier = productID;
        category.label = product;
        category.squareThumbnail = thumb;
        category.sublabel = manufacturer;
        category.subgroup = manufacturer;
        category.description = description;
        category.logo_image = logo;
        category.panorama = panorama;
        category.promovid = promovid;
        category.bracketvid = bracketvid;
        category.dynamicvid = dynamicvid;
        category.colorrendvid = colorrendvid;
        category.gscreenvid = gscreenvid;

        int i = 0;
        for(NSString *img in imgArr) {
            i++;
            Image *tmpImage = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:managedObjectContext];

            tmpImage.filename = img;
            tmpImage.order = [NSNumber numberWithInt:i];
            [category addImagesObject:tmpImage];

        }

        img = [row valueForKey:@"panorama"];
        Image *tmpImage = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:managedObjectContext];
        tmpImage.filename = img;
        tmpImage.order = [NSNumber numberWithInt:-1];
        [category addImagesObject:tmpImage];

        [imgArr release];
        imgArr = nil;

        NSString *qkey = @"";
        NSString *qval = @"";
        NSArray *l = [[NSArray alloc] initWithObjects:@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t", nil];
        category.details = [[NSMutableDictionary alloc] init];

        for(NSString *a in l) {
            qkey = [row valueForKey:[NSString stringWithFormat:@"spec_%@", a]];
            qval = [row valueForKey:[NSString stringWithFormat:@"info_spec_%@", a]];
            if (qkey != nil && ![qkey isEqualToString:@""]) [category.details setValue:qval forKey:qkey];

        }


        int kitCount = [kitrowset count];
        if (kitCount > 0) {
            category.kits = [[NSMutableArray alloc] init];
            for (i = 0; i < kitCount; i++) {
                NSDictionary *kit_row = [kitrowset objectAtIndex:i];

                NSString *asset_val = @"";
                NSString *qty_val = @"";

                asset_val = [kit_row valueForKey:[NSString stringWithFormat:@"asset"]];
                qty_val = [kit_row valueForKey:[NSString stringWithFormat:@"kitQTY"]];

                if (asset_val != nil && qty_val != nil) {

                    NSString *val = [[NSString alloc] initWithFormat:@"%@,%@", asset_val, qty_val];
                    [category.kits addObject:val];

                    [val release];
                }

            }
        }

        entity = [NSEntityDescription entityForName:@"Template" inManagedObjectContext:managedObjectContext];

        Template *tmp = (Template *)[[NSManagedObject alloc] initWithEntity:entity
                                             insertIntoManagedObjectContext:managedObjectContext];
        tmp.templateName = @"Default";
        tmp.tabletTemplate = @"template-ipad.html";


        TemplateTab *newTemplateTab;


        newTemplateTab = [NSEntityDescription insertNewObjectForEntityForName:@"TemplateTab" inManagedObjectContext:managedObjectContext];
        newTemplateTab.tabName = @"specs";
        newTemplateTab.tabLabel = @"Specs";
        newTemplateTab.tabIcon = @"tabBar2_specs.png";
        newTemplateTab.tabTemplate = @"template-iphone-specs2.html";
        [newTemplateTab addFirstTabsObject:tmp];

        newTemplateTab = [NSEntityDescription insertNewObjectForEntityForName:@"TemplateTab" inManagedObjectContext:managedObjectContext];
        newTemplateTab.tabName = @"images";
        newTemplateTab.tabLabel = @"Images";
        newTemplateTab.tabIcon = @"images.png";
        newTemplateTab.tabTemplate = @"";
        [newTemplateTab addThirdTabsObject:tmp];

        newTemplateTab = [NSEntityDescription insertNewObjectForEntityForName:@"TemplateTab" inManagedObjectContext:managedObjectContext];
        newTemplateTab.tabName = @"kit";
        newTemplateTab.tabLabel = @"Kit";
        newTemplateTab.tabIcon = @"tabBar2_kit.png";
        newTemplateTab.tabTemplate = @"template-iphone-kit.html";
        [newTemplateTab addFourthTabsObject:tmp];

        category.template = tmp;


    }

	[answerrowset release];
    [kitrowset release];

	[localDB release];

    NSLog(@"%@",category.details);
    return category;
}

- (NSInteger) createProject: (NSDictionary *)request {

    NSString *project = @"";
    NSDate *start = nil;
    NSDate *end = nil;
    NSString *company = @"";
    NSString *addr1 = @"";
    NSString *addr2 = @"";
    NSString *city = @"";
    NSString *state = @"";
    NSString *zip = @"";
    NSString *name = @"";
    NSString *phone = @"";
    NSString *email = @"";

    if (request != nil) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MM/dd/YYYY"];

        project = [request valueForKey:@"project"];
        start = [df dateFromString:[request valueForKey:@"start"]];
        end = [df dateFromString:[request valueForKey:@"end"]];
        company = [request valueForKey:@"company"];
        addr1 = [request valueForKey:@"addr1"];
        addr2 = [request valueForKey:@"addr2"];
        city = [request valueForKey:@"city"];
        state = [request valueForKey:@"state"];
        zip = [request valueForKey:@"zip"];
        name = [request valueForKey:@"name"];
        phone = [request valueForKey:@"phone"];
        email = [request valueForKey:@"email"];
    }
    if (project == nil) project = @"";
    if (start == nil) start = [[NSDate alloc] init];
    if (end == nil) end = [[NSDate alloc] init];
    if (company == nil) company = @"";
    if (addr1 == nil) addr1 = @"";
    if (addr2 == nil) addr2 = @"";
    if (city == nil) city = @"";
    if (state == nil) state = @"";
    if (zip == nil) zip = @"";
    if (name == nil) name = @"";
    if (phone == nil) phone = @"";
    if (email == nil) email = @"";

	Sqlite *localDB = [[Sqlite alloc] init];
	BOOL success = [localDB open:[self databasePath]];
	NSAssert(success, @"Cannot open local database");

    NSArray *answerrowset;
    [localDB executeNonQuery:@"INSERT INTO [rfq] ([projectname], [estimated_start], [estimated_end], [productioncompany], [addressline1_bill], [addressline2_bill], [city_bill], [state_bill], [zip_bill], [poc_name], [poc_phone], [poc_email], [is_current]) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", project, start, end, company, addr1, addr2, city, state, zip, name, phone, email, @"1"];

    answerrowset = [localDB executeQuery:@"SELECT last_insert_rowid() AS rowid"];
    NSString *res = 0;

    for (NSDictionary *row in answerrowset) {
        res = [row valueForKey:@"rowid"];
    }



    [localDB executeNonQuery:@"UPDATE rfq SET rfq_id = rowid WHERE rowid = ?", res];
    [localDB executeNonQuery:@"UPDATE rfq SET is_current = 0 WHERE rowid != ?", res];

	[answerrowset release];
	[localDB release];
    return [res integerValue];
}

- (NSArray *) getProjects: (NSDictionary *)request {
	Sqlite *localDB = [[Sqlite alloc] init];
	BOOL success = [localDB open:[self databasePath]];
	NSAssert(success, @"Cannot open local database");

    NSArray *answerrowset;
    answerrowset = [localDB executeQuery:@"SELECT * FROM rfq ORDER BY projectname ASC"];
    NSMutableArray *res = [NSMutableArray array];

    for (NSDictionary *row in answerrowset) {
        NSString *projectname = [row valueForKey:@"projectname"];
        NSString *is_current = [row valueForKey:@"is_current"];
        NSString *rfq_id = [row valueForKey:@"rfq_id"];

        NSMutableDictionary *q = [[NSMutableDictionary alloc] init];
        [q setValue:projectname forKey:@"project"];
        [q setValue:is_current forKey:@"is_current"];
        [q setValue:rfq_id forKey:@"id"];

        [res addObject:q];
    }

	[answerrowset release];
	[localDB release];
    return res;
}

- (NSInteger) setCurrentProject: (NSDictionary *)request {

    NSString *rfq_id = @"";

    if (request != nil) {
        rfq_id = [request valueForKey:@"id"];
    }
    if (rfq_id == nil) rfq_id = @"";

	Sqlite *localDB = [[Sqlite alloc] init];
	BOOL success = [localDB open:[self databasePath]];
	NSAssert(success, @"Cannot open local database");
    [localDB executeNonQuery:@"UPDATE rfq SET is_current = 0 WHERE rfq_id != ?", rfq_id];
    [localDB executeNonQuery:@"UPDATE rfq SET is_current = 1 WHERE rfq_id = ?", rfq_id];

	[localDB release];
    return [rfq_id integerValue];
}

- (BOOL) isExistActiveProject {
    Sqlite *localDB = [[Sqlite alloc] init];
	BOOL success = [localDB open:[self databasePath]];
	NSAssert(success, @"Cannot open local database");

    NSArray *rowset = [localDB executeQuery:@"SELECT * FROM rfq WHERE is_current=1"];

    if ([rowset count] == 0)
        return FALSE;
    return TRUE;

}

- (void) addToCurrentProject: (NSDictionary *)request {

    NSLog(@"%@",request);
    NSString *comment = @"";
    NSString *count = @"0";
    NSString *productId = @"";

    if (request != nil) {
        comment = [request valueForKey:@"comment"];
        count = [request valueForKey:@"count"];
        productId = [request valueForKey:@"productId"];
    }
    if (comment == nil) comment = @"";
    if (count == nil) count = @"0";
    if (productId == nil) productId = @"";

	Sqlite *localDB = [[Sqlite alloc] init];
    NSLog(@"database init");
	BOOL success = [localDB open:[self databasePath]];
	NSAssert(success, @"Cannot open local database");
    [localDB executeNonQuery:@"INSERT INTO cart (rfq_id, product_ID, qty, comments) SELECT rfq_id, ?, ?, ? FROM rfq WHERE is_current = 1", productId, count, comment];
    NSArray *answerrowset;
    answerrowset = [localDB executeQuery:[NSString stringWithFormat:@"SELECT * FROM cart"]];
    NSLog(@"%@",answerrowset);
    [answerrowset release];
	[localDB release];
    NSLog(@"database release");
}

- (void) deleteItemFromCart:(NSDictionary *)request {

    NSString *rowid = @"";

    if (request != nil) {
        rowid = [request valueForKey:@"rowId"];
    }
    if (rowid == nil) rowid = @"0";

	Sqlite *localDB = [[Sqlite alloc] init];
	BOOL success = [localDB open:[self databasePath]];
	NSAssert(success, @"Cannot open local database");

    [localDB executeNonQuery:@"DELETE FROM cart WHERE rowid = ?", rowid];

	[localDB release];
}

- (NSDictionary *) getCurrentCart: (NSDictionary *)request {
    // returns current project and cart for it


    NSString *where = nil;

    if (request != nil) {
        where = [request valueForKey:@"id"];
    }
    if (where == nil) where = @"is_current = 1";
    else where = [NSString stringWithFormat:@"rfq_id = %@", where];

	Sqlite *localDB = [[Sqlite alloc] init];
	BOOL success = [localDB open:[self databasePath]];
	NSAssert(success, @"Cannot open local database");

    NSArray *answerrowset;
    answerrowset = [localDB executeQuery:[NSString stringWithFormat:@"SELECT * FROM rfq WHERE %@", where]];
    NSMutableDictionary *res = [[NSMutableDictionary alloc] init];
    NSString *rfq_id = @"";
    for (NSDictionary *row in answerrowset) {
        NSString *projectname = [row valueForKey:@"projectname"];
        rfq_id = [row valueForKey:@"rfq_id"];
        NSInteger start = [[row valueForKey:@"estimated_start"] integerValue];
        NSInteger end = [[row valueForKey:@"estimated_end"] integerValue];
        NSString *name = [row valueForKey:@"poc_name"];
        NSString *email = [row valueForKey:@"poc_email"];
        NSString *phone = [row valueForKey:@"poc_phone"];

        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:start];
        NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:end];

        [res setValue:projectname forKey:@"project"];
        [res setValue:rfq_id forKey:@"id"];
        [res setValue:startDate forKey:@"start"];
        [res setValue:endDate forKey:@"end"];
        [res setValue:name forKey:@"name"];
        [res setValue:email forKey:@"email"];
        [res setValue:phone forKey:@"phone"];

    }

	[answerrowset release];

    answerrowset = [localDB executeQuery:@"SELECT c.rowid, c.*, p.Product FROM [cart] AS c INNER JOIN Product_Catalog AS p ON p.product_ID = c.product_ID WHERE c.rfq_id = ?", rfq_id];
    NSMutableArray *cart = [NSMutableArray array];
    for (NSDictionary *row in answerrowset) {
        NSString *row_id = [row valueForKey:@"rowid"];
        NSString *product_id = [row valueForKey:@"product_ID"];
        NSString *product = [row valueForKey:@"Product"];
        NSString *qty = [row valueForKey:@"qty"];
        NSString *comments = [row valueForKey:@"comments"];

        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];

        [item setValue:row_id forKey:@"rowId"];
        [item setValue:product_id forKey:@"productId"];
        [item setValue:product forKey:@"product"];
        [item setValue:qty forKey:@"count"];
        [item setValue:comments forKey:@"comments"];

        [cart addObject:item];
    }

    [res setValue:cart forKey:@"cart"];
	[answerrowset release];

	[localDB release];
    return res;

}

@end