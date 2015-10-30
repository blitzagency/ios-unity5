//
//  UnityUtils.m
//
//  Created by Adam Venturella on 10/28/15.
//  Copyright © 2015 Adam Venturella. All rights reserved.
//
// this is taken directly from the unity generated main.mm file.
// if they change that initialization, this will need to be updated
// as well.


#include "RegisterMonoModules.h"
#include "RegisterFeatures.h"
#include <csignal>


// Hack to work around iOS SDK 4.3 linker problem
// we need at least one __TEXT, __const section entry in main application .o files
// to get this section emitted at right time and so avoid LC_ENCRYPTION_INFO size miscalculation
static const int constsection = 0;

void UnityInitTrampoline();


extern "C" void custom_unity_init(int argc, char* argv[]){
    UnityInitTrampoline();
    UnityParseCommandLine(argc, argv);

    RegisterMonoModules();
    NSLog(@"-> registered mono modules %p\n", &constsection);
    RegisterFeatures();

    // iOS terminates open sockets when an application enters background mode.
    // The next write to any of such socket causes SIGPIPE signal being raised,
    // even if the request has been done from scripting side. This disables the
    // signal and allows Mono to throw a proper C# exception.
    std::signal(SIGPIPE, SIG_IGN);
}
