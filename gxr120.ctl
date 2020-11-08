cpu 6502
load $8000 gxr120.orig
save gxr120.asm
symbols gxr120.sym
newsym z.sym ; TODO: get rid of this

; ROM header
string $8000 3 ; text in language entry
entry $8003 ; service entry
byte $8006 ; rom type
byte pc ; copyright offset
byte pc ; binary version
stringz pc ; title
stringz pc ; copyright

stringz $81e0
entry pc
;stringz $81f5
;entry pc
newpc $81f5
repeat 18
    stringz pc
endrepeat
wordentry pc 14
entry pc

byte $8368
string $8369 $17
entry pc

byte $8393
string $8394 $09
entry pc

byte $83a3
string $83a4 $10
entry pc

byte $83bf
string $83c0 $03
entry pc

byte $83c9
string $83ca $02
entry pc

byte $8400
string $8401 $19
entry pc

byte $842a
string $842b $13
entry pc

byte $8448
string $8449 $14
entry pc

stringz $846d
stringz pc
stringz pc
entry pc

byte $89a0
string $89a1 $1f
entry pc

byte $89dd
string $89de $0b
entry pc

byte $8a8a $96
entry pc
byte $8b71 $43
entry pc

byte $a415
string $a416 $03
entry pc

byte $a420
string $a421 $06
entry pc

stringz $a577
entry pc
stringz $a591
entry pc
stringz $a67f
entry pc
stringz $a71d
entry pc
stringz $a75a
entry pc
stringz $a7dc
entry pc
stringz $a7ee
entry pc

byte $a819
string $a81a $08
entry pc

byte $a828
string $a829 $04
entry pc

byte $a836
string $a837 $04
entry pc

byte $a841
string $a842 $06
entry pc

byte $a996
string $a997 $09
entry pc

byte $aa26 $22
entry pc

byte $ab20
string $ab21 $0c
entry pc

byte $ab3e
string $ab3f $13
entry pc

byte $ac67
string $ac68 $0f
entry pc

byte $ad50 $5f
entry pc

byte $b228
string $b229 $06
entry pc

byte $b2c1
string $b2c2 $06
entry pc

byte $b33e
string $b33f $09
entry pc

byte $b35a
string $b35b $07
entry pc

stringz $b89a
entry pc

byte $b8f1
string $b8f2 $06
entry pc

byte $b901
string $b902 $09
entry pc

byte $b915
string $b916 $04
entry pc

byte $b935
string $b936 $05
entry pc

byte $b94f
string $b950 $02
entry pc

byte $b95e
string $b95f $07
entry pc

byte $b982
string $b983 $06
entry pc

string $bfc7 $39

hexdump output.hex ; TODO: Get rid of this?
