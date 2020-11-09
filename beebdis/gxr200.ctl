cpu 6502
load $8000 ..\roms\gxr200.orig
save ..\asm\gxr200.asm
symbols gxr200.sym

; ROM header
string $8000 3 ; text in language entry
entry $8003 ; service entry
byte $8006 ; rom type
byte pc ; copyright offset
byte pc ; binary version
stringz pc ; title
stringz pc ; copyright

stringz $81e0
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

byte $89de
string $89df $0b
entry pc

byte $8a8b $96
entry pc
byte $8b72 $43
entry pc

byte $a41d
string $a41e $03
entry pc

byte $a428
string $a429 $06
entry pc

stringz $a58b
entry pc
stringz $a5a5
entry pc
stringz $a693
entry pc
stringz $a731
entry pc
stringz $a76e
entry pc
stringz $a7f0
entry pc
stringz $a802
entry pc

byte $a82d
string $a82e $08
entry pc

byte $a83c
string $a83d $04
entry pc

byte $a84a
string $a84b $04
entry pc

byte $a855
string $a856 $06
entry pc

byte $a9aa
string $a9ab $09
entry pc

byte $aa3a $22
entry pc

byte $ab34
string $ab35 $0c
entry pc

byte $ab67 $07
entry pc

byte $ab52
string $ab53 $13
entry pc

byte $ac7b
string $ac7c $0f
entry pc

byte $ad63 $60
entry pc

byte $b23c
string $b23d $06
entry pc

byte $b2d5
string $b2d6 $06
entry pc

byte $b352
string $b353 $09
entry pc

byte $b36e
string $b36f $07
entry pc

stringz $b8ae
entry pc

byte $b905
string $b906 $06
entry pc

byte $b915
string $b916 $09
entry pc

byte $b929
string $b92a $04
entry pc

byte $b94a
string $b94b $05
entry pc

byte $b963
string $b964 $02
entry pc

byte $b972
string $b973 $07
entry pc

byte $b996
string $b997 $06
entry pc

byte $b9f4 $10
entry pc

string $bfdb $25
