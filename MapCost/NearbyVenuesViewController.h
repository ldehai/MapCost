//
//  NearbyVenuesViewController.h
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/20/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class FSVenue;
@interface NearbyVenuesViewController :UIViewController<CLLocationManagerDelegate>{
    CLLocationManager *_locationManager;
}

@property (strong,nonatomic)IBOutlet MKMapView* mapView;
@property (strong,nonatomic)IBOutlet UITableView* tableView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutlet UIView *editVenue;

@property (strong, nonatomic) IBOutlet UIView *popMenuHome;
@property (strong, nonatomic) IBOutlet UIView *popMenuSimple;
@property (strong, nonatomic) IBOutlet UIView *popMenuCost;
@property (strong, nonatomic) IBOutlet UIView *popMenuCostSimple;

@property (strong,nonatomic) FSVenue* selected;
//@property (strong,nonatomic) id <MKAnnotation> selected;
@property (weak, nonatomic) IBOutlet UITextField *venueName;
@property (weak, nonatomic) IBOutlet UITextField *venueAddress;
@property (strong,nonatomic)NSMutableArray* nearbyVenues;
- (IBAction)saveVenue:(id)sender;
- (IBAction)cancelVenue:(id)sender;
- (IBAction)billStat:(id)sender;

- (IBAction)upgradePro:(id)sender;
- (IBAction)loadAllVenue:(id)sender;
- (IBAction)loadFavoriteVenue:(id)sender;
- (IBAction)giveFeedback:(id)sender;
- (IBAction)suggestApps:(id)sender;
- (IBAction)about:(id)sender;
- (IBAction)exportBills:(id)sender;

@end
