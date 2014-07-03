//
//  PaymentViewController.h
//  PizzaTheAppStripe
//
//  Created by Joe Vasquez on 5/28/14.
//  Copyright (c) 2014 Joe Vasquez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPView.h"

@interface PaymentViewController : UIViewController <STPViewDelegate>{
}

@property IBOutlet UIBarButtonItem *saveButton;


@property IBOutlet STPView* stripeView;
@property IBOutlet UILabel *storedCCLabel;
@property IBOutlet UILabel *creditCardLabel;
@property IBOutlet UIButton *cardCheck;

@property IBOutlet UITextField *phoneNumberField;
@property IBOutlet UILabel *phoneNumberLabel;
@property IBOutlet UIButton *phoneCheck;

@property IBOutlet UITextField *nameField;
@property IBOutlet UILabel *nameLabel;
@property IBOutlet UIButton *nameCheck;

@property IBOutlet UITextField *emailField;
@property IBOutlet UILabel *emailLabel;
@property IBOutlet UIButton *emailCheck;

@property IBOutlet UIButton *clearButton;

- (IBAction)cancelPhone:(id)sender;
- (IBAction)cancelCard:(id)sender;
- (IBAction)clearAllData:(id)sender;

@end