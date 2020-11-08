#!/bin/bash
#beebasm -v -i gxr120.asm -D BeebDisStartAddr=0x8000 > gxr120.lst
#beebasm -v -i gxr200.asm -D BeebDisStartAddr=0x8000 > gxr200.lst
beebasm -v -i top-b.asm -D BeebDisStartAddr=0x8000 > gxr120.lst
beebasm -v -i top-b-plus.asm -D BeebDisStartAddr=0x8000 > gxr200.lst
