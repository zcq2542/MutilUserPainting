// Import D standard libraries
import std.stdio;
import std.string;

// Load the SDL2 library
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

import Surface:Surface;

const SDLSupport ret;

shared static this() {
	version(Windows){
        writeln("Searching for SDL on Windows");
		ret = loadSDL("SDL2.dll");
	}
    version(OSX){
        writeln("Searching for SDL on Mac");
        ret = loadSDL();
    }
    version(linux){ 
        writeln("Searching for SDL on Linux");
		ret = loadSDL();
	}

	// Error if SDL cannot be loaded
    if(ret != sdlSupport){
        writeln("error loading SDL library");
        
        foreach( info; loader.errors){
            writeln(info.error,':', info.message);
        }
    }
    if(ret == SDLSupport.noLibrary){
        writeln("error no library found");    
    }
    if(ret == SDLSupport.badLibrary){
        writeln("Eror badLibrary, missing symbols, perhaps an older or very new version of SDL is causing the problem?");
    }

    // Initialize SDL
    if(SDL_Init(SDL_INIT_EVERYTHING) !=0){
        writeln("SDL_Init: ", fromStringz(SDL_GetError()));
    }
}

shared static ~this(){
	SDL_Quit();
	writeln("Ending application--good bye!");
}

class SDLApp{
    SDL_Window* window;
	Surface usableSurface;

    this(){
	 	// Handle initialization...
 		// SDL_Init
    window = SDL_CreateWindow("D SDL Painting",
                                        SDL_WINDOWPOS_UNDEFINED,
                                        SDL_WINDOWPOS_UNDEFINED,
                                        640,
                                        480, 
                                        SDL_WINDOW_SHOWN);
	usableSurface = Surface(640,480);
 	}
    
 	~this(){
        SDL_DestroyWindow(window);
 	}

 		
 	void MainApplicationLoop(){ 

    // Flag for determing if we are running the main application loop
	bool runApplication = true;
	// Flag for determining if we are 'drawing' (i.e. mouse has been pressed
	//                                                but not yet released)
	bool drawing = false;

	// Main application loop that will run until a quit event has occurred.
	// This is the 'main graphics loop'
	while(runApplication){
		SDL_Event e;
		// Handle events
		// Events are pushed into an 'event queue' internally in SDL, and then
		// handled one at a time within this loop for as many events have
		// been pushed into the internal SDL queue. Thus, we poll until there
		// are '0' events or a NULL event is returned.
		while(SDL_PollEvent(&e) !=0){
			if(e.type == SDL_QUIT){
				runApplication= false;
			}
			else if(e.type == SDL_MOUSEBUTTONDOWN){
				drawing=true;
			}else if(e.type == SDL_MOUSEBUTTONUP){
				drawing=false;
			}else if(e.type == SDL_MOUSEMOTION && drawing){
				// retrieve the position
				int xPos = e.button.x;
				int yPos = e.button.y;
				// Loop through and update specific pixels
				// NOTE: No bounds checking performed --
				//       think about how you might fix this :)
				int brushSize=4;
				for(int w=-brushSize; w < brushSize; w++){
					for(int h=-brushSize; h < brushSize; h++){
						usableSurface.UpdateSurfacePixel(xPos+w,yPos+h,32,128,255);
					}
				}
			}
		}

		// Blit the surace (i.e. update the window with another surfaces pixels
		//                       by copying those pixels onto the window).
		SDL_BlitSurface(usableSurface.imgSurface,null,SDL_GetWindowSurface(window),null);
		// Update the window surface
		SDL_UpdateWindowSurface(window);
		// Delay for 16 milliseconds
		// Otherwise the program refreshes too quickly
		SDL_Delay(16);
	}
    }				
 		
}