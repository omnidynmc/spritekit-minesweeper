//
//  OESTwitterManager.m
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

#import "OESTwitterManager.h"
#import "OESTwitterAction.h"

NSString *OESTwitterManagerUrlFavorite = @"https://api.twitter.com/1/favorites/create/%@.json";
NSString *OESTwitterManagerUrlUnfavorite = @"https://api.twitter.com/1/favorites/destroy/%@.json";
NSString *OESTwitterManagerUrlRetweet = @"https://api.twitter.com/1/statuses/retweet/%@.json";

@interface OESTwitterManager ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccountType *accountType;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) OESTwitterAction *twitterAction;
@property (nonatomic, strong) UIAlertView *loadingAlertView;
@end

@implementation OESTwitterManager

#pragma mark - Shared Instance Setup

OESSHARED_INSTANCE(OESTwitterManager *)

#pragma mark - Public

- (void)postRetweet:(NSString *)idStr object:(id)object
{
    OESTwitterAction *twitterAction = [OESTwitterAction new];
    twitterAction.twitterId = idStr;
    twitterAction.action = OESTwitterActionRetweet;
    twitterAction.object = object;
        
    [self postToTwitterApi:[NSString stringWithFormat:OESTwitterManagerUrlRetweet, idStr] twitterAction:twitterAction];
}

- (void)postFavorite:(NSString *)idStr object:(id)object
{
    OESTwitterAction *twitterAction = [OESTwitterAction new];
    twitterAction.twitterId = idStr;
    twitterAction.action = OESTwitterActionFavorite;
    twitterAction.object = object;
        
    [self postToTwitterApi:[NSString stringWithFormat:OESTwitterManagerUrlFavorite, idStr] twitterAction:twitterAction];
}

- (void)postUnfavorite:(NSString *)idStr object:(id)object
{
    OESTwitterAction *twitterAction = [OESTwitterAction new];
    twitterAction.twitterId = idStr;
    twitterAction.action = OESTwitterActionUnfavorite;
    twitterAction.object = object;
    [self postToTwitterApi:[NSString stringWithFormat:OESTwitterManagerUrlUnfavorite, idStr] twitterAction:twitterAction];
}

- (void)postToTwitterApi:(NSString *)urlString twitterAction:(OESTwitterAction *)twitterAction
{
    self.url = [NSURL URLWithString:urlString];
    self.twitterAction = twitterAction;

    __block OESTwitterManager *weakSelf = self;

    // Request access from the user to use their Twitter accounts.
    [self.accountStore requestAccessToAccountsWithType:self.accountType withCompletionHandler:^(BOOL granted, NSError *error) {

        // always dismiss before we do anything else
        [weakSelf.loadingAlertView dismissWithClickedButtonIndex:0 animated:YES];
        self.loadingAlertView = nil;

        if (granted) {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [self.accountStore accountsWithAccountType:weakSelf.accountType];

            // is allowed and there are multiple accounts, allow the user to choose
            if ([accountsArray count] > 1 && [weakSelf isAllowAccountChoice]) {
                [self displayMultiAccountSelection:accountsArray];
            } // if
            else if ([accountsArray count] > 0) {
                // Grab the initial Twitter account to tweet from.
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                

                [weakSelf postURLRequestWithAccount:twitterAccount url:weakSelf.url twitterAction:twitterAction];
            } // else if
            else if ([accountsArray count] == 0) {
              [OESTwitterManager displayNoTwitterAccountsAlert];
            } // else if
        } // if
        else {
            [OESTwitterManager displayNoAccessToTwitterAccountsAlert];
        } // else
    }];
}

+ (void)displayNoAccessToTwitterAccountsAlert
{
      // make sure this happens on the main thread
    dispatch_async(dispatch_get_main_queue(), ^ {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Twitter Account Access", @"")
                                                         message:NSLocalizedString(@"Access to your Twitter account was denied. You can enable accesss to Twitter accounts in Settings.", @"")
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                               otherButtonTitles:nil];
        [alertView show];
    });
}

- (BOOL)registerDelegate:(id <OESTwitterManagerDelegate>)delegate
{
    BOOL alreadyRegistered = [self.delegates containsObject:delegate];

    if (alreadyRegistered)
        return NO;

    NSMutableArray *delegates = [NSMutableArray arrayWithArray:self.delegates];
    [delegates addObject:delegate];

    self.delegates = delegates;

    return YES;
}

- (BOOL)unregisterDelegate:(id <OESTwitterManagerDelegate>)delegate
{
    BOOL alreadyRegistered = [self.delegates containsObject:delegate];

    if (!alreadyRegistered) {
        OESLogWarn(@"Possible memory leak, Twitter Manager could not unregisterDelegate(%d), not found: %@", [self.delegates count], delegate)
        return NO;
    } // if

    NSMutableArray *delegates = [NSMutableArray arrayWithArray:self.delegates];
    [delegates removeObject:delegate];

    self.delegates = delegates;

    return YES;
}


#pragma mark - Private

// copied from DETweet for consistency
+ (void)displayNoTwitterAccountsAlert
    // We have an instance method that's identical to this. Make sure it stays identical.
    // This duplicates the message and buttons displayed in Apple's TWTweetComposeViewController alert message.
{
      // make sure this happens on the main thread
    dispatch_async(dispatch_get_main_queue(), ^ {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Twitter Accounts", @"")
                                                         message:NSLocalizedString(@"There are no Twitter accounts configured. You can configure or create a Twitter account in Settings.", @"")
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                               otherButtonTitles:nil];
        [alertView show];
    });
}

- (void)presentAccountSelectorActionSheet
{
    // make sure this happens on the main thread
    dispatch_async(dispatch_get_main_queue(), ^ {
        UIActionSheet *sheet = [[UIActionSheet alloc] init];
        sheet.title = nil;
        sheet.delegate = self;
 
        for(ACAccount *account in self.accounts) {
            [sheet addButtonWithTitle:[NSString stringWithFormat:@"@%@", account.username]];
        } // for

        sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    
        // Show the sheet
        [sheet showInView:[[UIApplication sharedApplication] keyWindow]];
    }); // dispatch_async
}

- (void)displayMultiAccountSelection:(NSArray *)accounts
{
    self.accounts = [[NSArray alloc] initWithArray:accounts];
    
    [self presentAccountSelectorActionSheet];
}

- (void)postURLRequestWithAccount:(ACAccount *)twitterAccount url:(NSURL *)url twitterAction:(OESTwitterAction *)twitterAction
{
    // Create a request, which in this example, posts a tweet to the user's timeline.
    // This example uses version 1 of the Twitter API.
    // This may need to be changed to whichever version is currently appropriate.
    TWRequest *postRequest = [[TWRequest alloc] initWithURL:url parameters:nil requestMethod:TWRequestMethodPOST];

    // Set the account used to post the tweet.
    [postRequest setAccount:twitterAccount];

    // Perform the request created above and create a handler block to handle the response.
    __block OESTwitterManager *blockSelf = self;
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSInteger statusCode = [urlResponse statusCode];

        NSError *jsonError;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];

        OESLogInfo(@"Twitter Request Response: status code %d, status message %@, error %@, headers %@, data %@", statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode], error, [urlResponse allHeaderFields], dict);
        
        // let our delegate know what happened
        if (statusCode == 200) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [blockSelf.delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [obj twitterPostDidSucceed:dict twitterAction:twitterAction];
                }];
            });
        } // if
        else {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [blockSelf.delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [obj twitterPostDidFail:dict twitterAction:twitterAction];
                }];
            });
        } // else

    }];

}

- (void)selectedAccountAt:(NSInteger)row
{
    ACAccount *account = [self.accounts objectAtIndex:row];
    [self postURLRequestWithAccount:account url:self.url twitterAction:self.twitterAction];
}

#pragma mark - Accessor Overrides

- (NSArray *)delegates
{
    return !isNil(_delegates) ? _delegates : (_delegates = [NSArray new]);
}

- (ACAccountStore *)accountStore
{
    if (!isNil(_accountStore))
        return _accountStore;
    
    // default to allow choosing which account to use
    self.allowAccountChoice = YES;
    
    _accountStore = [ACAccountStore new];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    self.accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    return _accountStore;
}

#pragma mark - <UIActionSheetDelegate>

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= [self.accounts count]) {
        // canceled
        return;
    } // if
    
    [self selectedAccountAt:buttonIndex];
}

@end
