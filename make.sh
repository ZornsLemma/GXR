#!/bin/bash
set -e
cd asm
# beebasm -v -i gxr120.asm -D BeebDisStartAddr=0x8000 > gxr120.lst
# beebasm -v -i gxr200.asm -D BeebDisStartAddr=0x8000 > gxr200.lst
beebasm -v -i top-b.asm -D BeebDisStartAddr=0x8000 > gxr120.lst && mv gxr120.rom ../roms
beebasm -v -i top-b-plus.asm -D BeebDisStartAddr=0x8000 > gxr200.lst && mv gxr200.rom ../roms
beebasm -v -i top-electron.asm -D BeebDisStartAddr=0x8000 > gxr100.lst && mv gxr100.rom ../roms
cd ..
cmp roms/gxr120.orig roms/gxr120.rom || echo "GXR 1.20 rebuild is not byte-for-byte identical"
cmp roms/gxr200.orig roms/gxr200.rom || echo "GXR 2.00 rebuild is not byte-for-byte identical"
