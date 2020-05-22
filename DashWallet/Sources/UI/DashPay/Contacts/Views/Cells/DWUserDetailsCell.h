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

#import <UIKit/UIKit.h>

#import "DWUserDetails.h"

NS_ASSUME_NONNULL_BEGIN

@class DWUserDetailsCell;

@protocol DWUserDetailsCellDelegate <NSObject>

- (void)userDetailsCell:(DWUserDetailsCell *)cell didAcceptContact:(id<DWUserDetails>)contact;
- (void)userDetailsCell:(DWUserDetailsCell *)cell didDeclineContact:(id<DWUserDetails>)contact;

@end

@interface DWUserDetailsCell : UITableViewCell

@property (readonly, nullable, nonatomic, strong) id<DWUserDetails> userDetails;
@property (nullable, nonatomic, weak) id<DWUserDetailsCellDelegate> delegate;

- (void)setUserDetails:(id<DWUserDetails>)userDetails highlightedText:(nullable NSString *)highlightedText;

@end

NS_ASSUME_NONNULL_END