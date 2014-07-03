//
//  PizzaViewController.m
//  pizzaTheApp2
//
//  Created by Joe Vasquez on 5/15/14.
//  Copyright (c) 2014 Joe Vasquez. All rights reserved.
//

#import "PizzaViewController.h"
#import "PaymentViewController.h"
#import "SPGooglePlacesAutocompleteDemoViewController.h"

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define DEGREES_TO_RADIANS(x) (x * M_PI/180.0)

#define TAG_BASE 100

@interface PizzaViewController ()

@property NSMutableArray *toppingButtons;

@end

@implementation PizzaViewController

- (NSString *) generatePizzaDescription {
    //NSMutableString *pizzaDescription = [NSMutableString stringWithFormat:@"Your order is a"];
    NSMutableString *pizzaDescription = [NSMutableString stringWithFormat:@"16 inch"];
    NSMutableArray *chosenToppings = [[[NSUserDefaults standardUserDefaults] objectForKey:@"chosenToppings"] mutableCopy];
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
    
    if(numToppings==0){
        [pizzaDescription appendString:[NSString stringWithFormat:@" delicious plain pizza!"]];
    }
    for(int i = 0; i < [chosenToppings count]; i++){
        if(numToppings==0){
            // Nothing to do here.
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
    return pizzaDescription;
}

- (void) tweakButtonState {
    NSLog(@"toppingsArray: %d", [toppingsArray count]);
    NSLog(@"toppingsButtons: %d", [self.toppingButtons count]);
    for (int i=0;i<[toppingsArray count]; i++){
        if (![[selectedToppings objectAtIndex:i] isEqualToString:@"none"])
            [[self.toppingButtons objectAtIndex:i] setAlpha: 1.0];
        else
            [[self.toppingButtons objectAtIndex:i] setAlpha: 0.2];
    }
}

- (void) createToppingButtons {
    screenRect = [[UIScreen mainScreen] bounds];
    CGFloat buttonWidth = screenRect.size.width/6;
    CGFloat buttonHeight = buttonWidth;
    CGFloat buttonMargin = screenRect.size.width/36;
    self.toppingButtons = [[NSMutableArray alloc] init];
    for (int i=0;i<[toppingsArray count]; i++){
        UIButton *toppingSelect = [UIButton buttonWithType:UIButtonTypeCustom ];
        toppingSelect.frame = CGRectMake(i*buttonWidth+(buttonMargin*(i+1)), screenRect.size.height-buttonHeight-20, buttonWidth, buttonHeight);
        [toppingSelect setTitle:[NSString stringWithFormat:@"%@",[toppingsArray objectAtIndex:i]] forState:UIControlStateNormal];
        [toppingSelect.titleLabel removeFromSuperview];
        toppingSelect.backgroundColor = [UIColor colorWithRed:0.925 green:0.941 blue:0.945 alpha:1.000];
        [[toppingSelect layer] setMasksToBounds:YES];
        [[toppingSelect layer] setBorderWidth:0.0f];
        [toppingSelect addTarget:self action:@selector(addPizzaTopping:) forControlEvents:UIControlEventTouchUpInside];
        toppingSelect.layer.masksToBounds = YES;
        //toppingSelect.tag = i + [toppingsArray count];
        
        [self.view addSubview:toppingSelect];
        [self.toppingButtons addObject:toppingSelect];
        
        UIImageView *toppingForButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-bg.png",[toppingsArray objectAtIndex:i]]]];
        [toppingForButton setContentMode:UIViewContentModeScaleAspectFit];
        toppingForButton.frame = CGRectMake(-50, -50, 150, 150);
        [toppingSelect addSubview:toppingForButton];
    }
    [self tweakButtonState];
}

- (void) createDescriptionString {
    screenRect = [[UIScreen mainScreen] bounds];
    CGFloat buttonWidth = screenRect.size.width/6;
    CGFloat buttonHeight = buttonWidth;
    pizzaString = [[UILabel alloc] initWithFrame:CGRectMake(15, screenRect.size.height-buttonHeight-70, screenRect.size.width-30, 50)];
    pizzaString.lineBreakMode = NSLineBreakByWordWrapping;
    pizzaString.numberOfLines = 0;
    pizzaString.font = [UIFont fontWithName:@"Verlag-Bold" size:14];
    pizzaString.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:pizzaString];
    pizzaString.text = [NSString stringWithFormat:@"%@", [self generatePizzaDescription]];
}

- (void) drawToppings {
    selectedToppings = [[NSMutableArray alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([[userDefaults valueForKey:@"chosenToppings"] count]!=0){
        selectedToppings = [[userDefaults valueForKey:@"chosenToppings"] mutableCopy];
        //ADD TOPPING SUBVIEWS NOW
        for(int i = 0; i < [toppingsArray count]; i++){
            if(![[selectedToppings objectAtIndex:i] isEqualToString:@"none"]){
                UIImageView *toppingOnPizza = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@new.png",[selectedToppings objectAtIndex:i]]]];
                toppingOnPizza.frame = CGRectMake(0, 0, self.pizzaMain.frame.size.width, self.pizzaMain.frame.size.height);
                float position = [toppingsArray indexOfObject:[toppingsArray objectAtIndex:i]];
                toppingOnPizza.tag = position + TAG_BASE;
                [self.pizzaMain addSubview:toppingOnPizza];
            }
        }
    } else {
        selectedToppings = [NSMutableArray arrayWithObjects: @"none", @"none", @"none", @"none", @"none", nil];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");
    [super viewWillAppear:animated];

    
    // FIRST TIME LOADING
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
        // app already launched
    } else {
        [self.navigationItem setHidesBackButton:YES];
        // Setup next button
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(next:)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }

    [self drawToppings];
    [self createToppingButtons];
    [self createDescriptionString];
}

- (void)viewDidLoad {
    NSLog(@"viewDidLoad");
    [super viewDidLoad];

    //Mixpanel *mixpanel = [Mixpanel sharedInstance];
    //[mixpanel track:@"Visit pizza page"];
    
    // Do any additional setup after loading the view from its nib.
    [self setTitle:@"PICK YOUR TOPPINGS"];
    percussionMode = YES;
    pizzaSong = [[NSMutableArray alloc] init];
    
    toppingsArray = [NSMutableArray arrayWithObjects: @"pepperoni", @"sausage", @"mushrooms", @"peppers", @"olives", nil];
}


- (IBAction)addPizzaTopping:(id)sender {
    
    NSString *value = (NSString *)[sender currentTitle];
    [pizzaSong addObject:value];
    
    // SOUNDS, yo!
    if(percussionMode == YES){
        pizzaSound   = [[NSBundle mainBundle] URLForResource: [NSString stringWithFormat:@"%@Drum",value] withExtension: @"aif"];
    } else {
        pizzaSound   = [[NSBundle mainBundle] URLForResource: [NSString stringWithFormat:@"%@Guitar",value] withExtension: @"aif"];
    }
    AudioServicesCreateSystemSoundID (CFBridgingRetain(pizzaSound), &(soundClick));
    AudioServicesPlaySystemSound(soundClick);
    
    float position = [toppingsArray indexOfObject:value];
    if([[selectedToppings objectAtIndex:(position)] isEqualToString:@"none"]){
        UIImageView *toppingSelect = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@new.png",[sender currentTitle]]]];
        toppingSelect.frame = CGRectMake(0, 0, self.pizzaMain.frame.size.width, self.pizzaMain.frame.size.height);
        toppingSelect.tag = position + TAG_BASE;
        [self.pizzaMain addSubview:toppingSelect];
        NSLog(@"%@", selectedToppings);
        [selectedToppings replaceObjectAtIndex:(position) withObject:[NSString stringWithFormat:@"%@",value]];
        NSLog(@"%@", selectedToppings);
        
    } else {
        UIView * v = [self.view viewWithTag:position + TAG_BASE];
        if (v != nil) {
            [v removeFromSuperview];
        }
        [selectedToppings replaceObjectAtIndex:(position) withObject:@"none"];
    }
    
    NSLog(@"%@", selectedToppings);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:selectedToppings forKey:@"chosenToppings"];
    [defaults synchronize];
    
    pizzaString.text = [NSString stringWithFormat:@"%@",[self generatePizzaDescription]];
    [self tweakButtonState];
}

- (void)playPizzaSong:(id)sender {

}

- (IBAction)next:(id)sender {
    UIViewController *sec=[[SPGooglePlacesAutocompleteDemoViewController alloc] initWithNibName:@"SPGooglePlacesAutocompleteDemoViewController" bundle:nil];
    [self.navigationController pushViewController:sec animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end