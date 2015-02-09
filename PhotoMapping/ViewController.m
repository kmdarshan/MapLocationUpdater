//
//  ViewController.m
//  PhotoMapping
//
//  Created by kmd on 2/8/15.
//  Copyright (c) 2015 Happy Days. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    UILabel *addressLabel;
    MKAnnotationView *customAnnotationView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

-(void) setup {
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.mapView];
    
    [self.mapView setDelegate:self];
    self.locationManager = [CLLocationManager new];
    [self.locationManager setDelegate:self];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.mapView setShowsUserLocation:YES];
    
    addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height + self.view.frame.origin.y - 50, self.view.frame.size.width, 60)];
    [addressLabel setText:@"retrieving address"];
    [addressLabel setBackgroundColor:[UIColor yellowColor]];
    [self.mapView addSubview:addressLabel];
    
    customAnnotationView = [[MKAnnotationView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.view addSubview:customAnnotationView];
    [customAnnotationView setCenter:self.view.center];
    [customAnnotationView setImage:[UIImage imageNamed:@"target"]];
    
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    CLLocationCoordinate2D centre = [self.mapView centerCoordinate];
    [self currentAddress:centre.latitude longitude:centre.longitude];
}
-(CLLocationCoordinate2D) currentLocationInCoordinates {
    CLLocation *userLoc = [self.locationManager location];
    CLLocationCoordinate2D userCoordinate = userLoc.coordinate;
    return userCoordinate;
}

-(void)viewDidAppear:(BOOL)animated {
    
    if([CLLocationManager locationServicesEnabled]){
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Permission Denied"
                                               message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
            [alert show];
        } else {
            [self currentAddress:[self currentLocationInCoordinates].latitude longitude:[self currentLocationInCoordinates].longitude];
        }
    }
}

-(void) currentAddress:(CLLocationDegrees) latitude longitude:(CLLocationDegrees) longitude {
    CLGeocoder *geo = [CLGeocoder new];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [geo reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        NSLog(@"placemark %@",placemark);
        NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        NSLog(@"addressDictionary %@", placemark.addressDictionary);
        NSLog(@"placemark %@",placemark.region);
        NSLog(@"placemark %@",placemark.country);  // Give Country Name
        NSLog(@"locality %@",placemark.locality); // Extract the city name
        NSLog(@"location %@",placemark.name);
        NSLog(@"location %@",placemark.ocean);
        NSLog(@"location %@",placemark.postalCode);
        NSLog(@"location %@",placemark.subLocality);
        NSLog(@"location %@",placemark.location);
        NSLog(@"I am currently at %@",locatedAt);
        [addressLabel setText:locatedAt];
    }];
}
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *annotationView = [views objectAtIndex:0];
    id<MKAnnotation> mp = [annotationView annotation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate] ,250,250);
    [mv setRegion:region animated:YES];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *location in locations) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 800, 800);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
