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
    UITextField *phoneNumberField;
    UIBarButtonItem *saveButton;
}
@property STPView* stripeView;
@end