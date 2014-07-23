//
//  PizzaViewController.h
//  pizzaTheApp2
//
//  Created by Joe Vasquez on 5/15/14.
//  Copyright (c) 2014 Joe Vasquez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface PizzaViewController : UIViewController{
    NSMutableArray* toppingsArray;
    NSMutableArray* selectedToppings;
    NSMutableArray* pizzaSong;
    UILabel *pageTitle;
    CGRect screenRect;
    UIView *view1;
    UILabel * yourOrder;
    NSString *ingredients;
    SystemSoundID soundClick;
    BOOL percussionMode;
    NSURL *pizzaSound;
    UILabel *pizzaString;
    BOOL animating;
}

@property (nonatomic, retain) IBOutlet UIButton* pizzaMain;


@property (nonatomic, retain) IBOutlet UIButton* pepperoni;
@property (nonatomic, retain) IBOutlet UIButton* sausage;
@property (nonatomic, retain) IBOutlet UIButton* mushrooms;
@property (nonatomic, retain) IBOutlet UIButton* peppers;
@property (nonatomic, retain) IBOutlet UIButton* olive;

- (void)playPizzaSong:(id)sender;

@end
