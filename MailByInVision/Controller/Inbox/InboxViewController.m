//
//  InboxViewController.m
//  MailByInVision
//
//  Created by Michal Kalis on 16/03/16.
//  Copyright © 2016 Michal Kalis. All rights reserved.
//

#import "InboxViewController.h"
#import "MessageService.h"
#import "UIViewController+CoreDataStack.h"
#import "FetchedResultsDataProvider.h"
#import "InboxDataSource.h"
#import "Message.h"
#import "NSManagedObject+CustomInit.h"
#import "DataSourceDelegate.h"
#import "InboxTableViewCell.h"
#import "UITableViewCell+ReuseIdentifier.h"

@interface InboxViewController () <DataProviderDelegate, DataSourceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) InboxDataSource *dataSource;

@end

@implementation InboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Inbox";
    
    [self setupTableView];
    
    [MessageService fetchAllMessagesWithCoreDataStack:self.coreDataStack requestResult:^(NSArray *messages, NSError *error) {
        NSLog(@"messages %@", messages);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)setupTableView {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[Message entityName]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"receivedAt" ascending:false]];
    // Fetch only message that are not part of a thread or only the newest message in a thread
    NSPredicate *singleMessage = [NSPredicate predicateWithFormat:@"threadID = nil"];
    NSPredicate *lastMessageInThread = [NSPredicate predicateWithFormat:@"lastMessage == YES"];
    request.predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[singleMessage, lastMessageInThread]];
    request.returnsObjectsAsFaults = NO;
    request.fetchBatchSize = 40;
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.coreDataStack.mainContext sectionNameKeyPath:nil cacheName:nil];
    FetchedResultsDataProvider *dataProvider = [[FetchedResultsDataProvider alloc] initWithFetchedResultsController:frc delegate:self];
    self.dataSource = [[InboxDataSource alloc] initWithTableView:self.tableView dataProvider:dataProvider delegate:self];
}

#pragma mark - Data Source Delegate

- (NSString *)cellIdentifierForObject:(NSManagedObject *)object {
    return [InboxTableViewCell automaticReuseIdentifier];
}

#pragma mark - Data Provider Delegate

- (void)dataProviderDidUpdateWithUpdates:(NSArray<DataProviderUpdate *> *)updates {
    [self.dataSource processUpdates:updates];
}

@end