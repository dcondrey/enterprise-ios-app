//
// downloadhelper.m
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

#import "DownloadHelper.h"
#import "Sqlite.h"

#define DELEGATE_CALLBACK(X, Y) if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(X)]) [sharedInstance.delegate performSelector:@selector(X) withObject:Y]
#define NUMBER(X) [NSNumber numberWithFloat:X]

static DownloadHelper *sharedInstance = nil;

@implementation DownloadHelper

@synthesize response;
@synthesize data;
@synthesize delegate;
@synthesize urlString;
@synthesize urlConnection;
@synthesize isDownloading;

- (void) start {
    self.isDownloading = NO;

    NSURL *url = [NSURL URLWithString:self.urlString];
    if (!url) {
        NSString *reason = [NSString stringWithFormat:@"Could not create URL from string %@", self.urlString];
        DELEGATE_CALLBACK(dataDownloadFailed:, reason);
        return;
    }

    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    if (!theRequest) {
        NSString *reason = [NSString stringWithFormat:@"Could not create URL request from string %@", self.urlString];
        DELEGATE_CALLBACK(dataDownloadFailed:, reason);
        return;
    }

    self.urlConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (!self.urlConnection) {
        NSString *reason = [NSString stringWithFormat:@"URL connection failed for string %@", self.urlString];
        DELEGATE_CALLBACK(dataDownloadFailed:, reason);
    }

    self.isDownloading = YES;

    self.data = [NSMutableData data];
    self.response = nil;

    [self.urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) cleanup {
    self.data = nil;
    self.response = nil;
    self.urlConnection = nil;
    self.urlString = nil;
    self.isDownloading = NO;
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse {
    self.response = aResponse;

	if ([aResponse expectedContentLength] < 0) {
        NSString *reason = [NSString stringWithFormat:@"Invalid URL [%@]", self.urlString];
        DELEGATE_CALLBACK(dataDownloadFailed:, reason);
        [connection cancel];
        [self cleanup];
        return;
    }

    if ([aResponse suggestedFilename])
        DELEGATE_CALLBACK(didReceiveFileName:, [aResponse suggestedFilename]);
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData {
    [self.data appendData:theData];
    if (self.response)
    {
        float expectedLength = [self.response expectedContentLength];
        float currentLength = self.data.length;
        float percent = currentLength / expectedLength;
        DELEGATE_CALLBACK(dataDownloadAtPercent:, NUMBER(percent));
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {

    [self didReceiveData:self.data];
    [self cleanup];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.isDownloading = NO;
    NSLog(@"Error: Failed connection, %@", [error localizedDescription]);
    DELEGATE_CALLBACK(dataDownloadFailed:, @"Failed Connection");
    [self cleanup];
}

+ (DownloadHelper *) sharedInstance {
    if (!sharedInstance)
        sharedInstance = [[self alloc] init];
    return sharedInstance;
}

- (void) download:(NSString *)aURLString {
    if (sharedInstance.isDownloading) {
        NSLog(@"Error: Cannot start new download until current download finishes");
        DELEGATE_CALLBACK(dataDownloadFailed:, @"");
        return;
    }

    sharedInstance.urlString = aURLString;
    [sharedInstance start];
}

- (void) cancel{
    if (sharedInstance.isDownloading)
        [sharedInstance.urlConnection cancel];
}

- (void) didReceiveData: (NSData *) theData {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savePath = [documentsDirectory stringByAppendingPathComponent:@"temp.sqlite"];

    [theData writeToFile:savePath atomically:YES];

    [self updateProductInfo:savePath];
}

- (void) updateProductInfo:(NSString *)tempPath {
    Sqlite *tempDB = [[Sqlite alloc] init];
	BOOL success = [tempDB open:tempPath];
	NSAssert(success, @"Cannot open local database");

    Sqlite *localDB = [[Sqlite alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *l_writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"radical_v2-506.sqlite"];

	success = [localDB open:l_writableDBPath];
	NSAssert(success, @"Cannot open local database");

    NSArray *temp_versionInfoSet = [tempDB executeQuery:@"SELECT * FROM version"];
    NSArray *cur_versionInfoSet = [localDB executeQuery:@"SELECT * FROM version"];
    if (temp_versionInfoSet == nil || cur_versionInfoSet == nil)
        return;

    NSMutableDictionary *temp_versionSet = [temp_versionInfoSet objectAtIndex:0];
    NSString *temp_versionID = [temp_versionSet valueForKey:@"versionid"];
    NSMutableDictionary *cur_versionSet = [cur_versionInfoSet objectAtIndex:0];
    NSString *cur_versionID = [cur_versionSet valueForKey:@"versionid"];
    if ([temp_versionID compare:cur_versionID] == 0)
        return;
    if ([temp_versionInfoSet count] < 1)
        return;



    NSString *updateCatalogRow = [[temp_versionInfoSet objectAtIndex:0] valueForKey:@"updatecatalogrow"];
    NSLog(@"%@", updateCatalogRow);

    if (updateCatalogRow == NULL || ([updateCatalogRow compare:@""]) == 0)
        return;

    int c_startIndex = [updateCatalogRow intValue];

	NSArray *temp_cat_rowset = [tempDB executeQuery:@"SELECT * FROM Product_Catalog"];
    int temp_rowCount = [temp_cat_rowset count];


    for (int i = c_startIndex-1; i < temp_rowCount; i++) {
        NSDictionary *row = [temp_cat_rowset objectAtIndex:i];

        NSString *product_ID = [row valueForKey:[NSString stringWithFormat:@"product_ID"]];
        if (product_ID == nil)  product_ID = @"";
        NSString *Product = [row valueForKey:[NSString stringWithFormat:@"Product"]];
        if (Product == nil)  Product = @"";
        NSString *Manufacturer = [row valueForKey:[NSString stringWithFormat:@"Manufacturer"]];
        if (Product == nil)  Product = @"";

        NSString *cat = [row valueForKey:[NSString stringWithFormat:@"cat"]];
        if (cat == nil)  cat = @"";

        NSString *displayorder = [row valueForKey:[NSString stringWithFormat:@"displayorder"]];
        if (displayorder == nil)  displayorder = @"";

        NSString *display_Thumbnail = [row valueForKey:[NSString stringWithFormat:@"display_Thumbnail"]];
        if (display_Thumbnail == nil)  display_Thumbnail = @"";

        NSString *display_Image01 = [row valueForKey:[NSString stringWithFormat:@"display_Image01"]];
        if (display_Image01 == nil)  display_Image01 = @"";

        NSString *display_Image02 = [row valueForKey:[NSString stringWithFormat:@"display_Image02"]];
        if (display_Image02 == nil)  display_Image02 = @"";

        NSString *display_Image03 = [row valueForKey:[NSString stringWithFormat:@"display_Image03"]];
        if (display_Image03 == nil)  display_Image03 = @"";

        NSString *display_Image04 = [row valueForKey:[NSString stringWithFormat:@"display_Image04"]];
        if (display_Image04 == nil)  display_Image04 = @"";

        NSString *display_Image05 = [row valueForKey:[NSString stringWithFormat:@"display_Image05"]];
        if (display_Image05 == nil)  display_Image05 = @"";

        NSString *t_360 = [row valueForKey:[NSString stringWithFormat:@"panorama"]];
        if (t_360 == nil)  t_360 = @"";
        NSString *p_vid = [row valueForKey:[NSString stringWithFormat:@"promovid"]];
        if (p_vid == nil) p_vid = @"";
        NSString *b_vid = [row valueForKey:[NSString stringWithFormat:@"bracketvid"]];
        if (b_vid == nil) b_vid = @"";
        NSString *d_vid = [row valueForKey:[NSString stringWithFormat:@"dynamicvid"]];
        if (d_vid == nil) d_vid = @"";
        NSString *c_vid = [row valueForKey:[NSString stringWithFormat:@"colorrendvid"]];
        if (c_vid == nil) c_vid = @"";
        NSString *g_vid = [row valueForKey:[NSString stringWithFormat:@"gscreenvid"]];
        if (g_vid == nil) g_vid = @"";


        NSString *description = [row valueForKey:[NSString stringWithFormat:@"description"]];
        if (description == nil)  description = @"";

        NSString *info_DetailsKey = [row valueForKey:[NSString stringWithFormat:@"info_DetailsKey"]];
        if (info_DetailsKey == nil)  info_DetailsKey = @"";

        NSString *info_spec_a = [row valueForKey:[NSString stringWithFormat:@"info_spec_a"]];
        if (info_spec_a == nil)  info_spec_a = @"";

        NSString *info_spec_b = [row valueForKey:[NSString stringWithFormat:@"info_spec_b"]];
        if (info_spec_b == nil)  info_spec_b = @"";

        NSString *info_spec_c = [row valueForKey:[NSString stringWithFormat:@"info_spec_c"]];
        if (info_spec_c == nil)  info_spec_c = @"";

        NSString *info_spec_d = [row valueForKey:[NSString stringWithFormat:@"info_spec_d"]];
        if (info_spec_d == nil)  info_spec_d = @"";

        NSString *info_spec_e = [row valueForKey:[NSString stringWithFormat:@"info_spec_e"]];
        if (info_spec_e == nil)  info_spec_e = @"";

        NSString *info_spec_f = [row valueForKey:[NSString stringWithFormat:@"info_spec_f"]];
        if (info_spec_f == nil)  info_spec_f = @"";

        NSString *info_spec_g = [row valueForKey:[NSString stringWithFormat:@"info_spec_g"]];
        if (info_spec_g == nil)  info_spec_g = @"";

        NSString *info_spec_h = [row valueForKey:[NSString stringWithFormat:@"info_spec_h"]];
        if (info_spec_h == nil)  info_spec_h = @"";

        NSString *info_spec_i = [row valueForKey:[NSString stringWithFormat:@"info_spec_i"]];
        if (info_spec_i == nil)  info_spec_i = @"";

        NSString *info_spec_j = [row valueForKey:[NSString stringWithFormat:@"info_spec_j"]];
        if (info_spec_j == nil)  info_spec_j = @"";

        NSString *info_spec_k = [row valueForKey:[NSString stringWithFormat:@"info_spec_k"]];
        if (info_spec_k == nil)  info_spec_k = @"";

        NSString *info_spec_l = [row valueForKey:[NSString stringWithFormat:@"info_spec_l"]];
        if (info_spec_l == nil)  info_spec_l = @"";

        NSString *info_spec_m = [row valueForKey:[NSString stringWithFormat:@"info_spec_m"]];
        if (info_spec_m == nil)  info_spec_m = @"";

        NSString *info_spec_n = [row valueForKey:[NSString stringWithFormat:@"info_spec_n"]];
        if (info_spec_n == nil)  info_spec_n = @"";

        NSString *info_spec_o = [row valueForKey:[NSString stringWithFormat:@"info_spec_o"]];
        if (info_spec_o == nil)  info_spec_o = @"";

        NSString *info_spec_p = [row valueForKey:[NSString stringWithFormat:@"info_spec_p"]];
        if (info_spec_p == nil)  info_spec_p = @"";

        NSString *info_spec_q = [row valueForKey:[NSString stringWithFormat:@"info_spec_q"]];
        if (info_spec_q == nil)  info_spec_q = @"";

		[localDB executeNonQuery:@"INSERT INTO Product_Catalog (product_ID, Product, Manufacturer, cat, displayorder, display_Thumbnail, display_Image01, display_Image02, display_Image03, display_Image04, display_Image05, panorama, promovid, bracketvid, dynamicvid, colorrendvid, gscreenvid, description, info_DetailsKey, info_spec_a, info_spec_b, info_spec_c, info_spec_d, info_spec_e, info_spec_f, info_spec_g, info_spec_h, info_spec_i, info_spec_j, info_spec_k, info_spec_l, info_spec_m, info_spec_n, info_spec_o, info_spec_p, info_spec_q) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", product_ID, Product, Manufacturer, cat, displayorder, display_Thumbnail, display_Image01, display_Image02, display_Image03, display_Image04, display_Image05, t_360, p_vid, b_vid, d_vid, c_vid, g_vid, description, info_DetailsKey, info_spec_a, info_spec_b, info_spec_c, info_spec_d, info_spec_e, info_spec_f, info_spec_g, info_spec_h, info_spec_i, info_spec_j, info_spec_k, info_spec_l, info_spec_m, info_spec_n, info_spec_o, info_spec_p, info_spec_q];

    }

    NSString *updateAssetRow = [[temp_versionInfoSet objectAtIndex:0] valueForKey:@"updateassetrow"];
    if (updateAssetRow != nil && ([updateAssetRow compare:@""]) != 0) {

        int a_startIndex = [updateAssetRow intValue];
        NSArray *temp_asset_rowset = [tempDB executeQuery:@"SELECT * FROM Product_Assets"];

        int temp_assetCount = [temp_asset_rowset count];

        for (int i = a_startIndex-1; i < temp_assetCount; i++) {
            NSDictionary *row = [temp_asset_rowset objectAtIndex:i];
            NSString *assetID = [row valueForKey:[NSString stringWithFormat:@"assetID"]];
            NSString *kitID = [row valueForKey:[NSString stringWithFormat:@"kitID"]];
            NSString *asset = [row valueForKey:[NSString stringWithFormat:@"asset"]];
            NSString *kitQTY = [row valueForKey:[NSString stringWithFormat:@"kitQTY"]];

            [localDB executeNonQuery:@"INSERT INTO Product_Assets (assetID, kitID, asset, kitQTY) VALUES(?, ?, ?, ?)", assetID, kitID, asset, kitQTY];
        }
    }

    if (temp_versionID == nil)
        temp_versionID = @"";
    if (updateCatalogRow == nil)
        updateCatalogRow = @"";
    if (updateAssetRow == nil)
        updateAssetRow = @"";

    [localDB executeNonQuery:@"DELETE FROM version"];
    [localDB executeNonQuery:@"INSERT INTO version (versionid, updatecatalogrow, updateassetrow) VALUES(?, ?, ?)", temp_versionID, updateCatalogRow, updateAssetRow];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notify" message:@"Database updated." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
}

@end
