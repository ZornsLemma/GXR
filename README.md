# Acornsoft Graphics Extension ROM (GXR)

A disassembly of the Acornsoft Graphics Extension ROMs for the BBC B and B+ computers, with an additional port to the Acorn Electron.

## Links and credits

The stardot discussion at https://stardot.org.uk/forums/viewtopic.php?f=2&t=20899 inspired me to take a look at this. *You can download DFS disc images with the pre-built Electron version of the ROM and sample programs from that thread*, if you don't want to build the contents of this repository yourself.

dv8 has remastered the GXR user guide; it's available at https://stardot.org.uk/forums/viewtopic.php?f=42&t=16838&p=271460. The two disc images of example programs in this repository are taken from that thread.

The initial disassembly was performed using Phill Harvey-Smith's [BeebDis](https://github.com/prime6809/BeebDis). The beebdis directory in the repository contains the control and symbol files I used, although they don't specify all the subroutine tables correctly and the ones in the final disassembly were manually tweaked.

The excellent annotated disassembly of BBC OS 1.2 at https://tobylobster.github.io/mos/index.html and the disassembly of Electron OS 1.0 at http://mdfs.net/System/ROMs/AcornMOS/Electron/ were very helpful in determining the relevant addresses of the graphics routines in the Electron OS ROM.

## Building

You'll need a copy of [BeebAsm](https://github.com/stardot/beebasm/) to build the ROMs.

If you're on a Unix-like system and have beebasm on your PATH, running "./make.sh" should build all three ROMs and the sample disc images. It doesn't do anything clever so you should easily be able to execute the equivalent commands manually on other platforms.

## Technical notes

The disassembly has been commented and given human-readable labels as I picked through the code to see why it wasn't working, but it's nowhere near fully annotated. There may be absolute offsets or addresses which I haven't picked up, so if you're going to use the disassembly as the basis for your own project it would be safest to "patch" the ROM by replacing code or data byte-for-byte rather than adding or removing things.

As you'd expect the BBC B (1.20) and B+ (2.00) versions published by Acornsoft are very nearly identical. The differences are:

* Internal graphics routines have moved in the OS ROM and the correct addresses need to be used. The runtime check for the matching OS version has to be altered as well, of course.

* GXR 1.20 automatically enables itself if (and only if) it's in an odd-numbered ROM bank. GXR 2.00 instead automatically enables itself if (and only if) it's in a ROM bank which has bit 1 set, i.e. banks 2, 3, 6, 7, 10, 11, 14 or 15. I believe this is done because each physical ROM socket in a B+ corresponds to two 16K banks, so it's not possible to choose either an odd or even-numbered ROM bank by plugging a physical 16K ROM into different sockets.

* In order for the GXR to work correctly in shadow screen modes on the B+, *all* screen reads and writes must be done using code executing at the special hardware-recognised addresses in the OS ROM. This means that where GXR 1.20 sometimes uses its own code to read and write the screen RAM, GXR 2.00 has to call into the OS ROM. In a few places this requires slightly more convoluted code because the OS ROM doesn't happen to contain a subroutine which does exactly what's required.

As the convention seems to be that the GXR version matches the version of the OS it's meant to run on, the Electron port has been given version 1.00. A letter suffix has been added to allow versions with bug fixes or new features to be distinguished.

The Electron version is very similar to the BBC B version. The differences are:

* Internal graphics routines are located in different places in the OS ROM so the correct addresses need to be used.

* The Electron uses the zero page VDU workspace differently from the BBC B/B+, so the GXR's use of these addresses has to be swapped round to match.

* Currently the Electron version uses the same convention as the BBC B for deciding whether to enable the GXR automatically, i.e. it is automatically enabled if (and only if) it's in an odd-numbered ROM bank. I don't know if this is ideal for the Electron, any thoughts on this are welcome!

## Possible enhancements

The GXR raises PAGE by &300 (&100 if the flood fill routines are disabled). Discarding the lengthy help messages in the ROM would easily free up &300 bytes, which opens up the possibility of creating variants (one for each system) designed to run from sideways RAM which don't raise PAGE.

I don't think this would be too hard but:

* In order to avoid the overhead of going through the extended vector mechanism for OSWRCH, the GXR copies a code stub into the first 71 bytes of its private workspace and points WRCHV at that stub. Since that's in main RAM, no extended vectors need to be used; instead the stub pages in the GXR directly and calls into the ROM. I don't have any timing data to hand, but I know from my experiments when writing [STEM](https://github.com/ZornsLemma/STEM) that this does significantly improve the performance. Bear in mind that every character written to the screen has to be redirected via WRCHV, so a small per-call overhead adds up. However, a sideways RAM version of GXR which doesn't claim any private workspace doesn't have any main RAM belonging to it where this stub can live.

    * It would be possible to change the GXR to use the extended vector mechanism for OSWRCH and just accept the performance hit:

    * It would be possible for the GXR to use 71 bytes elsewhere in main RAM for the stub, e.g. the RS423 output buffer at $0900-$09BF. Of course, doing this opens up the potential for clashes with other code trying to use that space.

* Ideally care would need to be taken so that allocating memory for sprites still works correctly. What "correctly" means would have to be decided, but sprite support shouldn't be broken. I suspect the best approach would be for sprite workspace to be claimed at PAGE as usual. This probably isn't a big deal, but it would be easy to forget this when hacking together a sideways RAM version.
