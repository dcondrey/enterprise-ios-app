//
// gscreenvidviewcontroller.m
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

#import "GscreenvidViewController.h"

@interface GscreenvidViewController ()

@end

@implementation GscreenvidViewController

@synthesize delegate;
@synthesize webView;
@synthesize gscreenvid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil gscreenvid:(NSString *)url {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		gscreenvid = url;
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    if (gscreenvid != nil && [gscreenvid compare:@""] != 0) {
        NSURL *p_url = [NSURL URLWithString:gscreenvid];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:p_url];
        [webView loadRequest:requestObj];
    }
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateDidChange:) name:@"MPAVControllerItemPlaybackDidEndNotification" object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerWillExitFullscreen) name:@"UIMoviePlayerControllerWillExitFullscreenNotification" object:nil];
}

- (void)playerWillExitFullscreen {
	[self.delegate dismissViewControllerAnimated:YES completion:nil];
}

- (void) playbackStateDidChange:(NSNotification *)note {
    NSLog(@"note.name=%@ state=%d", note.name, [[note.userInfo objectForKey:@"MPAVControllerNewStateParameter"] intValue]);

	[self.delegate dismissViewControllerAnimated:YES completion:nil];
}


- (NSUInteger)supportedInterfaceOrientations {
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown);
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction) cancelButtonTapped:(id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end