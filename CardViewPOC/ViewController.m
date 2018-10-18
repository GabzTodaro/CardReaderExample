//
//  ViewController.m
//  CardViewPOC
//
//  Created by Gabriel Todaro on 17/10/18.
//  Copyright © 2018 Todaro. All rights reserved.
//

#import "ViewController.h"
#import "CardIO.h"

@interface ViewController () <CardIOPaymentViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *mCardNumber;
@property (weak, nonatomic) IBOutlet UITextField *mExpDate;
@property (weak, nonatomic) IBOutlet UITextField *mCVV;
@property (weak, nonatomic) IBOutlet UITextField *mHolderName;
@property (weak, nonatomic) IBOutlet UISwitch *mHolderNameSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *mSupressCardImageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *mSecureCardNumberSwitch;

@end

@implementation ViewController {
    BOOL mHolderName;
    BOOL mSupressCardImage;
    BOOL mSecureCardNumber;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    mHolderName = FALSE;
    [_mHolderNameSwitch setOn:mHolderName];
    
    mSupressCardImage = FALSE;
    [_mSupressCardImageSwitch setOn:mSupressCardImage];
    
    mSecureCardNumber = FALSE;
    [_mSecureCardNumberSwitch setOn:mSecureCardNumber];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CardIOUtilities preloadCardIO];
}

- (IBAction)openCardViewController:(id)sender {
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    [self presentViewController:scanViewController animated:YES completion:nil];
    
    [scanViewController setScanInstructions:@"Put your credit card into the box.\nJust wait after."];
    [scanViewController setHideCardIOLogo:TRUE];
    
    // Asks for user input Holder's Name
    [scanViewController setCollectCardholderName:mHolderName];
    
    // Set rect color
    [scanViewController setGuideColor:[UIColor greenColor]];
    
    // Supress the card image when scanned, showing the card number and the expeditor image
    [scanViewController setSuppressScannedCardImage:mSupressCardImage];    
    
}
- (IBAction)holderNameSwitchTouched:(id)sender {
    mHolderName = !mHolderName;
}
- (IBAction)supressCardImageTouched:(id)sender {
    mSupressCardImage = !mSupressCardImage;
    
    if (mSupressCardImage){
        mHolderName = FALSE;
        [_mHolderNameSwitch setOn:FALSE];
    }
}
- (IBAction)secureCardNumberTouched:(id)sender {
    mSecureCardNumber = !mSecureCardNumber;
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    NSLog(@"User canceled payment info");
    // Handle user cancellation here...
    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)cardInfo inPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    // The full card number is available as info.cardNumber, but don't log that!
    NSLog(@"Received card info. Number: %@, expiry: %02lu/%lu, cvv: %@.", cardInfo.redactedCardNumber, (unsigned long)cardInfo.expiryMonth, (unsigned long)cardInfo.expiryYear, cardInfo.cvv);
    // Use the card info...
    
    _mCardNumber.text   = mSecureCardNumber ? cardInfo.redactedCardNumber : cardInfo.cardNumber;
    _mExpDate.text      = [NSString stringWithFormat:@"%lu / %lu", cardInfo.expiryMonth, cardInfo.expiryYear];
    _mCVV.text          = cardInfo.cvv;
    _mHolderName.text   = cardInfo.cardholderName;
    
    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
