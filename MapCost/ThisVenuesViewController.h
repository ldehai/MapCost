//
//  ThisVenuesViewController.h
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/20/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class FSVenue;
@interface ThisVenuesViewController :UIViewController<CLLocationManagerDelegate>{
    CLLocationManager *_locationManager;
}

@property (strong,nonatomic)IBOutlet MKMapView* mapView;
@property (strong,nonatomic)IBOutlet UITableView* tableView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UILabel *totalCostLabel;
@property (nonatomic,retain)  NSMutableArray *colors;

- (id)initWithVenues:(FSVenue*)venue;
- (IBAction)billStat:(id)sender;

- (IBAction)goback:(id)sender;
- (IBAction)addbill:(id)sender;

//@property (strong,nonatomic)FSVenue* selected;
//@property (strong,nonatomic)NSArray* nearbyVenues;



@end
