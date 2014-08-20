//
//  Coord2D.h
//  OCOLO
//
//  Created by masaya_fuyuhiro on 2013/11/20.
//  Copyright (c) 2014 LOCKON CO.,LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface OCLCoord : NSObject

@property (nonatomic) NSString* stringGeoName;
@property (nonatomic) double latitude,longitude;

-(CLLocationCoordinate2D) getCoord;
-(OCLCoord*) initWithCLCoord:(CLLocationCoordinate2D)CLCoord;
-(NSString*) getPositionName;
-(NSString*) getDistanceWithUnit:(OCLCoord*)coord;

typedef void (^Coord2DNameHandler)(NSString *name, NSError *error);

-(void) getPositionNameWithHandler:(Coord2DNameHandler) handler;

@end
