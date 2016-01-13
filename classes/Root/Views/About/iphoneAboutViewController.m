//
// iphoneaboutviewcontroller.m
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

#import "iphoneAboutViewController.h"

@implementation iphoneAboutViewController

@synthesize logo = logo;
@synthesize telephone = _telephone;
@synthesize website = _website;

- (void) viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Radiant Images",nil);

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) didReceiveMemoryWarning {
	self.logo = nil;
	self.telephone = nil;
	self.website = nil;
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload {
	self.logo = nil;
	self.telephone = nil;
	self.website = nil;
    [super viewDidUnload];

}

- (void) dealloc {
	[logo release];
	[_telephone release];
	[_website release];
    [super dealloc];
}


@end
