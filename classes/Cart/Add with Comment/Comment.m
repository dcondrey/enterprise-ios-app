//
// comment.m
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

#import "Comment.h"
#import "DataSource.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
#import "NewProjectController.h"
#import "DisplayProjectsController.h"

@implementation Comment

@synthesize titleLabel = _titleLabel;
@synthesize userComment = _userComment;
@synthesize backgroundGradient = _backgroundGradient;
@synthesize stepper = _stepper;
@synthesize countLabel = _countLabel;

@synthesize detailCategory = _detailCategory;

@synthesize delegate;

NSString *textPlaceholder = @"";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (IBAction) addButtonTapped:(id) sender {
    NSLog(@"ADD tapped");

    NSString *comment = _userComment.text;
    NSString *count = [NSString stringWithFormat:@"%i", (int)_stepper.value];
    NSString *productId = _detailCategory.identifier;

    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setValue:comment forKey:@"comment"];
    [request setValue:count forKey:@"count"];
    [request setValue:productId forKey:@"productId"];

    if (_detailCategory != nil) {
        [[DataSource sharedInstance] addToCurrentProject:request];
        [SVProgressHUD showSuccessWithStatus:@"Product Added"];

    } else {
        [SVProgressHUD showErrorWithStatus:@"Navigate to a Product First"];

    }
    [self.delegate dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) cancelButtonTapped:(id) sender; {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1]; // fade away over 1 seconds
        [delegate.view setAlpha:0];
        [UIView commitAnimations];
    } else {
        [self.delegate dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction) createProjectButtonTapped:(id) sender {
    NewProjectController *newProjectController = [[NewProjectController alloc] init];

    newProjectController.delegate = (UIViewController *)self;
    [newProjectController.delegate.navigationController presentViewController:newProjectController animated:YES completion:nil];

    [newProjectController release];
}

- (IBAction) viewProjectsButtonTapped:(id) sender {
    DisplayProjectsController *displayProjectsController = [[DisplayProjectsController alloc] init];

    displayProjectsController.delegate = (UIViewController *)self;
    [displayProjectsController.delegate.navigationController presentViewController:displayProjectsController animated:YES completion:nil];

    [displayProjectsController release];
}

- (BOOL) textViewShouldReturn:(UITextView *)textView {
    [textView resignFirstResponder];
    return NO;
}

- (IBAction) stepperValueChanged:(id) sender {
    _countLabel.text = [NSString stringWithFormat:@"%i", (int)_stepper.value];
}

- (void) viewDidLoad {
    _userComment.text = textPlaceholder;
    _userComment.textColor = [UIColor lightGrayColor];
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    if ([_userComment.text isEqualToString:textPlaceholder]) {
        _userComment.text = @"";
    }
    _userComment.textColor = [UIColor blackColor];
    return YES;
}

- (void) textViewDidChange:(UITextView *)textView {
    if (_userComment.text.length == 0){
        _userComment.textColor = [UIColor lightGrayColor];
        _userComment.text = textPlaceholder;
        [_userComment resignFirstResponder];
    }
}

- (void) dealloc {
    [super dealloc];
}

@end