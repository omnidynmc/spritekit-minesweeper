//
//  OESURLConnection.m
//  OpenEssentials
//
//  Created by Gregory Carter on 11/26/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "OESURLConnection.h"

@implementation OESURLConnection

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
  return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}
 
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    if ([self.trustedHosts containsObject:challenge.protectionSpace.host])
      [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
 
  [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end
