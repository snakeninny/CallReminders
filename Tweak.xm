#import "CallReminders.h"
#import "CallRemindersDelegates.h"
#import <AddressBook/AddressBook.h>

#define SETTINGS @"/var/mobile/Library/Preferences/com.naken.callreminders.plist"
#define BUNDLE [NSBundle bundleWithPath:@"/Library/PreferenceBundles/CallRemindersPB.bundle"]

NSMutableArray *addressArray = nil;
NSMutableArray *kindArray = nil;
UIAlertView *addressesAlertView = nil;
UITableView *addressesTableView = nil;
CRUIAlertViewDelegate *alertViewDelegate = nil;
CRUITableViewDelegate *tableViewDelegate = nil;
CRUITableViewDataSource *tableViewDataSource = nil;
static NSString *delimiterString = nil;

static void LoadSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:SETTINGS];

	[delimiterString release];
	delimiterString = nil;
	delimiterString = [[NSString alloc] initWithString:[dictionary objectForKey:@"delimiter"]];
}

static void CopySettings()
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:SETTINGS])
	{
		[fileManager removeItemAtPath:SETTINGS error:nil];
		[fileManager copyItemAtPath:[[BUNDLE bundlePath] stringByAppendingPathComponent:@"/com.naken.callreminders.plist"] toPath:SETTINGS error:nil];
	}

	LoadSettings(nil, nil, nil, nil, nil);
}

%group iOSXHook

%hook RemindersListController
- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	%orig;

	EKReminder *reminder = [self reminderAtIndexPath:indexPath];
	NSString *text = reminder.title;
	NSString *name = nil;

	if ([text length] != 0)
	{
		// get the name in title
		int length = [text length];
		int firstLocation = 0;
		int secondLocation = 0;
		NSRange firstDelimiter = [text rangeOfString:delimiterString];
		if ( (firstLocation = firstDelimiter.location) != NSNotFound)
		{
			NSRange secondDelimiter = [text rangeOfString:delimiterString options:NSCaseInsensitiveSearch range:NSMakeRange(firstLocation + 1, length - firstLocation - 1)];
			if ( (secondLocation = secondDelimiter.location) != NSNotFound)
				name = [text substringWithRange:NSMakeRange(firstLocation + 1, secondLocation - firstLocation - 1)];
		}
	}

	if ([name length] != 0)
	{
		[addressArray release];
		addressArray = nil;
		addressArray = [[NSMutableArray alloc] initWithCapacity:36]; // store all addresses under one name

		[kindArray release];
		kindArray = nil;
		kindArray = [[NSMutableArray alloc] initWithCapacity:36]; // store all labels under one name

		// get the address(es) of that name
		ABAddressBookRef addressBook = ABAddressBookCreate();
		CFArrayRef people = ABAddressBookCopyPeopleWithName(addressBook, (CFStringRef)name);
		if (people != nil && CFArrayGetCount(people) > 0)
		{
			for (int i = 0; i < CFArrayGetCount(people); i++) // enumerate all people under one name
			{
				ABRecordRef person = CFArrayGetValueAtIndex(people, i);
				ABMultiValueRef addresses = ABRecordCopyValue(person, kABPersonPhoneProperty);    
				if (addresses != nil)
				{
					for (int i = 0; i < ABMultiValueGetCount(addresses); i++) // enumerate all addresses under one people
					{
						NSString *address = (NSString *)ABMultiValueCopyValueAtIndex(addresses, i);
						[addressArray addObject:address];
						CFRelease(address);

						CFStringRef kind = ABMultiValueCopyLabelAtIndex(addresses, i);
						NSString *localizedKind = (NSString *)ABAddressBookCopyLocalizedLabel(kind);
						[kindArray addObject:localizedKind];
						CFRelease(kind);
						CFRelease(localizedKind);
					}
				}
				CFRelease(addresses);
			}
		}
		CFRelease(addressBook);
		CFRelease(people);

		// show them
		if ([addressArray count] != 0)
		{
			addressesAlertView.delegate = nil;
			[alertViewDelegate release];
			alertViewDelegate = nil;
			alertViewDelegate = [[CRUIAlertViewDelegate alloc] init];

			[addressesAlertView release];
			addressesAlertView = nil;
			addressesAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Call %@?", @"Localizable", BUNDLE, nil), name] message:@"\n\n\n\n\n\n\n\n\n" delegate:alertViewDelegate cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", @"Localizable", BUNDLE, nil) otherButtonTitles:nil];

			addressesTableView.delegate = nil;
			addressesTableView.dataSource = nil;
			[addressesTableView release];
			addressesTableView = nil;
			addressesTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 48, 264, 180)];

			[tableViewDelegate release];
			tableViewDelegate = nil;
			tableViewDelegate = [[CRUITableViewDelegate alloc] init];
			addressesTableView.delegate = tableViewDelegate;

			[tableViewDataSource release];
			tableViewDataSource = nil;
			tableViewDataSource = [[CRUITableViewDataSource alloc] init];
			addressesTableView.dataSource = tableViewDataSource;

			[addressesAlertView addSubview:addressesTableView];
			[addressesAlertView show];
		}
		else
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Ooops", @"Localizable", BUNDLE, nil) message:NSLocalizedStringFromTableInBundle(@"No match found", @"Localizable", BUNDLE, nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"OK", @"Localizable", BUNDLE, nil) otherButtonTitles:nil];
			[alertView show];
			[alertView release];

			[addressArray release];
			addressArray = nil;

			[kindArray release];
			kindArray = nil;
		}
	}
}
%end

%end // end of iOSXHook

%ctor
{
	%init;

	CopySettings();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, LoadSettings, CFSTR("com.naken.callreminders.loadsettings"), NULL, CFNotificationSuspensionBehaviorCoalesce);

	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_0) %init(iOSXHook);
}
