//
//  ViewController.m
//  MapShare
//
//  Created by Ethan Hess on 4/8/15.
//  Copyright (c) 2015 Ethan Hess. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+UIColorCategory.h"
#import "MapAnnotation.h"
#import "LocationController.h"
#import "SoundController.h"
#import "DismissView.h"
#import "SnapshotController.h"
#import "SnapshotCollectionView.h"
#import "InstructionsViewController.h"
#import "LocationManagerController.h"
#import "PictureChoiceCollectionViewController.h"
#import <CoreGraphics/CoreGraphics.h>

#define METERS_PER_MILE 23609.344

#define IS_IPHONE_4 ([UIScreen mainScreen].bounds.size.height == 480.0)

@interface ViewController () <UISearchBarDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) id <MKAnnotation> selectedAnnotation;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SoundController *soundController;
@property (nonatomic, strong) DismissView *dismissView;
@property (nonatomic, strong) UIImage *shareImage;
@property (nonatomic, assign) MKMapType currentMapType;
@property (nonatomic, strong) MKPinAnnotationView *pinAnnotation;
@property (nonatomic, strong) UIColor *pinTintColor;
@property (nonatomic, strong) NSArray *arrayOfPins;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *collectionContainerView;
@property (nonatomic, assign) CLLocationCoordinate2D *currentLocation;


@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    
    [[self navigationController] setNavigationBarHidden:YES];
    
    [self registerForNotifications]; 
    
    //[LocationManagerController sharedInstance];
    
    /*
    
    [[LocationManagerController sharedInstance]getCurrentLocationWithCompletion:^(CLLocationCoordinate2D currentLocation, BOOL success) {
        
        self.currentLocation = &(currentLocation);
        
    }];
     
     */
    
    //[self setUpMapView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[LocationManagerController sharedInstance];
    
    self.calloutView = [[CalloutView alloc] init];
    self.arrayOfPins = [NSArray new];
    self.pinTintColor = [UIColor redColor];
    self.soundController = [SoundController new];
    
    [self setUpMapView];
    [self setUpToolBar];
    [self setUpNavigationToolBar];
    [self setUpSearchBar];
    [self setAnnotations];
    [self setUpDismissView];
    [self setUpTableView];
    [self setUpCollectionView];
    
    [self.view bringSubviewToFront:self.navToolBar];
    [self.calloutView setHidden:YES];
    [self.view addSubview:self.calloutView];
    
    //dealloc too
    
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setUpMapView) name:@"LocationReady" object:nil];
}

- (void)registerForNotifications {
    
    //remove before adding
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"pictureAdded" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshMapView) name:@"pictureAdded" object:nil];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

//from pic vc, after picture is chosen

- (void)refreshMapView {

    self.arrayOfPins = @[];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    self.annType = annImage;
    
    [self setAnnotations];

}

//from self, after pin color is chosen

- (void)refreshMap {
    
    self.arrayOfPins = @[];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    self.annType = pinColor;
    
    [self setAnnotations];
}

- (void)setUpMapView {
    
    /*
    
    if (self.currentLocation) {
        
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 75)];
        self.mapView.delegate = self;
        [self.mapView setMapType:MKMapTypeHybrid];
        self.currentMapType = MKMapTypeHybrid;
        
        MKCoordinateRegion mapRegion;
        
        mapRegion.center = *(_currentLocation);
        mapRegion.span.latitudeDelta = 0.025;
        mapRegion.span.longitudeDelta = 0.025;
        
        [self.mapView setRegion:mapRegion animated:YES];
        
        [self.view addSubview:self.mapView];
        [self.view sendSubviewToBack:self.mapView];
    }
     
     */
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,
    self.view.frame.size.height - 75)];
    self.mapView.delegate = self;
    [self.mapView setMapType:MKMapTypeHybrid];
    self.currentMapType = MKMapTypeHybrid;
        
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    
    UITapGestureRecognizer *pressRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapPressGesture:)];
    [self.mapView addGestureRecognizer:pressRecognizer];
}

- (void)setUpNavigationToolBar {
    
    UIColor *tintColor = [UIColor whiteColor];
    
    self.navToolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 75)];
    self.navToolBar.barTintColor = [UIColor blackColor];
    [self.view addSubview:self.navToolBar];
    
    UIImage *pencil = [UIImage imageNamed:@"pencil"];
    UIImage *question = [UIImage imageNamed:@"question"];
    UIImage *search = [UIImage imageNamed:@"search"];
    UIImage *archives = [UIImage imageNamed:@"archives"];
    
    NSMutableArray *navItems = [[NSMutableArray alloc] initWithCapacity:3];
    
    UIBarButtonItem *flexItem0 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [navItems addObject:flexItem0];
    
    UIBarButtonItem *pinColor = [[UIBarButtonItem alloc]initWithImage:pencil style:UIBarButtonItemStylePlain target:self action:@selector(changePinColor)];
    pinColor.tintColor = tintColor;
    [navItems addObject:pinColor];
    
    UIBarButtonItem *flexItem1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [navItems addObject:flexItem1];
    
    UIBarButtonItem *questionButton = [[UIBarButtonItem alloc]initWithImage:question style:UIBarButtonItemStylePlain target:self action:@selector(onboarding)];
    questionButton.tintColor = tintColor;
    [navItems addObject:questionButton];
    
    UIBarButtonItem *flexItem2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [navItems addObject:flexItem2];
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc]initWithImage:search style:UIBarButtonItemStylePlain target:self action:@selector(popSearchBar)];
    searchButton.tintColor = tintColor;
    [navItems addObject:searchButton];
    
    UIBarButtonItem *flexItem3 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [navItems addObject:flexItem3];
    
    UIBarButtonItem *archiveButton = [[UIBarButtonItem alloc]initWithImage:archives style:UIBarButtonItemStylePlain target:self action:@selector(archivesController)];
    archiveButton.tintColor = tintColor;
    [navItems addObject:archiveButton];
    
    UIBarButtonItem *flexItem4 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [navItems addObject:flexItem4];
    
    [self.navToolBar setItems:navItems];
}

- (void)setUpToolBar {
    
    UIColor *tintColor = [UIColor whiteColor];
    
    self.toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 75, self.view.frame.size.width, 75)];
    self.toolBar.barTintColor = [UIColor blackColor];
    [self.view addSubview:self.toolBar];
    
    UIImage *map = [UIImage imageNamed:@"map"];
    UIImage *boom = [UIImage imageNamed:@"boom"];
    UIImage *zoom = [UIImage imageNamed:@"zoomOut"];
    UIImage *photo = [UIImage imageNamed:@"Photo"];
    
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:3];
    
    UIBarButtonItem *flexItem0 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [buttons addObject:flexItem0];
    
    UIBarButtonItem *mapType = [[UIBarButtonItem alloc]initWithImage:map style:UIBarButtonItemStylePlain target:self action:@selector(mapType)];
    mapType.tintColor = tintColor;
    [buttons addObject:mapType];
    
    UIBarButtonItem *flexItem1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [buttons addObject:flexItem1];
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc]initWithImage:boom style:UIBarButtonItemStylePlain target:self action:@selector(clearAll)];
    clearButton.tintColor = tintColor;
    [buttons addObject:clearButton];
    
    UIBarButtonItem *flexItem2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [buttons addObject:flexItem2];
    
    UIBarButtonItem *zoomOut = [[UIBarButtonItem alloc]initWithImage:zoom style:UIBarButtonItemStylePlain target:self action:@selector(zoomOut)];
    zoomOut.tintColor = tintColor;
    [buttons addObject:zoomOut];
    
    UIBarButtonItem *flexItem3 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [buttons addObject:flexItem3];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]initWithImage:photo style:UIBarButtonItemStylePlain target:self action:@selector(saveSnapshot)];
    shareButton.tintColor = tintColor;
    [buttons addObject:shareButton];
    
    UIBarButtonItem *flexItem4 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [buttons addObject:flexItem4];
    
    [self.toolBar setItems:buttons];
}

- (void)resetPinTint:(UIColor *)color {
    
    //clears image data out
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    self.pinTintColor = color;
    [self refreshMap];
}

- (void)changePinColor {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Pin Color" message:@"Pick a color!" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Red" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (self.annType == annImage) {
            
            [self resetPinTint:[UIColor redColor]];
        }
        
        else {
            
            self.pinTintColor = [UIColor redColor];
            for (MKPinAnnotationView *pin in self.arrayOfPins) {
                [self.mapView removeAnnotation:pin.annotation];
                
                pin.pinTintColor = [UIColor redColor];
                [self.mapView addAnnotation:pin.annotation];
            }
        }
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Green" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (self.annType == annImage) {
            
            [self resetPinTint:[UIColor greenColor]];
        }
        
        else {
            
            self.pinTintColor = [UIColor greenColor];
            for (MKPinAnnotationView *pin in self.arrayOfPins) {
                [self.mapView removeAnnotation:pin.annotation];
                
                pin.pinTintColor = [UIColor greenColor];
                [self.mapView addAnnotation:pin.annotation];
            }
        }
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Blue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (self.annType == annImage) {
            
            [self resetPinTint:[UIColor blueColor]];
        }
        
        else {
            
            self.pinTintColor = [UIColor blueColor];
            for (MKPinAnnotationView *pin in self.arrayOfPins) {
                [self.mapView removeAnnotation:pin.annotation];
                
                pin.pinTintColor = [UIColor blueColor];
                [self.mapView addAnnotation:pin.annotation];
            }
        }
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Custom" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //pop out collection view with custom color here!
        
        if (self.collectionContainerView.frame.origin.x < 0) {
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.collectionContainerView.hidden = NO;
            
            self.collectionContainerView.center = CGPointMake(self.collectionContainerView.center.x + 250, self.collectionContainerView.center.y);
            
        }];
        }
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Image" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        PictureChoiceCollectionViewController *pvc = [PictureChoiceCollectionViewController new];

        [self presentViewController:pvc animated:YES completion:nil];
        
        //dispatch_async(dispatch_get_main_queue(), ^{});
        //CFRunLoopWakeUp(CFRunLoopGetCurrent());
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)archivesController {
    
    SnapshotCollectionView *snapshotView = [SnapshotCollectionView new];
    [self.navigationController pushViewController:snapshotView animated:YES];
}

- (void)onboarding {
    
    InstructionsViewController *instructions = [InstructionsViewController new];
    [self presentViewController:instructions animated:YES completion:nil];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [self.searchBarView.searchBar becomeFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    [self.searchBarView.searchBar resignFirstResponder];
}

- (void)mapType {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Map Type" message:@"Choose Style" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Hybrid" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.mapView setMapType:MKMapTypeHybrid];
        self.currentMapType = MKMapTypeHybrid;
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Satellite" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.mapView setMapType:MKMapTypeSatellite];
        self.currentMapType = MKMapTypeSatellite;
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Standard" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.mapView setMapType:MKMapTypeStandard];
        self.currentMapType = MKMapTypeStandard;
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

- (void)setUpSearchBar {
    
    self.searchBarView = [[SearchBarView alloc] initWithFrame:CGRectMake(0, -80, self.view.frame.size.width, 80)];
    [self.view addSubview:self.searchBarView];
    
    [self.searchBarView.button addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)popSearchBar {
    
    if (self.searchBarView.frame.origin.y < 75) {
        
        [self popSearchBar:self.searchBarView distance:self.searchBarView.frame.size.height + 75];
        [self.searchBarView.searchBar becomeFirstResponder];
        
    }
    
    else {
        
        [self popSearchBarBack:self.searchBarView distance:self.searchBarView.frame.size.height + 75];
        [self.searchBarView.searchBar resignFirstResponder];
    }
}

- (void)popSearchBar:(UIView *)view distance:(float)distance {
    
    [UIView animateWithDuration:0.5 animations:^{
        
        view.center = CGPointMake(view.center.x, view.center.y + distance);
    }];
}

- (void)popSearchBarBack:(UIView *)view distance:(float)distance {
    
    [UIView animateWithDuration:0.5 animations:^{
        
        view.center = CGPointMake(view.center.x, view.center.y - distance);
    }];
}

//Adds pin when tapped

- (void)handleTapPressGesture:(UIGestureRecognizer *)sender {
    
    CGPoint point = [sender locationInView:self.mapView];
    CLLocationCoordinate2D locCoord = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    
    MapAnnotation *dropPin = [[MapAnnotation alloc] initWithLocation:locCoord];
    
    NSString *latitude = [NSString stringWithFormat:@"%f", dropPin.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", dropPin.coordinate.longitude];
    
    [[LocationController sharedInstance] addLocationWithLatitude:latitude longitude:longitude];
    
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:dropPin reuseIdentifier:[NSString stringWithFormat:@"pin %lu",(unsigned long)self.arrayOfPins.count]];
    self.arrayOfPins = [self.arrayOfPins arrayByAddingObject:pin];
    
    [self.mapView addAnnotation:dropPin];
    [self playClongSound];
}

- (void)playClongSound {
    
    NSURL *urlForClong = [[NSBundle mainBundle] URLForResource:@"clong-1" withExtension:@"mp3"];
    
    [self.soundController playAudioFileAtURL:urlForClong];
}

#pragma mark - adding annotations from core data

- (void)setAnnotations {
    
    NSArray *locations = [LocationController sharedInstance].locations;
    
    for (Location *location in locations) {
        double latitudeDouble = [location.latitude doubleValue];
        double longitudeDouble = [location.longitude doubleValue];
        
        CLLocationCoordinate2D locCoord = CLLocationCoordinate2DMake(latitudeDouble, longitudeDouble);
        
        MapAnnotation *dropPin = [[MapAnnotation alloc] initWithLocation:locCoord];
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:dropPin reuseIdentifier:[NSString stringWithFormat:@"pin %lu",(unsigned long)self.arrayOfPins.count]];
        self.arrayOfPins = [self.arrayOfPins arrayByAddingObject:pin];
        
        [self.mapView addAnnotation:dropPin];
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    self.calloutView.annotation = view.annotation;
    
    [self.calloutView setFrame:CGRectMake(view.center.x, view.center.y, 80, 100)];
    
    [self.calloutView.removeButton addTarget:self action:@selector(removeLocation) forControlEvents:UIControlEventTouchUpInside];
    self.selectedAnnotation = view.annotation;
    [self.calloutView setHidden:NO];
}

- (void)setUpDismissView {
    
    self.dismissView = [[DismissView alloc]initWithFrame:CGRectMake(80, 170, self.view.frame.size.width - 160, 70)];
    [self.dismissView.dismissButton addTarget:self action:@selector(dismissTableView) forControlEvents:UIControlEventTouchUpInside];
    [self.dismissView setHidden:YES];
    [self.view addSubview:self.dismissView];
}

- (void)dismissTableView {
    
    [self.tableView removeFromSuperview];
    [self.dismissView setHidden:YES];
}

- (void)search {
    
    NSString *searchText = self.searchBarView.searchBar.text;
    
    if ([searchText isEqual: @""]) {
        return;
    }
    
    else {
        
        MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
        [searchRequest setNaturalLanguageQuery:[NSString stringWithFormat:@"%@", searchText]];
        
        MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
        [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
            if (!error) {
                [self.searchBarView.searchBar resignFirstResponder];
                self.resultPlaces = [response mapItems];
                [self setUpTableView];
                [self.dismissView setHidden:NO];
                [self.tableView reloadData];
            } else {
                [self errorMessage];
            }
        }];
    }
}

- (void)errorMessage {
    
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"No Results" message:@"Search Again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [errorAlert show];
}

#pragma CollectionView for pin colors

- (void)popBack {
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.collectionContainerView.hidden = YES;
        
        if (self.collectionContainerView.frame.origin.x >= 0) {
            
            self.collectionContainerView.center = CGPointMake(self.collectionContainerView.center.x - 250, self.collectionContainerView.center.y);
        }
    }];
}

#pragma Pop out collection view

- (void)setUpCollectionView {
    
    self.collectionContainerView = [[UIView alloc]initWithFrame:CGRectMake(-250, self.view.frame.size.height / 2 - 75, 250, 300)];
    self.collectionContainerView.layer.cornerRadius = 15;
    self.collectionContainerView.backgroundColor = [UIColor clearColor];
    self.collectionContainerView.layer.borderColor = [[UIColor blackColor]CGColor];
    self.collectionContainerView.layer.borderWidth = 2;
    self.collectionContainerView.layer.masksToBounds = YES;
    self.collectionContainerView.hidden = NO;
    [self.view addSubview:self.collectionContainerView];
    
//    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.collectionContainerView.bounds];
//    imageView.layer.masksToBounds = YES;
//    imageView.image = [UIImage imageNamed:@"popOutBackgroundMS"];
//    [self.collectionContainerView addSubview:imageView];
    
    self.collectionContainerView.backgroundColor = [UIColor blackColor];
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(self.collectionContainerView.frame.size.width / 2 - 25, self.collectionContainerView.frame.size.height - 75, 50, 50)];

    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    backButton.layer.cornerRadius = 25;
    backButton.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    backButton.layer.borderWidth = 2;
    backButton.layer.masksToBounds = YES;
    [backButton setBackgroundImage:[UIImage imageNamed:@"PopButtonBackground"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    [self.collectionContainerView addSubview:backButton];
    
    //establish layout
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.collectionContainerView.frame.size.width, 250) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self registerCollectionView:self.collectionView];
    [self.collectionContainerView addSubview:self.collectionView];
}

- (void)registerCollectionView:(UICollectionView *)collectionView {
    
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if (indexPath.row < 8 && indexPath.row != 3) {
        
        [self configureCell:cell atIndexPath:indexPath andColor:[UIColor blackColor]];
    }
    
    if (indexPath.row == 3) {
        
        [self configureCell:cell atIndexPath:indexPath andColor:[UIColor whiteColor]];
    }
    
    if (indexPath.row == 8) {
        
        cell.layer.cornerRadius = cell.frame.size.height / 2;
        cell.layer.borderColor = [[UIColor blackColor]CGColor];
        cell.layer.masksToBounds = YES;
        cell.layer.borderWidth = 1;
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:cell.bounds];
        imageView.image = [UIImage imageNamed:@"randomButton"];
        imageView.layer.masksToBounds = YES;
        [cell addSubview:imageView];
    }
    
    return cell;
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath andColor:(UIColor *)borderColor {
    
    cell.layer.cornerRadius = cell.frame.size.height / 2;
    cell.layer.borderColor = [borderColor CGColor];
    cell.layer.borderWidth = 1;
    cell.backgroundColor = [self customColors][indexPath.row];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self customColors].count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.annType == annImage) {
        
        UIColor *colorToChangeTo = [self customColors][indexPath.row];
        
        [self resetPinTint:colorToChangeTo];
    }
    
    else {
    
    self.pinTintColor = [self customColors][indexPath.row];
    
    for (MKPinAnnotationView *pin in self.arrayOfPins) {
        [self.mapView removeAnnotation:pin.annotation];
        pin.pinTintColor = self.pinTintColor;
        [self.mapView addAnnotation:pin.annotation];
    }
    }
}

- (NSArray *)customColors {
    
    //change to better colors eventually
    
    UIColor *yellowColor = [UIColor yellowColor];
    UIColor *orangeColor = [UIColor orangeColor];
    UIColor *cyanColor = [UIColor cyanColor];
    UIColor *blackColor = [UIColor blackColor];
    UIColor *grayColor = [UIColor grayColor];
    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *purpleColor = [UIColor purpleColor];
    UIColor *brownColor = [UIColor brownColor];
    
    UIColor *randomColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
    
    NSArray *colorArray = @[yellowColor, orangeColor, cyanColor, blackColor, grayColor, whiteColor, purpleColor, brownColor, randomColor];
    
    return colorArray;
}

#pragma TableView for MKMapItems (locations)


- (void)setUpTableView {
    
    [self.tableView removeFromSuperview];
    
    CGFloat tableViewHeight;
    
    if (self.resultPlaces.count < 5) {
        tableViewHeight = 80 * self.resultPlaces.count;
    }
    else
    {
        tableViewHeight = 80 * 4;
    }
    
    if (IS_IPHONE_4) {
        
        if (self.resultPlaces.count < 3) {
            tableViewHeight = 80 * self.resultPlaces.count;
        }
        else {
            tableViewHeight = 80 * 2;
        }
    }

    self.tableView.backgroundColor = [UIColor blackColor];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(80, 240, self.view.frame.size.width - 160, tableViewHeight)];
    self.tableView.layer.cornerRadius = 10;
    self.tableView.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.tableView.layer.borderWidth = 1;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; 
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self registerTableView:self.tableView];
    
    [self.view addSubview:self.tableView];
}

- (void)registerTableView:(UITableView *)tableView {
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
    MKMapItem *item = self.resultPlaces[indexPath.row];
    
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.text = item.name;
    cell.textLabel.font = [UIFont fontWithName:@"Chalkduster" size:16];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.text = item.placemark.title;
    cell.detailTextLabel.font = [UIFont fontWithName:@"Chalkduster" size:12];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.resultPlaces.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MKMapItem *zoomItem = self.resultPlaces[indexPath.row];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance([zoomItem placemark].coordinate, 0.1*METERS_PER_MILE, 0.1*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80;
}


- (void)removeLocation {
    
    NSString *lat = [NSString stringWithFormat:@"%f", [self.selectedAnnotation coordinate].latitude];
    NSString *lon = [NSString stringWithFormat:@"%f", [self.selectedAnnotation coordinate].longitude];
    
    for (Location *location in [LocationController sharedInstance].locations) {
        
        if ([location.latitude isEqualToString:lat] && [location.longitude isEqualToString:lon]) {
            
            [[LocationController sharedInstance]removeLocation:location];
            
            [self.mapView removeAnnotation:self.selectedAnnotation];
        }
    }
    
    [self.calloutView setHidden:YES];
    [self playWaterSplashSound];
}



- (void)clearAll {
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Delete" message:@"Delete All Annotations?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];
}

#pragma mark - clears all

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        for (Location *location in [LocationController sharedInstance].locations) {
            
            [[LocationController sharedInstance] removeLocation:location];
            
        }
        
        self.arrayOfPins = @[];
        
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self playBombSound];
    }
}

//TODO: Move methods to sound controller?

- (void)playWaterSplashSound {
    
    NSURL *urlForWater = [[NSBundle mainBundle] URLForResource:@"water-splash-3" withExtension:@"mp3"];
    
    [self.soundController playAudioFileAtURL:urlForWater];
}

- (void)playBombSound {
    
    NSURL *urlForBomb = [[NSBundle mainBundle] URLForResource:@"bomb" withExtension:@"mp3"];
    
    [self.soundController playAudioFileAtURL:urlForBomb];
}

- (void)squareMapView {
    
    [UIView animateWithDuration:0 animations:^{
        
        for (UIView *view in self.view.subviews) {
            
            if (view != self.mapView) {
                
                view.alpha = 0;
            }
        }
        
        float yCoord = (self.view.frame.size.height - self.mapView.frame.size.width) / 2;
        float mapDimensions = self.mapView.frame.size.width;
        
        self.mapView.frame = CGRectMake(0, yCoord, mapDimensions ,mapDimensions);
    }];
    
    [UIView animateWithDuration:0 animations:^{
        
        
    } completion:^(BOOL finished) {
        
        [self performSelector:@selector(unsquareMapView) withObject:nil afterDelay:1];
    }];
}

- (void)unsquareMapView {
    
    [UIView animateWithDuration:0 animations:^{
        
        for (UIView *view in self.view.subviews) {
            
            if (view != self.mapView) {
                
                view.alpha = 1;
            }
        }
        
        self.mapView.frame = CGRectMake(0, 0, self.view.frame.size.width,
                                        self.view.frame.size.height - 75);
        
    }];
}

- (void)snapScreenshot:(void (^)(UIImage *image))completion {
    
    //code to snapshot screen since mksnapshotter doesn't get pictures well
    
    [self squareMapView];
    
    CGRect rect = [self.mapView bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.mapView.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    completion(image);
}


//doesn't snapshot images well, so this is called for pins only

- (void)snapshotMapImage:(void (^)(UIImage *image))completion {
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    
    options.region = self.mapView.region;
    options.mapType = self.currentMapType;
    options.showsPointsOfInterest = YES;
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        
        UIImage *image = snapshot.image;
        
        CGRect finalImageRect = CGRectMake(0, 0, image.size.width, image.size.height);
        
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@""];

        pin.pinTintColor = self.pinTintColor;
        UIImage *pinImage = pin.image;
        
        //create final image
        
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        
        [image drawAtPoint:CGPointMake(0, 0)];
        
        //loop through annotations
        
        for (id<MKAnnotation>annotation in self.mapView.annotations)
        {
            CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
            if (CGRectContainsPoint(finalImageRect, point)) // this is too conservative, but you get the idea
            {
                CGPoint pinCenterOffset = pin.centerOffset;
                point.x -= pin.bounds.size.width / 2.0;
                point.y -= pin.bounds.size.height / 2.0;
                point.x += pinCenterOffset.x;
                point.y += pinCenterOffset.y;
                
                [pinImage drawAtPoint:point];
            }
        }
        // the final image
        
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        completion(finalImage);
    }];
}


- (void)zoomOut {
    
    MKMapRect zoomRect = MKMapRectNull;
    
    for (MapAnnotation *annotation in self.mapView.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    
    [self.mapView setVisibleMapRect:zoomRect animated:YES];
}

- (void)saveSnapshot {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Snapshot saved!" message:@"Now add a caption" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Add caption";
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Save caption" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *caption = alertController.textFields[0].text;
        
        if (self.annType == pinColor) {
        
        [self snapshotMapImage:^(UIImage *image) {
            
            [[SnapshotController sharedInstance] addSnapshotWithImage:image caption:caption];
        }];
            
        } else if (self.annType == annImage) {
            
        [self snapScreenshot:^(UIImage *image) {
            
            [[SnapshotController sharedInstance] addSnapshotWithImage:image caption:caption];
        }];
        }
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    [self playSnapSound];
}

- (void)playSnapSound {
    
    NSURL *urlForSnap = [[NSBundle mainBundle] URLForResource:@"snapSound" withExtension:@"mp3"];
    
    [self.soundController playAudioFileAtURL:urlForSnap];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if (self.annType == pinColor) {
        
        self.pinAnnotation = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"pinAnnotation"];
        [self defaultPin];
        self.pinAnnotation.animatesDrop = YES;
        
        return self.pinAnnotation;
    }
    
    else if (self.annType == annImage) {
        
        MKAnnotationView *annView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"identifier"];
        
        annView.annotation = annotation;
        [self withCustomImage:annView];
        
        return annView;
    }
    
    else { //move to own function so I don't have to write it twice
        
        self.pinAnnotation = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"pinAnnotation"];
        [self defaultPin];
        self.pinAnnotation.animatesDrop = YES;
        
        return self.pinAnnotation;
    }
}

- (BOOL)annotationDataExists {
    
    return [self imagePath] != nil;
}

- (NSString *)imagePath {
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"annotationImageData"];
}

- (void)defaultPin {
    
    self.pinAnnotation.pinTintColor = self.pinTintColor;
}

- (void)withCustomImage:(MKAnnotationView *)annotationView {
    
    if ([self annotationDataExists] == YES) {
        
        UIImage *imageToResize = [UIImage imageWithData:[NSData dataWithContentsOfFile:[self imagePath]]];
        CGSize size = CGSizeMake(150, 150);
        UIGraphicsBeginImageContext(size);
        [imageToResize drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //add image view to make round
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(-20, -20, 130, 130)];
        imageView.image = resizedImage;
        imageView.layer.cornerRadius = imageView.frame.size.height / 2;
        imageView.layer.masksToBounds = YES;
        
        [annotationView addSubview:imageView];
    }
}

//TODO : for when user location feature complete

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    //
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    //
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
