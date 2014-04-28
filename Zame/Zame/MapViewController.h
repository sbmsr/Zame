//
//  MapViewController.h
//  Zame
//
//  Created by Leonard Loo on 27/4/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView * mapView;

@end
