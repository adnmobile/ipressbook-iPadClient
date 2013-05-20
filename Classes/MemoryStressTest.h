//
//  MemoryStressTest.h
//  immobilier
//
//  Created by Medhi NAITMAZI on 21/12/10.
//  Copyright 2010 Neotilus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemoryStressTest : NSObject
{
	NSData *dataToRetainToSimulateMemoryScarcity; // ne pas faire de release sur cette var sinon on perd le sens de la classe
}

- (void)launchStressTests;

@end
