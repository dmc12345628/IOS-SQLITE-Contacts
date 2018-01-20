//
//  ViewController.m
//  Contacts
//
//  Created by Jesus Daniel Medina Cruz on 19/01/2018.
//  Copyright © 2018 Jesus Daniel Medina Cruz. All rights reserved.
//


#import "ViewController.h"

@interface ViewController ()

- (void) setTextWithName:(NSString *) name Address:(NSString *)address Phone:(NSString *) phone Status: (NSString *) status;
- (void) updateContact;

@end

@implementation ViewController

int actualUserId = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    _databasePath = [[NSString alloc] initWithFormat:@"%@%@", docsDir, @"/contacts.db"];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: _databasePath] == NO) {
        const char *dbpath = [_databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS contacts (\
            id INTEGER PRIMARY KEY AUTOINCREMENT, \
            name TEXT UNIQUE, \
            address TEXT, \
            phone TEXT)";
            if (sqlite3_exec(_contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                _lblStatus.text = @"Failed to create table";
            }
            sqlite3_close(_contactDB);
        } else
            _lblStatus.text = @"Failed to open/create table";
    }
    NSLog(@"Path %@", docsDir);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)saveContact:(id)sender {
    sqlite3_stmt *statement = nil;
    const char *dbPath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbPath, &_contactDB) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO CONTACTS \
                               (name, address, phone) \
                               VALUES (\"%@\", \"%@\", \"%@\")",
                               _txfName.text, _txfAddress.text, _txfPhone.text];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_contactDB, insert_stmt, -1, &statement, NULL);
        int SQLITE_CODE = sqlite3_step(statement);
        if (SQLITE_CODE == SQLITE_CONSTRAINT) {
            [self updateContact];
        } else if (SQLITE_CODE == SQLITE_DONE) {
            [self setTextWithName:@"" Address:@"" Phone:@"" Status:@"Contact Added"];
            sqlite3_finalize(statement);
            sqlite3_close(_contactDB);
        } else {
            _lblStatus.text = @"Failed to add contact";
            sqlite3_finalize(statement);
            sqlite3_close(_contactDB);
        }
    }
}

- (void) updateContact {
    sqlite3_stmt *statement = nil;
    const char *dbPath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbPath, &_contactDB) == SQLITE_OK) {
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE CONTACTS SET address = \"%@\", phone = \"%@\" WHERE id = '%d'",
                               _txfAddress.text, _txfPhone.text, actualUserId];
        
        const char *update_stmt = [updateSQL UTF8String];
        sqlite3_prepare_v2(_contactDB, update_stmt, -1, &statement, NULL);
        int SQLITE_CODE = sqlite3_step(statement);
        if (SQLITE_CODE == SQLITE_DONE) {
            _lblStatus.text = @"Contact Updated";
            _btnRemove.enabled = YES;
        } else
            _lblStatus.text = @"Failed to update contact";
        
        sqlite3_finalize(statement);
        sqlite3_close(_contactDB);
    }
}

- (IBAction)findContact:(id)sender {
    const char *dbPath = [_databasePath UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open(dbPath, &_contactDB) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT id, address, phone FROM contacts WHERE name = \"%@\"",
                              _txfName.text];
        
        const char *query_stmt = [querySQL UTF8String];
        
        int prepare = sqlite3_prepare_v2(_contactDB, query_stmt, -1, &statement, NULL);
        if (prepare == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                actualUserId = sqlite3_column_int(statement, 0);
                NSString *addressField = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                NSString *phoneField = [[NSString alloc]
                                        initWithUTF8String:(const char *)
                                        sqlite3_column_text(statement, 2)];
                
                [self setTextWithName:_txfName.text Address:addressField Phone:phoneField Status:@"Match Found"];
                _btnRemove.enabled = YES;
            } else {
                actualUserId = 0;
                _btnRemove.enabled = NO;
                
                [self setTextWithName:_txfName.text Address:@"" Phone:@"" Status:@"Match Not Found"];
            }
            sqlite3_finalize(statement);
        } else
            _lblStatus.text = [@(prepare) stringValue];
        
        sqlite3_close(_contactDB);
    }
}

- (IBAction)removeContact:(id)sender {
    sqlite3_stmt *statement = nil;
    const char *dbPath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbPath, &_contactDB) == SQLITE_OK) {
        NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM CONTACTS \
                               WHERE id = %d",
                               actualUserId];
        
        const char *delete_stmt = [deleteSQL UTF8String];
        sqlite3_prepare_v2(_contactDB, delete_stmt, -1, &statement, NULL);
        int SQLITE_CODE = sqlite3_step(statement);
        if (SQLITE_CODE == SQLITE_DONE) {
            [self setTextWithName:@"" Address:@"" Phone:@"" Status:@"Contact Deleted"];
        } else
            _lblStatus.text = @"Failed to delete contact";
        
        sqlite3_finalize(statement);
        sqlite3_close(_contactDB);
    }
}

- (void) setTextWithName:(NSString *)name Address:(NSString *)address Phone:(NSString *)phone Status:(NSString *) status {
    _txfName.text = name;
    _txfAddress.text = address;
    _txfPhone.text = phone;
    _lblStatus.text = status;
}

- (IBAction)textFieldReturn:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)disableRemove:(id)sender {
    _btnRemove.enabled = NO;
}

@end
