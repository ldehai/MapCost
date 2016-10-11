//
//  InAppPurchaseManager.h
//  somoloread
//
//  Created by Andy on 12-10-11.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kIAPTransactionFailedNotification @"kIAPTransactionFailedNotification"
#define kIAPTransactionSucceededNotification @"kIAPTransactionSucceededNotification"

#define kInAppPurchaseProUpgradeProductId @"com.amstudio.mapcostupgrade"
#define kInAppPurchaseDonate1ProductId @"com.amstudio.donate1"
#define kInAppPurchaseDonate2ProductId @"com.amstudio.donate2"
#define kIAPDonateSucceededNotification @"kIAPDonateSucceededNotification"

@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProduct *proUpgradeProduct;
    SKProductsRequest *productsRequest;
}


@property (nonatomic,retain) NSString *price;
@property (nonatomic,assign) int type;

+ (InAppPurchaseManager*)sharedInstance;

- (void)requestProductData:(NSString*)productid;
- (void)requestProUpgradeProductData;
- (void)loadStore;
- (void)restore;
- (BOOL)canMakePurchases;
- (void)purchaseProUpgrade;
- (void)purchaseProUpgrade:(SKProduct*)product;

@end
