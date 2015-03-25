//
//  ViewController.m
//  FMDBDemo
//
//  Created by Suraj on 14/07/14.
//  Copyright (c) 2014 Suraj. All rights reserved.
//

#import "ViewController.h"

#define NUMBERS_ONLY @"1234567890"
#define K_DB_NAME @"StudentsDB.sqlite"
#define K_DB_TABLE_STUDENTS @"STUDENTS"
#define K_TABLE_STUDENTS_COLUMN_NAME @"NAME"
#define K_TABLE_STUDENTS_COLUMN_AGE @"AGE"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    arrayForName = [[NSMutableArray alloc] init];
    arrayForage = [[NSMutableArray alloc] init];
    
    [self createDatabase:K_DB_NAME];
    [self createTableInDB:K_DB_TABLE_STUDENTS :[NSArray arrayWithObjects:K_TABLE_STUDENTS_COLUMN_NAME, K_TABLE_STUDENTS_COLUMN_AGE, nil]];
    
    [self fetchDataFromTable:K_DB_TABLE_STUDENTS];
    [tableViewForDB reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addToDB:(id)sender {
    if ([txtFieldForName isEditing])
        [txtFieldForName resignFirstResponder];
    
    if ([txtFieldForAge isEditing])
        [txtFieldForAge resignFirstResponder];
    
    if ([txtFieldForName.text length] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Please fill in the name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    if ([txtFieldForAge.text length] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Please fill in the age." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    // Insert Data to Database Table
    [self insertDataToDBTable:K_DB_TABLE_STUDENTS];
    [txtFieldForName setText:@""];
    [txtFieldForAge setText:@""];
    [arrayForName removeAllObjects];
    [arrayForage removeAllObjects];
    
    // Fetch Data from Database Table
    [self fetchDataFromTable:K_DB_TABLE_STUDENTS];
    [tableViewForDB reloadData];
    
    // Scroll UITableView to Last row (Bottom)
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[arrayForName count]-1 inSection:0];
    [tableViewForDB scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma UITextField Delegate Method
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    if (textField.tag == 2) {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS_ONLY] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    } else {
        NSCharacterSet *cs1 = [NSCharacterSet characterSetWithCharactersInString:NUMBERS_ONLY];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs1] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == txtFieldForName) {
        [txtFieldForAge becomeFirstResponder];
    } else if (textField == txtFieldForAge) {
        [txtFieldForAge resignFirstResponder];
    }
    
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayForName count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellidentifier = @"StudentsCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellidentifier];
    }
    cell.textLabel.text = [arrayForName objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[arrayForage objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete Data from Database Table
        if ([fmDatabase open]) {
            NSString *strSQLQueryToDeleteDataFromTable = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@'", K_DB_TABLE_STUDENTS, K_TABLE_STUDENTS_COLUMN_NAME, [arrayForName objectAtIndex:indexPath.row], K_TABLE_STUDENTS_COLUMN_AGE, [NSString stringWithFormat:@"%@",[arrayForage objectAtIndex:indexPath.row]]];
            if (![fmDatabase executeUpdate:strSQLQueryToDeleteDataFromTable]) {
                NSLog(@"Error in deleting data from Table in Database");
            } else {
                NSLog(@"Success in deleting data from Table in Database");
            }
            [arrayForName removeObjectAtIndex:indexPath.row];
            [arrayForage removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            [fmDatabase close];
        } else {
            NSLog(@"Unable to open Database");
        }
    }
}

#pragma mark - Database Handling
+(NSString *)getDocumentDirectoryPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

-(void)createDatabase:(NSString *)strSQLiteDatabaseName {
    NSString *strDBPath = [[ViewController getDocumentDirectoryPath] stringByAppendingPathComponent:strSQLiteDatabaseName];
    fmDatabase = [FMDatabase databaseWithPath:strDBPath];
    NSLog(@"Database Path: %@",strDBPath);
}

-(void)createTableInDB:(NSString *)strTableName :(NSArray *)arrTableColumns {
    if ([fmDatabase open]) {
        NSString *strSQLQueryToCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (ID INTEGER PRIMARY KEY AUTOINCREMENT, '%@' TEXT, '%@' INTEGER)",strTableName, arrTableColumns[0], arrTableColumns[1]];
        if (![fmDatabase executeUpdate:strSQLQueryToCreateTable]) {
            NSLog(@"Error in creating Table in Database");
        } else {
            NSLog(@"Success in creating Table in Database");
        }
        [fmDatabase close];
    } else {
        NSLog(@"Unable to open Database");
    }
}

-(void)insertDataToDBTable:(NSString *)strTableName {
    if ([fmDatabase open]) {
        NSString *strSQLQueryToAddDataToTable = [NSString stringWithFormat:@"INSERT INTO '%@' ('%@','%@') VALUES ('%@','%@')", strTableName, K_TABLE_STUDENTS_COLUMN_NAME, K_TABLE_STUDENTS_COLUMN_AGE,txtFieldForName.text,txtFieldForAge.text];
        if(![fmDatabase executeUpdate:strSQLQueryToAddDataToTable]) {
            NSLog(@"Error in adding data to Table in Database");
        } else {
            NSLog(@"Success in adding data to Table in Database");
        }
        [fmDatabase close];
    } else {
        NSLog(@"Unable to open Database");
    }
}

- (void)fetchDataFromTable:(NSString *)strTableName {
    if ([fmDatabase open]) {
        NSString *strSQLQueryToGetDataFromTable = [NSString stringWithFormat:@"SELECT * FROM '%@'",strTableName];
        FMResultSet *fmResultSet = [fmDatabase executeQuery:strSQLQueryToGetDataFromTable];
        while ([fmResultSet next]) {
            NSString *strName = [fmResultSet stringForColumn:K_TABLE_STUDENTS_COLUMN_NAME];
            NSInteger age = [fmResultSet intForColumn:K_TABLE_STUDENTS_COLUMN_AGE];
            NSLog(@"STUDENT: %@ - %ld",strName,(long)age);
            
            [arrayForName addObject:strName];
            [arrayForage addObject:[NSNumber numberWithInt:age]];
        }
        [fmDatabase close];
    } else {
        NSLog(@"Unable to open Database");
    }
}

// Resign the UIKeyboard if user touches outside the UITextField
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if (![[touch view] isKindOfClass:[UITextField class]]) {
        [self.view endEditing:YES];
    }
    [super touchesBegan:touches withEvent:event];
}
@end
