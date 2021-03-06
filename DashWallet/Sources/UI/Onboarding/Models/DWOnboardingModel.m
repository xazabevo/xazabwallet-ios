//
//  Created by Andrew Podkovyrin
//  Copyright © 2019 Dash Core Group. All rights reserved.
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

#import "DWOnboardingModel.h"

NS_ASSUME_NONNULL_BEGIN

// use legacy User Defaults key to determine if this is an upgrade process
static NSString *const HAS_WALLET_FLAG = @"BALANCE";

@interface DWOnboardingPage : NSObject <DWOnboardingPageProtocol>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detail;

@end

@implementation DWOnboardingPage

@end

#pragma mark - Model

@implementation DWOnboardingModel

- (instancetype)init {
    self = [super init];
    if (self) {
        NSMutableArray<id<DWOnboardingPageProtocol>> *items = [NSMutableArray array];

        {
            DWOnboardingPage *page = [[DWOnboardingPage alloc] init];
            const BOOL hasWallet = [[NSUserDefaults standardUserDefaults] objectForKey:HAS_WALLET_FLAG] != nil;
            if (hasWallet) {
                page.title = NSLocalizedString(@"We Upgraded", nil);
            }
            else {
                page.title = NSLocalizedString(@"Welcome", nil);
            }
            page.detail = NSLocalizedString(@"An intuitive and familiar experience across all your devices", nil);
            [items addObject:page];
        }

        {
            DWOnboardingPage *page = [[DWOnboardingPage alloc] init];
            page.title = NSLocalizedString(@"Pay with Ease", nil);
            page.detail = NSLocalizedString(@"Pay and get paid instantly with easy to use payment flows", nil);
            [items addObject:page];
        }

        {
            DWOnboardingPage *page = [[DWOnboardingPage alloc] init];
            page.title = NSLocalizedString(@"More Control", nil);
            page.detail = NSLocalizedString(@"Have complete control and customize your wallet based on your needs", nil);
            [items addObject:page];
        }

        _items = [items copy];
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
