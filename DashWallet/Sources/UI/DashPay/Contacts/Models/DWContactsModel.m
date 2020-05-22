//
//  Created by Andrew Podkovyrin
//  Copyright © 2020 Dash Core Group. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "DWContactsModel.h"

#import "DWContactsDataSourceObject.h"
#import "DWEnvironment.h"
#import "DWFetchedResultsDataSource.h"
#import "DWIncomingContactItem.h"
#import "UIView+DWFindConstraints.h"

NS_ASSUME_NONNULL_BEGIN

@interface DWContactsModel () <DWFetchedResultsDataSourceDelegate>

@property (readonly, nonatomic, strong) DWContactsDataSourceObject *aggregateDataSource;

@property (nonatomic, strong) DWFetchedResultsDataSource *incomingDataSource;
@property (nonatomic, strong) DWFetchedResultsDataSource *contactsDataSource;

@end

NS_ASSUME_NONNULL_END

@implementation DWContactsModel

@synthesize sortMode;

- (instancetype)init {
    self = [super init];
    if (self) {
        _aggregateDataSource = [[DWContactsDataSourceObject alloc] init];
        [self rebuildDataSources];
    }
    return self;
}

- (BOOL)isEmpty {
    return self.aggregateDataSource.isEmpty;
}

- (BOOL)isSearching {
    return self.aggregateDataSource.isSearching;
}

- (id<DWContactsDataSource>)dataSource {
    return self.aggregateDataSource;
}

- (BOOL)hasBlockchainIdentity {
    DSWallet *wallet = [DWEnvironment sharedInstance].currentWallet;
    DSBlockchainIdentity *mineBlockchainIdentity = wallet.defaultBlockchainIdentity;
    return mineBlockchainIdentity != nil;
}

- (void)rebuildDataSources {
    DSBlockchainIdentity *blockchainIdentity = [DWEnvironment sharedInstance].currentWallet.defaultBlockchainIdentity;
    if (!blockchainIdentity) {
        return;
    }

    NSManagedObjectContext *context = [NSManagedObject mainContext];

    _incomingDataSource = [[DWFetchedResultsDataSource alloc]
                       initWithContext:context
                            entityName:NSStringFromClass(DSFriendRequestEntity.class)
        shouldSubscribeToNotifications:YES];
    _incomingDataSource.delegate = self;
    _incomingDataSource.predicate = [NSPredicate
        predicateWithFormat:
            @"destinationContact == %@ && (SUBQUERY(destinationContact.outgoingRequests, $friendRequest, $friendRequest.destinationContact == SELF.sourceContact).@count == 0)",
            [blockchainIdentity matchingDashpayUserInContext:context]];
    _incomingDataSource.invertedPredicate = [NSPredicate
        predicateWithFormat:
            @"sourceContact == %@ && (SUBQUERY(sourceContact.incomingRequests, $friendRequest, $friendRequest.sourceContact == SELF.destinationContact).@count > 0)",
            [blockchainIdentity matchingDashpayUserInContext:context]];
    NSSortDescriptor *incomingSortDescriptor = [[NSSortDescriptor alloc]
        initWithKey:@"sourceContact.associatedBlockchainIdentity.dashpayUsername.stringValue"
          ascending:YES];
    _incomingDataSource.sortDescriptors = @[ incomingSortDescriptor ];

    _contactsDataSource = [[DWFetchedResultsDataSource alloc]
                       initWithContext:context
                            entityName:NSStringFromClass(DSDashpayUserEntity.class)
        shouldSubscribeToNotifications:YES];
    _contactsDataSource.delegate = self;
    _contactsDataSource.predicate = [NSPredicate
        predicateWithFormat:
            @"ANY friends == %@",
            [blockchainIdentity matchingDashpayUserInContext:context]];
    NSSortDescriptor *contactsSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"associatedBlockchainIdentity.dashpayUsername.stringValue" ascending:YES];
    _contactsDataSource.sortDescriptors = @[ contactsSortDescriptor ];
}

- (void)start {
    [self fetchData];

    [self activateFRCs];
}

- (void)stop {
    [self resetFRCs];
}

- (void)fetchData {
    DSWallet *wallet = [DWEnvironment sharedInstance].currentWallet;
    DSBlockchainIdentity *mineBlockchainIdentity = wallet.defaultBlockchainIdentity;
    __weak typeof(self) weakSelf = self;
    [mineBlockchainIdentity fetchContactRequests:^(BOOL success, NSArray<NSError *> *_Nonnull errors) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        DSLogVerbose(@"DWDP: Fetch contact requests %@: %@", success ? @"Succeeded" : @"Failed", errors);

        // TODO: temp workaround to force reload contact list
        [strongSelf resetFRCs];
        [strongSelf activateFRCs];
    }];
}

- (void)acceptContactRequest:(id<DWUserDetails>)userDetails {
    NSAssert([userDetails isKindOfClass:DWIncomingContactItem.class], @"Inconsistent state");
    if ([userDetails isKindOfClass:DWIncomingContactItem.class]) {
        DWIncomingContactItem *contact = (DWIncomingContactItem *)userDetails;
        DSWallet *wallet = [DWEnvironment sharedInstance].currentWallet;
        DSBlockchainIdentity *mineBlockchainIdentity = wallet.defaultBlockchainIdentity;
        __weak typeof(self) weakSelf = self;
        [mineBlockchainIdentity acceptFriendRequest:contact.friendRequestEntity
                                         completion:^(BOOL success, NSArray<NSError *> *_Nonnull errors) {
                                             __strong typeof(weakSelf) strongSelf = weakSelf;
                                             if (!strongSelf) {
                                                 return;
                                             }

                                             DSLogVerbose(@"DWDP: accept contact request %@: %@", success ? @"Succeeded" : @"Failed", errors);

                                             // TODO: temp workaround to update and force reload contact list
                                             [strongSelf fetchData];
                                         }];
    }
}

- (void)searchWithQuery:(NSString *)searchQuery {
    [self.dataSource searchWithQuery:searchQuery];

    [self.delegate contactsModelDidUpdate:self];
}

#pragma mark - DWFetchedResultsDataSourceDelegate

- (void)fetchedResultsDataSourceDidUpdate:(DWFetchedResultsDataSource *)fetchedResultsDataSource {
    NSAssert([NSThread isMainThread], @"Main thread is assumed here");

    if (fetchedResultsDataSource == self.incomingDataSource) {
        [self.aggregateDataSource reloadIncomingContactRequests:fetchedResultsDataSource.fetchedResultsController];
    }
    else {
        [self.aggregateDataSource reloadContacts:fetchedResultsDataSource.fetchedResultsController];
    }

    [self.delegate contactsModelDidUpdate:self];
}

#pragma mark - Private

- (void)activateFRCs {
    if (!self.incomingDataSource) {
        [self rebuildDataSources];
    }

    [self.incomingDataSource start];
    [self.contactsDataSource start];

    [self.aggregateDataSource beginReloading];
    [self.aggregateDataSource reloadIncomingContactRequests:self.incomingDataSource.fetchedResultsController];
    [self.aggregateDataSource reloadContacts:self.contactsDataSource.fetchedResultsController];
    [self.aggregateDataSource endReloading];

    [self.delegate contactsModelDidUpdate:self];
}

- (void)resetFRCs {
    [self.incomingDataSource stop];
    [self.contactsDataSource stop];
}

@end