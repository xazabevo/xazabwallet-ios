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

#import "DWProfileDisplayNameCellModel.h"

@implementation DWProfileDisplayNameCellModel

- (DWTextFieldFormValidationResult *)postValidate {
    NSUInteger len = self.text.length;
    const NSUInteger max = 20;
    NSString *info = [NSString stringWithFormat:NSLocalizedString(@"%ld/%ld Characters", @"10/20 Characters"),
                                                len, max];
    if (len > max) {
        return [[DWTextFieldFormValidationResult alloc] initWithError:info];
    }
    return [[DWTextFieldFormValidationResult alloc] initWithInfo:info];
}

@end
