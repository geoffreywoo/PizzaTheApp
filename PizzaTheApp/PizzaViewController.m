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



@interface PizzaViewController ()

@end

@implementation PizzaViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    //Mixpanel *mixpanel = [Mixpanel sharedInstance];
    //[mixpanel track:@"Visit pizza page"];
    
    // Do any additional setup after loading the view from its nib.
    [self setTitle:@"PICK YOUR TOPPINGS"];
    percussionMode = YES;
    
    screenRect = [[UIScreen mainScreen] bounds];
    CGFloat buttonWidth = screenRect.size.width/6;
    CGFloat buttonHeight = buttonWidth;
    CGFloat buttonMargin = screenRect.size.width/36;
    
    // FIRST TIME LOADING
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
        // app already launched
    } else {
        [self.navigationItem setHidesBackButton:YES];
        // Setup next button
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(next:)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   SETTING UP MAIN PIZZA VIEW
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
    
    pizzaMain = [UIButton buttonWithType:UIButtonTypeCustom];
    pizzaMain.frame = CGRectMake(10, 70, (screenRect.size.width)-20, (screenRect.size.width)-20);
    [pizzaMain setTitle:[NSString stringWithFormat:@"pizza"] forState:UIControlStateNormal];
    [pizzaMain setImage:[UIImage imageNamed:[NSString stringWithFormat:@"pizza.png"]] forState:UIControlStateNormal];
    [pizzaMain addTarget:self action:@selector(playPizzaSong:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pizzaMain];
    
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   INITIALIZING ARRAYS
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
    
    toppingsArray = [NSMutableArray arrayWithObjects: @"pepperoni", @"sausage", @"mushrooms", @"peppers", @"olives", nil];
    
    selectedToppings = [[NSMutableArray alloc] init];
    NSUserDefaults *alreadyPicked = [NSUserDefaults standardUserDefaults];
    if([[alreadyPicked valueForKey:@"chosenToppings"] count]!=0){
        selectedToppings = [[alreadyPicked valueForKey:@"chosenToppings"] mutableCopy];
        //ADD TOPPING SUBVIEWS NOW
        for(int i = 0; i < [toppingsArray count]; i++){
            if(![[selectedToppings objectAtIndex:i] isEqualToString:@"none"]){
                UIImageView *toppingForButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@new.png",[selectedToppings objectAtIndex:i]]]];
                toppingForButton.frame = CGRectMake(0, 0, pizzaMain.frame.size.width, pizzaMain.frame.size.height);
                float position = [toppingsArray indexOfObject:[toppingsArray objectAtIndex:i]] + 1;
                toppingForButton.tag = position;
                [pizzaMain addSubview:toppingForButton];
            }
        }
    } else {
        selectedToppings = [NSMutableArray arrayWithObjects: @"none", @"none", @"none", @"none", @"none", nil];
    }
    
    pizzaSong = [[NSMutableArray alloc] init];
    
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   CREATE BUTTONS TO SELECT TOPPINGS
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
    
    // CREATING BUTTONS FOR TOPPINGS
    for (int i=0;i<[toppingsArray count]; i++){
        UIButton *toppingSelect = [UIButton buttonWithType:UIButtonTypeCustom ];
        toppingSelect.frame = CGRectMake(i*buttonWidth+(buttonMargin*(i+1)), screenRect.size.height-buttonHeight-20, buttonWidth, buttonHeight);
        [toppingSelect setTitle:[NSString stringWithFormat:@"%@",[toppingsArray objectAtIndex:i]] forState:UIControlStateNormal];
        toppingSelect.backgroundColor = [UIColor colorWithRed:0.925 green:0.941 blue:0.945 alpha:1.000];
        [[toppingSelect layer] setMasksToBounds:YES];
        [[toppingSelect layer] setBorderWidth:0.0f];
        [toppingSelect addTarget:self action:@selector(addPizzaTopping:) forControlEvents:UIControlEventTouchUpInside];
        [selectedToppings addObject:@"none"];
        toppingSelect.layer.masksToBounds = YES;
        toppingSelect.tag = i + [toppingsArray count] + 1;
        [toppingSelect setAlpha: 0.7];
        [toppingSelect.titleLabel removeFromSuperview];
        [self.view addSubview:toppingSelect];
        
        
        UIImageView *toppingForButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@new.png",[toppingsArray objectAtIndex:i]]]];
        toppingForButton.frame = CGRectMake(-50, -50, 200, 200);
        [toppingSelect addSubview:toppingForButton];
        
        /*
        toppingLabel = [[UILabel alloc] initWithFrame:CGRectMake(i*buttonWidth+(buttonMargin*(i+1)), screenRect.size.height-buttonHeight-60, buttonWidth, 30)];
        toppingLabel.textColor = [UIColor whiteColor];
        toppingLabel.tag = i + [toppingsArray count] + 1;
        toppingLabel.text = [NSString stringWithFormat:@"%@",[toppingsArray objectAtIndex:i]];
        toppingLabel.font = [UIFont fontWithName:@"Verlag-Bold" size:10];
        toppingLabel.backgroundColor = [UIColor blackColor];
        toppingLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:toppingLabel];*/
    }
    
    
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   THIS DESCRIBES THE PIZZA TOPPINGS
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
    
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
        [pizzaDescription appendString:[NSString stringWithFormat:@" pizza."]];
    }
    
    NSLog(@"Selected Toppings: %@", selectedToppings);
    NSLog(@"Array of Available Toppings: %@", toppingsArray);
    
    pizzaString = [[UILabel alloc] initWithFrame:CGRectMake(15, screenRect.size.height-buttonHeight-70, screenRect.size.width-30, 50)];
    pizzaString.lineBreakMode = NSLineBreakByWordWrapping;
    pizzaString.numberOfLines = 0;
    pizzaString.text = [NSString stringWithFormat:@"%@",pizzaDescription];
    pizzaString.font = [UIFont fontWithName:@"Verlag-Bold" size:14];
    pizzaString.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:pizzaString];
    
    
    
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
    
    
    
    float position = [toppingsArray indexOfObject:value] + 1;
    if([[selectedToppings objectAtIndex:(position-1)] isEqualToString:@"none"]){
        
        
        UIImageView *toppingSelect = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@new.png",[sender currentTitle]]]];
        toppingSelect.frame = CGRectMake(0, 0, pizzaMain.frame.size.width, pizzaMain.frame.size.height);
        toppingSelect.tag = position;
        [pizzaMain addSubview:toppingSelect];
        NSLog(@"%@", selectedToppings);
        [selectedToppings replaceObjectAtIndex:(position-1) withObject:[NSString stringWithFormat:@"%@",value]];
        NSLog(@"%@", selectedToppings);
        
    } else {
        NSLog(@"Already Added!");
        UIView * v = [self.view viewWithTag:position];
        if (v != nil) {
            [v removeFromSuperview];
        }
        [selectedToppings replaceObjectAtIndex:(position-1) withObject:@"none"];
    }
    
    NSLog(@"%@", selectedToppings);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:selectedToppings forKey:@"chosenToppings"];
    [defaults synchronize];
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   THIS DESCRIBES THE PIZZA TOPPINGS
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
    
    NSMutableString *pizzaDescription = [NSMutableString stringWithFormat:@"Your order is a"];
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
    
    pizzaString.text = [NSString stringWithFormat:@"%@",pizzaDescription];
    
    
}

- (void)playPizzaSong:(id)sender {

}


- (void) stopSpin {
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear animations:^{
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI * 0.05);
        pizzaMain.transform = transform;
    } completion:NULL];
    
    animating = NO;
}

- (void) startSpin {
    [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear animations:^{
        CGAffineTransform transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(360));
        pizzaMain.transform = transform;
    } completion:NULL];
    
    animating = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    
    /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
     |
     |   THIS DESCRIBES THE PIZZA TOPPINGS
     |
     |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
    
    NSMutableString *pizzaDescription = [NSMutableString stringWithFormat:@"Your order is a"];
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
    
    pizzaString.text = [NSString stringWithFormat:@"%@",pizzaDescription];
    
    
    /*
    NSArray *viewsToRemove = [pizzaMain subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    NSUserDefaults *pizzaFetcher = [NSUserDefaults standardUserDefaults];
    if([pizzaFetcher objectForKey:@"chosenToppings"] != nil || [[pizzaFetcher objectForKey:@"chosenToppings"] count]==0){
        for(int i = 0; i < [[pizzaFetcher objectForKey:@"chosenToppings"] count]; i++){
            if(![[[pizzaFetcher objectForKey:@"chosenToppings"] objectAtIndex:i] isEqualToString:@"none"]){
                UIImageView *toppingForButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[[pizzaFetcher objectForKey:@"chosenToppings"] objectAtIndex:i]]]];
                toppingForButton.frame = CGRectMake(0, 0, pizzaMain.frame.size.width, pizzaMain.frame.size.height);
                [pizzaMain addSubview:toppingForButton];
            }
        }
    }*/
    
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