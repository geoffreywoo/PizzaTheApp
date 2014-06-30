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

//#import <Crashlytics/Crashlytics.h>

#define STRIPE_KEY @"pk_test_9wPOvSKQ8o5EsuXDWUIBjzlQ"
#define API_CONFIG @"https://pizzatheapp-staging.herokuapp.com/api/config"
#define API_ORDERS @"https://pizzatheapp-staging.herokuapp.com/api/orders"
#define API_CUSTOMERS @"https://pizzatheapp-staging.herokuapp.com/api/customers/"
#define BASE_URL_RESTAURANTS @"https://pizzatheapp-staging.herokuapp.com/api/closest-restaurants?"
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

- (void)viewDidLoad

{
    
    [super viewDidLoad];
    
   //[[vlytics sharedInstance] crash];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"chosenToppings"];
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   TOP OF PAGE IMAGE
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
    
    UIImage *titleImage = [UIImage imageNamed:@"header-logo.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   FETCH PRICES OF PIZZA & TOPPINGS
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *stringForPrices = API_CONFIG;
    [manager GET:[NSString stringWithFormat:@"%@",stringForPrices] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        int toppingPrice = [[responseObject objectForKey:@"TOPPING_PRICE_CENTS"] intValue]/100;
        int tipPrice = [[responseObject objectForKey:@"TIP_CENTS"] intValue]/100;
        int basePrice = [[responseObject objectForKey:@"BASE_PRICE_CENTS"] intValue]/100;
        NSLog(@"Topping Price %d", toppingPrice);
        NSLog(@"tip Price %d", tipPrice);
        NSLog(@"Base Price %d", basePrice);
        
        NSUserDefaults *pricingStore = [NSUserDefaults standardUserDefaults];
        [pricingStore setInteger:toppingPrice forKey:@"toppingPrice"];
        [pricingStore setInteger:tipPrice forKey:@"tipPrice"];
        [pricingStore setInteger:basePrice forKey:@"basePrice"];
        [pricingStore synchronize];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"Error: %@", error.description);
    }];
    
    
    
    
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   SET LAST FOUR and EXPIRY INFO
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerID"]!=nil){
        //https://pizzatheapp-staging.herokuapp.com/api/customers/cus_4Bbh2EUpfzGogn/card
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:[NSString stringWithFormat:@"%@%@/card",API_CUSTOMERS,[[NSUserDefaults standardUserDefaults] objectForKey:@"customerID"]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            NSLog(@"JSON: %@", responseObject);
            NSLog(@"Exp Year: %@",[responseObject objectForKey:@"exp_year"]);
            NSLog(@"Exp Month: %@",[responseObject objectForKey:@"exp_month"]);
            NSLog(@"Last Four: %@",[responseObject objectForKey:@"last4"]);
            
            NSString *displayString = [NSString stringWithFormat:@"•••• •••• %@  %@/%@",[responseObject objectForKey:@"last4"],[responseObject objectForKey:@"exp_month"],[responseObject objectForKey:@"exp_year"]];
            [[NSUserDefaults standardUserDefaults] setObject:displayString forKey:@"displayString"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"Error customer card: %@", error.description);
        }];
    }
    
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   FIRST TIME LOADING SCRIPT
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

    // CHANGE THIS LATTERRRR!!!
    //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HasLaunchedOnce"];
    //[[NSUserDefaults standardUserDefaults] synchronize];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
        [self.navigationItem setHidesBackButton:YES];
    } else {
        [self.navigationItem setHidesBackButton:YES];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        PizzaViewController *sec= [storyboard instantiateViewControllerWithIdentifier:@"PizzaViewController"];
        [self.navigationController pushViewController:sec animated:YES];
    }
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(goToPaymentPage:)];
    
    
    UIImage *faceImage = [UIImage imageNamed:@"pizzaCutter.png"];
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    face.bounds = CGRectMake( 0, 0, faceImage.size.width, faceImage.size.height );//set bound as per you want
    [face addTarget:self action:@selector(goToPaymentPage:) forControlEvents:UIControlEventTouchUpInside];
    [face setImage:faceImage forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:face];
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    
    
    
    self.view.backgroundColor = backgroundGrey;
    
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"REVIEW YOUR ORDER"];
    
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
    [goToPizzaPage.titleLabel setFont:[UIFont fontWithName:@"Verlag-Bold" size:15]];
    [goToPizzaPage setTitleEdgeInsets:UIEdgeInsetsMake(-5.0f, 15.0f, 0.0f, screenRect.size.width/3)];

    
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   THIS DESCRIBES THE PIZZA TOPPINGS
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

    
    NSMutableString *pizzaDescription = [NSMutableString stringWithFormat:@"Large"];
    [chosenToppings removeAllObjects];
    NSUserDefaults *pizzaFetcher = [NSUserDefaults standardUserDefaults];
    chosenToppings = [[pizzaFetcher objectForKey:@"chosenToppings"] mutableCopy];
    
    for(int i = 0; i < [chosenToppings count]; i++){
        if([[chosenToppings objectAtIndex:i] isEqualToString:@"none"]){
            // Do nothing
        } else {
            [pizzaDescription appendString:[NSString stringWithFormat:@" %@,", [chosenToppings objectAtIndex:i]]];
        }
    }
    [pizzaDescription appendString:[NSString stringWithFormat:@" pizza"]];
    [goToPizzaPage setTitle:[NSString stringWithFormat:@"%@", pizzaDescription] forState:UIControlStateNormal];
    [self.view addSubview:goToPizzaPage];
    
    
    // Add pizza background image to button
    pizzaImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"pizza.png"]]];
    pizzaImage.frame = CGRectMake(screenRect.size.width-100, -50, 260, 260);
    [goToPizzaPage addSubview:pizzaImage];
    
    
    
    UIImageView *chevronRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"chevron - forward@2x.png"]]];
    chevronRight.frame = CGRectMake(screenRect.size.width-50, (goToPizzaPage.frame.size.height/2)-20, 30, 40);
    // [goToPizzaPage addSubview:chevronRight];
    
    
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
    
    
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   THIS DESCRIBES THE DELIVERY INFORMATION
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
    
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
        userAddress = [NSString stringWithFormat:@"%@, %@ %@", [[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] componentsSeparatedByString:@","] objectAtIndex:0], [[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] componentsSeparatedByString:@","] objectAtIndex:1], [[NSUserDefaults standardUserDefaults] objectForKey:@"zipCode"]];
        NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"]);
    }
    
    
    UIButton *deliveryPage = [UIButton buttonWithType:UIButtonTypeCustom ];
    deliveryPage.frame = CGRectMake(-1, 115, screenRect.size.width+2, 73.5  );
    [deliveryPage setTitle:[NSString stringWithFormat:@"%@",userAddress] forState:UIControlStateNormal];
    deliveryPage.titleLabel.font = [UIFont fontWithName:@"Verlag-Bold" size:18];
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
    
    
    
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   THIS CREATES THE CONFIRMATION BUTTON
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
    
    
    int price = [[NSUserDefaults standardUserDefaults] integerForKey:@"basePrice"]+[[NSUserDefaults standardUserDefaults] integerForKey:@"tipPrice"];
    for(int i = 0; i < [chosenToppings count]; i++){
        if([[chosenToppings objectAtIndex:i] isEqualToString:@"none"]){
            // Do nothing
        } else {
            price = price + [[NSUserDefaults standardUserDefaults] integerForKey:@"toppingPrice"];
        }
    }
    NSLog(@"%d", price);
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom ];
    confirmButton.frame = CGRectMake(0,  screenRect.size.height-50, screenRect.size.width, 50);
    [confirmButton setTitle:[NSString stringWithFormat:@"PLACE ORDER"] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont fontWithName:@"Verlag-Black" size:16];
    confirmButton.layer.cornerRadius = 0;
    confirmButton.backgroundColor = pizzaRedColor;
    [[confirmButton layer] setMasksToBounds:YES];
    [[confirmButton layer] setBorderWidth:0.0f];
    [confirmButton addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
    
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 300, 5)];
    priceLabel.textColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.35f];
    priceLabel.text = [NSString stringWithFormat:@"$%d",price];
    priceLabel.font = [UIFont fontWithName:@"Verlag-Bold" size:18];
    [confirmButton addSubview:priceLabel];
    
}


- (void)viewWillAppear:(BOOL)animated{
    NSArray *viewsToRemove = [pizzaImage subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    NSUserDefaults *pizzaFetcher = [NSUserDefaults standardUserDefaults];
    chosenToppings = [[pizzaFetcher objectForKey:@"chosenToppings"] mutableCopy];

    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   THIS CREATES THE PIZZA TOPPINGS SUBVIEWS
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
    
    
    if([pizzaFetcher objectForKey:@"chosenToppings"] != nil || [[pizzaFetcher objectForKey:@"chosenToppings"] count]==0){
        
        for(int i = 0; i < [chosenToppings count]; i++){
            if(![[chosenToppings objectAtIndex:i] isEqualToString:@"none"]){
                UIImageView *toppingForButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@new.png",[chosenToppings objectAtIndex:i]]]];
                toppingForButton.frame = CGRectMake(0, 0, 260, 260);
                [pizzaImage addSubview:toppingForButton];
            }
        }
    }
    
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   THIS DESCRIBES THE PIZZA TOPPINGS
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
    
    NSMutableString *pizzaDescription = [NSMutableString stringWithFormat:@"Large"];
    NSString *lastTopping;
    
    int numToppings = 0;
    if(chosenToppings != nil || [chosenToppings count]==0){
        for(int i = 0; i<[chosenToppings count]; i++){
            if(![[chosenToppings objectAtIndex:i] isEqualToString:@"none"]){
                numToppings++;
                lastTopping = [chosenToppings objectAtIndex:i];
            }
        }
    }
    
    for(int i = 0; i < [chosenToppings count]; i++){
        if(numToppings==0){
            [pizzaDescription appendString:[NSString stringWithFormat:@" delicious plain pizza!"]];
        } else if (numToppings==1){
            if(i == [chosenToppings indexOfObject:lastTopping]){
                [pizzaDescription appendString:[NSString stringWithFormat:@" %@", lastTopping]];
            }
        } else if (numToppings==2){
            if(![[chosenToppings objectAtIndex:i] isEqualToString:@"none"]){
                if(i != [chosenToppings indexOfObject:lastTopping]){
                    [pizzaDescription appendString:[NSString stringWithFormat:@" %@ and", [chosenToppings objectAtIndex:i]]];
                } else {
                    [pizzaDescription appendString:[NSString stringWithFormat:@" %@", [chosenToppings objectAtIndex:i]]];
                }
            }
        } else {
            if([[chosenToppings objectAtIndex:i] isEqualToString:@"none"]){
                // Do nothing
            } else {
                if(i == [chosenToppings indexOfObject:lastTopping]){
                    [pizzaDescription appendString:[NSString stringWithFormat:@" and %@", [chosenToppings objectAtIndex:i]]];
                } else {
                    [pizzaDescription appendString:[NSString stringWithFormat:@" %@,", [chosenToppings objectAtIndex:i]]];
                }
            }
        }
    }
    if(numToppings != 0){
        [pizzaDescription appendString:[NSString stringWithFormat:@" pizza"]];
    }

    [goToPizzaPage setTitle:[NSString stringWithFormat:@"%@", pizzaDescription] forState:UIControlStateNormal];
    NSLog(@"%@",[pizzaFetcher objectForKey:@"chosenToppings"]);
    
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   THIS CREATES THE CONFIRMATION BUTTON
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
    
    int price = [[NSUserDefaults standardUserDefaults] integerForKey:@"basePrice"]+[[NSUserDefaults standardUserDefaults] integerForKey:@"tipPrice"];
    for(int i = 0; i < [chosenToppings count]; i++){
        if([[chosenToppings objectAtIndex:i] isEqualToString:@"none"]){
            // Do nothing
        } else {
            price = price + [[NSUserDefaults standardUserDefaults] integerForKey:@"toppingPrice"];
        }
    }
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom ];
    confirmButton.frame = CGRectMake(0,  screenRect.size.height-50, screenRect.size.width, 50);
    [confirmButton setTitle:[NSString stringWithFormat:@"PLACE ORDER"] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont fontWithName:@"Verlag-Black" size:18];
    confirmButton.layer.cornerRadius = 0;
    confirmButton.backgroundColor = pizzaRedColor;
    [[confirmButton layer] setMasksToBounds:YES];
    [[confirmButton layer] setBorderWidth:0.0f];
    [confirmButton addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
    
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 300, 25)];
    priceLabel.textColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.35f];
    priceLabel.text = [NSString stringWithFormat:@"$%d",price];
    priceLabel.font = [UIFont fontWithName:@"Verlag-Bold" size:18];
    [confirmButton addSubview:priceLabel];
    
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   SET LAST FOUR and EXPIRY INFO
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"customerID"]!=nil){
        //https://pizzatheapp-staging.herokuapp.com/api/customers/cus_4Bbh2EUpfzGogn/card
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:[NSString stringWithFormat:@"%@%@/card",API_CUSTOMERS,[[NSUserDefaults standardUserDefaults] objectForKey:@"customerID"]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            NSLog(@"JSON: %@", responseObject);
            NSLog(@"Exp Year: %@",[responseObject objectForKey:@"exp_year"]);
            NSLog(@"Exp Month: %@",[responseObject objectForKey:@"exp_month"]);
            NSLog(@"Last Four: %@",[responseObject objectForKey:@"last4"]);
            
            NSString *displayString = [NSString stringWithFormat:@"•••• •••• %@  %@/%@",[responseObject objectForKey:@"last4"],[responseObject objectForKey:@"exp_month"],[responseObject objectForKey:@"exp_year"]];
            [[NSUserDefaults standardUserDefaults] setObject:displayString forKey:@"displayString"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"Error customer card: %@", error.description);
        }];
    }
    
}





- (void)didReceiveMemoryWarning

{
    
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
}

- (void)placeOrder:(UIBarButtonItem *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Order"
                                                    message:@"Are you ready for some pizza?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0: //"No" pressed
            //do something?
            break;
        case 1: //"Yes" pressed
            //here you pop the viewController
            //[self.navigationController popViewControllerAnimated:YES];
            [self getRestaurantIDs];
            break;
    }
}


- (NSString *)URLEncodeStringFromString:(NSString *)string
{
    static CFStringRef charset = CFSTR("!@#$%&*()+'\";:=,/?[] ");
    CFStringRef str = (__bridge CFStringRef)string;
    CFStringEncoding encoding = kCFStringEncodingUTF8;
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, str, NULL, charset, encoding));
}

- (void)getRestaurantIDs {
    NSLog(@"getting restaurant ids");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *BaseURL = BASE_URL_RESTAURANTS;
    /*NSString *address1 = @"341 Jersey Street";
    NSString *address2 = @"";
    NSString *zip = @"94114";
    */
    NSUserDefaults *orderInfo = [NSUserDefaults standardUserDefaults];
    NSLog(@"Customer ID: %@", [orderInfo objectForKey:@"customerID"]);
    
    NSString *address1 = [[[orderInfo objectForKey:@"UserAddressString"] componentsSeparatedByString:@","] objectAtIndex:0];
    NSString *address2 = @"";
    NSString *zip = [orderInfo objectForKey:@"zipCode"];

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

    NSMutableArray *toppingsFormattedForOrder = [NSMutableArray arrayWithObjects:@"green_peppers", @"mushrooms", @"pepperoni", @"sausage", @"black_olives", nil];
    
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
                lastTopping = [toppingsFormattedForOrder objectAtIndex:i];
            }
        }
    }
    NSLog(@"Last Topping: %@", lastTopping);
    
    for(int i = 0; i<[toppingsArrayForOrder count]; i++){
        if(![[toppingsArrayForOrder objectAtIndex:i] isEqualToString:@"none"] && ![[toppingsFormattedForOrder objectAtIndex:i] isEqualToString:lastTopping]){
            [toppingsStringForOrder appendString:[NSString stringWithFormat:@"%@,",[toppingsFormattedForOrder objectAtIndex:i]]];
            [formattedToppingsForSubmission addObject:[toppingsFormattedForOrder objectAtIndex:i]];
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
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         NSLog(@"Error Restaurants: %@", error.description);
    }];
}

- (void)submitOrderToServer {
    NSLog(@"submit order to server");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    NSUserDefaults *orderInfo = [NSUserDefaults standardUserDefaults];
    NSLog(@"Customer ID: %@", [orderInfo objectForKey:@"customerID"]);
    
    NSString *streetAddress = [[[orderInfo objectForKey:@"UserAddressString"] componentsSeparatedByString:@","] objectAtIndex:0];
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
        customerID = @"0000";
  /*  } else if(customerID==NULL || phoneNumber==NULL || customerID==nil || phoneNumber==nil){
        NSLog(@"nil information");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        PizzaViewController *sec= [storyboard instantiateViewControllerWithIdentifier:@"PizzaViewController"];
        [self.navigationController pushViewController:sec animated:YES];*/
    } else {
        //@"restaurantIds": restaurantIDList,
        //@"fetchRestaurants": @"true",
        
        NSMutableArray *restaurantIDList = [[orderInfo objectForKey:@"restaurantIDs"] mutableCopy];
        NSLog(@"restaurant id list: %@",restaurantIDList);
        NSMutableArray *formattedToppingsForSubmission = [[orderInfo objectForKey:@"formattedToppingsForSubmission"] mutableCopy];
        [formattedToppingsForSubmission removeObjectIdenticalTo:@"none"];
        NSLog(@"Array of toppings submitting: %@", formattedToppingsForSubmission);
        
        NSDictionary *params = @{@"phone": phoneNumber,
                                 @"stripeCustomerId": customerID,
                                 @"firstName": @"Joey",
                                 @"lastName": @"Pepperoni",
                                 @"email": @"joseph.c.vasquez@gmail.com",
                                 @"delivery_address": streetAddress,
                                 @"delivery_apartment": @"",
                                 @"delivery_zip": zipCode,
                                 @"restaurantIds": restaurantIDList,
                                 @"toppings": formattedToppingsForSubmission};
        
        
        NSLog(@"params: %@", params);
        [manager POST:API_ORDERS parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Customer ID: %@", [orderInfo objectForKey:@"customerID"]);
            NSLog(@"Response: %@", responseObject);
            
            if ([[responseObject objectForKey:@"error"] rangeOfString:@"Failed to order from any of"].location == NSNotFound || [responseObject objectForKey:@"error"]==nil) {
                MJDetailViewController *detailViewController = [[MJDetailViewController alloc] initWithNibName:@"MJDetailViewController" bundle:nil];
                [self presentPopupViewController:detailViewController animationType:MJPopupViewAnimationSlideBottomBottom];
                
                Mixpanel *mixpanel = [Mixpanel sharedInstance];
                [mixpanel identify:mixpanel.distinctId];
                
                
                int price = [[NSUserDefaults standardUserDefaults] integerForKey:@"basePrice"]+[[NSUserDefaults standardUserDefaults] integerForKey:@"tipPrice"];
                for(int i = 0; i < [chosenToppings count]; i++){
                    if([[chosenToppings objectAtIndex:i] isEqualToString:@"none"]){
                        // Do nothing
                    } else {
                        price = price + [[NSUserDefaults standardUserDefaults] integerForKey:@"toppingPrice"];
                    }
                }
                NSNumber *nsprice = [NSNumber numberWithInt:price];
                [mixpanel.people trackCharge:nsprice];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [mixpanel.people increment:@{
                                             @"dollars spent":nsprice,
                                             @"pizzas ordered":@1
                                             }];
                
            } else {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                message:@"We're not in your area or are closed!"
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok, thanks!"
                                                      otherButtonTitles: nil];
                [alert show];
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error.description);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"We're not in your area or are closed!"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok, thanks!"
                                                  otherButtonTitles: nil];
            [alert show];
            
        }];
    }
    
}


-(IBAction)goToPizzaPage:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    PizzaViewController *sec= [storyboard instantiateViewControllerWithIdentifier:@"PizzaViewController"];
    [self.navigationController pushViewController:sec animated:YES];
}

-(IBAction)goToPaymentPage:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    PizzaViewController *sec= [storyboard instantiateViewControllerWithIdentifier:@"PaymentViewController"];
    [self.navigationController pushViewController:sec animated:YES];
}

-(IBAction)GoToMapSearchPage:(id)sender{
    UIViewController *sec=[[SPGooglePlacesAutocompleteDemoViewController alloc] initWithNibName:@"SPGooglePlacesAutocompleteDemoViewController" bundle:nil];
    [self.navigationController pushViewController:sec animated:YES];
}
@end

