// main.cpp - entry point

#include <memory>
#include <iostream>

#include <SDL.h>

#include "host.hpp"
using namespace PanzerChasm;

#ifdef __EMSCRIPTEN__
#include <emscripten/emscripten.h>

static Host* g_host = nullptr;
static int g_argc = 0;
static char** g_argv = nullptr;
static bool g_host_boot_pending = true;
static bool g_main_loop_started = false;

static void EmscriptenMainLoop()
{
	if( g_host_boot_pending )
	{
		g_host_boot_pending = false;
		g_host = new Host( g_argc, g_argv );
		return;
	}

	if( g_host == nullptr || !g_host->Loop() )
	{
		emscripten_cancel_main_loop();
		static const char c_exit_screen_text[]=
R"(
                                  PanzerChasm
                    (c) 2016-2023 Artjom "Panzerschrek" Kunz,
                              github contributors
--------------------------------------------------------------------------------
                                CHASM - The Rift
                      (C) Megamedia Corp, Action Forms Ltd.
                          Published by Megamedia Corp.
                         Developed by Action Forms Ltd.
--------------------------------------------------------------------------------
)";
		std::cout << c_exit_screen_text;
		delete g_host;
		g_host = nullptr;
	}
}
#endif

extern "C" int main( int argc, char *argv[] )
{
	// Skip first param - program path.
	argc--;
	argv++;

#ifdef __EMSCRIPTEN__
	g_argc = argc;
	g_argv = argv;
	if( !g_main_loop_started )
	{
		g_main_loop_started = true;
		emscripten_set_main_loop( EmscriptenMainLoop, 0, 1 );
	}
	return 0;
#else
	// "Host" may be hard object. Create it on the heap.
	std::unique_ptr<Host> host( new Host( argc, argv ) );

	while( host->Loop() )
	{
	}

	// Print exit text to console.
	// Authors list is reconstructed. In original game it was hardcoded in executable.
	//TODO - maybe make system window with this text?
	static const char c_exit_screen_text[]=
R"(
                                  PanzerChasm
                    (c) 2016-2023 Artjom "Panzerschrek" Kunz,
                              github contributors
--------------------------------------------------------------------------------
                                CHASM - The Rift
                      (C) Megamedia Corp, Action Forms Ltd.
                          Published by Megamedia Corp.
                         Developed by Action Forms Ltd.
--------------------------------------------------------------------------------
               Programming      :  Oleg Slusar
               Artwork          :  Yaroslav Kravchenko,
                                   Alexey Serhiy,
                                   Alexey Pivtorak
               SFX and Music    :  Alex Kot
               Level Design     :  Yaroslav Kravchenko, Denis Vereschagin
                                   Andrey Sharanevitch, Alexey Pechenkin
               Directed by      :  Igor Karev, Denis Vereschagin
               Special thanks to:  Alexander Soroka, Peter M.Kolos
--------------------------------------------------------------------------------
)";

	std::cout << c_exit_screen_text;
	return 0;
#endif
}
