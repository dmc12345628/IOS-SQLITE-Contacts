//
//  AppDelegate.h
//  Contacts
//
//  Created by Jesus Daniel Medina Cruz on 19/01/2018.
//  Copyright © 2018 Jesus Daniel Medina Cruz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

