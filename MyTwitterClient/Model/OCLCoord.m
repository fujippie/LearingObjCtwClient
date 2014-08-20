//
//  Coord2D.m
//  OCOLO
//
//  Created by masaya_fuyuhiro on 2013/11/20.
//  Copyright (c) 2014 LOCKON CO.,LTD. All rights reserved.
//

#import "OCLCoord.h"
#import <MapKit/MapKit.h>

@implementation OCLCoord

@synthesize latitude;
@synthesize longitude;

-(CLLocationCoordinate2D) getCoord
{
    CLLocationCoordinate2D ret;
    
    ret.longitude = longitude;
    ret.latitude = latitude;
    
    return ret;
}

-(OCLCoord*) initWithCLCoord:(CLLocationCoordinate2D)CLCoord
{
    self = [super init];
    latitude = CLCoord.latitude;
    longitude = CLCoord.longitude;
    
    return self;
}

-(NSString*) getDistanceWithUnit:(OCLCoord*)coord
{
    NSString* ret = nil;
    CLLocation* mine = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    CLLocation* dest = [[CLLocation alloc]initWithLatitude:coord.latitude longitude:coord.longitude];
    
    CLLocationDistance distance = [mine distanceFromLocation:dest];
    
    
    if(distance >= 1000){
        ret = [NSString stringWithFormat:@"%dkm",(int)(distance/1000)];
    }
    else{
        ret = [NSString stringWithFormat:@"%dm",(int)(distance)];
    }
    return ret;
}


-(void) getPositionNameWithHandler:(Coord2DNameHandler) handler;
{
    
    if(_stringGeoName!=nil)
    {
        handler(_stringGeoName,nil);
        return;
    }
    
    CLLocation *loc;
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    
    loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    
    [geoCoder reverseGeocodeLocation:loc completionHandler:^(NSArray* placemarks,NSError* error)
     {
         if(error){
             handler(nil,error);
         }
         else{
             CLPlacemark* placemark = placemarks[0];
             
             handler(placemark.subLocality,error);
             _stringGeoName = placemark.subLocality;
         }
     }];
}

-(NSString*) getPositionName
{
    __block NSString* ret = @"";
    CLLocation *loc;
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    
    loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    
    [geoCoder reverseGeocodeLocation:loc completionHandler:^(NSArray* placemarks,NSError* error)
     {
         if(error){
             return;
         }
         
         CLPlacemark* placemark = placemarks[0];
         ret = placemark.subLocality;
     }];
    
    return ret;
}
@end

