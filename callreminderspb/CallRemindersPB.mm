#import "PSViewController.h"
#import <notify.h>

#define SETTINGS @"/var/mobile/Library/Preferences/com.naken.callreminders.plist"
#define BUNDLE [NSBundle bundleWithPath:@"/Library/PreferenceBundles/CallRemindersPB.bundle"]

@interface CallRemindersPBListController: PSViewController <UITextFieldDelegate>
{
	UITableView *tbView;
	UITextField *delimiterField;
}
@end

@implementation CallRemindersPBListController
- (id)init
{
	if ( (self = [super init]) )
	{
		self.title = @"CallReminders";
		tbView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) style:UITableViewStyleGrouped];
		tbView.delegate = self;
		tbView.dataSource = self;
	}
	return self;
}

- (id)view
{
	return tbView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return NSLocalizedStringFromTableInBundle(@"By snakeninny & DJ NightLife", @"Localizable", BUNDLE, nil);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return NSLocalizedStringFromTableInBundle(@"Delimiter", @"Localizable", BUNDLE, nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-fucking-cell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		delimiterField.delegate = nil;
		[delimiterField release];
		delimiterField = nil;
		delimiterField = [[UITextField alloc] initWithFrame:CGRectMake(8.0f, 10.0f, cell.contentView.frame.size.width - 30.0f, 22.0f)];;

		NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:SETTINGS];		
		delimiterField.text = [dictionary objectForKey:@"delimiter"];
		delimiterField.delegate = self;
		delimiterField.clearButtonMode = UITextFieldViewModeWhileEditing;
		delimiterField.placeholder = NSLocalizedStringFromTableInBundle(@"\" is the delimeter of \"Name\"", @"Localizable", BUNDLE, nil);

		[cell.contentView addSubview:delimiterField];
	}
	return cell;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:SETTINGS];
	[dictionary setObject:[delimiterField.text length] != 0 ? delimiterField.text : @"\"" forKey:@"delimiter"];
	[dictionary writeToFile:SETTINGS atomically:YES];
	[delimiterField release];
	delimiterField = nil;
	notify_post("com.naken.callreminders.loadsettings");	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.view.window endEditing:YES];
}

- (void)dealloc
{
	tbView.delegate = nil;
	tbView.dataSource = nil;
	[tbView release];
	tbView = nil;

	[super dealloc];
}
@end
