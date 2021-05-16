#!/bin/bash
set -e
cd asm
# beebasm -v -i gxr120.asm -D BeebDisStartAddr=0x8000 > gxr120.lst
# beebasm -v -i gxr200.asm -D BeebDisStartAddr=0x8000 > gxr200.lst
beebasm -v -i top-b.asm -D BeebDisStartAddr=0x8000 > gxr120.lst && mv gxr120.rom ../roms
beebasm -v -i top-integra-b.asm -D BeebDisStartAddr=0x8000 > gxr12i.lst && mv gxr12i.rom ../roms
beebasm -v -i top-b-plus.asm -D BeebDisStartAddr=0x8000 > gxr200.lst && mv gxr200.rom ../roms
beebasm -v -i top-electron.asm -D BeebDisStartAddr=0x8000 > gxr100.lst && mv gxr100.rom ../roms
cd ..
cmp roms/gxr120.orig roms/gxr120.rom || echo "GXR 1.20 rebuild is not byte-for-byte identical"
cmp roms/gxr12i.orig roms/gxr12i.rom || echo "GXR 1.2i rebuild is not byte-for-byte identical"
cmp roms/gxr200.orig roms/gxr200.rom || echo "GXR 2.00 rebuild is not byte-for-byte identical"
beebasm -i discs/add-gxr100.asm -di discs/Graphics_Extension_ROM.orig.ssd -do discs/Graphics_Extension_ROM.ssd
beebasm -i discs/add-gxr100.asm -di discs/Graphics_Extension_ROM_Sprites.orig.ssd -do discs/Graphics_Extension_ROM_Sprites.ssd
