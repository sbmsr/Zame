//
//  CustomAnnotation.h
//  Zame
//
//  Created by Leonard Loo on 28/4/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSDictionary *user;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate
                AndTitle:(NSString *)title
             AndSubtitle:(NSString *)subtitle
                 AndUser: (NSDictionary *)user;

@end
