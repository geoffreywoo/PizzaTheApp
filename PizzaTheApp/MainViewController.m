//
//  MainViewController.m
//  pizzaTheApp2
//
//  Created by Joe Vasquez on 5/15/14.
//  Copyright (c) 2014 Joe Vasquez. All rights reserved.
//

#import "MainViewController.h"
#import "PizzaViewController.h"
#import "PaymentViewController.h"
#import "SPGooglePlacesAutocompleteDemoViewController.h"
#import "MBProgressHUD.h"
#import "UIViewController+MJPopupViewController.h"
#import "MJDetailViewController.h"
#import "Mixpanel.h"
#import "AFNetworking.h"
#import "AnimatedGif.h"
#import "UIImageView+AnimatedGif.h"
#import <MessageUI/MessageUI.h>

//#import <Crashlytics/Crashlytics.h>

/*
#define STRIPE_KEY @"pk_test_9wPOvSKQ8o5EsuXDWUIBjzlQ"
#define API_CONFIG @"https://pizzatheapp-staging.herokuapp.com/api/config"
#define API_ORDERS @"https://pizzatheapp-staging.herokuapp.com/api/orders"
#define API_CUSTOMERS @"https://pizzatheapp-staging.herokuapp.com/api/customers/"
#define API_CHECK_PRICES_ZIP @"https://pizzatheapp-staging.herokuapp.com/api/zipCodePrice/"
#define BASE_URL_RESTAURANTS @"https://pizzatheapp-staging.herokuapp.com/api/closest-restaurants?"
*/

#define STRIPE_KEY @"pk_live_5l59z07mDTFiUSSxp9UGBYxr"
#define API_CONFIG @"https://pizzatheapp.herokuapp.com/api/config"
#define API_ORDERS @"https://pizzatheapp.herokuapp.com/api/orders"
#define API_CUSTOMERS @"https://pizzatheapp.herokuapp.com/api/customers/"
#define API_CHECK_PRICES_ZIP @"https://pizzatheapp.herokuapp.com/api/zipCodePrice/"
#define BASE_URL_RESTAURANTS @"https://pizzatheapp.herokuapp.com/api/closest-restaurants?"

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define pizzaRedColor RGB(195,36,43)
#define backgroundGrey RGB(248,248,248)
#define strokeGrey RGB(224,224,224)



//#define LIVE KEY @"pk_live_5l59z07mDTFiUSSxp9UGBYxr"
//#define TEST KEY @"pk_test_9wPOvSKQ8o5EsuXDWUIBjzlQ"
//#define STRIPE_TEST_POST_URL @"https://pizzatheapp.herokuapp.com/api/orders"



@interface MainViewController ()

@end

@implementation MainViewController

- (void) displayPrice {
    self.price = [[NSUserDefaults standardUserDefaults] integerForKey:@"basePrice"]+[[NSUserDefaults standardUserDefaults] integerForKey:@"tipPrice"]+[[NSUserDefaults standardUserDefaults] integerForKey:@"taxAndDeliveryPrice"];
    for(int i = 0; i < [chosenToppings count]; i++){
        if([[chosenToppings objectAtIndex:i] isEqualToString:@"none"]){
            // Do nothing
        } else {
            self.price = self.price + [[NSUserDefaults standardUserDefaults] integerForKey:@"toppingPrice"];
        }
    }
    NSLog(@"%d", self.price);
    double finalPrice = self.price / 100.0;
    self.priceLabel.text = [NSString stringWithFormat:@"$%.2f",finalPrice];
}

- (void)popEmailModal:(UIButton*)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[@"new_city@pizzatheapp.com"]];
        [composeViewController setSubject:@"I want pizza in my area!"];
        [composeViewController setMessageBody:[NSString stringWithFormat:@"My zipcode is %@.",[[NSUserDefaults standardUserDefaults] objectForKey:@"zipCode"]] isHTML:NO];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    if (error) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error"
                              
                                                        message:[NSString stringWithFormat:@"error %@", [error description]]
                              
                                                       delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
        
        [alert show];
        [self dismissViewControllerAnimated:NO completion:nil];
        
    }
    
    else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
}

- (void) setNotSupportedConfirmButton {
    [self.confirmButton setTitle:@"I WANT PIZZA(THEAPP)" forState:UIControlStateNormal];
    [self.confirmButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.confirmButton addTarget:self action:@selector(popEmailModal:) forControlEvents:UIControlEventTouchUpInside];
    self.priceLabel.hidden = YES;
}

- (void) setSupportedConfirmButton {
    [self.confirmButton setTitle:@"PLACE ORDER" forState:UIControlStateNormal];
    [self.confirmButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.confirmButton addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
    self.priceLabel.hidden = NO;
}

- (void) checkPrices {
    self.confirmButton.enabled = NO;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@",API_CHECK_PRICES_ZIP,[[NSUserDefaults standardUserDefaults] objectForKey:@"zipCode"]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSLog(@"STATUS CODE: %@",[responseObject objectForKey:@"status code"]);
        
        int toppingPrice = [[responseObject objectForKey:@"TOPPING_PRICE_CENTS"] intValue];
        int tipPrice = [[responseObject objectForKey:@"TIP_CENTS"] intValue];
        int taxAndDeliveryPrice = [[responseObject objectForKey:@"TAX_AND_DELIVERY_CENTS"] intValue];
        int basePrice = [[responseObject objectForKey:@"BASE_PRICE_CENTS"] intValue];
        NSLog(@"Topping Price %d", toppingPrice);
        NSLog(@"tip Price %d", tipPrice);
        NSLog(@"Base Price %d", basePrice);
        
        NSUserDefaults *pricingStore = [NSUserDefaults standardUserDefaults];
        [pricingStore setInteger:toppingPrice forKey:@"toppingPrice"];
        [pricingStore setInteger:tipPrice forKey:@"tipPrice"];
        [pricingStore setInteger:taxAndDeliveryPrice forKey:@"taxAndDeliveryPrice"];
        [pricingStore setInteger:basePrice forKey:@"basePrice"];
        [pricingStore synchronize];
        
        [self displayPrice];
        self.confirmButton.enabled = YES;
        [self setSupportedConfirmButton];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
        if ([operation.response statusCode] == 404) {
            [self setNotSupportedConfirmButton];
            self.confirmButton.enabled = YES;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:[NSString stringWithFormat:@"We're not delivering in your area just yet 🙆"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

- (void) fetchCustomerData {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerID"]!=nil){
        //https://pizzatheapp-staging.herokuapp.com/api/customers/cus_4Bbh2EUpfzGogn/card
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:[NSString stringWithFormat:@"%@%@/card",API_CUSTOMERS,[[NSUserDefaults standardUserDefaults] objectForKey:@"customerID"]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            NSLog(@"JSON: %@", responseObject);
            NSLog(@"Exp Year: %@",[responseObject objectForKey:@"exp_year"]);
            NSLog(@"Exp Month: %@",[responseObject objectForKey:@"exp_month"]);
            NSLog(@"Last Four: %@",[responseObject objectForKey:@"last4"]);
            
            NSString *displayString = [NSString stringWithFormat:@"•••• •••• •••• %@  %@/%@",[responseObject objectForKey:@"last4"],[responseObject objectForKey:@"exp_month"],[responseObject objectForKey:@"exp_year"]];
            [[NSUserDefaults standardUserDefaults] setObject:displayString forKey:@"displayString"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error customer card: %@", error.description);
        }];
    }
}

- (void) settingsButton {
    NSLog(@"settingsButton");
    UIImage *faceImage = [UIImage imageNamed:@"menu-icon.png"];
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    face.bounds = CGRectMake( 0, 0, 30, 30);//set bound as per you want
    [face addTarget:self action:@selector(goToPaymentPage:) forControlEvents:UIControlEventTouchUpInside];
    [face setImage:faceImage forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:face];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void) deliveryLabel {
    NSLog(@"delivery label");
    UILabel *deliveryLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 53, screenRect.size.width, 95)];
    deliveryLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.45f];
    deliveryLabel.text = [NSString stringWithFormat:@"DELIVER TO"];
    deliveryLabel.font = [UIFont fontWithName:@"Verlag-Bold" size:11];
    //deliveryLabel.backgroundColor = [UIColor redColor];
    [self.view addSubview:deliveryLabel];
    
    NSString *userAddress = @"";
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] == nil || [[NSUserDefaults standardUserDefaults] objectForKey:@"zipCode"] == nil || [[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] componentsSeparatedByString:@","] count]<2){
        userAddress = @"No address set";
    } else {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString2"] == nil || [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString2"] isEqualToString:@""]) {
            userAddress = [NSString stringWithFormat:@"%@\n%@, %@ %@", [[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] componentsSeparatedByString:@", "] objectAtIndex:0], [[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] componentsSeparatedByString:@", "] objectAtIndex:1], [[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] componentsSeparatedByString:@", "] objectAtIndex:2], [[NSUserDefaults standardUserDefaults] objectForKey:@"zipCode"]];
        } else {
            userAddress = [NSString stringWithFormat:@"%@ #%@\n%@, %@ %@", [[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] componentsSeparatedByString:@", "] objectAtIndex:0], [[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString2"], [[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] componentsSeparatedByString:@", "] objectAtIndex:1], [[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] componentsSeparatedByString:@", "] objectAtIndex:2],[[NSUserDefaults standardUserDefaults] objectForKey:@"zipCode"]];
        }
        
        NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"]);
        NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString2"]);
    }
    
    
    UIButton *deliveryPage = [UIButton buttonWithType:UIButtonTypeCustom ];
    deliveryPage.frame = CGRectMake(-1, 115, screenRect.size.width+2, 73.5  );
    [deliveryPage setTitle:[NSString stringWithFormat:@"%@",userAddress] forState:UIControlStateNormal];
    deliveryPage.titleLabel.font = [UIFont fontWithName:@"Verlag-Book" size:18];
    deliveryPage.backgroundColor = [UIColor whiteColor];
    deliveryPage.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [deliveryPage setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [[deliveryPage layer] setMasksToBounds:YES];
    deliveryPage.titleLabel.numberOfLines = 0;
    deliveryPage.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [deliveryPage setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 15.0f)];
    [[deliveryPage layer] setBorderWidth:0.0f];
    [[deliveryPage layer] setBorderWidth:0.5f];
    [[deliveryPage layer] setBorderColor:strokeGrey.CGColor];
    [deliveryPage addTarget:self action:@selector(GoToMapSearchPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deliveryPage];
}

- (void) yourPizzaLabel {
    NSLog(@"yourPizzaLabel");
    screenRect = [[UIScreen mainScreen] bounds];
    
    UILabel *pizzaOrderLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 210, screenRect.size.width, 50)];
    pizzaOrderLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.45f];
    pizzaOrderLabel.text = [NSString stringWithFormat:@"YOUR PIZZA"];
    pizzaOrderLabel.font = [UIFont fontWithName:@"Verlag-Bold" size:11];
    [self.view addSubview:pizzaOrderLabel];
    
    goToPizzaPage = [UIButton buttonWithType:UIButtonTypeCustom ];
    goToPizzaPage.frame = CGRectMake(-1, 250, screenRect.size.width+2, 85);
    [goToPizzaPage setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    goToPizzaPage.backgroundColor = [UIColor whiteColor];
    [[goToPizzaPage layer] setMasksToBounds:YES];
    [[goToPizzaPage layer] setBorderWidth:0.5f];
    [[goToPizzaPage layer] setBorderColor:strokeGrey.CGColor];
    [goToPizzaPage addTarget:self action:@selector(goToPizzaPage:) forControlEvents:UIControlEventTouchUpInside];
    [goToPizzaPage setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    goToPizzaPage.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [goToPizzaPage.titleLabel setFont:[UIFont fontWithName:@"Verlag-Book" size:15]];
    [goToPizzaPage setTitleEdgeInsets:UIEdgeInsetsMake(-5.0f, 15.0f, 0.0f, screenRect.size.width/3)];
    
    NSMutableString *pizzaDescription = [NSMutableString stringWithFormat:@"Large"];
    [chosenToppings removeAllObjects];
    NSUserDefaults *pizzaFetcher = [NSUserDefaults standardUserDefaults];
    chosenToppings = [[pizzaFetcher objectForKey:@"chosenToppings"] mutableCopy];
    
    int numToppings = 0;
    for(int i = 0; i < [chosenToppings count]; i++){
        if([[chosenToppings objectAtIndex:i] isEqualToString:@"none"]){
            // Do nothing
        } else {
            numToppings++;
        }
    }
    if (numToppings != 0) {
        int printedToppings = 0;
        for(int i = 0; i < [chosenToppings count]; i++){
            if([[chosenToppings objectAtIndex:i] isEqualToString:@"none"]){
                // Do nothing
            } else {
                printedToppings++;
                if (printedToppings < numToppings) {
                    [pizzaDescription appendString:[NSString stringWithFormat:@" %@,", [chosenToppings objectAtIndex:i]]];
                } else {
                    [pizzaDescription appendString:[NSString stringWithFormat:@" %@", [chosenToppings objectAtIndex:i]]];
                }
            }
        }
    } else {
        [pizzaDescription appendString:[NSString stringWithFormat:@" plain and cheesy"]];
    }
    [pizzaDescription appendString:[NSString stringWithFormat:@" pizza"]];
    [goToPizzaPage setTitle:[NSString stringWithFormat:@"%@", pizzaDescription] forState:UIControlStateNormal];
    [self.view addSubview:goToPizzaPage];
    
    
    // Add pizza background image to button
    pizzaImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"pizza.png"]]];
    pizzaImage.frame = CGRectMake(screenRect.size.width-100, -50, 260, 260);
    [goToPizzaPage addSubview:pizzaImage];
    
    /*
     UIImageView *chevronRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"chevron - forward@2x.png"]]];
     chevronRight.frame = CGRectMake(screenRect.size.width-50, (goToPizzaPage.frame.size.height/2)-20, 30, 40);
     [goToPizzaPage addSubview:chevronRight];
     */
    
    NSArray *viewsToRemove = [pizzaImage subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    if(chosenToppings != nil || [chosenToppings count]==0){
        for(int i = 0; i < [chosenToppings count]; i++){
            if(![[chosenToppings objectAtIndex:i] isEqualToString:@"none"]){
                UIImageView *toppingForButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@new.png",[chosenToppings objectAtIndex:i]]]];
                toppingForButton.frame = CGRectMake(0, 0, 260, 260);
                [pizzaImage addSubview:toppingForButton];
            }
        }
    }
}

- (void) placeConfirmButton {
    [self.confirmButton setTitle:[NSString stringWithFormat:@"PLACE ORDER"] forState:UIControlStateNormal];
    self.confirmButton.titleLabel.font = [UIFont fontWithName:@"Verlag-Black" size:16];
    self.confirmButton.layer.cornerRadius = 0;
    self.confirmButton.backgroundColor = pizzaRedColor;
    [[self.confirmButton layer] setMasksToBounds:YES];
    [[self.confirmButton layer] setBorderWidth:0.0f];
    [self.confirmButton addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
    
    self.priceLabel.font = [UIFont fontWithName:@"Verlag-Black" size:20];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIImage *titleImage = [UIImage imageNamed:@"pizza-logo.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    
    [self.view setBackgroundColor:backgroundGrey];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
        [self.navigationItem setHidesBackButton:YES];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"mainViewController"];
        
        [self settingsButton];
        
        [self yourPizzaLabel];
        
        [self deliveryLabel];
        
        [self placeConfirmButton];
        [self checkPrices];
        [self displayPrice];
        [self setupWaitingGif];
    } else {
        [self.navigationItem setHidesBackButton:YES];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        PizzaViewController *sec= [storyboard instantiateViewControllerWithIdentifier:@"PizzaViewController"];
        [self.navigationController pushViewController:sec animated:YES];
    }
}

- (void) setupWaitingGif {
    self.waitingText.font = [UIFont fontWithName:@"Verlag-Bold" size:18];
    
    screenRect = [[UIScreen mainScreen] bounds];
    
    self.waitingScreen = [[UIImageView alloc] initWithFrame:screenRect];
    [self.waitingScreen setImage:[UIImage imageNamed:@"blackOverlay.png"]];
    [self.waitingScreen setUserInteractionEnabled:YES];
}

- (void) showWaitingGif {
    self.waitingGIF = [[UIImageView alloc] initWithFrame:CGRectMake((screenRect.size.width-200)/2,(screenRect.size.height-200)/2,200,200)];
    [self.waitingGIF setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.waitingText setFrame:CGRectMake((screenRect.size.width-200)/2,(screenRect.size.height-200)/2-30,200,30)];
    
    NSInteger randomNumber = arc4random() % 5;
    switch (randomNumber)
    {
        case 0: {
            NSData * animationData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dancingpizzas.gif" ofType:nil]];
            AnimatedGif * animation = [AnimatedGif getAnimationForGifWithData:animationData];
            [self.waitingGIF setAnimatedGif:animation startImmediately:YES];
            break;
        }
        case 1: {
            NSData * animationData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"spongebob.gif" ofType:nil]];
            AnimatedGif * animation = [AnimatedGif getAnimationForGifWithData:animationData];
            [self.waitingGIF setAnimatedGif:animation startImmediately:YES];
            break;
        }
        case 2: {
            NSData * animationData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pizzacat.gif" ofType:nil]];
            AnimatedGif * animation = [AnimatedGif getAnimationForGifWithData:animationData];
            [self.waitingGIF setAnimatedGif:animation startImmediately:YES];
            break;
        }
        case 3: {
            NSData * animationData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ninjaturtle.gif" ofType:nil]];
            AnimatedGif * animation = [AnimatedGif getAnimationForGifWithData:animationData];
            [self.waitingGIF setAnimatedGif:animation startImmediately:YES];
            break;
        }
        case 4: {
            NSData * animationData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cowboy.gif" ofType:nil]];
            AnimatedGif * animation = [AnimatedGif getAnimationForGifWithData:animationData];
            [self.waitingGIF setAnimatedGif:animation startImmediately:YES];
            break;
        }
            
    }
    
    [self.navigationController.view addSubview:self.waitingScreen];
    
    
    [self.navigationController.view addSubview:self.waitingGIF];
    self.waitingGIF.hidden = NO;
    [self.navigationController.view addSubview:self.waitingText];
    self.waitingText.hidden = NO;
}

- (void) hideWaitingGif {
    self.waitingGIF.hidden = YES;
    self.waitingText.hidden = YES;
    
    [self.waitingScreen removeFromSuperview];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self fetchCustomerData];
}

- (void)didReceiveMemoryWarning

{
    
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
}

- (void)placeOrder:(UIBarButtonItem *)sender
{
    NSUserDefaults *orderInfo = [NSUserDefaults standardUserDefaults];
    NSString *customerID = [orderInfo objectForKey:@"customerID"];
    if ( (customerID == nil) || ([customerID isEqualToString:@""]) ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payments"
                                                        message:@"Let's get your payment information."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        alert.tag = 2;
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Order"
                                                        message:@"Are you ready for some pizza?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        alert.tag = 1;
        [alert show];
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        switch(buttonIndex) {
            case 0: //"No" pressed
                //do something?
                break;
            case 1: //"Yes" pressed
                [self checkZip];
                break;
        }
    } else if (alertView.tag == 2) {
        [self goToPaymentPage:nil];
    }
}


- (NSString *)URLEncodeStringFromString:(NSString *)string
{
    static CFStringRef charset = CFSTR("!@#$%&*()+'\";:=,/?[] ");
    CFStringRef str = (__bridge CFStringRef)string;
    CFStringEncoding encoding = kCFStringEncodingUTF8;
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, str, NULL, charset, encoding));
}

- (void) checkZip {
    NSUserDefaults *orderInfo = [NSUserDefaults standardUserDefaults];
    NSString *zip = [orderInfo objectForKey:@"zipCode"];
    if (!zip) {
        NSLog(@"no zip");
        [self GoToMapSearchPage:nil];
        return;
    }
    
    [self getRestaurantIDs];
}

- (void)getRestaurantIDs {
    NSLog(@"getting restaurant ids");
    NSString *BaseURL = BASE_URL_RESTAURANTS;

    NSUserDefaults *orderInfo = [NSUserDefaults standardUserDefaults];
    NSLog(@"Customer ID: %@", [orderInfo objectForKey:@"customerID"]);
    
    NSString *zip = [orderInfo objectForKey:@"zipCode"];
    NSString *address1 = [[[orderInfo objectForKey:@"UserAddressString"] componentsSeparatedByString:@","] objectAtIndex:0];
    NSString *address2 = ([orderInfo objectForKey:@"UserAddressString2"] != nil) ? [orderInfo objectForKey:@"UserAddressString2"] : @"";

    if (!address1) {
        NSLog(@"no address 1");
        [self GoToMapSearchPage:nil];
        return;
    }
    
    [self showWaitingGif];

    //https://pizzatheapp-staging.herokuapp.com/api/closest-restaurants?address1=201%20Post%20St&address2=&zip=94108&toppings=
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
    || GETS RESTAURANT IDs                                                               //
    ||+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
    ||
    || This function will make a call for a list of 6 or less restaurants and their
    || related information (Yelp rating, id, location, etc.)
    ||
    || SAMPLE API CALLBACK: https://pizzatheapp-staging.herokuapp.com/api/closest-restaurants?address1=199%20new%20montgomery%20st&address2=803&zip=94105&toppings=mushrooms
    ||
    ||
    ||
    ||+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

    
    NSMutableArray *toppingsArrayForOrder = [[orderInfo objectForKey:@"chosenToppings"] mutableCopy];
    NSMutableString *toppingsStringForOrder = [NSMutableString stringWithString:@""];
    NSString *lastTopping;
    NSLog(@"Chosen Toppings Array: %@", toppingsArrayForOrder);
    NSMutableArray *formattedToppingsForSubmission = [[NSMutableArray alloc] init];

    
    int numToppings = 0;
    if(toppingsArrayForOrder != nil && [toppingsArrayForOrder count]!=0){
        for(int i = 0; i<[toppingsArrayForOrder count]; i++){
            if(![[toppingsArrayForOrder objectAtIndex:i] isEqualToString:@"none"]){
                numToppings++;
                lastTopping = [toppingsArrayForOrder objectAtIndex:i];
            }
        }
    }
    NSLog(@"Last Topping: %@", lastTopping);
    
    for(int i = 0; i<[toppingsArrayForOrder count]; i++){
        if(![[toppingsArrayForOrder objectAtIndex:i] isEqualToString:@"none"] && ![[toppingsArrayForOrder objectAtIndex:i] isEqualToString:lastTopping]){
            [toppingsStringForOrder appendString:[NSString stringWithFormat:@"%@,",[toppingsArrayForOrder objectAtIndex:i]]];
            [formattedToppingsForSubmission addObject:[toppingsArrayForOrder objectAtIndex:i]];
        }
    }
    if(lastTopping!=nil || lastTopping!=NULL){
        [toppingsStringForOrder appendString:[NSString stringWithFormat:@"%@",lastTopping]];
        [formattedToppingsForSubmission addObject:lastTopping];
    }
    
    NSUserDefaults *toppingStore = [NSUserDefaults standardUserDefaults];
    [toppingStore setObject:formattedToppingsForSubmission forKey:@"formattedToppingsForSubmission"];
    [toppingStore synchronize];

    
    NSLog(@"Chosen Toppings String: %@", toppingsStringForOrder);
    NSLog(@"%@address1=%@&address2=%@&zip=%@&toppings=%@",BaseURL,address1,address2,zip,toppingsStringForOrder);
    
    NSString *getRequestString = [NSString stringWithFormat:@"%@address1=%@&address2=%@&zip=%@&toppings=%@",BaseURL,address1,address2,zip,toppingsStringForOrder];
    NSMutableString *urlEncodedString = [[NSMutableString alloc] init];
    [urlEncodedString setString:[getRequestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [urlEncodedString replaceOccurrencesOfString:@"," withString:@"%2C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [urlEncodedString length])];
  
    
    NSLog(@"GET REQUEST STRING: %@", getRequestString);
    NSLog(@"URL ENCODED GET REQUEST STRING: %@", urlEncodedString);

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET: urlEncodedString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        //CREATING
        NSArray *restaurants = [responseObject objectForKey:@"restaurants"];
        NSMutableArray *restaurantIDArray = [[NSMutableArray alloc]init];
        
        for(int i=0; i< restaurants.count; i++){
            NSDictionary *document = [restaurants objectAtIndex:i];
            NSString *restaurantID = [document objectForKey:@"restaurantid"];
            [restaurantIDArray addObject: restaurantID];
        }
        NSLog(@"%@",restaurantIDArray);
        NSUserDefaults *restaurantIDStore = [NSUserDefaults standardUserDefaults];
        [restaurantIDStore setObject:restaurantIDArray forKey:@"restaurantIDs"];
        [restaurantIDStore synchronize];
        
        [self submitOrderToServer];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self hideWaitingGif];
        NSLog(@"Error Restaurants: %@", error.description);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"We weren't able to find any pizzerias near you! You haven't been charged. "
                                                       delegate:self
                                              cancelButtonTitle:@"Ok, thanks!"
                                              otherButtonTitles: nil];
        [alert show];
    }];
}

- (void)submitOrderToServer {
    NSLog(@"submit order to server");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    NSUserDefaults *orderInfo = [NSUserDefaults standardUserDefaults];
    NSLog(@"Customer ID: %@", [orderInfo objectForKey:@"customerID"]);
    
    NSString *streetAddress = [[[orderInfo objectForKey:@"UserAddressString"] componentsSeparatedByString:@","] objectAtIndex:0];
    NSString *streetAddress2 = ([orderInfo objectForKey:@"UserAddressString2"] != nil) ? [orderInfo objectForKey:@"UserAddressString2"] : @"";
    NSString *customerID = [orderInfo objectForKey:@"customerID"];
    NSString *zipCode = [orderInfo objectForKey:@"zipCode"];
    NSString *phoneNumber = [orderInfo objectForKey:@"customerPhone"];
    
    NSLog(@"street address: %@", streetAddress);
    NSLog(@"customerID: %@", customerID);
    NSLog(@"zipCode: %@", zipCode);
    NSLog(@"phoneNumber: %@", phoneNumber);
    
    if(zipCode==NULL || streetAddress==NULL ){
        UIViewController *sec=[[SPGooglePlacesAutocompleteDemoViewController alloc] initWithNibName:@"SPGooglePlacesAutocompleteDemoViewController" bundle:nil];
        [self.navigationController pushViewController:sec animated:YES];
    } else if(customerID==NULL || phoneNumber==NULL || customerID==nil || phoneNumber==nil){
        NSLog(@"nil information");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        PizzaViewController *sec= [storyboard instantiateViewControllerWithIdentifier:@"PaymentViewController"];
        [self.navigationController pushViewController:sec animated:YES];
    } else {
        NSMutableArray *restaurantIDList = [[orderInfo objectForKey:@"restaurantIDs"] mutableCopy];
        NSLog(@"restaurant id list: %@",restaurantIDList);
        NSMutableArray *formattedToppingsForSubmission = [[orderInfo objectForKey:@"formattedToppingsForSubmission"] mutableCopy];
        [formattedToppingsForSubmission removeObjectIdenticalTo:@"none"];
        NSLog(@"Array of toppings submitting: %@", formattedToppingsForSubmission);
        
        NSString *firstName = [[NSUserDefaults standardUserDefaults] objectForKey:@"first_name"];
        NSString *lastName = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_name"];
        NSDictionary *params = @{@"phone": phoneNumber,
                                 @"stripeCustomerId": customerID,
                                 @"firstName": firstName,
                                 @"lastName": lastName,
                                 @"email": @"",
                                 @"delivery_address": streetAddress,
                                 @"delivery_apartment": streetAddress2,
                                 @"delivery_zip": zipCode,
                                 @"restaurantIds": restaurantIDList,
                                 @"toppings": formattedToppingsForSubmission,
                                 @"runAsync": @"true"};
        
        
        NSLog(@"params: %@", params);
        [manager POST:API_ORDERS parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Customer ID: %@", [orderInfo objectForKey:@"customerID"]);
            NSLog(@"Response: %@", responseObject);
            self.order_id = [responseObject objectForKey:@"_id"];
            [self startPollingForOrderStatus:self.order_id];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error.description);
            //[MBProgressHUD hideHUDForView:self.view animated:YES];
            [self hideWaitingGif];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Looks like our pizzerias are unresponsive! Try again. You have not been charged."
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok, thanks!"
                                                  otherButtonTitles: nil];
            [alert show];
            
        }];
    }
    
}

- (void) ping {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    [manager GET:[NSString stringWithFormat:@"%@/%@",API_ORDERS, self.order_id] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSLog(@"Order ID: %@", self.order_id);
        NSLog(@"Response: %@", responseObject);

        if ([[responseObject objectForKey:@"status"] isEqualToString:@"complete"]) {
            [self hideWaitingGif];
            
            MJDetailViewController *detailViewController = [[MJDetailViewController alloc] initWithNibName:@"MJDetailViewController" bundle:nil];
            [self presentPopupViewController:detailViewController animationType:MJPopupViewAnimationSlideBottomBottom];
            
            NSNumber *nsprice = [NSNumber numberWithInt:self.price];
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            [mixpanel.people trackCharge:nsprice];
            //[MBProgressHUD hideHUDForView:self.view animated:YES];
            
            [mixpanel.people increment:@{
                                         @"dollars spent":nsprice,
                                         @"pizzas ordered":@1
                                         }];
            
            NSUserDefaults *orderInfo = [NSUserDefaults standardUserDefaults];
            NSMutableArray *formattedToppingsForSubmission = [[orderInfo objectForKey:@"formattedToppingsForSubmission"] mutableCopy];
            [formattedToppingsForSubmission removeObjectIdenticalTo:@"none"];
            
            NSString *pizzaToppings = [formattedToppingsForSubmission componentsJoinedByString: @","];
            [mixpanel track:@"Pizza Toppings" properties:@{
                                                           @"toppings":pizzaToppings
                                                           }];
            [self.timer invalidate];

        } else if ([[responseObject objectForKey:@"status"] isEqualToString:@"failed"]) {
            [self hideWaitingGif];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"You won't be charged. Something went wrong with the order!"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok, thanks!"
                                                  otherButtonTitles: nil];
            [alert show];
            [self.timer invalidate];
        } else {
            NSLog(@"%@",[responseObject objectForKey:@"status"]);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
    }];
}

- (void) startPollingForOrderStatus:(NSString*)order_id {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(ping) userInfo:nil repeats:YES];
}


-(IBAction)goToPizzaPage:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    PizzaViewController *sec= [storyboard instantiateViewControllerWithIdentifier:@"PizzaViewController"];
    [self.navigationController pushViewController:sec animated:YES];
}

-(IBAction)goToPaymentPage:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    PaymentViewController *sec= [storyboard instantiateViewControllerWithIdentifier:@"PaymentViewController"];
    [self.navigationController pushViewController:sec animated:YES];
}

-(IBAction)GoToMapSearchPage:(id)sender{
    UIViewController *sec=[[SPGooglePlacesAutocompleteDemoViewController alloc] initWithNibName:@"SPGooglePlacesAutocompleteDemoViewController" bundle:nil];
    [self.navigationController pushViewController:sec animated:YES];
}

-(IBAction)popFaqModal:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"🍕HOW?🍕\nTap a button, get a pizza. Tip, tax, and delivery included.\n\n🍕WHAT?🍕\nThin crust, red sauce. \n16\" serves 2-3 people.\n\n🍕WHO?🍕\nWe send your order to our highest rated pizzeria that's open near you. All pizzerias in our network have at least 3 out of 5 stars in online reviews. And no \"fast food\" pizza chains - local shops only!\n\n🍕WHEN?🍕\nASAP! We work with the best local shops, the places that have reputations for fast delivery and yummy pizza.\n\n🍕I HAVE MORE QUESTIONS.🍕\nEmail us! pepperoni@pizzatheapp.com"
                                                   delegate:self
                                          cancelButtonTitle:@"🍕🍕🍕🍕🍕"
                                          otherButtonTitles: nil];
    alert.tag = 123;
    [alert show];
}

@end

