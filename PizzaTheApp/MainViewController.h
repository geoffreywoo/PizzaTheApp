//
//  MainViewController.h
//  pizzaTheApp2
//
//  Created by Joe Vasquez on 5/15/14.
//  Copyright (c) 2014 Joe Vasquez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController{
    CGRect screenRect;
    NSMutableArray *chosenToppings;
    UIImageView *pizzaImage;
    UILabel *pizzaDescribe;
    UIButton *goToPizzaPage;
    //NSMutableString *pizzaDescription;
}

//@property(nonatomic, retain) IBOutlet UIButton *clickMeButton;

//-(IBAction)goToPizzaPage:(id)sender;

@end
