//
//  ViewController.h
//  FMDBDemo
//
//  Created by Suraj on 14/07/14.
//  Copyright (c) 2014 Suraj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@interface ViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    __weak IBOutlet UITextField *txtFieldForName;
    __weak IBOutlet UITextField *txtFieldForAge;
    __weak IBOutlet UIButton *btnAdd;
    __weak IBOutlet UITableView *tableViewForDB;
    NSMutableArray *arrayForName;
    NSMutableArray *arrayForage;
    
    FMDatabase *fmDatabase;
}

- (IBAction)addToDB:(id)sender;

@end
