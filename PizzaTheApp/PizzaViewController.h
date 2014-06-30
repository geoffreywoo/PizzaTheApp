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

@property IBOutlet UIButton* pizzaMain;

- (void)playPizzaSong:(id)sender;

@end
