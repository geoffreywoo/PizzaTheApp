//
//  PaymentViewController.m
//  PizzaTheAppStripe
//
//  Created by Joe Vasquez on 5/28/14.
//  Copyright (c) 2014 Joe Vasquez. All rights reserved.
//

#import "PaymentViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "MainViewController.h"
#import "PKView.h"
#import "Mixpanel/Mixpanel.h"

/*
#define STRIPE_KEY @"pk_test_9wPOvSKQ8o5EsuXDWUIBjzlQ"
#define API_ORDERS @"https://pizzatheapp-staging.herokuapp.com/api/orders"
#define API_CUSTOMERS @"https://pizzatheapp-staging.herokuapp.com/api/customers/"
*/

#define STRIPE_KEY @"pk_live_5l59z07mDTFiUSSxp9UGBYxr"
#define API_ORDERS @"https://pizzatheapp.herokuapp.com/api/orders"
#define API_CUSTOMERS @"https://pizzatheapp.herokuapp.com/api/customers/"


#define DefaultBoldFont [UIFont boldSystemFontOfSize:17]
#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define DarkGreyColor RGB(247,247,247)
#define backgroundGrey RGB(248,248,248)
#define cardAlertView 1
#define phoneAlertView 2
#define allAlertView 3
#define plateSize 20
#define kOFFSET_FOR_KEYBOARD 80.0


//#define LIVE KEY @"pk_live_5l59z07mDTFiUSSxp9UGBYxr"
//#define TEST KEY @"pk_test_9wPOvSKQ8o5EsuXDWUIBjzlQ"
//#define STRIPE_TEST_POST_URL @"https://pizzatheapp.herokuapp.com/api/orders"

@interface PaymentViewController ()
- (void)hasError:(NSError *)error;
- (void)hasToken:(STPToken *)token;
- (void)textFieldDidChange;
@end

bool _firstTime;

bool _phonePopulated;
bool _cardPopulated;
bool _namePopulated;
bool _emailPopulated;

bool _cardValid;

@implementation PaymentViewController

- (void) checkToEnableSave {
    if ( ([[NSUserDefaults standardUserDefaults] objectForKey:@"first_name"]) || (![self.nameField.text isEqualToString:@""]) ) {
        
    } else {
        self.saveButton.enabled = NO;
        return;
    }
    
    if ( ([[NSUserDefaults standardUserDefaults] objectForKey:@"customerPhone"]) || ([self.phoneNumberField.text length]>=10) ) {
    } else {
        self.saveButton.enabled = NO;
        return;
    }
    if (_cardValid) {
        
    } else {
        self.saveButton.enabled = NO;
        return;
    }
    
    self.saveButton.enabled = YES;
}

- (void)textFieldDidChange {
    [self checkToEnableSave];
}

- (IBAction)clearAllData:(id)sender
{
    [self cancelAll:sender];
}

- (IBAction)cancelName:(id)sender {
    if (!_namePopulated) return;
    _namePopulated = NO;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"first_name"]!=nil){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"first_name"];
    }
    self.nameCheck.hidden = YES;
    self.nameField.placeholder = @"Joey Pepperoni";
}

- (IBAction)cancelEmail:(id)sender {
    if (!_emailPopulated) return;
    _emailPopulated = NO;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"email"]!=nil){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"email"];
    }
    self.emailCheck.hidden = YES;
    self.emailField.placeholder = @"pepperoni@pizzatheapp.com";
}

- (IBAction)cancelPhone:(id)sender {
    if (!_phonePopulated) return;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You sure about that?"
                                                    message:@"Do you really want to delete your phone number?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    alert.tag = phoneAlertView;
    [alert show];
}

- (IBAction)cancelCard:(id)sender {
    if (!_cardPopulated) return;
    UIAlertView *alertCard = [[UIAlertView alloc] initWithTitle:@"You sure about that?"
                                                        message:@"Do you really want to delete your card information?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    alertCard.tag = cardAlertView;
    [alertCard show];
}


- (IBAction)cancelAll:(id)sender {
    UIAlertView *alertCard = [[UIAlertView alloc] initWithTitle:@"You sure about that?"
                                                        message:@"Do you really want to delete all your information?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    alertCard.tag = allAlertView;
    [alertCard show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == phoneAlertView){
        NSLog(@"Phone!");
        switch(buttonIndex) {
            case 0: //"No" pressed
                //do something?
                break;
            case 1: //"Yes" pressed
                if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerPhone"]!=nil){
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"customerPhone"];
                }
                _phonePopulated = NO;
                self.phoneCheck.hidden = YES;
                self.phoneNumberField.placeholder = @"Phone Number";
                self.phoneNumberField.enabled = YES;
                [self textFieldDidChange];
                
                break;
        }
    } else if (alertView.tag == cardAlertView){
        NSLog(@"Card!");
        switch(buttonIndex) {
            case 0: //"No" pressed
                NSLog(@"Cool, so you don't want to delete it");
                break;
            case 1: //"Yes" pressed
                if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerID"]!=nil){
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"customerID"];
                }
                _cardPopulated = NO;
                self.cardCheck.hidden = YES;
                
                [self addStripeView];
                self.storedCCLabel.hidden = YES;
                break;
        }
    } else if (alertView.tag == allAlertView) {
        NSLog(@"All!");
        switch(buttonIndex) {
            case 0: //"No" pressed
                NSLog(@"Cool, so you don't want to delete it");
                break;
            case 1: //"Yes" pressed
                if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerID"]!=nil){
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"customerID"];
                }
                _cardPopulated = NO;
                self.cardCheck.hidden = YES;
                
                [self addStripeView];
                self.storedCCLabel.hidden = YES;
                
                if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerPhone"]!=nil){
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"customerPhone"];
                }
                _phonePopulated = NO;
                self.phoneCheck.hidden = YES;
                self.phoneNumberField.placeholder = @"Phone Number";
                self.phoneNumberField.enabled = YES;
                [self textFieldDidChange];
                
                _namePopulated = NO;
                
                if([[NSUserDefaults standardUserDefaults] objectForKey:@"first_name"]!=nil){
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"first_name"];
                }
                self.nameCheck.hidden = YES;
                self.nameField.placeholder = @"Joey Pepperoni";
                self.nameField.enabled = YES;
                
                self.clearButton.enabled = NO;
                self.clearButton.hidden = YES;
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void) setupLabels {
    self.creditCardLabel.textColor = [UIColor blackColor];
    self.creditCardLabel.text = [NSString stringWithFormat:@"CREDIT CARD INFO"];
    self.creditCardLabel.font = [UIFont fontWithName:@"Verlag-Bold" size:13];
    //pizzaOrderLabel.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.creditCardLabel];
    
    self.phoneNumberLabel.textColor = [UIColor blackColor];
    self.phoneNumberLabel.text = [NSString stringWithFormat:@"PHONE NUMBER"];
    self.phoneNumberLabel.font = [UIFont fontWithName:@"Verlag-Bold" size:13];
    [self.view addSubview:self.phoneNumberLabel];
    
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.text = [NSString stringWithFormat:@"NAME"];
    self.nameLabel.font = [UIFont fontWithName:@"Verlag-Bold" size:13];
    [self.view addSubview:self.nameLabel];
    
    self.emailLabel.textColor = [UIColor blackColor];
    self.emailLabel.text = [NSString stringWithFormat:@"EMAIL (OPTIONAL)"];
    self.emailLabel.font = [UIFont fontWithName:@"Verlag-Bold" size:13];
    [self.view addSubview:self.emailLabel];
}

- (void) setupPhoneField {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerPhone"]!=NULL){
        NSLog(@"placing: '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"customerPhone"]);
        self.phoneNumberField.placeholder = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"customerPhone"]];
        self.phoneNumberField.enabled = NO;
    } else {
        self.phoneNumberField.placeholder = @"Phone Number";
    }
    
    self.phoneNumberField.font = [UIFont fontWithName:@"Verlag-Bold" size:18];
    self.phoneNumberField.textColor = [UIColor blackColor];
    self.phoneNumberField.borderStyle = UITextBorderStyleRoundedRect;
    self.phoneNumberField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.phoneNumberField.returnKeyType = UIReturnKeyDone;
    self.phoneNumberField.textAlignment = NSTextAlignmentLeft;
    self.phoneNumberField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.phoneNumberField.tag = 2;
    self.phoneNumberField.backgroundColor = DarkGreyColor;
    self.phoneNumberField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.phoneNumberField.keyboardType = UIKeyboardTypeNumberPad;
    [self.phoneNumberField addTarget:self
                              action:@selector(textFieldDidChange)
                    forControlEvents:UIControlEventEditingChanged];
}

- (void) optionalFieldDidChange:(id) optionalField {
    [self checkToEnableSave];
}

- (void) setupNameField {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"first_name"]!=NULL){
        self.nameField.placeholder = [NSString stringWithFormat:@"%@ %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"first_name"],[[NSUserDefaults standardUserDefaults] objectForKey:@"last_name"]];
        _namePopulated = YES;
        self.nameField.enabled = NO;
    } else {
        self.nameField.placeholder = @"Joey Pepperoni";
        self.nameCheck.hidden = YES;
    }
    
    self.nameField.font = [UIFont fontWithName:@"Verlag-Bold" size:18];
    self.nameField.textColor = [UIColor blackColor];
    self.nameField.borderStyle = UITextBorderStyleRoundedRect;
    self.nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameField.returnKeyType = UIReturnKeyDone;
    self.nameField.textAlignment = NSTextAlignmentLeft;
    self.nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.nameField.tag = 3;
    self.nameField.backgroundColor = DarkGreyColor;
    self.nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.nameField.keyboardType = UIKeyboardTypeAlphabet;
    [self.nameField addTarget:self
                  action:@selector(optionalFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}

- (void) setupEmailField {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"email"]!=NULL){
        NSLog(@"placing: '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]);
        self.emailField.placeholder = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
        _emailPopulated = YES;
    } else {
        self.emailField.placeholder = @"pepperoni@pizzatheapp.com";
        self.emailCheck.hidden = YES;
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect rect = CGRectMake(15,120,screenRect.size.width-10,55);
    [self.emailField setFrame:rect];
    
    self.emailField.font = [UIFont fontWithName:@"Verlag-Bold" size:18];
    self.emailField.textColor = [UIColor blackColor];
    self.emailField.borderStyle = UITextBorderStyleRoundedRect;
    self.emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.emailField.returnKeyType = UIReturnKeyDone;
    self.emailField.textAlignment = NSTextAlignmentLeft;
    self.emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.emailField.tag = 4;
    self.emailField.backgroundColor = DarkGreyColor;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    [self.emailField addTarget:self
                  action:@selector(optionalFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}

- (void) labelRightBarButton {
    // FIRST TIME LOADING
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
        _firstTime = NO;
        self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
        self.navigationItem.rightBarButtonItem = self.saveButton;
    } else {
        // Setup next button
        _firstTime = YES;
        self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
        self.navigationItem.rightBarButtonItem = self.saveButton;
    }
    [self checkToEnableSave];
}

- (void) addStripeView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.stripeView = [[STPView alloc] initWithFrame:CGRectMake(13,90,screenRect.size.width-10,55)
                                              andKey:STRIPE_KEY];
    self.stripeView.delegate = self;
    self.stripeView.tag = 99;
    [self.view addSubview:self.stripeView];
}

- (void) removeStripeView {
    UIView * v2 = [self.view viewWithTag:99];
    if (v2 != nil) {
        [v2 removeFromSuperview];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.saveButton.enabled = NO;
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"paymentViewController"];
    
    self.clearButton.titleLabel.font = [UIFont fontWithName:@"Verlag-Bold" size:17];
    
    // IF CUSTOMER ID IS SAVED, CHANGE THE DISPLAY
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerID"]!=nil){
        [self removeStripeView];
        _cardPopulated = YES;
        
        self.storedCCLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.45f];
        self.storedCCLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"displayString"];
        self.storedCCLabel.font = [UIFont fontWithName:@"Verlag-Bold" size:17];
        [self.view addSubview:self.storedCCLabel];
        self.cardCheck.hidden = NO;
        self.clearButton.enabled = YES;
        self.clearButton.hidden = NO;
        
        
    } else {
        [self addStripeView];
        _cardPopulated = NO;
        self.storedCCLabel.hidden = YES;
        self.cardCheck.hidden = YES;
        self.clearButton.enabled = NO;
        self.clearButton.hidden = YES;
    }
    
    
    // IF PHONE IS SAVED, CHANGE THE DISPLAY
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerPhone"]!=nil) {
        _phonePopulated = YES;
        self.phoneCheck.hidden = NO;
    } else {
        _phonePopulated = NO;
        self.phoneCheck.hidden = YES;
    }

    [self setupLabels];
    [self setupPhoneField];
    [self setupNameField];
    if (_firstTime)
        [self.nameField becomeFirstResponder];
    [self setupEmailField];
    [self labelRightBarButton];
}

// THIS IS CALLED WHEN THE CARD IS VALID
- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    NSLog(@"stp view callback");
    _cardValid = valid;
    [self checkToEnableSave];
}

- (IBAction)save:(id)sender{
    NSLog(@"saving");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"customerPhone"] isEqualToString:self.phoneNumberField.text]) {
        if (![self.phoneNumberField.text isEqualToString:@""]) {
            [[NSUserDefaults standardUserDefaults] setObject:self.phoneNumberField.text forKey:@"customerPhone"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    if (![self.nameField.text isEqualToString:@""]) {
        NSArray *array = [self.nameField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSString *first_name = [array objectAtIndex:0];
        NSMutableArray *nameArrayClone = [[NSMutableArray alloc] initWithArray:array];
        [nameArrayClone removeObjectAtIndex:0];
        
        NSString *last_name = [nameArrayClone componentsJoinedByString:@" "];
        if ([last_name isEqualToString:@""])
            [[NSUserDefaults standardUserDefaults] setObject:@"Pepperoni" forKey:@"last_name"];
        else
            [[NSUserDefaults standardUserDefaults] setObject:last_name forKey:@"last_name"];
            
    
        [[NSUserDefaults standardUserDefaults] setObject:first_name forKey:@"first_name"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"first_name: %@", first_name);
        NSLog(@"last_name: %@", last_name);
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel createAlias:[NSString stringWithFormat:@"%@ %@", first_name, last_name]
                forDistinctID:mixpanel.distinctId];
        [mixpanel.people set:@{
            @"first_name" : first_name,
            @"last_name" : last_name
        }];
        [mixpanel identify:mixpanel.distinctId];
    }
   /*
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"email"] isEqualToString:self.emailField.text]) {
        if (![self.emailField.text isEqualToString:@""]) {
            [[NSUserDefaults standardUserDefaults] setObject:self.emailField.text forKey:@"email"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    */
    if (self.stripeView == nil) {
        //[self writeMetadata:cardID];

    } else {
        [self.stripeView createToken:^(STPToken *token, NSError *error) {
            if (error) {
                [self hasError:error];
            } else {
                [self hasToken:token];
            }
        }];
    }
}

- (void)hasError:(NSError *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) writeMetadata:(NSString*)tokenId {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //NSString *first_name
    /* if([[NSUserDefaults standardUserDefaults] objectForKey:@"name"]!=NULL){
     NSLog(@"placing: '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"name"]);
     */
    NSString *first_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"first_name"];
    NSString *last_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_name"];
    NSString *customerPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"customerPhone"];
    
    NSLog(@"saving metadata");
    NSLog(@"first_name: %@", first_name);
    NSLog(@"last_name: %@", last_name);
    NSLog(@"customerPhone: %@", customerPhone);
    
    NSDictionary *params = @{@"cardToken": tokenId, @"email": @"joey@pepperoni.com", @"metadata": @{@"first_name": first_name, @"last_name": last_name, @"email": @"joey@pepperoni.com", @"delivery_phone": customerPhone}};
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    // SAVE CARD ID
    [[NSUserDefaults standardUserDefaults] setObject:tokenId forKey:@"cardID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [manager POST:API_CUSTOMERS parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        /*
         NSError *error;
         NSObject *o =[NSJSONSerialization JSONObjectWithData:responseObject
         options:NSJSONReadingMutableContainers
         error:&error];
         */
        NSLog(@"JSON: %@", responseObject);
        NSLog(@"Customer ID:%@", [responseObject objectForKey:@"id"]);
        
        id cardsContainer = [responseObject objectForKey:@"cards"];
        id data = [cardsContainer objectForKey:@"data"];
        NSLog(@"data: %@",data);
        id obj = [data objectAtIndex:0];
        NSLog(@"obj: %@",obj);
        
        NSString *displayString = [NSString stringWithFormat:@"•••• •••• •••• %@  %@/%@",[obj objectForKey:@"last4"],[obj objectForKey:@"exp_month"],[obj objectForKey:@"exp_year"]];
        [[NSUserDefaults standardUserDefaults] setObject:displayString forKey:@"displayString"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // SAVE CUSTOMER ID
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[responseObject objectForKey:@"id"] forKey:@"customerID"];
        [defaults synchronize];
        
        // FIRST TIME LOADING
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[self navigationController] popToRootViewControllerAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)hasToken:(STPToken *)token {
    NSLog(@"Received token %@", token.tokenId);
    [self writeMetadata:token.tokenId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end