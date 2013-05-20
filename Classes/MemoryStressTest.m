//
//  MemoryStressTest.m
//  immobilier
//
//  Created by Medhi NAITMAZI on 21/12/10.
//  Copyright 2010 Neotilus. All rights reserved.
//

#pragma mark -
#pragma mark Memory stress test
#define MEMORY_STRESS_TEST_SCARCITY_ENABLED				0 // In production mode, this should be set to 0
#define MEMORY_STRESS_LOW_MEMORY_WARNINGS_SIMULATED		0 // In production mode, this should be set to 0

#if (MEMORY_STRESS_TEST_SCARCITY_ENABLED || MEMORY_STRESS_LOW_MEMORY_WARNINGS_SIMULATED) && !(DEVELOPMENT_MODE)
//#error I don't think you really want to compile this.
#endif

#import "MemoryStressTest.h"

@interface MemoryStressTest (PrivateMethods)
- (void)launchStressTestWithDelay:(int)delay;
- (void)stressTestTheApplicationBySimulatingMemoryScarcity;

- (void)simulateRepeatingLowMemoryWarningsWithTimeInterval:(NSTimeInterval)seconds;

@end

 
@implementation MemoryStressTest

- (void)launchStressTests
{
	[self launchStressTestWithDelay:2];	
	[self simulateRepeatingLowMemoryWarningsWithTimeInterval:5.0];
}

//- (void)dealloc {
//	// Does nothing on purpose
//	// TODO: why? That registers as a leak in Instruments. This object could be retained, and this dealloc never called.
//    
//}

- (id)init {
	if ( (self = [super init]) ) {
		dataToRetainToSimulateMemoryScarcity = [[NSData alloc] init];
	}
	return self;
}

- (void)launchStressTestWithDelay:(int)delay {
	[self performSelector:@selector(stressTestTheApplicationBySimulatingMemoryScarcity)
               withObject:nil
               afterDelay:delay];
}

#define MEGA (1024 * 1024)
- (void)stressTestTheApplicationBySimulatingMemoryScarcity
{
	
	NSUInteger sizeInMB = 20; 		// Size in MB. The higher, the more memory will be used here, leaving less for the application
	// On iPad: 30 seems to be the upper limit you can ask. YMMV
	
#if MEMORY_STRESS_TEST_SCARCITY_ENABLED
#warning MEMORY_STRESS_TEST_SCARCITY_ENABLED - THIS SHOULD NOT HAPPEN IN PRODUCTION
#else
	return;
#endif
	
	NSLog(@"MEMORY STRESS TEST ENABLED (%dMB)", sizeInMB);
	
	void * unusedMemoryBufferToSimulateMemoryScarcity = NSZoneCalloc(NSDefaultMallocZone(), sizeInMB * MEGA, 1);
	
	if (unusedMemoryBufferToSimulateMemoryScarcity == NULL)
	{
		// Assert?
		NSLog(@"MEMORY STRESS TEST FAILED: Was unable to allocate requested memory");
		return;
	}
	
	dataToRetainToSimulateMemoryScarcity = [[NSData dataWithBytesNoCopy:unusedMemoryBufferToSimulateMemoryScarcity
                                                                 length:sizeInMB * MEGA
                                                           freeWhenDone:YES] retain];
	if (dataToRetainToSimulateMemoryScarcity == nil)
	{
		// Assert?
		NSLog(@"Failed to retain data to simulate memory scarcity");
	}

}

#pragma mark -
#pragma mark Simulate memory warning repeatedly. 


- (void) simulateLowMemoryWarning {
	// Send out MemoryWarningNotification
	[[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification
														object:[UIApplication sharedApplication]];

	// Manually call applicationDidReceiveMemoryWarning
	[[[UIApplication sharedApplication] delegate] applicationDidReceiveMemoryWarning:[UIApplication sharedApplication]];

	NSLog(@"Simulating low memory warning");
}

static NSTimer *lowMemoryWarningTimer = nil;

- (void)stopLowMemoryWarningTimer {
	[lowMemoryWarningTimer invalidate];
	lowMemoryWarningTimer = nil;
}


- (void)simulateRepeatingLowMemoryWarningsWithTimeInterval:(NSTimeInterval)seconds {
	#if MEMORY_STRESS_LOW_MEMORY_WARNINGS_SIMULATED
	#warning MEMORY_STRESS_LOW_MEMORY_WARNINGS_SIMULATED - THIS SHOULD NOT HAPPEN IN PRODUCTION
	#else
		return;
	#endif
	
	
	if (lowMemoryWarningTimer) {
		[self stopLowMemoryWarningTimer];
	}

	lowMemoryWarningTimer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                             target:self
                                                           selector:@selector(simulateLowMemoryWarning)
                                                           userInfo:nil
                                                            repeats:YES];

}




@end
