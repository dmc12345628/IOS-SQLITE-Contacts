//
//  ViewController.h
//  Contacts
//
//  Created by Jesus Daniel Medina Cruz on 19/01/2018.
//  Copyright © 2018 Jesus Daniel Medina Cruz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *contactDB;

// Outlets
@property (weak, nonatomic) IBOutlet UITextField *txfName;
@property (weak, nonatomic) IBOutlet UITextField *txfAddress;
@property (weak, nonatomic) IBOutlet UITextField *txfPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnRemove;


// Actions
- (IBAction)saveContact:(id)sender;
- (IBAction)findContact:(id)sender;
- (IBAction)removeContact:(id)sender;
- (IBAction)disableRemove:(id)sender;

@end

