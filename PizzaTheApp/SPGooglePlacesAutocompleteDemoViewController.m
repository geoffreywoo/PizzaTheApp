//
//  SPGooglePlacesAutocompleteDemoViewController.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesAutocompleteDemoViewController.h"
#import "SPGooglePlacesAutocomplete.h"
#import <CoreLocation/CoreLocation.h>
#import "MainViewController.h"
#import "PaymentViewController.h"
#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define pizzaRedColor RGB(195,36,43)



@interface SPGooglePlacesAutocompleteDemoViewController()

@end

@implementation SPGooglePlacesAutocompleteDemoViewController
@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:@"AIzaSyDCu6HVjgUqN0hqC8TFXpR92o1XAXB8WxY"];
        shouldBeginEditing = YES;
    }
    return self;
}

- (void)viewDidLoad {
    screenRect = [[UIScreen mainScreen] bounds];
    self.searchDisplayController.searchBar.placeholder = @"Search or Address";
    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    
   // Mixpanel *mixpanel = [Mixpanel sharedInstance];
    //[mixpanel track:@"Visit map page"];
    
    // FIRST TIME LOADING
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
        
        UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchBarShouldBeginEditing:)];
        self.navigationItem.rightBarButtonItem = searchButton;
        [searchButton setTintColor:pizzaRedColor];

        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom ];
        confirmButton.frame = CGRectMake(0,  screenRect.size.height-113, screenRect.size.width, 50);
        [confirmButton setTitle:[NSString stringWithFormat:@"CONFIRM LOCATION"] forState:UIControlStateNormal];
        confirmButton.titleLabel.font = [UIFont fontWithName:@"Verlag-Black" size:20];
        confirmButton.layer.cornerRadius = 0;
        confirmButton.backgroundColor = pizzaRedColor;
        [[confirmButton layer] setMasksToBounds:YES];
        [[confirmButton layer] setBorderWidth:0.0f];
        [confirmButton addTarget:self action:@selector(sendToOverviewScreenTouch:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:confirmButton];
    } else {
        // Setup next button
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(next:)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
    
    
    UIImageView *mapPin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"map-pinPizza.png"]]];
    mapPin.frame = CGRectMake(screenRect.size.width/2-40, screenRect.size.height/2-80, 80, 80);
    [self.view addSubview:mapPin];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if ( !_initialLocation )
    {
        self.initialLocation = userLocation.location;
        
        MKCoordinateRegion region;
        region.center = mapView.userLocation.coordinate;
        region.span = MKCoordinateSpanMake(0.03, 0.03);
        
        region = [mapView regionThatFits:region];
        [mapView setRegion:region animated:YES];
    }
    
    [self performCoordinateGeocode:self];
    
}


- (IBAction)next:(id)sender {
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] == nil || [[NSUserDefaults standardUserDefaults] objectForKey:@"zipCode"] == nil || [[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] componentsSeparatedByString:@","] count]<2){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                        message:@"Are you sure that's the right address?"
                                                       delegate:self
                                              cancelButtonTitle:@"Hm, I'll try again."
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
    } else {
        [self.locationManager stopUpdatingLocation];
        UIViewController *sec=[[PaymentViewController alloc] initWithNibName:@"PaymentViewController" bundle:nil];
        [self.navigationController pushViewController:sec animated:YES];
    }
}

- (IBAction)performCoordinateGeocode:(id)sender
{
    //[self lockUI:YES];
    
    CLLocationCoordinate2D center = mapView.centerCoordinate;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            NSLog(@"Geocode failed with error!");
            return;
        }
        NSLog(@"Received placemarks: %@", placemarks);
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        NSLog(@"%@ %@ %@ %@",[placemark locality], [placemark subLocality], [placemark thoroughfare], [placemark subThoroughfare]);
        if([placemark subThoroughfare]==NULL || [placemark thoroughfare] == NULL || [placemark locality] == NULL || [placemark   postalCode] == NULL){
            self.searchDisplayController.searchBar.placeholder = [NSString stringWithFormat:@"Finding your location..."];
        } else{
            self.searchDisplayController.searchBar.placeholder = [NSString stringWithFormat:@"%@ %@, %@ %@",[placemark subThoroughfare],[placemark thoroughfare], [placemark locality], [placemark   postalCode]];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSString stringWithFormat:@"%@ %@,%@",[placemark subThoroughfare],[placemark thoroughfare], [placemark locality]] forKey:@"UserAddressString"];
            [defaults setObject:[NSString stringWithFormat:@"%@",[placemark   postalCode]] forKey:@"zipCode"];
            [defaults synchronize];
        }
        
    }];
    
    UIView * v = [self.view viewWithTag:1];
    if (v != nil) {
        [v removeFromSuperview];
    }

}


- (IBAction)recenterMapToUserLocation:(id)sender {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.01;
    span.longitudeDelta = 0.01;
    
    region.span = span;
    region.center = self.mapView.userLocation.coordinate;
    
    [self.mapView setRegion:region animated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Search 1");
    return [searchResultPlaces count];
}

- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Search 2");

    return searchResultPlaces[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Search 3");

    static NSString *cellIdentifier = @"SPGooglePlacesAutocompleteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Verlag-Bold" size:16.0];
    cell.textLabel.text = [self placeAtIndexPath:indexPath].name;
    return cell;

}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)recenterMapToPlacemark:(CLPlacemark *)placemark {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.015;
    span.longitudeDelta = 0.015;
    
    region.span = span;
    region.center = placemark.location.coordinate;
    NSLog(@"%@", placemark.postalCode);
    [self.mapView setRegion:region];
    
    NSUserDefaults *zipStore = [NSUserDefaults standardUserDefaults];
    [zipStore setObject:[NSString stringWithFormat:@"%@", placemark.postalCode] forKey:@"zipCode"];
    [zipStore synchronize];
}

- (void)addPlacemarkAnnotationToMap:(CLPlacemark *)placemark addressString:(NSString *)address {
    [self.mapView removeAnnotation:selectedPlaceAnnotation];
    
    selectedPlaceAnnotation = [[MKPointAnnotation alloc] init];
    selectedPlaceAnnotation.coordinate = placemark.location.coordinate;
    selectedPlaceAnnotation.title = address;
    [self.mapView addAnnotation:selectedPlaceAnnotation];
}

- (void)reverseGeocoder:(CLGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark{
    //NSString *zipCode = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressZIPKey];
}


- (void)dismissSearchControllerWhileStayingActive {
    // Animate out the table view.
    NSTimeInterval animationDuration = 0.3;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.searchDisplayController.searchResultsTableView.alpha = 0.0;
    [UIView commitAnimations];
    
    [self.searchDisplayController.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchDisplayController.searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Search 5");

    SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];
    [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not map selected Place"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        } else if (placemark) {
            [self addPlacemarkAnnotationToMap:placemark addressString:addressString];
            [self recenterMapToPlacemark:placemark];
            [self dismissSearchControllerWhileStayingActive];
            [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3* NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[NSString stringWithFormat:@"%@", addressString] forKey:@"UserAddressString"];
                [defaults synchronize];
                
                if([[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] == nil || [[NSUserDefaults standardUserDefaults] objectForKey:@"zipCode"] == nil || [[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] componentsSeparatedByString:@","] count]<2){
                        NSLog(@"No address set");
                } else {
                    self.searchDisplayController.searchBar.placeholder = [NSString stringWithFormat:@"%@, %@ %@", [[addressString componentsSeparatedByString:@","] objectAtIndex:0], [[addressString componentsSeparatedByString:@","] objectAtIndex:1], [defaults valueForKey:@"zipCode"]];
                }
                shouldBeginEditing = NO;
                [self.searchDisplayController setActive:NO];
                [self.mapView removeAnnotation:selectedPlaceAnnotation];
                
                //[self sendToOverviewScreen];
            });
            
            
            /*shouldBeginEditing = NO;
            [self.searchDisplayController setActive:NO];
            [self.mapView removeAnnotation:selectedPlaceAnnotation];*/ 
            
        }
    }];
}

#pragma mark -
#pragma mark UISearchDisplayDelegate

- (void)handleSearchForSearchString:(NSString *)searchString {

    searchQuery.location = self.mapView.userLocation.coordinate;
    searchQuery.input = searchString;
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not fetch places"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        } else {
            searchResultPlaces = places;
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSLog(@"Search 6");

    [self handleSearchForSearchString:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark -
#pragma mark UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchBar isFirstResponder]) {
        // User tapped the 'clear' button.
        shouldBeginEditing = NO;
        [self.searchDisplayController setActive:NO];
        [self.mapView removeAnnotation:selectedPlaceAnnotation];
    }
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    if (shouldBeginEditing) {
        self.searchDisplayController.searchBar.placeholder = @"Enter an address...";
        // Animate in the table view.
        NSTimeInterval animationDuration = 0.3;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        self.searchDisplayController.searchResultsTableView.alpha = 0.95;
        [UIView commitAnimations];
        
        [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:YES];
    }
    BOOL boolToReturn = shouldBeginEditing;
    shouldBeginEditing = YES;
    return boolToReturn;
}

#pragma mark -
#pragma mark MKMapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapViewIn viewForAnnotation:(id <MKAnnotation>)annotation {
    if (mapViewIn != self.mapView || [annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    static NSString *annotationIdentifier = @"SPGooglePlacesAutocompleteAnnotation";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
    }
    annotationView.animatesDrop = YES;
    annotationView.canShowCallout = YES;
    
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [detailButton addTarget:self action:@selector(annotationDetailButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.rightCalloutAccessoryView = detailButton;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    // Whenever we've dropped a pin on the map, immediately select it to present its callout bubble.
    [self.mapView selectAnnotation:selectedPlaceAnnotation animated:YES];
}

- (void)annotationDetailButtonPressed:(id)sender {
    // Detail view controller application logic here.
}

-(void)sendToOverviewScreen{
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] == nil || [[NSUserDefaults standardUserDefaults] objectForKey:@"zipCode"] == nil || [[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] componentsSeparatedByString:@","] count]<2){

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                        message:@"Are you sure that's the right address?"
                                                       delegate:self
                                              cancelButtonTitle:@"Hm, I'll try again."
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
    } else {
        UIViewController *sec=[[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        [self.navigationController pushViewController:sec animated:YES];
    }
    
}

-(IBAction)sendToOverviewScreenTouch:(id)sender{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] == nil || [[NSUserDefaults standardUserDefaults] objectForKey:@"zipCode"] == nil || [[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAddressString"] componentsSeparatedByString:@","] count]<2){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                        message:@"Are you sure that's the right address?"
                                                       delegate:self
                                              cancelButtonTitle:@"Hm, I'll try again."
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
    } else {
        UIViewController *sec=[[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        [self.navigationController pushViewController:sec animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    if (self.locationManager){
        mapView.showsUserLocation = NO;
        [self.locationManager stopUpdatingLocation];
    }
    [super viewWillDisappear:animated];
}

- (void)dealloc{
    if (self.locationManager){
        self.locationManager = nil;
    }
}

@end
