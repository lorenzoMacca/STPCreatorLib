# trainingLib


qmake -spec win32-msvc2008 -tp vc

following the same instruction to use the lib in your visual studio project
http://stackoverflow.com/questions/6093325/how-to-link-a-lib-in-visual-studio-2008-c
To link with a .lib file, you just need to:

    right clic on the project name, select Properties
    under Properties->configuration properties->C/C++->General item "other include directories" add the path to your .h file
    under Properties->Linker->Input add the path and name of your .lib file

And that's it.
at the moment you should point the header to the folder src
