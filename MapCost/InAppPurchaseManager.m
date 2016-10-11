//
//  InAppPurchaseManager.m
//  somoloread
//
//  Created by Andy on 12-10-11.
//
//

#import "InAppPurchaseManager.h"
#import "AppHelper.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

@implementation InAppPurchaseManager
@synthesize price,type;

static InAppPurchaseManager *instance = nil;

+ (InAppPurchaseManager*)sharedInstance
{
    @synchronized(self){
        if (instance == nil) {
            instance = [[InAppPurchaseManager alloc]init];
            [instance start];
        }
    }
    return instance;
}

- (void)start
{
    
}

- (void)requestProductData:(NSString*)productid
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    NSSet *productIdentifiers = [NSSet setWithObject:productid];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)requestProUpgradeProductData
{
    NSSet *productIdentifiers = [NSSet setWithObject:kInAppPurchaseProUpgradeProductId];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
    // we will release the request object in the delegate callback
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [SVProgressHUD dismiss];
    NSArray *products = response.products;
    proUpgradeProduct = [products count] == 1 ? [products lastObject] : nil;
    if (proUpgradeProduct)
    {
        NSLog(@"Product title: %@" , proUpgradeProduct.localizedTitle);
        NSLog(@"Product description: %@" , proUpgradeProduct.localizedDescription);
        NSLog(@"Product price: %@" , proUpgradeProduct.price);
        //self.price = [NSString stringWithFormat:@"%@%@",proUpgradeProduct.localizedTitle, proUpgradeProduct.price];
        NSLog(@"Product id: %@" , proUpgradeProduct.productIdentifier);
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:proUpgradeProduct.priceLocale];
        self.price = [numberFormatter stringFromNumber:proUpgradeProduct.price];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
    
    //去支付
    if (self.type == 2) {
        if (!proUpgradeProduct) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Can't connect to iTunes, Please try again later" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            return;
        }
        
        [self purchaseProUpgrade:proUpgradeProduct];
    }
}

- (void)loadStore
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
    [self requestProUpgradeProductData];
}

- (void)restore
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseProUpgrade:(SKProduct*)product
{
    float sysversion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (sysversion < 5.0) //5.0之前
    {
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:kInAppPurchaseProUpgradeProductId];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else
    {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)purchaseProUpgrade
{
    float sysversion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (sysversion < 5.0) //5.0之前
    {
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:kInAppPurchaseProUpgradeProductId];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else
    {
        if (!proUpgradeProduct) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable to Purchase" message:@"Invalid Product" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
        SKPayment *payment = [SKPayment paymentWithProduct:proUpgradeProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

#pragma -
#pragma Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProUpgradeProductId])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:kInAppPurchaseProUpgradeProductId])
    {
        // enable the pro features
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isProUpgradePurchased" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        NSString *curProductId = transaction.payment.productIdentifier;
        if ([curProductId isEqualToString:kInAppPurchaseProUpgradeProductId]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kIAPTransactionSucceededNotification object:self userInfo:userInfo];
            NSLog(@"upgrade success");
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kIAPDonateSucceededNotification object:self userInfo:userInfo];
        }
        // send out a notification that we’ve finished the transaction
        //mark the book as purchased
        NSLog(@"payment success");
        
        
        //记录应用内购买
        [[AppHelper sharedInstance] writePurchaseInfo];
        
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kIAPTransactionFailedNotification object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    if (queue.transactions.count == 0) {
        NSString *msg = @"No purchase history";
        NSLog(@"%@",msg);
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"%@", error.description);
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:error.description delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
}
@end
