//
//  ViewController.h
//  MapShare
//
//  Created by Ethan Hess on 4/8/15.
//  Copyright (c) 2015 Ethan Hess. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchBarView.h"
@import MapKit;

@interface ViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) SearchBarView *searchBar;


@end
