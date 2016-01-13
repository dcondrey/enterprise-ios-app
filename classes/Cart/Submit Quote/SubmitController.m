//
// submitcontroller.m
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

#import "SubmitController.h"
#import "DataSource.h"
#import "SKPSMTPMessage.h"

@interface SubmitController ()

@end

@implementation SubmitController

@synthesize textView = _textView;
@synthesize delegate;

NSMutableString *submitText;
NSString *project;
NSDate *start;
NSDate *end;
NSString *name;
NSString *email;
NSString *phone;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    NSDictionary *cart = [[DataSource sharedInstance] getCurrentCart:nil];

    project = [cart valueForKey:@"project"];
    start = [cart valueForKey:@"start"];
    end = [cart valueForKey:@"end"];
    name = [cart valueForKey:@"name"];
    email = [cart valueForKey:@"email"];
    phone = [cart valueForKey:@"phone"];

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/YYYY"];

    submitText = [NSMutableString stringWithFormat:@"Project: %@\nEstimated dates: %@ - %@\nContact: %@\nEmail: %@\nPhone: %@\n------------------\n", project, [df stringFromDate:start], [df stringFromDate:end], name, email, phone];

    NSArray *items = (NSArray *)[cart valueForKey:@"cart"];

    for (NSDictionary *row in items) {
        NSString *line = [NSString stringWithFormat:@" * %@ | %@ - %@pcs : %@\n", [row valueForKey:@"productId"], [row valueForKey:@"product"], [row valueForKey:@"count"], [row valueForKey:@"comments"]];
        [submitText appendString:line];
    }
    _textView.text = submitText;

    if ([project isEqualToString:@""] || [name isEqualToString:@""] || [email isEqualToString:@""] || [phone isEqualToString:@""] || start == nil || end == nil)
    {
        DarkAlertView *incompleteAlert = [[DarkAlertView alloc] initWithTitle:@"Please fill in all contact information for us to process your request." message:@"Please fill all fields in the form" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];

        [incompleteAlert show];
        [incompleteAlert release];

        return;
    }
}

- (BOOL) textViewShouldReturn:(UITextView *)textView {
    [textView resignFirstResponder];
    return NO;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction) okButtonTapped:(id) sender {
    NSLog(@"OK tapped");

    SKPSMTPMessage *msg = [[SKPSMTPMessage alloc] init];
    msg.login = @""; // from email address
    msg.pass = @""; // email password

    msg.relayHost = @"smtp.gmail.com"; // SMTP SERVER
    msg.relayPorts = [NSArray arrayWithObjects:[NSNumber numberWithInt:587], nil]; // and port

    msg.requiresAuth = YES;
    msg.wantsSecure = YES;

    msg.subject = @""; // email subject
    msg.fromEmail = [NSString stringWithFormat:@"%@", msg.login];
    msg.toEmail = @""; // to email address

    NSString *body = [NSString stringWithString:_textView.text];

    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain", @"kSKPSMTPPartContentTypeKey", body, @"kSKPSMTPPartMessageKey", @"8bit", @"kSKPSMTPPartContentTransferEncodingKey", nil];


    msg.parts = [NSArray arrayWithObjects:plainPart, nil];

    msg.delegate = self;
    [msg send];
}

- (IBAction) cancelButtonTapped:(id) sender {
    [self.delegate dismissViewControllerAnimated:YES completion:nil];
}

- (void) messageSent:(SKPSMTPMessage *)message {
    NSLog(@"Email sent");
    [message release];

    DarkAlertView *submittedAlert = [[DarkAlertView alloc] initWithTitle:@"Order Submitted" message:@"Your order has been submitted successfully.\nYou should receive a response shortly.\nIf you need a more urgent response please give us a call." delegate:self cancelButtonTitle:@"" otherButtonTitles:@"Finish", nil];
    [submittedAlert show];
    [submittedAlert release];


    [self.delegate dismissViewControllerAnimated:YES completion:nil];
}

- (void) messageFailed:(SKPSMTPMessage *)message error:(NSError *)error {
    NSLog(@"%@", [NSString stringWithFormat:@"Email failed!\n%i: %@\n%@", [error code], [error localizedDescription], [error localizedRecoverySuggestion]]);
    [message release];

    DarkAlertView *failedAlert = [[DarkAlertView alloc] initWithTitle:@"Error" message:@"Your order has not be received.\nPlease submit your order again, after you have verified that your device has an active network connection.\nIf the problem persists please give us a call." delegate:self cancelButtonTitle:@"" otherButtonTitles:@"Continue", nil];
    [failedAlert show];
    [failedAlert release];
}

@end