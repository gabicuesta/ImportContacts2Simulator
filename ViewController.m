//
//  ViewController.m
//  AddContacts2Simulator
//
//  Created by Gabriel Cuesta Arza on 20/4/17.
//  Copyright © 2017 Gabriel Cuesta Arza. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loadContacts:(UIButton *)sender {
    [self addSampleContacts];
}

- (IBAction)deleteContacts:(UIButton *)sender {
    [self removeSampleContacts];
}

-(void)addSampleContacts
{
    NSError *error;
    CFErrorRef castError = (__bridge CFErrorRef)error;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &castError);
    __block BOOL accessAllowed = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6 or above
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessAllowed = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    
    if(accessAllowed)
    {
        NSString *vFilePath = [[NSBundle mainBundle] pathForResource:@"YourContactFile" ofType:@"vcf"];
        NSData *myData = [NSData dataWithContentsOfFile:vFilePath];
        CFDataRef vCardData = (__bridge CFDataRef)myData;
        
        NSError *error;
        CFErrorRef castError = (__bridge CFErrorRef)error;
        ABAddressBookRef ContactBook = ABAddressBookCreateWithOptions(NULL, &castError);
        ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(ContactBook);
        CFArrayRef vCardContact = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, vCardData);
        NSArray *arrayContacts = (__bridge_transfer NSArray *)vCardContact;
        NSInteger totalVCFContactCount = arrayContacts.count;
        
        for (CFIndex index = 0; index < totalVCFContactCount; index++)
        {
            ABRecordRef contact = CFArrayGetValueAtIndex(vCardContact, index);
            ABAddressBookAddRecord(ContactBook, contact, NULL);
            ABAddressBookSave(ContactBook, nil);
            CFRelease(contact);
        }
        
        CFRelease(vCardContact);
        CFRelease(defaultSource);
    }
    
    
    NSLog(@"Contacts added.");
}

-(void)removeSampleContacts
{
    NSError *error;
    CFErrorRef castError = (__bridge CFErrorRef)error;
    ABAddressBookRef contactBook = ABAddressBookCreateWithOptions(NULL, &castError);
    
    __block BOOL accessAllowed = NO;
    
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6 or above
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(contactBook, ^(bool granted, CFErrorRef error) {
            accessAllowed = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    
    if(accessAllowed)
    {
        CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople( contactBook );
        NSArray *arrayContacts = (__bridge_transfer NSArray *)allContacts;
        
        for ( int i = 0; i < arrayContacts.count; i++ )
        {
            ABRecordRef ref = CFArrayGetValueAtIndex(allContacts, i);
            ABAddressBookRemoveRecord(contactBook, ref, nil);
            ABAddressBookSave(contactBook, nil);
        }
    }
    
    NSLog(@"Contacts removed.");
}


@end
