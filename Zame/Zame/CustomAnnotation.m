//
//  CustomAnnotation.m
//  Zame
//
//  Created by Leonard Loo on 28/4/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import "CustomAnnotation.h"


@implementation CustomAnnotation

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate
                AndTitle:(NSString *)title
             AndSubtitle:(NSString *)subtitle
                 AndUser: (NSDictionary *)user {
    if ((self = [super init])) {
        self.coordinate =coordinate;
        self.title = title;
        self.subtitle = subtitle;
        self.user = user;
    }
    return self;
}


@end
