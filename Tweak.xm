#import <sys/stat.h>

//Path for reading AppList configuration & Current App
static NSString* AppListPref = @"/var/mobile/Library/Preferences/ic.nuts.disablenc.plist";
static NSString* CurrentApp = @"/var/mobile/Library/Preferences/ic.nuts.currapp.plist";

//IPC 
@interface CPDistributedMessagingCenter
+ (id)centerNamed:(id)arg1;
- (BOOL)sendMessageName:(id)arg1 userInfo:(id)arg2;
- (void)runServerOnCurrentThread;
- (void)registerForMessageName:(id)arg1 target:(id)arg2 selector:(SEL)arg3;
- (id)sendMessageAndReceiveReplyName:(id)arg1 userInfo:(id)arg2;
@end

//Hook For Avoiding Pull-down NC
%hook SBBulletinListController

-(void)handleShowNotificationsGestureBeganWithTouchLocation:(CGPoint)touchLocation{
	NSDictionary *applist = [[NSDictionary alloc] initWithContentsOfFile: AppListPref];
	NSDictionary *curr = [[NSDictionary alloc] initWithContentsOfFile: CurrentApp];
	if(nil == applist || nil == curr || 0 == [[applist objectForKey:[curr objectForKey: @"identifier"]] intValue]){
		%orig;
	}
}
%end

//Get Current App's Bundle Identifier
%hook UIApplication
//Hook more functions to ensure no leaks
- (void)_run{
	[self currentIdentifierParser];
	%orig;
}
- (void)_sendWillEnterForegroundCallbacks{
	[self currentIdentifierParser];
	%orig;
}
- (void)setStatusBarMode:(int)arg1 duration:(float)arg2{
	[self currentIdentifierParser];
	%orig;
}
- (BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2{
	[self currentIdentifierParser];
	%orig;
}
- (void)applicationDidResume{
	[self currentIdentifierParser];
	%orig;
}
- (void)applicationDidResumeFromUnderLock{
	[self currentIdentifierParser];
	%orig;
}
- (void)setStatusBarHidden:(BOOL)arg1 withAnimation:(int)arg2{
	[self currentIdentifierParser];
	%orig;
}
- (void)setStatusBarStyle:(int)arg1 animated:(BOOL)arg2{
	[self currentIdentifierParser];
	%orig;
}
- (void)_restoreApplicationPreservationState{
	[self currentIdentifierParser];
	%orig;
}

%new(v@:)
- (void) currentIdentifierParser{
	NSString* identifier = [[NSBundle mainBundle] bundleIdentifier];
	NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys: identifier,@"msg",nil];
	CPDistributedMessagingCenter *mCenter = [CPDistributedMessagingCenter centerNamed:@"ic.nuts.disablenc.server"];
	[mCenter sendMessageName:@"ic.nuts.currentIdentifier" userInfo: dictionary];
}
%end

//Message Handler
%hook SBApplicationController
- (id)init{
	CPDistributedMessagingCenter *
		center = [CPDistributedMessagingCenter centerNamed:@"ic.nuts.disablenc.server"];
	[center runServerOnCurrentThread];
	[center registerForMessageName:@"ic.nuts.currentIdentifier" target:self selector:@selector(identifierParser:userInfo:)];
	return %orig;
}
%new(v@:@@)
- (void)identifierParser:(NSString*) name userInfo:(NSDictionary *)userInfo{
	NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] init];
	[plistDict setValue:[userInfo objectForKey: @"msg"] forKey:@"identifier"];
	[plistDict writeToFile: CurrentApp atomically: YES];
	[plistDict release];
}
%end



