#import "CallRemindersDelegates.h"

@implementation CRUIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	addressesTableView.delegate = nil;
	[tableViewDelegate release];
	tableViewDelegate = nil;

	addressesTableView.dataSource = nil;
	[tableViewDataSource release];
	tableViewDataSource = nil;

	[addressesTableView release];
	addressesTableView = nil;

	addressesAlertView.delegate = nil;
	[alertViewDelegate release];
	alertViewDelegate = nil;

	[addressesAlertView release];
	addressesAlertView = nil;

	[addressArray release];
	addressArray = nil;

	[kindArray release];
	kindArray = nil;
}
@end

@implementation CRUITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[addressesAlertView dismissWithClickedButtonIndex:0 animated:YES];

	NSString *address = [addressArray objectAtIndex:indexPath.row];
	address = [address stringByReplacingOccurrencesOfString:@" " withString:@""];
	address = [address stringByReplacingOccurrencesOfString:@"-" withString:@""];
	address = [address stringByReplacingOccurrencesOfString:@"(" withString:@""];
	address = [address stringByReplacingOccurrencesOfString:@")" withString:@""];

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", address]]];

	addressesTableView.delegate = nil;
	[tableViewDelegate release];
	tableViewDelegate = nil;

	addressesTableView.dataSource = nil;
	[tableViewDataSource release];
	tableViewDataSource = nil;

	[addressesTableView release];
	addressesTableView = nil;

	addressesAlertView.delegate = nil;
	[alertViewDelegate release];
	alertViewDelegate = nil;

	[addressesAlertView release];
	addressesAlertView = nil;

	[addressArray release];
	addressArray = nil;

	[kindArray release];
	kindArray = nil;
}
@end

@implementation CRUITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-fucking-cell"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.text = [kindArray objectAtIndex:indexPath.row];
	}
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [addressArray count];
}
@end
