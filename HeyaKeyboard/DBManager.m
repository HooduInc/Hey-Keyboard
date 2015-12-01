//
//  DBManager.m
//  iCompliance
//
//  Created by Boudhayan Biswas on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "sqlite3.h"
#import "DBManager.h"
#import "DBDirectory.h"

#import "ModelMenu.h"
#import "ModelSubMenu.h"

#import "ModelPickListMenu.h"
#import "ModelPickListSubMenu.h"
//#import "ModelUserProfile.h"
//#import "ModelFevorite.h"
//#import "ModelGroup.h"
//#import "ModelGroupMembers.h"

@implementation DBManager

#pragma mark
#pragma mark Database Initialization
#pragma mark

+ (NSURL *)getSharedContainerURL
{
    NSString *appGroupName = @"group.V832NBX5Y5.com.hooduinc.HeyKeyboard";
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *containerURL = [fm containerURLForSecurityApplicationGroupIdentifier:appGroupName];
    return containerURL;
}

#pragma mark
#pragma mark Database Initialization
#pragma mark

+ (NSURL *)getDBURL
{
    NSURL *groupContainerURL = [self getSharedContainerURL];
    NSURL *dbUrl= [groupContainerURL URLByAppendingPathComponent:@"HeyDatabase.sqlite"];
    return dbUrl;
}

+ (NSString *)getDBPath
{
    NSString *dbPath = [[self getDBURL] absoluteString];
    return dbPath;
}



+ (FMDatabase *)getDatabase
{
    FMDatabase *database = [FMDatabase databaseWithPath:[DBManager getDBPath]];
    if([database open]) return database;
    else return nil;
}


//var theError: NSError?;
//let fm : NSFileManager = NSFileManager.defaultManager();
//
//var groupContainerURL: NSURL = fm.containerURLForSecurityApplicationGroupIdentifier(suiteName)!;
//
//var success: Bool = fm.createDirectoryAtURL(groupContainerURL, withIntermediateDirectories: true, attributes: nil, error: &theError)
//
//if (!success) {
//    NSLog("WRITE FAILED: %d",success);
//    NSLog("unable to create path %@",theError!);
//}
//
//else {
//    NSLog("CREATED SHARED DIR OK: %d", success);
//}
//
//return success;

#pragma mark
#pragma mark BOOL sharedDirExists
#pragma mark

+ (BOOL)sharedDirExists
{
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = YES;
    return [fm fileExistsAtPath:[[self getSharedContainerURL] absoluteString] isDirectory:&isDir];
}


#pragma mark - Search if database exists at that path else copy it there from application bundle

+ (void) checkAndCreateDatabase
{
	BOOL success;
    NSError *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSURL *copyURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:DATABASE_NAME];
    
    NSURL *toURL = [self getDBURL];

    success = [fileManager fileExistsAtPath:[toURL absoluteString]];
    if (success) return;
    
    success = [fileManager copyItemAtURL:copyURL toURL:toURL error:&error];
    if (!success)
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
}

+ (void) checkAndCreateDatabaseAtPath:(NSString *)databasePath
{
    BOOL success;
    NSError *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *copyURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:DATABASE_NAME];
    
    success = [fileManager fileExistsAtPath:databasePath];
    if (success) return;
    
    success = [fileManager copyItemAtPath:[copyURL absoluteString] toPath:databasePath error:&error];
    if (!success)
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    //[fileManager release];
}


#pragma mark
#pragma mark Menu
#pragma mark

+ (NSMutableArray*)fetchmenu:(int)startLimit noOfRows:(int)noOfRows
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        
        sqlite3 *database;
        NSURL *dbURL = [self getDBURL];
        NSLog(@"DBPath: %@", [[self getDBURL] absoluteString]);
        const char *dbPath = [[dbURL absoluteString] UTF8String];

        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM menulist ORDER BY menuOrder limit %d,%d",startLimit, noOfRows];
            
//            NSLog(@"Executed Menu Query with limits: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
               // NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
               
                    NSMutableDictionary *menuMsgDict = [[NSMutableDictionary alloc] init];
                    
                    [menuMsgDict setValue:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)] forKey:@"MenuId"];
                    [menuMsgDict setValue:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)] forKey:@"MenuName"];
                    [menuMsgDict setValue:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)] forKey:@"MenuOrder"];
                    [menuMsgDict setValue:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)] forKey:@"MenuColor"];
                    
                    [menuMsgDict setValue:@"" forKey:@"SubMenu"];
                    
                    [arr addObject:menuMsgDict];
                }
                sqlite3_finalize(querryStatement);
                
            }
            else {
//                NSLog(@"error while conversion....");
                NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
            }
            sqlite3_close(database);
        }
    }
    
    return arr;
}



+ (NSMutableArray*)fetchMenuForPageNo:(NSInteger)menuPageNo
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];

        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM menulist where menuPageNo=%ld ORDER BY menuOrder",(long)menuPageNo];
            
            //NSLog(@"Executed Menu Query: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                //NSLog(@"Executed successfully....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelMenu *obj = [[ModelMenu alloc] init];
                    
                    obj.strMenuId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    obj.strMenuName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)];
                    obj.strMenuOrder=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    obj.strMenuColor=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
                    obj.strMenuPageNo=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)];
                    obj.arrSubMenu=[DBManager fetchSubmenuWithmenuIdUpdated:obj.strMenuId];
                    [arr addObject:obj];
                }
                sqlite3_finalize(querryStatement);
                
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
    return arr;
}


+(void) updatemenuWithMenuId:(NSString*)strId withMenuTitle:(NSString*)menuText
{
    
    if([menuText containsString:@"'"])
        menuText= [menuText stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            if([menuText containsString:@"'"])
                menuText= [menuText stringByReplacingOccurrencesOfString:@"\'" withString:@"`"];
            
            NSString *stm = [NSString stringWithFormat:@"UPDATE menulist Set menuname ='%@'where  menuId ='%@'",menuText,strId];
            NSLog(@"Update Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"Updation Successful....");
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                //sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
                
                //if (sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK)
                NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
            }
            else
            {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
}

+(void) updatemenuWithMenuId:(NSString*)menuId withTableColoum:(NSString*)tableColoumName withColoumValue:(NSString*)tableColoumValue
{
    
    if([tableColoumValue containsString:@"'"])
        tableColoumValue= [tableColoumValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            
            NSString *stm = [NSString stringWithFormat:@"UPDATE menulist Set %@ ='%@' where  menuId ='%@'",tableColoumName,tableColoumValue,menuId];
            NSLog(@"Update Menu Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                if(sqlite3_step(querryStatement)!=SQLITE_DONE){
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_reset(querryStatement);
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
                /*if (sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK)
                 NSLog(@"SQL Error: %s",sqlite3_errmsg(database));*/
                
                NSLog(@"Updation Successful....");
            }
            else
            {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
}

+(BOOL) checkmenuWithMenuText:(NSString*)tableColoumValue withTableColoum:(NSString*)tableColoumName
{
    NSString *stm = [NSString stringWithFormat:@"SELECT * FROM menulist  where %@ ='%@'",tableColoumName,tableColoumValue];
    NSLog(@"Select Querystring: %@", stm);
    
    BOOL recordExist = [self recordExistOrNot:stm];
    NSLog(@"recordExist: %d",recordExist);
    
    if(recordExist)
        return true;
    else
        return false;
}

+(void) updateMenuOrderWithMenuId:(NSString*)menuId withMenuOrder:(NSString*)menuOrder
{
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            
            NSString *stm = [NSString stringWithFormat:@"UPDATE menulist Set menuOrder ='%@' where menuId ='%@' ",menuOrder,menuId];
            NSLog(@"MenuUpdate for menuOrder Query: %@", stm);
            
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"MenuOrderSource Updated successfully....");
                
                if(SQLITE_DONE != sqlite3_step(querryStatement))
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_finalize(querryStatement);
            }
            else
            {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
}

+(void) updateMenuOrderWithMenuId:(NSString*)menuIdSource withMenuOrder:(NSString*)menuOrderSource withMenuIdDestination:(NSString*)menuIdDestination withMenuOrderDestination:(NSString*)menuOrderDestination
{
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            
            NSString *stm = [NSString stringWithFormat:@"UPDATE menulist Set menuOrder ='%@' where menuId ='%@' ",menuOrderDestination,menuIdSource];
            NSLog(@"MenuUpdate for sourcemenu Query: %@", stm);
            
            NSString *stmDest = [NSString stringWithFormat:@"UPDATE menulist Set menuOrder ='%@' where menuId ='%@' ",menuOrderSource,menuIdDestination];
            NSLog(@"MenuUpdate for destinationmenu Query: %@", stmDest);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"MenuOrderSource Updated successfully....");
                
                const char *sqlQuerryDest= [stmDest UTF8String];
                sqlite3_stmt *querryStatementDest;
                if(sqlite3_prepare_v2(database, sqlQuerryDest, -1, &querryStatementDest, NULL)==SQLITE_OK)
                {
                    NSLog(@"MenuOrderDestination Updated successfully....");
                    
                    if(SQLITE_DONE != sqlite3_step(querryStatementDest))
                    {
                        NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                    }
                    sqlite3_reset(querryStatementDest);
                }
                
                
                if(SQLITE_DONE != sqlite3_step(querryStatement))
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_reset(querryStatement);
            }
            else
            {
                NSLog(@"error while conversion....");
            }
            sqlite3_reset(querryStatement);
            sqlite3_close(database);
        }
    }
}


#pragma mark
#pragma mark Submenu
#pragma mark

+ (NSMutableArray*)fetchTotalSubmenu
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        
        
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT DISTINCT menuId FROM submenulist ORDER BY menuId"];
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
//                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelMenu *obj = [[ModelMenu alloc] init];
                    
                    obj.strMenuId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    obj.strMenuName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)];
                    obj.strMenuOrder=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    obj.strMenuColor=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
                    obj.strMenuPageNo=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)];
                    obj.arrSubMenu=[DBManager fetchSubmenuWithmenuIdUpdated:obj.strMenuId];
                    
                    [arr addObject:obj];
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
    return arr;
}


+ (NSMutableArray*) fetchSubmenuWithmenuIdUpdated:(NSString*)menuId
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM submenulist  where  menuId ='%@' ORDER BY submenuOrder",menuId];
            //NSLog(@"Executed QUery: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                //NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelSubMenu *obj = [[ModelSubMenu alloc] init];
                    obj.strMenuId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    obj.strSubMenuId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)];
                    obj.strSubMenuName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    obj.strSubMenuColor=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
                    obj.strSubMenuOrder=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)];
                    [arr addObject:obj];
                    
                }
                sqlite3_finalize(querryStatement);
                
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
    
    
    return arr;
}


+ (NSMutableArray*) fetchSubmenuWithmenuId:(NSString*)menuId
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM submenulist  where  menuId ='%@' ORDER BY submenuOrder",menuId];
            //NSLog(@"Executed QUery: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                //NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    NSMutableDictionary *subMenuDict = [[NSMutableDictionary alloc] init];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)] forKey:@"MenuId"];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)] forKey:@"SubmenuId"];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)] forKey:@"SubMenuName"];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)] forKey:@"ColourName"];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)] forKey:@"SubMenuOrder"];
                    [arr addObject:subMenuDict];

                }
                sqlite3_finalize(querryStatement);
                
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }

    
    
    return arr;
}


+ (NSMutableArray*) fetchSubmenuWithmenuId:(NSString*)menuId subMenuID:(NSString*)subMenuID
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM submenulist  where  menuId ='%@' AND submenuId='%@' ORDER BY submenuOrder" ,menuId,subMenuID];
            //NSLog(@"Executed SUbmenu Color QUery: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                //NSLog(@"conversion successful for SUbmenu Color QUery....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    NSMutableDictionary *subMenuDict = [[NSMutableDictionary alloc] init];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)] forKey:@"MenuId"];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)] forKey:@"SubmenuId"];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)] forKey:@"SubMenuName"];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)] forKey:@"ColourName"];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)] forKey:@"SubMenuOrder"];
                    [arr addObject:subMenuDict];
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    return arr;
}


+(void)addSubMenuWithMenuId:(NSString *)strMenuId withSubMenuText:(NSString *)strSubMenuText
{
    
    if([strSubMenuText containsString:@"'"])
        strSubMenuText= [strSubMenuText stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
        FMDatabase *database=[DBManager getDatabase];
        if(database)
        {
            sqlite3 *database;
            NSString *dbpath = [DBManager getDBPath];
            const char* dbPath=[dbpath UTF8String];
            NSMutableArray *submenuexists=[[NSMutableArray alloc] init];
            
            submenuexists=[DBManager fetchSubmenuWithmenuIdUpdated:strMenuId];
            NSLog(@"%ld",(long)submenuexists.count);
            
            if(sqlite3_open(dbPath, &database)==SQLITE_OK)
            {
                NSString *stm =
                [NSString stringWithFormat:@"INSERT INTO submenulist(menuId,submenuId,submenuname,colorName,submenuOrder) values(\"%@\", \"%ld\", \"%@\", \"%@\",\"%ld\")",strMenuId,(long)submenuexists.count+1, strSubMenuText, @"",(long)submenuexists.count+1];
                
                NSLog(@"submenu Insertion Querystring: %@", stm);
                const char *sqlQuerry= [stm UTF8String];
                sqlite3_stmt *querryStatement;
                if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
                {
                    NSLog(@"submenu insertion successful....");
                    
                    if(sqlite3_step(querryStatement)!=SQLITE_DONE)
                    {
                        NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                    }
                    sqlite3_reset(querryStatement);
                }
                else {
                    NSLog(@"error while inserting submenu....");
                }

                sqlite3_close(database);
            }
        }
}


+(void) deleteAllSubMenuWithMenuId:(NSString *)strMenuId
{
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm =
            [NSString stringWithFormat:@"Delete from submenulist where menuId='%@'",strMenuId];
            
            NSLog(@"All Submenu Delete Querystring: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"All submenus deleted....");
                
                if(SQLITE_DONE != sqlite3_step(querryStatement))
                {
                    NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while deleting submenus....");
            }
            
            sqlite3_close(database);
        }
    }
}


+(void)deleteSubMenuWithMenuId:(NSString *)strMenuId withSubMenuId:(NSString *)strSubMenuID
{
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm =
            [NSString stringWithFormat:@"Delete from submenulist where menuId='%@' AND submenuId='%@'",strMenuId,strSubMenuID];
            
            
            NSLog(@"Submenu Delete Querystring: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"submenu deleted....");
                
                if(SQLITE_DONE != sqlite3_step(querryStatement))
                {
                    NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while deleting submenu....");
            }
            
            sqlite3_close(database);
        }
    }
}



+(BOOL) checkSubmenuWithMenuText:(NSString*)tableColoumValue withTableColoum:(NSString*)tableColoumName
{
    NSString *stm = [NSString stringWithFormat:@"SELECT * FROM submenulist  where %@ ='%@'",tableColoumName,tableColoumValue];
    NSLog(@"Select Querystring: %@", stm);
    
    BOOL recordExist = [self recordExistOrNot:stm];
    NSLog(@"recordExist: %d",recordExist);
    
    if(recordExist)
        return true;
    else
        return false;
}


+(void) updatesubnemuWithMenuId:(NSString*)str withsubmenutitle:(NSString*)submenu_txt
{
    if([submenu_txt containsString:@"'"])
        submenu_txt= [submenu_txt stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSArray *arr = [str componentsSeparatedByString:@","];
    
    NSString *menuId = [arr objectAtIndex:0];
    NSString *submenuId = [arr objectAtIndex:1];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"UPDATE submenulist Set submenuname ='%@'where  menuId ='%@' and submenuId ='%@'",submenu_txt,menuId,submenuId];
            NSLog(@"Update Querystring for submenu: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"Updation Successful....");
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                //sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
            }
            else
            {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
    // [self fetchmenu];
    
    
}


+(void) updateSubmenuWithMenuId:(NSString*)menuId subMenuID:(NSString*)subMenuID withTableColoum:(NSString*)tableColoumName withColoumValue:(NSString*)tableColoumValue
{
    
    if([tableColoumValue containsString:@"'"])
        tableColoumValue= [tableColoumValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            
            NSString *stm= [NSString stringWithFormat:@"UPDATE submenulist Set %@ ='%@' where menuId ='%@' AND submenuId='%@'",tableColoumName,tableColoumValue,menuId,subMenuID];
            NSLog(@"Update submenu Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                if(sqlite3_step(querryStatement)!=SQLITE_DONE){
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_reset(querryStatement);
                if (sqlite3_finalize(querryStatement) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
            }
            else
            {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
}



+(void) updateSubMenuTableMenuId:(NSString*)MenuID withcolorName:(NSString*)subMenuColorName
{
    if([subMenuColorName containsString:@"'"])
        subMenuColorName= [subMenuColorName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            
            NSString *stm = [NSString stringWithFormat:@"UPDATE submenulist Set colorName ='%@' where menuId ='%@'",subMenuColorName,MenuID];
            NSLog(@"Update Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"ColorMenu Updated successfully....");
                
                if(sqlite3_step(querryStatement)!=SQLITE_DONE){
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_reset(querryStatement);
                if (sqlite3_finalize(querryStatement) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
                /*if (sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(database));*/
            }
            else
            {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
}


+(void) updateSubMenuColorWithMenuId:(NSString*)MenuID subMenuID:(NSString*)subMenuID withcolorName:(NSString*)subMenuColorName
{
    if([subMenuColorName containsString:@"'"])
        subMenuColorName= [subMenuColorName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            
            //NSString *stm = [NSString stringWithFormat:@"UPDATE submenulist Set colorName ='%@' where menuId ='%@' AND submenuId='%@' ",subMenuColorName,MenuID,subMenuID];
            
            NSString *stm = [NSString stringWithFormat:@"UPDATE submenulist Set colorName ='%@' where menuId ='%@' ",subMenuColorName,MenuID];
            NSLog(@"SubMenuUpdate Query: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"ColorMenu Updated successfully....");
                
                if(SQLITE_DONE != sqlite3_step(querryStatement))
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_reset(querryStatement);
            }
            else
            {
                NSLog(@"error while conversion....");
            }
            sqlite3_reset(querryStatement);
            sqlite3_close(database);
        }
    }
}





#pragma mark
#pragma mark Picklist
#pragma mark

+ (NSMutableArray*)fetchAllPickFromListUpdated
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        
        
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM pickFromListMenu ORDER BY pickMenuOrder"];
            //NSLog(@"FetchAllPickFromList Query: %@",stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
//                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelPickListMenu *obj=[[ModelPickListMenu alloc] init];
                    
                    obj.strPickMenuId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    obj.strPickMenuName= [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)];
                    obj.strPickImage=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    obj.strPickMenuOrder=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text (querryStatement, 3)];
                    obj.arrPickSubMenu=[DBManager fetchPickSubMenuWithPickMenuIdUpdated:obj.strPickMenuId];
                    [arr addObject:obj];
                    
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
    return arr;
}


+ (NSMutableArray*) fetchPickSubMenuWithPickMenuIdUpdated:(NSString *)pickMenuId
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM pickFromListSubMenu where pickMenu ='%@' AND pickText!='' ORDER BY pickOrder",pickMenuId];
            
            //NSLog(@"Executed Query: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
//                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelPickListSubMenu *subObj=[[ModelPickListSubMenu alloc] init];
                    
                    subObj.strPickSubMenuId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    subObj.strPickSubMenuName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)];
                    subObj.strPickMenuId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    subObj.strPickSubMenuOrder=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
                    subObj.strPickSubMenuFlag=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text (querryStatement, 4)];
                    [arr addObject:subObj];
                    
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    return arr;
}

+(void) updatePickSubMenuWithPickId:(NSString *)pickId withTableColoum:(NSString *)tableColoumName withColoumValue:(NSString *)tableColoumValue
{
    
    
    if([tableColoumValue containsString:@"'"])
        tableColoumValue= [tableColoumValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"UPDATE pickFromListSubMenu Set %@ ='%@' where  pickId ='%@'",tableColoumName,tableColoumValue,pickId];
            //NSLog(@"Update picklistsubmenu Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
//                NSLog(@"conversion successful....");

                if(SQLITE_DONE != sqlite3_step(querryStatement)){
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            //sqlite3_reset(querryStatement);
            sqlite3_close(database);
        }
    }
    
}


+(void) updatePickSubMenuWithPickName:(NSString*)pickName withTableColoum:(NSString*)tableColoumName withColoumValue:(NSString*)tableColoumValue
{
    //NSLog(@"pick Text: %@",tableColoumValue);
    /*NSMutableString *muPickName = [NSMutableString stringWithString:pickName];
    if([muPickName rangeOfString:@"'"].location !=NSNotFound)
    {
        [muPickName insertString:@"'" atIndex:[muPickName rangeOfString:@"'"].location];
        pickName=muPickName;
    }*/
    
    if([tableColoumValue containsString:@"'"])
        tableColoumValue= [tableColoumValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"UPDATE pickFromListSubMenu Set %@ ='%@' where  pickText ='%@'",tableColoumName,tableColoumValue,pickName];
            //NSLog(@"Update picklistsubmenu Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");
                
                if(SQLITE_DONE != sqlite3_step(querryStatement)){
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_reset(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_reset(querryStatement);
            sqlite3_close(database);
        }
    }
    
}


+(BOOL) insertPickSubMenu:(NSMutableArray *)pickArray
{
    BOOL isInserted=NO;
    ModelPickListSubMenu *objPickSub=[pickArray objectAtIndex:0];
    
    if([objPickSub.strPickSubMenuName containsString:@"'"])
        objPickSub.strPickSubMenuName= [objPickSub.strPickSubMenuName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"INSERT INTO contractTable(pickText, pickMenu, pickOrder, displayFlag) values(\"%@\", \"%@\", \"%@\",\"%@\")",objPickSub.strPickSubMenuName, objPickSub.strPickSubMenuId, objPickSub.strPickSubMenuOrder, objPickSub.strPickSubMenuFlag];
            
            NSLog(@"Insert picklistsubmenu Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"Insertion successful....");
                isInserted=YES;
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                    isInserted=NO;
                }
                sqlite3_reset(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_reset(querryStatement);
            sqlite3_close(database);
        }
    }
    return isInserted;
}

+(BOOL) deletePickTextWithSubPickId:(NSString *)subPickId
{
    BOOL isDeleted=NO;
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm =[NSString stringWithFormat:@"Delete from pickFromListSubMenu where pickId='%d'",[subPickId intValue]];
            
            NSLog(@"PickText Delete QueryString: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"PickText Details deleted....");
                isDeleted=YES;
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                    isDeleted=NO;
                }
                sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
            }
            else
            {
                NSLog(@"error while deleting PickText....");
            }
            
            sqlite3_close(database);
        }
    }
    return isDeleted;
}


//#pragma mark
//#pragma mark UserProfile
//#pragma mark
//
//+(BOOL) addProfile:(NSMutableArray *)profileArray
//{
//    BOOL isInserted=NO;
//    FMDatabase *database=[DBManager getDatabase];
//    if(database)
//    {
//        sqlite3 *database;
//        NSString *dbpath = [DBManager getDBPath];
//        const char* dbPath=[dbpath UTF8String];
//        
//        ModelUserProfile *userObj=[[ModelUserProfile alloc] init];
//        
//        userObj=[profileArray objectAtIndex:0];
//        
//        
//        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
//        {
//            NSString *stm =[NSString stringWithFormat:@"INSERT INTO userProfile(firstName,lastName,heyName,phoneNo,deviceUDID,profileImage) values(\"%@\", \"%@\", \"%@\", \"%@\",  \"%@\", \"%@\")", userObj.strFirstName,userObj.strLastName, userObj.strHeyName, userObj.strPhoneNo, userObj.strDeviceUDID, userObj.strProfileImage];
//            
//            NSLog(@"Profile Insertion Querystring: %@", stm);
//            const char *sqlQuerry= [stm UTF8String];
//            sqlite3_stmt *querryStatement;
//            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
//            {
//                
//                NSLog(@"UserProfile Inserted....");
//                isInserted=YES;
//
//                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
//                
//                if(!executeQueryResults)
//                {
//                    NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
//                    isInserted=NO;
//                }
//                
//                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
//                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
//            }
//            else
//            {
//                NSLog(@"error while inserting profile....");
//            }
//            
//            sqlite3_close(database);
//        }
//    }
//    
//    return isInserted;
//}
//
//+(BOOL) updateProfile:(NSMutableArray *)profileArray
//{
//    BOOL isUpdated=NO;
//    FMDatabase *database=[DBManager getDatabase];
//    if(database)
//    {
//        sqlite3 *database;
//        NSString *dbpath = [DBManager getDBPath];
//        const char* dbPath=[dbpath UTF8String];
//        
//        ModelUserProfile *userObj=[[ModelUserProfile alloc] init];
//        
//        userObj=[profileArray objectAtIndex:0];
//        
//        
//        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
//        {
//            NSString *stm = [NSString stringWithFormat:@"UPDATE userProfile Set firstName ='%@', lastName ='%@'  , phoneNo ='%@', profileImage ='%@'",userObj.strFirstName,userObj.strLastName,  userObj.strPhoneNo, userObj.strProfileImage];
//            
//            //NSLog(@"Profile Updation Querystring: %@", stm);
//            const char *sqlQuerry= [stm UTF8String];
//            sqlite3_stmt *querryStatement;
//            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
//            {
//                NSLog(@"UserProfile Updated....");
//                isUpdated=YES;
//                
//                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
//                
//                if(!executeQueryResults)
//                {
//                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
//                }
//                //sqlite3_reset(querryStatement);
//                
//                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
//                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
//                
//            }
//            else
//            {
//                NSLog(@"error while inserting profile....");
//            }
//            
//            sqlite3_close(database);
//        }
//    }
//    
//    return isUpdated;
//}
//
//
//+ (NSMutableArray*) fetchUserProfile
//{
//    NSMutableArray *arr = [[NSMutableArray alloc]init];
//    
//    FMDatabase *database=[DBManager getDatabase];
//    if(database)
//    {
//        sqlite3 *database;
//        NSString *dbpath = [DBManager getDBPath];
//        const char* dbPath=[dbpath UTF8String];
//        
//        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
//        {
//            NSString *stm = @"SELECT * FROM userProfile limit 0,1";
//            
//            const char *sqlQuerry= [stm UTF8String];
//            sqlite3_stmt *querryStatement;
//            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
//            {
//                NSLog(@"conversion successful....");
//                while (sqlite3_step(querryStatement)==SQLITE_ROW)
//                {
//                    ModelUserProfile *userObj=[[ModelUserProfile alloc] init];
//                    
//                    userObj.strProfileId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
//                    userObj.strFirstName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)];
//                    userObj.strLastName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
//                    userObj.strHeyName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
//                    userObj.strPhoneNo=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text (querryStatement, 4)];
//                    userObj.strDeviceUDID=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text (querryStatement, 5)];
//                    userObj.strProfileImage=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text (querryStatement, 6)];
//                    [arr addObject:userObj];
//                    
//                }
//                sqlite3_finalize(querryStatement);
//            }
//            else {
//                NSLog(@"error while conversion....");
//            }
//            sqlite3_close(database);
//        }
//    }
//    return arr;
//}

#pragma mark
#pragma mark Other Helper Methods
#pragma mark

+(BOOL)recordExistOrNot:(NSString *)query
{
    BOOL recordExist=NO;
    FMDatabase *database=[DBManager getDatabase];
    
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        
        if(sqlite3_open([dbpath UTF8String], &database) == SQLITE_OK)
        {
            sqlite3_stmt *statement;
            if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)==SQLITE_OK)
            {
                if (sqlite3_step(statement)==SQLITE_ROW)
                {
                    recordExist=YES;
                }
                else
                {
                    //////NSLog(@"%s,",sqlite3_errmsg(database));
                }
                sqlite3_finalize(statement);
                sqlite3_close(database);
            }
        }
        
    }
    
    return recordExist;
}
@end
