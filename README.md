# TrailBlazer (BBC Micro)
Conversion of the Spectrum game Trailblazer to the BBC Micro

This game was originally designed by Mr Chip software and published by Gremlin. The ZX Spectrum port was done by the in house team at Gremlin and I used this as guide for my own version written from scratch in 100% 6502 assembler for the BBC. 

Here are some of the features of the game:

    50 FPS scrolling/animation
    2 game modes
        Arcade
        Test (Practise)
    14 levels
    7 coloured tile types with different functions
        Slow down
        Speed up
        Jump
        Reverse controls
    High scores and fastest times saved to disc
        Press R on the scores screen to reset them
    2 Input options
        Keyboard (usual Z, X, /, *, Enter keys)
        Joystick
        
        
tools used:
  BeebSpriter graphics editing
  BeebAsm - Assembling
  beebEm - Emulation
  b-em - Emulation/debugging


To build:
  Run the asm.bat this will assemble the code and generate the output files
  Create a new disc image in BeebEm and import all of the files INF files to the disc
