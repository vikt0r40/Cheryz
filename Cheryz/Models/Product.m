//
//  Product.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/15/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "Product.h"
#import "NSDate+Server.h"

@implementation Product
-(instancetype)init{
    self = [super init];
    if(!self) return nil;
    
    self.availableTypes = @[@"Fashion", @"Footwear", @"Food", @"Antique", @"Gifts", @"Electronics", @"For kids", @"Jewellery", @"Cosmetics"];
    self.availableTypeImages = @[@"fashion",@"Footwear",@"food",@"antique",@"gift",@"el",@"kid",@"jew",@"cos"];
    
    self.availableLanguags = @[@"English", @"Russian", @"German", @"French", @"Spanish", @"Chinese", @"Italian"];
    
    self.availableFilterTypes = @[@"Not specified", @"Fashion", @"Footwear", @"Food", @"Antique", @"Gifts", @"Electronics", @"For kids", @"Jewellery", @"Cosmetics"];
    
    self.availableFilterTypeImages = @[@"",@"fashion",@"Footwear",@"food",@"antique",@"gift",@"el",@"kid",@"jew",@"cos"];
    
    self.availableAccessTypes = @[@"Everyone", @"Only friends", @"Private"];
    self.pLanguage = ProducLanguageNotSpecified;
    self.pType = ProducTypeNotSpecified;
    self.accessType = ProductAccessTypeAll;
    
    return self;
}
+(instancetype)productWithDict:(NSDictionary *)dict{
    Product *product = [Product new];
    if(!product){
        return nil;
    }
    
    product.productTourID = dict[@"tour_id"];
    product.productID = dict[@"id"];
    product.productImageUrl = dict[@"image"];
    product.productPromoURL = dict[@"promo_url"];
    product.productName = dict[@"title"];
//    product.productPrice = dict[@"price"];
    product.price = [Price priceFromDictionary:dict[@"price"]];
    product.productDescription = dict[@"description"];
    product.location = [Location locationFromDictionary:dict[@"location"]];
    product.productVideoUrl = dict[@"video"];
    product.productImageUrl = dict[@"image"];
    product.productOwnerId = dict[@"owner_id"];
    product.visibility = [dict[@"visible_type"] intValue];
    product.createdDate = [NSDate dateFromServerFormat:[dict[@"create_date"] doubleValue]];
    product.status = [dict[@"tour_status"] intValue];
    
    NSMutableArray *wishlists = [NSMutableArray new];
    if(dict[@"wishList"]&&[dict[@"wishList"] isKindOfClass:[NSArray class]]){
        [dict[@"wishList"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:[NSDictionary class]]){
                Wishlist *wishlist = [Wishlist wishlistFromDictionary:obj];
                [wishlists addObject:wishlist];
            }
        }];
    }
    product.wishlists = [wishlists copy];
    return product;
}
//-(NSString *)formattedPlacename{
//    NSMutableString *address = [[NSMutableString alloc] init];
//    if([_placename isKindOfClass:[NSString class]]){
//        [address appendString:_placename];
//    }
//    if([_city isKindOfClass:[NSString class]]){
//        if(address.length>0){
//            [address appendString:@", "];
//        }
//        [address appendString:_city];
//    }
//    if([_region isKindOfClass:[NSString class]]){
//        if(address.length>0){
//            [address appendString:@", "];
//        }
//        [address appendString:_region];
//    }
//    if([_country isKindOfClass:[NSString class]]){
//        if(address.length>0){
//            [address appendString:@", "];
//        }
//        [address appendString:_country];
//    }
//    return address;
//}
-(NSString *)languageTitle{
    if(self.pLanguage != ProducLanguageNotSpecified)
        return self.availableLanguags[self.pLanguage];
    else
        return @"Not specified";
}
-(NSString *)typeTitle{
    if(self.pType != ProducTypeNotSpecified)
        return self.availableTypes[self.pType];
    else
        return @"Not specified";
}
-(NSString *)accessTypeTitle{
    return self.availableAccessTypes[self.accessType];
}

@end
