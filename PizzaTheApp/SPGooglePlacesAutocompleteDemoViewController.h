//
//  SPGooglePlacesAutocompleteDemoViewController.h
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class SPGooglePlacesAutocompleteQuery;

@interface SPGooglePlacesAutocompleteDemoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, MKMapViewDelegate> {
    NSArray *searchResultPlaces;
    SPGooglePlacesAutocompleteQuery *searchQuery;
    MKPointAnnotation *selectedPlaceAnnotation;
    
    BOOL shouldBeginEditing;
    CGRect screenRect;
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) CLLocation* initialLocation;
@property (nonatomic, retain) IBOutlet UITextField *streetAddress2;

@end
