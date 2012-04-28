//
//  main.m
//  AddressBooklet
//
//  Created by Krzysztof Wicher on 29/04/2012.
//  Copyright (c) 2012 MiK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
    return macruby_main("rb_main.rb", argc, argv);
}
