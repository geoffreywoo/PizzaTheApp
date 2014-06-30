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

#define STRIPE_KEY @"pk_test_9wPOvSKQ8o5EsuXDWUIBjzlQ"
#define API_ORDERS @"https://pizzatheapp-staging.herokuapp.com/api/orders"
#define API_CUSTOMERS @"https://pizzatheapp-staging.herokuapp.com/api/customers/"
#define DefaultBoldFont [UIFont boldSystemFontOfSize:17]
#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define DarkGreyColor RGB(247,247,247)
#define backgroundGrey RGB(248,248,248)
#define cardAlertView 1
#define phoneAlertView 2

//#define LIVE KEY @"pk_live_5l59z07mDTFiUSSxp9UGBYxr"
//#define TEST KEY @"pk_test_9wPOvSKQ8o5EsuXDWUIBjzlQ"
//#define STRIPE_TEST_POST_URL @"https://pizzatheapp.herokuapp.com/api/orders"

@interface PaymentViewController ()
- (void)hasError:(NSError *)error;
- (void)hasToken:(STPToken *)token;
- (void)textFieldDidChange;
@end

@implementation PaymentViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setTitle:@"SETTINGS"];

    //Mixpanel *mixpanel = [Mixpanel sharedInstance];
    //[mixpanel track:@"Visit settings page"];
    self.view.backgroundColor = backgroundGrey;
    
    // IF CUSTOMER ID IS SAVED, CHANGE THE DISPLAY
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerID"]!=nil){
        UIButton *cardCheck = [UIButton buttonWithType:UIButtonTypeCustom ];
        cardCheck.frame = CGRectMake(275, 125, 35, 35);
        cardCheck.tag = 200;
        [cardCheck addTarget:self action:@selector(cancelCard:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cardCheck];
        UIImageView *cardCheckImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"plateFull.png"]]];
        cardCheckImage.frame = CGRectMake(0, 0, 35, 35);
        [cardCheck addSubview:cardCheckImage];
        
    } else {
        UIImageView *noCardCheck = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"emptyPlate.png"]]];
        noCardCheck.frame = CGRectMake(275, 125, 35, 35);
        noCardCheck.tag = 100;
        [self.view addSubview:noCardCheck];
    }
    
    
    
    
    // IF PHONE IS SAVED, CHANGE THE DISPLAY
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerPhone"]!=nil){
        UIButton *phoneCheck = [UIButton buttonWithType:UIButtonTypeCustom];
        phoneCheck.frame = CGRectMake(275, 215, 35, 35);
        phoneCheck.tag = 150;
        [phoneCheck addTarget:self action:@selector(cancelPhone:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:phoneCheck];
        UIImageView *phoneCheckImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"plateFull.png"]]];
        phoneCheckImage.frame = CGRectMake(0, 0, 35, 35);
        [phoneCheck addSubview:phoneCheckImage];
    } else {
        UIImageView *noPhoneCheck = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"emptyPlate.png"]]];
        noPhoneCheck.frame = CGRectMake(275, 215, 35, 35);
        noPhoneCheck.tag = 50;
        [self.view addSubview:noPhoneCheck];
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.stripeView = [[STPView alloc] initWithFrame:CGRectMake(-2,120,screenRect.size.width+2,55)
                                              andKey:STRIPE_KEY];
    self.stripeView.delegate = self;
    
    [self.view addSubview:self.stripeView];
    
    
    // FIRST TIME LOADING
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
        saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
        saveButton.enabled = YES;
        self.navigationItem.rightBarButtonItem = saveButton;
        
        UIView * phone = [self.view viewWithTag:150];
        UIView * card = [self.view viewWithTag:200];
        if (phone != nil && card != nil) {
            saveButton.enabled = YES;
        }
    } else {
        // Setup next button
        saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
        saveButton.enabled = YES;
        
        UIView * phone = [self.view viewWithTag:150];
        UIView * card = [self.view viewWithTag:200];
        if (phone != nil && card != nil) {
            saveButton.enabled = YES;
        }
        self.navigationItem.rightBarButtonItem = saveButton;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    
    
    UILabel *creditCardLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, screenRect.size.width, 50)];
    creditCardLabel.textColor = [UIColor blackColor];
    creditCardLabel.text = [NSString stringWithFormat:@"CREDIT CARD INFO"];
    creditCardLabel.font = [UIFont fontWithName:@"Verlag-Bold" size:15];
    //pizzaOrderLabel.backgroundColor = [UIColor redColor];
    [self.view addSubview:creditCardLabel];
    
    
    UILabel *phoneNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 170, screenRect.size.width, 50)];
    phoneNumberLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.45f];
    phoneNumberLabel.text = [NSString stringWithFormat:@"PHONE NUMBER"];
    phoneNumberLabel.font = [UIFont fontWithName:@"Verlag-Bold" size:11];
    //pizzaOrderLabel.backgroundColor = [UIColor redColor];
    [self.view addSubview:phoneNumberLabel];
    
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 270, screenRect.size.width-30, 50)];
    noteLabel.textColor = [UIColor blackColor];
    noteLabel.text = [NSString stringWithFormat:@"Note: If you wish to clear your phone number or credit card information, select the icons to the right of the form field"];
    noteLabel.font = [UIFont fontWithName:@"Verlag-Bold" size:15];
    noteLabel.numberOfLines = 0;
    noteLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:noteLabel];
    
    
    CGRect phoneNumberFrame = CGRectMake(-2, 210, screenRect.size.width+4, 46);
    phoneNumberField = [[UITextField alloc] initWithFrame:phoneNumberFrame];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerPhone"]!=NULL){
        phoneNumberField.enabled = NO;
        phoneNumberField.placeholder = [NSString stringWithFormat:@"    %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"customerPhone"]];
    } else {
        phoneNumberField.placeholder = @"    Phone Number";
    }
    
    phoneNumberField.backgroundColor = [UIColor whiteColor];
    phoneNumberField.textColor = [UIColor blackColor];
    phoneNumberField.font = DefaultBoldFont;
    phoneNumberField.borderStyle = UITextBorderStyleRoundedRect;
    phoneNumberField.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneNumberField.returnKeyType = UIReturnKeyDone;
    phoneNumberField.textAlignment = NSTextAlignmentLeft;
    phoneNumberField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    phoneNumberField.tag = 2;
    phoneNumberField.backgroundColor = DarkGreyColor;
    phoneNumberField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    phoneNumberField.clearButtonMode = UITextFieldViewModeAlways;
    phoneNumberField.clearButtonMode = UITextFieldViewModeAlways;
    phoneNumberField.keyboardType = UIKeyboardTypeNumberPad;
    [phoneNumberField addTarget:self
                  action:@selector(textFieldDidChange)
        forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:phoneNumberField];

    /*
    UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(140, 310, 0, 0)];
    [mySwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:mySwitch];*/
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerPhone"]==NULL || [[NSUserDefaults standardUserDefaults] objectForKey:@"customerID"]==NULL){
        saveButton.enabled = YES;
    } else {
        saveButton.enabled = YES;
    }
    
}

- (void)textFieldDidChange {
    if([phoneNumberField.text length]>=10){
        UIView * v = [self.view viewWithTag:50];
        if (v != nil) {
            [v removeFromSuperview];
        }
        
        UIButton *phoneCheck = [UIButton buttonWithType:UIButtonTypeCustom ];
        phoneCheck.frame = CGRectMake(275, 215, 35, 35);
        phoneCheck.tag = 150;
        [phoneCheck addTarget:self action:@selector(cancelPhone:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:phoneCheck];
        UIImageView *phoneCheckImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"plateFull.png"]]];
        phoneCheckImage.frame = CGRectMake(0, 0, 35, 35);
        [phoneCheck addSubview:phoneCheckImage];
        
        
        [[NSUserDefaults standardUserDefaults] setObject:phoneNumberField.text forKey:@"customerPhone"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        UIView * v = [self.view viewWithTag:150];
        if (v != nil) {
            [v removeFromSuperview];
        }
            
        UIImageView *noPhoneCheck = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"emptyPlate.png"]]];
        noPhoneCheck.frame = CGRectMake(275, 215, 35, 35);
        noPhoneCheck.tag = 50;
        [self.view addSubview:noPhoneCheck];
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerPhone"]==NULL || [[NSUserDefaults standardUserDefaults] objectForKey:@"customerID"]==NULL){
        saveButton.enabled = YES;
    } else {
        saveButton.enabled = YES;
    }
}

- (IBAction)cancelPhone:(id)sender {
    NSLog(@"Hello!!");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You sure about that mate?"
                                                    message:@"Do you really want to delete your phone number?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    alert.tag = phoneAlertView;
    [alert show];
}

- (IBAction)cancelCard:(id)sender {
    UIAlertView *alertCard = [[UIAlertView alloc] initWithTitle:@"You sure about that mate?"
                                                        message:@"Do you really want to delete your card information?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    alertCard.tag = cardAlertView;
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
                phoneNumberField.placeholder = @"    Phone Number";
                phoneNumberField.enabled = YES;
                
                UIView * v = [self.view viewWithTag:150];
                if (v != nil) {
                    [v removeFromSuperview];
                }
                
                UIImageView *noPhoneCheck = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"emptyPlate.png"]]];
                noPhoneCheck.frame = CGRectMake(275, 215, 35, 35);
                noPhoneCheck.tag = 50;
                [self.view addSubview:noPhoneCheck];
                
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
                
                PKView * obje = [[PKView  alloc]init];
                //[obje setupCardNumberField];
                
                UIView * v = [self.view viewWithTag:200];
                if (v != nil) {
                    [v removeFromSuperview];
                }
                
                UIImageView *noPhoneCheck = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"emptyPlate.png"]]];
                noPhoneCheck.frame = CGRectMake(275, 125, 35, 35);
                noPhoneCheck.tag = 100;
                [self.view addSubview:noPhoneCheck];
                
                break;
        }
    }
}

/*


- (BOOL)textField:(UITextField *)phoneNumberField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
   
    int length = [self getLength:phoneNumberField.text];
    //NSLog(@"Length  =  %d ",length);
    
    if(length == 10)
    {
        if(range.length == 0)
            return NO;
    }
    
    if(length == 3)
    {
        NSString *num = [self formatNumber:phoneNumberField.text];
        phoneNumberField.text = [NSString stringWithFormat:@"(%@) ",num];
        if(range.length > 0)
            phoneNumberField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
    }
    else if(length == 6)
    {
        NSString *num = [self formatNumber:phoneNumberField.text];
        //NSLog(@"%@",[num  substringToIndex:3]);
        //NSLog(@"%@",[num substringFromIndex:3]);
        phoneNumberField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
        if(range.length > 0)
            phoneNumberField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
    }
    
    return YES;
}

-(NSString*)formatNumber:(NSString*)mobileNumber {
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSLog(@"%@", mobileNumber);
    
    int length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        NSLog(@"%@", mobileNumber);
        
    }
    
    
    return mobileNumber;
}


-(int)getLength:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = [mobileNumber length];
    
    return length;
    
    
} */


- (IBAction)clear:(id)sender {
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)viewWillAppear:(BOOL)animated{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerID"]!=nil){
        UIImageView *cardCheck = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"plateFull.jpg"]]];
        cardCheck.frame = CGRectMake(275, 125, 35, 35);
        cardCheck.tag = 200;
        [self.view addSubview:cardCheck];
        UIView * v = [self.view viewWithTag:100];
        if (v != nil) {
            [v removeFromSuperview];
        }
    } else {
        UIImageView *noCardCheck = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"emptyPlate.png"]]];
        noCardCheck.frame = CGRectMake(275, 125, 35, 35);
        noCardCheck.tag = 100;
        [self.view addSubview:noCardCheck];
        UIView * v = [self.view viewWithTag:200];
        if (v != nil) {
            [v removeFromSuperview];
        }
    }
    
    //?????
    PKView * obje = [[PKView  alloc]init];
   // [obje setupCardNumberField];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerPhone"]!=nil){
        UIImageView *phoneCheck = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"plateFull.png"]]];
        phoneCheck.frame = CGRectMake(275, 215, 35, 35);
        phoneCheck.tag = 150;
        [self.view addSubview:phoneCheck];
    } else {
        UIImageView *noPhoneCheck = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"emptyPlate.png"]]];
        noPhoneCheck.frame = CGRectMake(275, 215, 35, 35);
        noPhoneCheck.tag = 50;
        [self.view addSubview:noPhoneCheck];
    }
}


// Adds email field if user wants to e-mail receipt
- (void)changeSwitch:(id)sender{
    //NSUserDefaults *emailFetcher = [NSUserDefaults standardUserDefaults];

    if([sender isOn]){
        CGRect phoneNumberFrame = CGRectMake(20.0f, 370.0f, 280.0f, 31.0f);
        UITextField *emailField = [[UITextField alloc] initWithFrame:phoneNumberFrame];
        /*if([emailFetcher objectForKey:@"customerEmail"]==nil){
            emailField.placeholder = @"E-mail Address";
        } else {
            emailField.placeholder = [NSString stringWithFormat:@"%@", [emailFetcher objectForKey:@"customerEmail"]];
        } */
        emailField.placeholder = @"E-mail Address";

        emailField.backgroundColor = [UIColor whiteColor];
        emailField.textColor = [UIColor blackColor];
        emailField.font = [UIFont systemFontOfSize:14.0f];
        emailField.borderStyle = UITextBorderStyleRoundedRect;
        emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
        emailField.returnKeyType = UIReturnKeyDone;
        emailField.textAlignment = NSTextAlignmentLeft;
        emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        emailField.tag = 3;
        emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self.view addSubview:emailField];
        NSLog(@"%@",[emailField text]);

    } else{
        UIView * v = [self.view viewWithTag:3];
        if (v != nil) {
            [v removeFromSuperview];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)emailField
{
    //hide the keyboard
    [emailField resignFirstResponder];
    
    // SAVE CUSTOMER EMAIL
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:emailField forKey:@"customerEmail"];
    [defaults synchronize];
    NSLog(@"%@", [defaults objectForKey:@"customerEmail"]);
    return YES;
}



// THIS IS CALLED WHEN THE CARD IS VALID
- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    // Toggle navigation, for example
    //self.saveButton.enabled = valid;
    self.navigationItem.rightBarButtonItem.enabled = valid;
    saveButton.enabled = YES;
    
        UIView * v = [self.view viewWithTag:100];
        if (v != nil) {
            [v removeFromSuperview];
            UIImageView *cardCheck = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"plateFull.jpg"]]];
            cardCheck.frame = CGRectMake(275, 125, 35, 35);
            cardCheck.tag = 200;
            [self.view addSubview:cardCheck];
        }
}

- (IBAction)save:(id)sender{
    /*if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerPhone"]==NULL || [[NSUserDefaults standardUserDefaults] objectForKey:@"customerID"]==NULL){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [self.stripeView createToken:^(STPToken *token, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (error) {
                [self hasError:error];
            } else {
                [self hasToken:token];
            }
        }];
    } else {
        
        [[self navigationController] popToRootViewControllerAnimated:YES];
    } */
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self.stripeView createToken:^(STPToken *token, NSError *error) {
        if (error) {
            [self hasError:error];
        } else {
            [self hasToken:token];
        }
    }];
}

- (void)hasError:(NSError *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}


- (void)hasToken:(STPToken *)token {
    NSLog(@"Received token %@", token.tokenId);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"cardToken": token.tokenId, @"email": @"joey@pepperoni.com", @"metadata": @{@"first_name": @"Joey", @"last_name": @"Pepperoni", @"email": @"joey@pepperoni.com", @"delivery_phone": phoneNumberField.text}};

    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];

    
    
    
    // SAVE CARD ID
    [[NSUserDefaults standardUserDefaults] setObject:token.tokenId forKey:@"cardID"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [manager POST:@"https://pizzatheapp-staging.herokuapp.com/api/customers/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSLog(@"Customer ID:%@", [responseObject objectForKey:@"id"]);

        // SAVE CUSTOMER ID
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[responseObject objectForKey:@"id"] forKey:@"customerID"];
        [defaults synchronize];
        
        // FIRST TIME LOADING
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){

        } else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[self navigationController] popToRootViewControllerAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];


}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
