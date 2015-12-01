//
//  DBManager.h
//  iCompliance
//
//  Created by Boudhayan Biswas on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

#define DATABASE_FILE_PATH @"DataBase"
#define DATABASE_NAME @"Heydatabase.sqlite"


@interface DBManager : NSObject
//***************** DATABASE RELATED FUNCTIONS ***********************

+ (NSString *)getDBPath;
+ (NSURL *)getDBURL;
+ (NSURL *)getSharedContainerURL;

+ (FMDatabase *)getDatabase;

+ (BOOL)sharedDirExists;
+ (void)checkAndCreateDatabase;
+ (void) checkAndCreateDatabaseAtPath:(NSString *)databasePath;

////////////////////////////////////////////////////////////////////////////////////

//Menu & Submenu

+ (NSMutableArray*) fetchTotalSubmenu;
+ (NSMutableArray*)fetchmenu:(int)startLimit noOfRows:(int)noOfRows;
+ (NSMutableArray*)fetchMenuForPageNo:(NSInteger)menuPageNo;
+ (NSMutableArray*) fetchSubmenuWithmenuIdUpdated:(NSString*)menuId;
+ (NSMutableArray*) fetchSubmenuWithmenuId:(NSString*)menuId;
+ (NSMutableArray*) fetchSubmenuWithmenuId:(NSString*)menuId subMenuID:(NSString*)subMenuID;

+(void) updatemenuWithMenuId:(NSString*)strId withMenuTitle:(NSString*)menuText;
+(void) updatemenuWithMenuId:(NSString*)menuId withTableColoum:(NSString*)tableColoumName withColoumValue:(NSString*)tableColoumValue;

+(void) updatesubnemuWithMenuId:(NSString*)str withsubmenutitle:(NSString*)submenu_txt;
+(void) updateSubmenuWithMenuId:(NSString*)menuId subMenuID:(NSString*)subMenuID withTableColoum:(NSString*)tableColoumName withColoumValue:(NSString*)tableColoumValue;

+(void) addSubMenuWithMenuId:(NSString*)strMenuId withSubMenuText:(NSString*)strSubMenuText;
+(void) deleteSubMenuWithMenuId:(NSString*)strMenuId withSubMenuId:(NSString*)strSubMenuID;
+(void) deleteAllSubMenuWithMenuId:(NSString*)strMenuId;


+(BOOL) checkmenuWithMenuText:(NSString*)tableColoumValue withTableColoum:(NSString*)tableColoumName;
+(BOOL) checkSubmenuWithMenuText:(NSString*)tableColoumValue withTableColoum:(NSString*)tableColoumName;

+(void) updateSubMenuTableMenuId:(NSString*)MenuID  withcolorName:(NSString*)subMenuColorName;
+(void) updateSubMenuColorWithMenuId:(NSString*)MenuID subMenuID:(NSString*)subMenuID withcolorName:(NSString*)subMenuColorName;
+(void) updateMenuOrderWithMenuId:(NSString*)menuIdSource withMenuOrder:(NSString*)menuOrderSource withMenuIdDestination:(NSString*)menuIdDestination withMenuOrderDestination:(NSString*)menuOrderDestination;

+(void) updateMenuOrderWithMenuId:(NSString*)menuId withMenuOrder:(NSString*)menuOrder;
+(BOOL) deletePickTextWithSubPickId:(NSString*)subPickId;

//+(void) updateSubMenuOrderWithMenuId:(NSString*)menuId withSubMenuId:(NSString*)subMenuIdSource withSubMenuOrder:(NSString*)subMenuOrderSource withSubMenuIdDestination:(NSString*)subMenuIdDestination withSubMenuOrderDestination:(NSString*)subMenuOrderDestination;


//Favourite

//+(NSMutableArray*)insertToFavoriteTable:(NSMutableArray*)fevoriteArray;
//+(void) UpdateFavoriteWithId:(NSString*)favoriteId withTableColoum:(NSString*)tableColoumName withColoumValue:(NSString*)tableColoumValue;
//
//+(BOOL) UpdateFavoriteWithId:(NSString*)favoriteId withColoumValue:(NSString*)tableColoumValue;
//
//+(BOOL) deleteFavoriteDetailsWithFavoriteId:(NSString*)favoriteId;
//
//+(NSMutableArray*)fetchFavorite;
//+(NSMutableArray*)fetchFavoriteWithMobileNumber:(NSString*)Mob;

//Group

//+(NSMutableArray*)saveGroupNameToTable:(NSString*)groupName;
//+(NSMutableArray*)saveGroupMembersToGroup:(NSMutableDictionary*)infoGroupMember;
//
//
//+(NSMutableArray*)fetchDetailsFromGroup;
//+(NSMutableArray*)fetchDataFromGroupWithGroupId:(NSString*)groupId;
//+(NSMutableArray*)fetchGroupMembersWithGroupId:(NSString*)groupId;

//Updated
//+(long long) insertGroup:(NSString*)groupName;
//+(BOOL) updateGroupNameWithGroupId:(NSString*)groupId withGroupName:(NSString*)groupName;
//+(void) updateGroupWithId:(NSString*)groupId withTableColoum:(NSString*)tableColoumName withColoumValue:(NSString*)tableColoumValue;
//+(BOOL) deleteGroupWithGroupId:(NSString*)groupId;
//
//+(long long) insertGroupMember:(NSMutableArray*)groupMemberArray;
//+(BOOL) updateGroupMemberNameWithMemberId:(NSString*)memberId withGroupName:(NSString*)memberName;
//+(BOOL) deleteGroupMemberWithMemberId:(NSString*)memberId;
//+(BOOL) deleteGroupMemberWithGroupId:(NSString*)groupId;
//PickFromList

+ (NSMutableArray*) fetchAllPickFromListUpdated;
+ (NSMutableArray*) fetchPickSubMenuWithPickMenuIdUpdated:(NSString*)pickMenuId;


+(BOOL) insertPickSubMenu:(NSMutableArray*)pickArray;
+(void) updatePickSubMenuWithPickId:(NSString*)pickId withTableColoum:(NSString*)tableColoumName withColoumValue:(NSString*)tableColoumValue;

+(void) updatePickSubMenuWithPickName:(NSString*)pickName withTableColoum:(NSString*)tableColoumName withColoumValue:(NSString*)tableColoumValue;

//UserProfile

//+(BOOL) addProfile:(NSMutableArray*)profileArray;
//+(BOOL) updateProfile:(NSMutableArray*)profileArray;
//+ (NSMutableArray*) fetchUserProfile;
////////////////////////////////////////////////////////////////////////////////////


@end
