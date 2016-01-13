//
// appdelegate.m
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

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "DataFetcher.h"
#import "DataVersion.h"
#import "Template.h"
#import "TemplateTab.h"
#import "Image.h"
#import "Category.h"
#import "Group.h"
#import "VariableStore.h"
#import "iPhoneInitialLoadView.h"
#import "CustomSearchViewController.h"
#import "AtoZCategoryViewController.h"
#import "iphoneAboutViewController.h"
#import "DownloadHelper.h"
#import "Sqlite.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;

- (void) dealloc {
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [_navigationController release];
    [_splitViewController release];
    [super dealloc];
}

- (void) customizeAppearance {
    UIImage *gradientImage44 = [[UIImage imageNamed:@"navbar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *gradientImage32 = [[UIImage imageNamed:@"navbar(landscape).png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

    // Set the background image for *all* UINavigationBars
    [[UINavigationBar appearance] setBackgroundImage:gradientImage44 forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:gradientImage32 forBarMetrics:UIBarMetricsLandscapePhone];

    // Customize the title text for *all* UINavigationBars
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:244/255.0f green:252/255.0f blue:252/255.0f alpha:1.0f], UITextAttributeTextColor, [UIFont fontWithName:@"Helvetica" size:14], UITextAttributeFont,nil]];
	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self customizeAppearance];
    [self loadSettings];

    [self updateTableData];

    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"NOT_FIRST_TIME"] boolValue]) {
        DarkAlertView *firstStartAlert = [[DarkAlertView alloc]initWithTitle:@"Welcome to Radiant Images " message:@"An active internet connection is required/n to view the full content of this application." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [firstStartAlert show];
        [firstStartAlert release];

        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"NOT_FIRST_TIME"];
    }

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.

	//Database Check/Build
    BOOL buildingDatabase = NO;

	//Database setup occurs on a separate thread, buildingDatabase is used to prevent userinput and orientation changes in the iPad Version
	//while the database is building
	if (![[DataFetcher sharedInstance] databaseExists]||!isDatabaseComplete) {
		[self setupDatabase];
		buildingDatabase = YES;
	} else {
		//check if stored version number is the same as the current, if not, refresh database
        NSArray *currentVersionArray = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"DataVersion" withPredicate:nil];
        if ([currentVersionArray count] > 0) {

            DataVersion *currentDataVersion = [currentVersionArray objectAtIndex:0];
            if (![currentDataVersion.versionID isEqualToString:[VariableStore sharedInstance].currentDataVersion]) {
                NSLog(@"The database is being refreshed as the stored versionID is different to the CustomSettingsID");
                NSLog(@"Stored data version: %@", currentDataVersion.versionID);
                NSLog(@"CustomSetting data version: %@", [VariableStore sharedInstance].currentDataVersion);
                buildingDatabase = YES;
                [self refreshDatabase];
            }

        } else { //we don't have a version in the database, refersh
            NSLog(@"The data base is being refreshed as there is no versionID");
            buildingDatabase = YES;
            [self refreshDatabase];

        }

    }

	NSLog(@"Passed Database Build");

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (buildingDatabase) {
			iPhoneLoaderView = [[iPhoneInitialLoadView alloc] initWithNibName:@"iPhoneInitialLoadView" bundle:nil];
			[_window addSubview:iPhoneLoaderView.view];

		} else {
			[self initiPhoneLayout]; // iPhone Loading Path
		}

    } else { // iPad Loading Path

        MasterViewController *masterViewController = [[[MasterViewController alloc] initWithNibName:@"MasterViewController_iPad" bundle:nil] autorelease];
        UINavigationController *masterNavigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];

        DetailViewController *detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController_iPad" bundle:nil] autorelease];
    	detailViewController.managedObjectContext = self.managedObjectContext;

        self.splitViewController = [[[UISplitViewController alloc] init] autorelease];
        self.splitViewController.delegate = detailViewController;

        self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailViewController, nil];
        self.window.rootViewController = self.splitViewController;
        masterViewController.detailViewController = detailViewController;
        masterViewController.managedObjectContext = self.managedObjectContext;

		masterViewController.detailViewController.orientationLock = NO;
    }
    [self.window makeKeyAndVisible];

    return YES;
}

- (void) initiPhoneLayout {

	tabBarController = [[UITabBarController alloc] init];

    MasterViewController *masterViewController = [[[MasterViewController alloc] initWithNibName:@"MasterViewController_iPhone" bundle:nil] autorelease];
    masterViewController.managedObjectContext = self.managedObjectContext;
    masterViewController.tabBarItem.image = [UIImage imageNamed:@"sections.png"];
	masterViewController.title = NSLocalizedString(@"Radiant Images",nil);

    UINavigationController *groupNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];

    iphoneAboutViewController *aboutVC = [[iphoneAboutViewController alloc] initWithNibName:@"iphoneAboutViewController" bundle:nil];

    aboutVC.tabBarItem.image = [UIImage imageNamed:@"about.png"];
    aboutVC.title = NSLocalizedString(@"",nil);

    CustomSearchViewController *customSearchViewController = [[CustomSearchViewController alloc] initWithNibName:@"CustomSearchViewController" bundle:nil];

    customSearchViewController.managedObjectContext = self.managedObjectContext;
    UINavigationController *searchNavController = [[UINavigationController alloc] initWithRootViewController:customSearchViewController];

    searchNavController.tabBarItem.image = [UIImage imageNamed:@"search.png"];

    customSearchViewController.title =  NSLocalizedString(@"",nil);
    searchNavController.title = NSLocalizedString(@"",nil);

    AtoZCategoryViewController *aToZViewController = [[AtoZCategoryViewController alloc] initWithNibName:@"AtoZCategoryViewController" bundle:nil];

    aToZViewController.managedObjectContext = self.managedObjectContext;
    UINavigationController *aToZNavController = [[UINavigationController alloc] initWithRootViewController:aToZViewController];

    aToZNavController.tabBarItem.image = [UIImage imageNamed:@"indexaz.png"];

    aToZViewController.title = NSLocalizedString(@"",nil);
    aToZNavController.title = NSLocalizedString(@"",nil);

	NSArray *tabBarVCArray = [NSArray arrayWithObjects:groupNavigationController,aToZNavController,searchNavController,aboutVC, nil];

    tabBarController.viewControllers = tabBarVCArray;

	[_window addSubview:tabBarController.view];

	[customSearchViewController release];
    [searchNavController release];

	[aToZViewController release];
    [aToZNavController release];
    [aboutVC release];
}

- (void) updateTableData {
    NSString *stringURL = @"http://www.radiantimages.com/ios/resources/radical_v2-504.sqlite";

    [[DownloadHelper sharedInstance] download: stringURL];
}

- (void) applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}

- (void) saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;

    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            abort();
        }
    }
}

- (void) setupDatabase {
	if ([NSThread currentThread] == [NSThread mainThread]) {
		[self performSelectorInBackground:@selector(setupDatabase) withObject: nil];
		return;
	}

	//Setup pool
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
 	NSUInteger totalNumberOfRecords;
	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];

	int currentRecord = 1;
	NSManagedObjectContext *currentContext = [[DataFetcher sharedInstance] managedObjectContext];
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	NSString *commonArrayPath;

	if ((commonArrayPath =[thisBundle pathForResource:@"radiantimagesData" ofType:@"plist"])) {
		NSDictionary *loadValues = [NSDictionary dictionaryWithContentsOfFile:commonArrayPath];

		if ([loadValues count] > 0) {

			NSString *loadingVersionID = [loadValues objectForKey:@"versionID"];
            DataVersion *loadingDataVersion = [NSEntityDescription insertNewObjectForEntityForName:@"DataVersion" inManagedObjectContext:currentContext];
            loadingDataVersion.versionID = loadingVersionID;

            Template *defaultTemplate = [NSEntityDescription insertNewObjectForEntityForName:@"Template" inManagedObjectContext:currentContext];
            defaultTemplate.templateName = @"default";
            defaultTemplate.tabletTemplate = @"iPadTemplate.html";

            TemplateTab *imageTab =  [NSEntityDescription insertNewObjectForEntityForName:@"TemplateTab" inManagedObjectContext:currentContext];
            imageTab.tabName = @"images";
            imageTab.tabLabel= @"Images";
            imageTab.tabIcon=@"images.png";
			defaultTemplate.tabOne =imageTab;

            //Create Group
            NSArray *groupArray = [loadValues objectForKey:@"groupList"];
            for (NSDictionary *tmpGroup in groupArray) {

				Group *testGroup = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:currentContext];

				testGroup.label = [tmpGroup objectForKey:@"label"];
				testGroup.standardImage = [tmpGroup objectForKey:@"standardImage"];
				testGroup.highlightedImage = [tmpGroup objectForKey:@"highlightedImage"];
                testGroup.order = [f numberFromString:[tmpGroup objectForKey:@"order"]];
			}

            //load Objects
            NSArray *objectArray = [loadValues objectForKey:@"objectData"];
            totalNumberOfRecords = [objectArray count];
            for (NSDictionary *tmpObjectData in objectArray){
                currentRecord += 1;

				[self performSelectorOnMainThread:@selector(updateLoadProgress:) withObject:[NSNumber numberWithInt:currentRecord]  waitUntilDone:NO];

				// Load Categories
				Category *tmpCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:currentContext];

                tmpCategory.subgroup = [tmpObjectData objectForKey:@"subgroup"];
                tmpCategory.identifier = [tmpObjectData objectForKey:@"identifier"];
                tmpCategory.label = [tmpObjectData objectForKey:@"label"];
                tmpCategory.labelStyle = [tmpObjectData objectForKey:@"labelStyle"];
                tmpCategory.sublabel = [tmpObjectData objectForKey:@"sublabel"];
                tmpCategory.sublabelStyle = [tmpObjectData objectForKey:@"sublabelStyle"];
                tmpCategory.searchText =[tmpObjectData objectForKey:@"searchText"];
                tmpCategory.squareThumbnail = [tmpObjectData objectForKey:@"squareThumbnail"];

                NSDictionary *tmpDetails = [tmpObjectData objectForKey:@"details"];
                tmpCategory.details = tmpDetails;

                NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"label=%@", [tmpObjectData objectForKey:@"group"]];
				NSArray *currentgroup = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"Group" withPredicate:groupPredicate];

				if ([currentgroup count] > 0) {
					Group *localGroup = [currentgroup objectAtIndex:0];
		            [localGroup addObjectsObject:tmpCategory];
                }

				// HTML Templates
                NSString *tmpString = [tmpObjectData objectForKey:@"template"];

                if (([tmpString length]==0)||([tmpString isEqualToString:@"default"])) {
                    tmpCategory.template = defaultTemplate;

                } else {

                    NSPredicate *templatePredicate = [NSPredicate predicateWithFormat:@"templateName=%@", tmpString];
                    NSArray *currentTemplate = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"Template" withPredicate:templatePredicate];

					if (currentTemplate.count > 0) {
                        Template *objectTemplate = [currentTemplate objectAtIndex:0];
                        tmpCategory.template = objectTemplate;
                    }
                }

                NSArray *tmpImageArray = [tmpObjectData objectForKey:@"images"];
				int counter = 0;
				for (NSDictionary *tmpImageData in tmpImageArray){
					counter +=1;
					Image *tmpImage = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:currentContext];
					tmpImage.filename = [tmpImageData objectForKey:@"filename"];
					tmpImage.order = [NSNumber numberWithInt:counter];
					[tmpCategory addImagesObject:tmpImage];
                }
            }

            NSLog(@"About to Save");
			NSError *saveError;
            [currentContext save:&saveError];
        }
    }
    [self performSelectorOnMainThread:@selector(finishedImport) withObject:nil waitUntilDone:NO];
    [pool drain];
}

- (void) refreshDatabase {
    NSManagedObjectContext *currentContext = [[DataFetcher sharedInstance] managedObjectContext];
    NSArray *allGroups = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"Group" withPredicate:nil];

    for (Group *tmpGroup in allGroups){
        [currentContext deleteObject:tmpGroup];

    }

    NSArray *remainingCategory = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"Category" withPredicate:nil];
    NSLog(@"Remaining Object Count: %d", [remainingCategory count]);

    for (Category *tmpCategory in remainingCategory){
        [currentContext deleteObject:tmpCategory];
    }

    NSLog(@"About to Save");
    NSError *saveError;
    [currentContext save:&saveError];
    //now reload
    [self setupDatabase];
}

- (BOOL)databaseExists {
	NSString *path = [self databasePath];
	BOOL databaseExists = [[NSFileManager defaultManager] fileExistsAtPath:path];

	return databaseExists;
}

- (NSString *)databasePath {
	return [[[self applicationDocumentsDirectory] absoluteString] stringByAppendingPathComponent: @"temp.sqlite"];
}

- (void) updateLoadProgress:(id)value {
	NSNumber *currentCount = (NSNumber *) value;
	NSLog(@"Current Count, %d", [currentCount intValue]);
	float progress = [currentCount floatValue]/2000.0f;
	NSLog(@"Progress: %f", progress);

}

- (void) finishedImport {
	isDatabaseComplete = YES;
	[self saveSettings];

	// iPad Loaded
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		DetailViewController *iPadDetailVC = (DetailViewController *)[self.splitViewController.viewControllers objectAtIndex:1];
        iPadDetailVC.orientationLock = NO;

    } else {
		iPhoneLoaderView.view.hidden = YES;
		[iPhoneLoaderView.view removeFromSuperview];

        [self initiPhoneLayout];
    }
}

- (void) loadSettings {

	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    if ([prefs boolForKey:@"isDatabaseComplete"]) {
		isDatabaseComplete = [prefs boolForKey:@"isDatabaseComplete"];
	}
}

- (void) saveSettings {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setBool:isDatabaseComplete forKey:@"isDatabaseComplete"];
	[prefs synchronize];
}

- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"radiantimages" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"rad.sqlite"];

    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

	if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
		abort();
    }

    return __persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (AppDelegate *) get {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end