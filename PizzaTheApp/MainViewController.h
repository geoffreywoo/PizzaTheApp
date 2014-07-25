//
//  MainViewController.h
//  pizzaTheApp2
//
//  Created by Joe Vasquez on 5/15/14.
//  Copyright (c) 2014 Joe Vasquez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface MainViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    CGRect screenRect;
    NSMutableArray *chosenToppings;
    UIImageView *pizzaImage;
    UILabel *pizzaDescribe;
    UIButton *goToPizzaPage;
    //NSMutableString *pizzaDescription;
}

@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic) NSString *order_id;

@property (nonatomic,retain) IBOutlet UIButton *confirmButton;
@property (nonatomic,retain) IBOutlet UILabel *priceLabel;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *faqButton;

@property (nonatomic, retain) IBOutlet UIImageView *waitingGIF;
@property (nonatomic, retain) IBOutlet UIImageView *waitingScreen;
@property (nonatomic, retain) IBOutlet UILabel *waitingText;
@property (nonatomic) int price;

//@property(nonatomic, retain) IBOutlet UIButton *clickMeButton;

-(IBAction)popFaqModal:(id)sender;

@end
