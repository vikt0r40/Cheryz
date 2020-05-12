//
//  NALU.h
//  TestH264Stream
//
//  Created by Sergey on 02/11/2016.
//  Copyright © 2016 Sergey. All rights reserved.
//

#ifndef NALU_h
#define NALU_h



@interface NALU : NSObject

@property (nonatomic) int  pos;
@property (nonatomic) int  type;
@property (nonatomic) int  hdr;

@end

#endif /* NALU_h */
