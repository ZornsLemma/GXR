cpu 6502
load $8000 gxr200.orig
save gxr200.asm
symbols gxr200.sym
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
newpc $81f5
repeat 18
    stringz pc
endrepeat
wordentry pc 14
entry pc
