# Acornsoft Graphics Extension ROM (GXR)

A disassembly of the Acornsoft Graphics Extension ROMs for the BBC B and B+ computers, with an additional port to the Acorn Electron.

## Links and credits

The stardot discussion at https://stardot.org.uk/forums/viewtopic.php?f=2&t=20899 inspired me to take a look at this. You can download DFS disc images with the pre-built Electron version of the ROM and sample programs from that thread, if you don't want to build the contents of this repository yourself.

dv8 has remastered the GXR user guide; it's available at https://stardot.org.uk/forums/viewtopic.php?f=42&t=16838&p=271460. The two disc images of example programs in this repository are taken from this project.

The initial disassembly was performed using Phill Harvey-Smith's [BeebDis](https://github.com/prime6809/BeebDis). The beebdis directory in the repository contains the control and symbol files I used, although they don't specify all the subroutine tables correctly and the ones in the final disassembly were manually tweaked.

## Building

You'll need a copy of [BeebAsm](https://github.com/stardot/beebasm/) to build the ROMs.

If you're on a Unix-like system and have beebasm on your PATH, running "./make.sh" should build all three ROMs and the sample disc images. It doesn't do anything clever so you should easily be able to execute the equivalent commands manually on other platforms.
