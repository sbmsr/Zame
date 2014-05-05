//
//  MapViewController.h
//  Zame
//
//  Created by Leonard Loo on 27/4/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "REMarkerClusterer.h"
#import "REMarker.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, REMarkerClusterDelegate>

@property (weak, nonatomic) IBOutlet MKMapView * mapView;
@property (strong, nonatomic) REMarkerClusterer *clusterer;
@property (weak, nonatomic) IBOutlet UILabel * aggregateScoreLabel;

@end
