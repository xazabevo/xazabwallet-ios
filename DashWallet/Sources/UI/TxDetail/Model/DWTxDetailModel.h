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

#import <Foundation/Foundation.h>

#import "DWTitleDetailItem.h"
#import "DWTransactionListDataProviderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class DSTransaction;

@interface DWTxDetailModel : NSObject

@property (readonly, nonatomic, strong) DSTransaction *transaction;

@property (readonly, nonatomic) NSString *transactionId;
@property (readonly, nonatomic) DSTransactionDirection direction;
@property (readonly, nonatomic) NSString *fiatAmountString;

- (NSAttributedString *)dashAmountStringWithFont:(UIFont *)font;

- (NSUInteger)inputAddressesCount;
- (NSUInteger)outputAddressesCount;
- (NSUInteger)specialInfoCount;
- (BOOL)hasFee;
- (BOOL)hasDate;

- (NSArray<id<DWTitleDetailItem>> *)inputAddressesWithFont:(UIFont *)font;
- (NSArray<id<DWTitleDetailItem>> *)outputAddressesWithFont:(UIFont *)font;
- (NSArray<id<DWTitleDetailItem>> *)specialInfoWithFont:(UIFont *)font;
- (nullable id<DWTitleDetailItem>)feeWithFont:(UIFont *)font tintColor:(UIColor *)tintColor;
- (id<DWTitleDetailItem>)date;

- (nullable NSURL *)explorerURL;

- (BOOL)copyTransactionIdToPasteboard;

- (instancetype)initWithTransaction:(DSTransaction *)transaction
                       dataProvider:(id<DWTransactionListDataProviderProtocol>)dataProvider;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
