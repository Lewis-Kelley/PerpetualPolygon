//
//  Score+CoreDataProperties.h
//  PerpetualPolygon
//
//  Created by Lewis on 8/16/16.
//  Copyright © 2016 Lewis. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Score.h"

NS_ASSUME_NONNULL_BEGIN

@interface Score (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *score;
@property (nullable, nonatomic, retain) NSNumber *difficulty;

@end

NS_ASSUME_NONNULL_END
