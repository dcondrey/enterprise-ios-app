//
// newprojectcontroller.m
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

#import "NewProjectController.h"
#import "DataSource.h"

@interface NewProjectController ()

@end

@implementation NewProjectController

@synthesize okButton;
@synthesize cancelButton;
@synthesize delegate;
@synthesize prodText;
@synthesize startText;
@synthesize endText;
@synthesize nameText;
@synthesize emailText;
@synthesize phoneText;

UIDatePicker *datePicker;
NSDate *date;
UIToolbar *keyboardToolbar;

UITextField *curDateField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    if (keyboardToolbar == nil) {
        keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
        [keyboardToolbar setBarStyle:UIBarStyleBlackTranslucent];

        UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

        UIBarButtonItem *aceptar = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneDatePicker:)];

        [keyboardToolbar setItems:[[NSArray alloc] initWithObjects: extraSpace, aceptar, nil]];
    }

    self.startText.inputAccessoryView = keyboardToolbar;
    self.endText.inputAccessoryView = keyboardToolbar;

    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];

    self.startText.inputView = datePicker;
    self.endText.inputView = datePicker;
}

- (void) datePickerValueChanged:(id)sender {

    date = datePicker.date;

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/YYYY"];

    [curDateField setText:[df stringFromDate:date]];
    [df release];
}

- (void) doneDatePicker:(id)sender {
    [curDateField resignFirstResponder];
}

- (IBAction) dateTextEditingDidBegin:(id) sender {
    NSLog(@"begin");
    curDateField = (UITextField *) sender;

    date = datePicker.date;

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/YYYY"];

    [curDateField setText:[df stringFromDate:date]];
    [df release];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction) okButtonTapped:(id) sender {
    NSLog(@"OK tapped");

    NSString *prod = self.prodText.text;
    NSString *start = self.startText.text;
    NSString *end = self.endText.text;
    NSString *name = self.nameText.text;
    NSString *email = self.emailText.text;
    NSString *phone = self.phoneText.text;

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:name forKey:name];

    if ([prod isEqualToString:@""] || [name isEqualToString:@""] || [email isEqualToString:@""] || [phone isEqualToString:@""] || start == nil || end == nil) {
        DarkAlertView *incompleteAlert = [[DarkAlertView alloc] initWithTitle:@"Please fill in all contact information for us to process your request." message:@"Please fill all fields in the form" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];

        [incompleteAlert show];
        [incompleteAlert release];

        return;
    }

    [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@", prod, start, end, name, email, phone];

    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setValue:prod forKey:@"project"];
    [request setValue:start forKey:@"start"];
    [request setValue:end forKey:@"end"];
    [request setValue:name forKey:@"name"];
    [request setValue:email forKey:@"email"];
    [request setValue:phone forKey:@"phone"];

	NSInteger rowId = [[DataSource sharedInstance] createProject:request];

    [NSString stringWithFormat:@"ProjectID: %d", rowId];

    [self.delegate dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) cancelButtonTapped:(id) sender {
    [self.delegate dismissViewControllerAnimated:YES completion:nil];
}

@end