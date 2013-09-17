#import <EventKit/EKReminder.h>

@class CRUIAlertViewDelegate;
@class CRUITableViewDelegate;
@class CRUITableViewDataSource;

extern NSMutableArray *addressArray;
extern NSMutableArray *kindArray;
extern UIAlertView *addressesAlertView;
extern UITableView *addressesTableView;
extern CRUIAlertViewDelegate *alertViewDelegate;
extern CRUITableViewDelegate *tableViewDelegate;
extern CRUITableViewDataSource *tableViewDataSource;

@interface RemindersListController : UITableViewController
-(EKReminder *)reminderAtIndexPath:(NSIndexPath *)indexPath;
@end
