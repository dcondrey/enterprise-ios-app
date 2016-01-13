//
// comment.h
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
#import "Category.h"
#import "DarkAlertView.h"

@interface Comment : UIViewController  <UITextViewDelegate, UIAlertViewDelegate> {
    UILabel *_titleLabel;

	UITextView *_userComment;

    UIImageView *_backgroundGradient;
}

@property (nonatomic, assign) IBOutlet UILabel *titleLabel;

@property (nonatomic, assign) IBOutlet UITextView *userComment;
@property (nonatomic, assign) IBOutlet UIButton *addButon;
@property (nonatomic, assign) IBOutlet UIButton *cancelButton;

@property (nonatomic, assign) IBOutlet UIStepper *stepper;
@property (nonatomic, assign) IBOutlet UILabel *countLabel;


@property (nonatomic, assign) UIViewController *delegate;
@property (strong, nonatomic) Category *detailCategory;


@property (nonatomic, assign) IBOutlet UIImageView *backgroundGradient;

- (IBAction) addButtonTapped:(id) sender;
- (IBAction) cancelButtonTapped:(id) sender;
- (IBAction) stepperValueChanged:(id) sender;
- (IBAction) createProjectButtonTapped:(id) sender;
- (IBAction) viewProjectsButtonTapped:(id) sender;


@end
