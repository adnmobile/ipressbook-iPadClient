    //
//  PDFClientsViewController.m
//  IsoToner
//
//  Created by Guillaume Cerquant on 20/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#include <CommonCrypto/CommonDigest.h>
#import "MMURLConnection.h"



#import "PDFClientsViewController.h"

NSString * const kDateLastUpdateOfClientsPDFFile = @"DateLastUpdateOfClientsPDFFile";
NSString * const kDateLastUpdateOfRupturePDFFile = @"DateLastUpdateOfRupturePDFFile";

// Perso, on DropBox
NSString * const kURLOfPlistFileWithSyncDataForClients = @"http://dl.dropbox.com/u/1899122/www/IsoToner/PDF_File_sync_info_Clients.plist";
NSString * const kURLOfPlistFileWithSyncDataForRupture = @"http://dl.dropbox.com/u/1899122/www/IsoToner/PDF_File_sync_info_Rupture.plist";
// NSString * const kURLOfPlistFileWithSyncDataForClients = @"http://blumpit.com/Download%20Area/PDF_File_sync_info_Clients.plist";
// NSString * const kURLOfPlistFileWithSyncDataForRupture = @"http://blumpit.com/Download%20Area/PDF_File_sync_info_Rupture.plist";


@interface PDFClientsViewController (PrivateMethods)


- (void)updateTextOfUpdateInfoLabel;
- (void)updateTextOfUpdateInfoLabel;
- (NSURL *)URLOfDownloadedPDFFile;

- (void)downloadPDFFileAtURL:(NSURL *)anURL;

- (void)downloadSyncPlistFileAtURL:(NSString *) urlOfPlistFile;
- (BOOL)isChecksumOfFileDownloadedAtPathOk:(NSString *) tempFilePath;
- (void)closeHUDView;

- (NSString *)pathOfPDFFileInDocumentsFolder;

- (NSString *)keyOfLastUpdate;
- (NSString *)keyOfMD5;
- (NSString *)keyOfURL;

- (void)fileFetchComplete:(ASIHTTPRequest *)request;
- (void)fileFetchFailed:(ASIHTTPRequest *)request;



@end

@implementation PDFClientsViewController

@synthesize onlineMd5Checksum;


- (void)dealloc {
	[networkQueue reset];
	[networkQueue release];
	
	
    [super dealloc];
}



- (NSString *)keyForPlistFile {
	if (fiche_clients == [self typeOfInstanceOfPDFViewController] ) {
		return kURLOfPlistFileWithSyncDataForClients;
	} else if (etat_rupture == [self typeOfInstanceOfPDFViewController] ) {
		return kURLOfPlistFileWithSyncDataForRupture;
	} else {
		NSLog(@"Unexpected value");
		return nil;
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];

	[webViewForPDFFile loadRequest:[NSURLRequest requestWithURL:[self URLOfDownloadedPDFFile]]];
	
	[self updateTextOfUpdateInfoLabel];
	
	updateRequestIsManual = NO;
	
	[self downloadSyncPlistFileAtURL:[self keyForPlistFile]];
}

- (NSURL *)URLOfDownloadedPDFFile {
	return [NSURL fileURLWithPath:[self pathOfPDFFileInDocumentsFolder]];
}


- (void)updateTextOfUpdateInfoLabel {
	NSDateFormatter *dateFormatter;
	NSDate *dateOfLastUpdate;
	
	dateOfLastUpdate = [[NSUserDefaults standardUserDefaults] valueForKey:[self keyOfLastUpdate]];
	
	// NSLog(@"%s date: %@", _cmd, dateOfLastUpdate);
	
	
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];

	
	[updateInfoLabel setText:[NSString stringWithFormat:@"Dernière mise à jour : %@", (nil != dateOfLastUpdate ? [dateFormatter stringFromDate:dateOfLastUpdate] : @"date inconnue")]];	
	
	[dateFormatter release];
}

// refactor method name (now using the timestamp specified in plist)
- (void)setLastUpdateDateUsingTimeStamp:(NSString *) timestamp {
	NSDate *dateOfLastUpdate;
	                                                                                
	NSLog(@"%s timestamp: %@", _cmd, timestamp);
	
	dateOfLastUpdate = [NSDate dateWithTimeIntervalSince1970:[timestamp integerValue]]; 
	
	[[NSUserDefaults standardUserDefaults] setValue:dateOfLastUpdate forKey:[self keyOfLastUpdate]];
	
	[self updateTextOfUpdateInfoLabel];
}




- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)showTheHUDView {
	theHUD = [[MBProgressHUD alloc] initWithView:self.view]; // CGRectMake(20, 20, 1024 - 20 * 2, 500)];
	
	theHUD.labelText = @"Téléchargement en cours";
    theHUD.detailsLabelText = @"Merci de patienter";

	[theHUD setMode:MBProgressHUDModeCustomView];
	[theHUD addSubview:subViewOfHUD];
	
	[theHUD show:YES];
	[self.view addSubview:theHUD];
}


- (IBAction)updateFileAction:(id)sender {
	[self showTheHUDView];
	
	updateRequestIsManual = YES;
	[self downloadSyncPlistFileAtURL:[self keyForPlistFile]];
	
}

- (IBAction)goToFullScreenMode:(id)sender {
	NSURL *fileURL;
	
	fileURL = [self URLOfDownloadedPDFFile];
	
	if (! fileURL) {
		
		return;
	}
	
	
	docController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
		
	docController.delegate = self;
	
	[docController retain];
	

	BOOL result = [docController presentPreviewAnimated:YES];
	
	if (NO == result) {
		NSLog(@"Keep in mind that the previewAnimated does not work in the simulator");
	}
}

- (IBAction)stopDownloadOfFileInProgress:(id)sender {
	[theHUD hide:YES];
	[theHUD release];
	theHUD = nil;
	
	[networkQueue reset];
	[networkQueue release];
	networkQueue = nil;
}

#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
	return self;
	return self.parentViewController;
}

#pragma mark -
#pragma mark Download of file

- (void)downloadSyncPlistFileAtURL:(NSString *) urlOfPlistFile {
	if (nil == urlOfPlistFile) {
		NSLog(@"Nil urlOfPlistFile");
	} else {
		theConnection = [[MMURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlOfPlistFile]]
										delegate:self
										userInfo:nil];
	}
}



#pragma mark -
#pragma mark <MMURLConnectionDelegate>

- (void)connection:(MMURLConnection *)connection didFailWithError:(NSError *)error {
	[connection release];
	
	NSLog(@"%s could not download plist file", _cmd);
}

- (void)connection:(MMURLConnection *)connection didReceiveData:(NSData *)data {
	[connection.responseData appendData:data];        
}


- (void)closeHUDViewAndShowAlertViewErrorMessageWithString:(NSString *)errorMessage {
	if (updateRequestIsManual) {			
		[self closeHUDView];
		
		[[[[UIAlertView alloc] initWithTitle:@"Erreur"
                                     message:errorMessage
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil] autorelease] show];
	}
}

- (void)connectionDidFinishLoading:(MMURLConnection *)connection {
	NSDictionary *syncInfoDictionary;
	NSString *urlOfPDF;
	
	syncInfoDictionary = [NSPropertyListSerialization propertyListFromData:[connection responseData]
	                                                              mutabilityOption:NSPropertyListImmutable
	                                                                        format:NULL
	                                                              errorDescription:nil];
		
	if (!syncInfoDictionary) {
		[self closeHUDViewAndShowAlertViewErrorMessageWithString:@"Les infos de synchronisation ne sont pas correctes.\n\n(Le fichier plist fourni n'est pas valide.)"];
		return;
	}
	
	[self setOnlineMd5Checksum:[syncInfoDictionary valueForKey:@"MD5ChecksumFile"]];
	
	if (nil == [self onlineMd5Checksum] || [[self onlineMd5Checksum] isEqualToString:@""]) {
		[self closeHUDViewAndShowAlertViewErrorMessageWithString:@"Les infos de synchronisation ne sont pas correctes.\n\n(Le md5 fourni n'est pas valide.)"];		
		
		return;
	}
	
	// NSLog(@"%s comparaisa %@ | %@", _cmd, [[NSUserDefaults standardUserDefaults] valueForKey:[self keyOfMD5]], [self onlineMd5Checksum]);
	
	
	BOOL md5OnlineAndDownloadedAreTheSame = [[[NSUserDefaults standardUserDefaults] valueForKey:[self keyOfMD5]] isEqualToString:[self onlineMd5Checksum]];
	
	if (NO == updateRequestIsManual) {
		// Automatic update
		if (NO == md5OnlineAndDownloadedAreTheSame) {
			[[self tabBarItem] setBadgeValue:@"1"];
		}
		
		return;
	} 


	if (md5OnlineAndDownloadedAreTheSame) {
		[self closeHUDView];
		
		[[[[UIAlertView alloc] initWithTitle:nil
                                     message:@"Fichier local déjà à jour."
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil] autorelease] show];
		
		
		return;
	}
	
	
	
	urlOfPDF = [syncInfoDictionary valueForKey:[self keyOfURL]];	
	

	if (nil == urlOfPDF || [urlOfPDF isEqualToString:@""]) {
		[self closeHUDViewAndShowAlertViewErrorMessageWithString:[NSString stringWithFormat:@"Les infos de synchronisation ne sont pas correctes.\n\n(L'url fournie n'est pas valide.)\nURL: '%@'", urlOfPDF]];		
		return;
	}
	
	if (nil != urlOfPDF) {
		[self downloadPDFFileAtURL:[NSURL URLWithString:urlOfPDF]];
	} else {
		NSLog(@"Nil url");
	}
	
	NSLog(@"%s dico : %@", _cmd, syncInfoDictionary);
	
	timestamp1 = [[syncInfoDictionary valueForKey:@"dateTimestampOfUpdate"] retain];
	
	if (nil == timestamp1 || [timestamp1 isEqualToString:@""]) {
		[self closeHUDViewAndShowAlertViewErrorMessageWithString:@"Les infos de synchronisation ne sont pas correctes.\n\n(La date de mise à jour n'est pas valide.)"];		
		return;	
	}
	
	[fileDownloadProgressView setHidden:NO];

	[connection release];
}



#pragma mark Download using HTTPRequest
- (void)downloadPDFFileAtURL:(NSURL *)anURL {
	
	if (!networkQueue) {
		networkQueue = [[ASINetworkQueue alloc] init];	
	}
	failed = NO;
	[networkQueue reset];
	[networkQueue setDownloadProgressDelegate:fileDownloadProgressView];
	[networkQueue setRequestDidFinishSelector:@selector(fileFetchComplete:)];
	[networkQueue setRequestDidFailSelector:@selector(fileFetchFailed:)];
	[networkQueue setShowAccurateProgress:YES];
	[networkQueue setDelegate:self];
	
	ASIHTTPRequest *request;
	
	
	request = [ASIHTTPRequest requestWithURL:anURL];
	
	// [request setValidatesSecureCertificate:NO];  // Careful with IsoToner server. Weird side-effect ("failed to find PDF header: `%PDF' not found", "invalid md5"....)
	
	
	[request setDownloadDestinationPath:[self pathOfPDFFileInDocumentsFolder]];
	[request setDownloadProgressDelegate:fileDownloadProgressView];
	[networkQueue addOperation:request];
		
	[networkQueue go];
	
}

- (NSString *)pathOfPDFFileInDocumentsFolder {
	if (fiche_clients == [self typeOfInstanceOfPDFViewController] ) {
		return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"PDF1.pdf"];
	} else if (etat_rupture == [self typeOfInstanceOfPDFViewController] ) {
		return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"PDF2.pdf"];		
	} else {
		NSLog(@"Unexpected value");
		return nil;
	}
	
	
	
}

- (void)closeHUDView {
	[theHUD hide:YES];
	[theHUD release];
	theHUD = nil;
}

- (void)fileFetchComplete:(ASIHTTPRequest *)request
{
	
	[self closeHUDView];
	
	
	if (NO == [self isChecksumOfFileDownloadedAtPathOk:[request downloadDestinationPath]]) {
		[[[[UIAlertView alloc] initWithTitle:@"Erreur" message:@"Le md5 du fichier téléchargé ne correspond pas au md5 attendu." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];		
	} else {
		[[[[UIAlertView alloc] initWithTitle:@"Téléchargement réussi" message:@"La mise à jour du fichier pdf a été effectuée avec succès." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
		[self setLastUpdateDateUsingTimeStamp:timestamp1];
		
		[[NSUserDefaults standardUserDefaults] setValue:[self onlineMd5Checksum] forKey:[self keyOfMD5]];
		[webViewForPDFFile loadRequest:[NSURLRequest requestWithURL:[self URLOfDownloadedPDFFile]]];
	}
	[[self tabBarItem] setBadgeValue:nil];
	
}

- (void)fileFetchFailed:(ASIHTTPRequest *)request {
	UIAlertView *alertView;
	
	[self closeHUDView];
	
	if (!failed) {
		if ([[request error] domain] != NetworkRequestErrorDomain || [[request error] code] != ASIRequestCancelledErrorType) {
			alertView = [[[UIAlertView alloc] initWithTitle:@"Erreur" message:[NSString stringWithFormat:@"La mise à jour du fichier pdf n'a pas pu être effectué.\n\n(%@\n)", [[request error] localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
			[alertView show];
		}
		failed = YES;
	}
}


#pragma mark MD5_CHECKSUM

#define CC_MD5_DIGEST_LENGTH 16
#define MD5_DIGEST_LENGTH 16
- (NSString *)md5OfFileAtPath:(NSString *) filePath {
	NSData *fileData;
	NSString *computedMD5Checksum = nil;
	NSMutableData *digest;

 	fileData = [[NSData alloc] initWithContentsOfFile:filePath];
	if (nil == fileData) {
		NSLog(@"File data should not be nil");
		return nil;
	}
	
	
	digest = [NSMutableData dataWithLength:MD5_DIGEST_LENGTH];
	if (digest && CC_MD5([fileData bytes], [fileData length], [digest mutableBytes])) {
		computedMD5Checksum = [[[digest description] stringByReplacingOccurrencesOfString:@" " withString:@""] 
													stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	} else {
		NSLog(@"Couldn't compute MD5 of downloaded database");
	}
	
	[fileData release];
	
	return computedMD5Checksum;
}


- (BOOL)isChecksumOfFileDownloadedAtPathOk:(NSString *) tempFilePath {
	NSString *computedMD5Checksum;
	BOOL res;
	
	computedMD5Checksum = [self md5OfFileAtPath:tempFilePath];
	
	if (nil == computedMD5Checksum) {
		return NO;
	}
	
	
	res = [computedMD5Checksum isEqualToString:[self onlineMd5Checksum]];
	// [self setOnlineMd5Checksum:nil];
	
	return res;
}

#pragma mark UIWebView Delegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[[[UIAlertView alloc] initWithTitle:@"Erreur" message:@"Le fichier n'a pas pu être chargé" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
}


- (pdf_view_controllers) typeOfInstanceOfPDFViewController {
	NSUInteger tagOfTabBarItem;
	
	tagOfTabBarItem = [[self tabBarItem] tag];
	
	switch (tagOfTabBarItem) {
		case 1:
			return fiche_clients;
			break;
		case 2:
			return etat_rupture;
			break;
		default:
			NSAssert(NO, @"Unexpected tag");
			return 0;
	}
}


#pragma mark Keys depending on who is calling
- (NSString *)keyOfLastUpdate {
	if (fiche_clients == [self typeOfInstanceOfPDFViewController] ) {
		return kDateLastUpdateOfClientsPDFFile;
	} else if (etat_rupture == [self typeOfInstanceOfPDFViewController] ) {
		return kDateLastUpdateOfRupturePDFFile;
	} else {
		NSLog(@"Unexpected value");
		return nil;
	}
}

- (NSString *)keyOfMD5 {
	if (fiche_clients == [self typeOfInstanceOfPDFViewController] ) {
		return @"MD5ChecksumFile1";
	} else if (etat_rupture == [self typeOfInstanceOfPDFViewController] ) {
		return @"MD5ChecksumFile2";
	} else {
		NSLog(@"Unexpected value");
		return nil;
	}
}


- (NSString *)keyOfURL {
	return @"urlOfPDFFile";
	
	// if (fiche_clients == [self typeOfInstanceOfPDFViewController] ) {
	// 	return @"urlOfPDFFile1";
	// } else if (etat_rupture == [self typeOfInstanceOfPDFViewController] ) {
	// 	return @"urlOfPDFFile2";
	// } else {
	// 	NSLog(@"Unexpected value");
	// 	return nil;
	// }	
}


- (void)tabBarWasClicked:(id)sender {
	if ([[[self tabBarItem] badgeValue] isEqualToString:@"1"]) {
		[self updateFileAction:self];
	}
	
}

@end
