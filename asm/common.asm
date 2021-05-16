; Hex labels are based on GXR 1.20 absolute addresses.

macro unknown_machine
        error "Can't assemble for unknown machine!"
endmacro

wrchv = $020E
vduv = $0226
xvduv = $0DD8
vduCurrentScreenMODE = $0355
vduJumpVector = $035D
extendedVectorTableVduV = $ff39

service_request_private_workspace = $02
service_unrecognised_oscli = $04
service_unrecognised_osbyte = $07
service_help = $09

workspace_6c = $6c ; $20 bytes of data based on screen mode, set by L8D0E_get_mode_data
workspace_98 = $98 ; b7 set iff we have saved UDGs from page $C in private workspace

if BBC_B
        ; Labels here are chosen to correspond to the annotated OS disassembly
        ; at https://tobylobster.github.io/mos/index.html.
        sixteenColourMODEMaskTable = $C407
        gcolPlotOptionsTable = $C41C
        twoColourMODEParameterTable = $C424
        vdu25EntryPoint = $C98C
        vdu22EntryPoint = $C8EB
        exchangeTwoVDUBytes = $CDDE
        plotPointWithinBoundsAtY = $D0F3
        checkPointXIsWithinGraphicsWindow = $D10F
        checkPointIsWithinWindowHorizontalOrVertical = $D128
        plotConvertExternalRelativeCoordinatesToPixels = $D14D
        moveGraphicsCursorAddressUpOneCharacterCell = $D3D3
        moveGraphicsCursorAddressTotheRightAndUpdateMask = $D3ED
        moveGraphicsCursorAddressTotheRight = $D3F2
        moveGraphicsCursorAddressTotheLeftAndUpdateMask = $D3FD
        copyEightBytesWithinVDUVariables = $D47C
        copyTwoBytesWithinVDUVariables = $D482
        copyFourBytesWithinVDUVariables = $D48A
        fillRow = $D6A6
        setScreenAddress = $D864
elif BBC_B_PLUS
        sixteenColourMODEMaskTable = $C3FE
        gcolPlotOptionsTable = $C413
        twoColourMODEParameterTable = $C41B
        vdu25EntryPoint = $C939
        vdu22EntryPoint = $CAEE
        exchangeTwoVDUBytes = $CDA6
        plotPointWithinBoundsAtY = $D0BF
        checkPointXIsWithinGraphicsWindow = $CA79
        checkPointIsWithinWindowHorizontalOrVertical = $D0D9
        plotConvertExternalRelativeCoordinatesToPixels = $D0FE
        moveGraphicsCursorAddressUpOneCharacterCell = $D34B
        moveGraphicsCursorAddressTotheRightAndUpdateMask = $D365
        moveGraphicsCursorAddressTotheRight = $D36A
        moveGraphicsCursorAddressTotheLeftAndUpdateMask = $D375
        copyEightBytesWithinVDUVariables = $D3F4
        copyTwoBytesWithinVDUVariables = $D3FB
        copyFourBytesWithinVDUVariables = $D403
        fillRow = $D62E
        setScreenAddress = $D7ED

        ; We need to execute LDA (&D6),Y and STA (&D6),Y from within the OS
        ; address space in order to access main or shadow RAM as appropriate.
        ; There isn't a bare LDA (&D6),Y:RTS we can use, so we do the best we
        ; can, which requires a bit of fiddling around in the GXR code compared
        ; to the model B case.
        b_plus_sta_d6_indirect_y = $D0CD
        b_plus_modify_d6_indirect_y_by_ora_d4_eor_d5 = $D0D0
        b_plus_lda_d6_indirect_y_eor_35a_sta_da = $D427
elif ELECTRON
        sixteenColourMODEMaskTable = $C3C2
        gcolPlotOptionsTable = $C3D7
        twoColourMODEParameterTable = $C3DF
        vdu25EntryPoint = $C986
        vdu22EntryPoint = $C8EC
        exchangeTwoVDUBytes = $CD1A
        plotPointWithinBoundsAtY = $D004
        checkPointXIsWithinGraphicsWindow = $D020
        checkPointIsWithinWindowHorizontalOrVertical = $D039
        plotConvertExternalRelativeCoordinatesToPixels = $D05E
        moveGraphicsCursorAddressUpOneCharacterCell = $D2EA
        moveGraphicsCursorAddressTotheRightAndUpdateMask = $D304
        moveGraphicsCursorAddressTotheRight = $D309
        moveGraphicsCursorAddressTotheLeftAndUpdateMask = $D314
        copyEightBytesWithinVDUVariables = $D393
        copyTwoBytesWithinVDUVariables = $D399
        copyFourBytesWithinVDUVariables = $D3A1
        fillRow = $D5BC
        setScreenAddress = $D77A
        selectRom = $E3A0
else
        unknown_machine
endif

        ; The Electron has a different arrangement of zero page VDU variables
        ; compared to the BBC machines:
        ;
        ;                                               BBC B/B+        Electron
        ; vduCurrentPlotByteMask                        $D1             $D1
        ; vduGraphicsColourByteOR                       $D4             $DE
        ; vduGraphicsColourByteEOR                      $D5             $DF
        ; vduScreenAddressOfGraphicsCursorCellLow       $D6             $D4
        ; vduScreenAddressOfGraphicsCursorCellHigh      $D7             $D5
        ; vduTempStoreDA                                $DA             $D8
        ; vduTempStoreDB                                $DB             $D9
        ; vduTempStoreDC                                $DC             $DA
        ; vduTempStoreDD                                $DD             $DB
        ; vduTempStoreDE                                $DE             $DC
        ; vduTempStoreDF                                $DF             $DD
        ;
        ; Unfortunately Electron temporary locations $D8 and $D9 are used to
        ; hold vduWriteCursorScreenAddress{Low,High} on the BBC B/B+. This means
        ; that although the ROM contains code to check if it's installed on an
        ; incompatible machine, in practice an Electron GXR ROM installed on a
        ; BBC B/B+ will cause glitches as it scribbles over $D8 and $D9 and the
        ; OS writes to random addresses when it thinks it's writing to the
        ; screen. In practice this isn't a huge problem, and it seems best not
        ; to risk accidentally breaking things by trying to tweak the temporary
        ; use to avoid accessing $D8 or $D9 until after we've successfully
        ; checked we *are* running on an Electron.
if BBC_B or BBC_B_PLUS
        vduCurrentPlotByteMask = $D1
        vduGraphicsColourByteOR = $D4
        vduGraphicsColourByteEOR = $D5
        vduScreenAddressOfGraphicsCursorCellLow = $D6
        vduScreenAddressofGraphicsCursorCellHigh = $D7
        vduTempStoreDA = $DA
        vduTempStoreDB = $DB
        vduTempStoreDC = $DC
        vduTempStoreDD = $DD
        vduTempStoreDE = $DE
        vduTempStoreDF = $DF
elif ELECTRON
        vduCurrentPlotByteMask = $D1
        vduGraphicsColourByteOR = $DE
        vduGraphicsColourByteEOR = $DF
        vduScreenAddressOfGraphicsCursorCellLow = $D4
        vduScreenAddressofGraphicsCursorCellHigh = $D5
        vduTempStoreDA = $D8
        vduTempStoreDB = $D9
        vduTempStoreDC = $DA
        vduTempStoreDD = $DB
        vduTempStoreDE = $DC
        vduTempStoreDF = $DD
else
        unknown_machine
endif

L00A8   = $00A8
L00A9   = $00A9
L00AA   = $00AA
L00AB   = $00AB
L00AC   = $00AC
L00AD   = $00AD
L00AE   = $00AE
L00AF   = $00AF
L00EF   = $00EF
L00F0   = $00F0
L00F1   = $00F1
L00F2   = $00F2
L00F3   = $00F3
L00F4   = $00F4
L00F8   = $00F8
L00F9   = $00F9
L00FF   = $00FF
L0100   = $0100
L022E   = $022E
L0230   = $0230
L0234   = $0234
L028D   = $028D
L0300   = $0300
L0301   = $0301
L0302   = $0302
L0303   = $0303
L0304   = $0304
L0305   = $0305
L0306   = $0306
L0307   = $0307
L0308   = $0308
L0309   = $0309
L030A   = $030A
L0314   = $0314
L0315   = $0315
L0316   = $0316
L0317   = $0317
L031A   = $031A
L031C   = $031C
L031D   = $031D
L031F   = $031F
L0320   = $0320
L0321   = $0321
L0322   = $0322
L0323   = $0323
L0324   = $0324
L0325   = $0325
L0326   = $0326
L0327   = $0327
L0328   = $0328
L0329   = $0329
L032A   = $032A
L032B   = $032B
L032C   = $032C
L032D   = $032D
L032E   = $032E
L032F   = $032F
L0330   = $0330
L0331   = $0331
L0332   = $0332
L0333   = $0333
L0334   = $0334
L0335   = $0335
L0336   = $0336
L0337   = $0337
L0338   = $0338
L0339   = $0339
L033A   = $033A
L033B   = $033B
L033C   = $033C
L033D   = $033D
L033E   = $033E
L033F   = $033F
L0340   = $0340
L0341   = $0341
L0342   = $0342
L0343   = $0343
L0344   = $0344
L0345   = $0345
L0346   = $0346
L0347   = $0347
L0348   = $0348
L0352   = $0352
L0353   = $0353
L0354   = $0354
L0359   = $0359
if BBC_B_PLUS
L035A   = $035A
endif
L035B   = $035B
L0360   = $0360
L0361   = $0361
L0362   = $0362
L0363   = $0363
L0B1E   = $0B1E
L0B3B   = $0B3B
L0C00   = $0C00
L0C01   = $0C01
L0C02   = $0C02
L0C03   = $0C03
L0C04   = $0C04
L0C05   = $0C05
L0C06   = $0C06
L0C07   = $0C07
L0C08   = $0C08
L0C10   = $0C10
L0C11   = $0C11
L0C12   = $0C12
L0C13   = $0C13
L0C14   = $0C14
L0C15   = $0C15
L0C16   = $0C16
L0C17   = $0C17
L0C18   = $0C18
L0C19   = $0C19
L0C1A   = $0C1A
L0C1B   = $0C1B
L0C1C   = $0C1C
L0C1D   = $0C1D
L0C1E   = $0C1E
L0C1F   = $0C1F
L0C20   = $0C20
L0C21   = $0C21
L0C22   = $0C22
L0C23   = $0C23
L0C24   = $0C24
L0C25   = $0C25
L0C26   = $0C26
L0C27   = $0C27
L0C2C   = $0C2C
L0C2D   = $0C2D
L0C2E   = $0C2E
L0C2F   = $0C2F
L0C30   = $0C30
L0C31   = $0C31
L0C32   = $0C32
L0C33   = $0C33
L0C34   = $0C34
L0C35   = $0C35
L0C36   = $0C36
L0C37   = $0C37
L0C38   = $0C38
L0C39   = $0C39
L0C3A   = $0C3A
L0C3B   = $0C3B
L0C3C   = $0C3C
L0C3D   = $0C3D
L0C3E   = $0C3E
L0C3F   = $0C3F
L0C40   = $0C40
L0C41   = $0C41
L0C42   = $0C42
L0C43   = $0C43
L0C44   = $0C44
L0C45   = $0C45
L0C46   = $0C46
L0C47   = $0C47
L0C48   = $0C48
L0C49   = $0C49
L0C4A   = $0C4A
L0C4B   = $0C4B
L0C4F   = $0C4F
L0C50   = $0C50
L0C51   = $0C51
L0C52   = $0C52
L0DF0   = $0DF0
if BBC_B or BBC_B_PLUS
LFE30   = $FE30
endif
osfind  = $FFCE
osbget  = $FFD7
osargs  = $FFDA
osfile  = $FFDD
osrdch  = $FFE0
osnewl  = $FFE7
oswrch  = $FFEE
osbyte  = $FFF4
LFFFF   = $FFFF

        org     $8000
        guard   $c000
.L8000
        EQUS    "RCM"

.header_service_entry
        JMP     L8039

.L8006
        EQUB    $82

.L8007
        EQUB    copyright - L8000 - 1

.L8008_binary_version
if BBC_B or BBC_B_PLUS
        EQUB    $01
elif ELECTRON
        ; This is handled separately so the binary version number can be changed
        ; in bug fix releases.
        EQUB    $01
else
        unknown_machine
endif

.L8009
if BBC_B
    if not(BBC_INTEGRA_B)
        EQUS    "Graphics Extension ROM 1.20",$0A,$0D,$00
    else
        EQUS    "Graphics Extension ROM 1.2i",$0A,$0D,$00
    endif
elif BBC_B_PLUS
        EQUS    "Graphics Extension ROM 2.00",$0A,$0D,$00
elif ELECTRON
        EQUS    "Graphics Extension ROM 1.00a",$0A,$0D,$00
else
        unknown_machine
endif

.copyright
        EQUS    "(C)1985 Acornsoft",$00

.L8039
        CMP     #service_request_private_workspace
        BEQ     L8060_handle_service_request_private_workspace

        CMP     #service_unrecognised_osbyte
        BNE     L8044

        JMP     L82FB_handle_service_unrecognised_osbyte

.L8044
        CMP     #service_help
        BNE     L804B

        JMP     L8349_handle_service_help

.L804B
        CMP     #service_unrecognised_oscli
        BNE     L8052

        JMP     L8167_handle_service_unrecognised_oscli

.L8052
        RTS

.L8053_hard_break
        LDA     #$00
        STA     L0DF0,X
        TXA
if BBC_B
        AND     #$01
elif BBC_B_PLUS
        AND     #$02
elif ELECTRON
        ; TODO: What's the best rule for deciding default on/off for an Electron?
        ; I suspect a 1980s cartridge release for use with the Plus 1 would have
        ; done AND #2 so one cartridge would enable it by default and the other
        ; wouldn't.
        AND     #$01
else
        unknown_machine
endif
        BNE     L8087_claim_workspace

.L805D
        LDA     #service_request_private_workspace
        RTS

; Y contains the lowest free page
.L8060_handle_service_request_private_workspace
        STA     L0328
        STY     L032A
        JSR     L8943_set_f8_f9_to_private_workspace

        LDA     L00F9
        BEQ     L8076 ; branch if no workspace

        LDY     #workspace_98
        LDA     (L00F8),Y
        BPL     L8076 ; branch if no saved UDGs

        JSR     L8C80_restore_saved_udgs

.L8076
        LDY     L032A
        STY     L00F9
        LDA     L028D ; last break type: 0=soft, 1=power on, 2=hard
        AND     #$03
        BNE     L8053_hard_break

        LDA     L0DF0,X
        BEQ     L805D

.L8087_claim_workspace
{
        TYA
        CMP     L0DF0,X
        BEQ     L80A7

        ; We didn't have any workspace before, save address and initialise parts of it.
        STA     L0DF0,X
        LDA     #$00
        LDY     #$52
        STA     (L00F8),Y
        LDY     #$4B
        STA     (L00F8),Y
        DEY
        STA     (L00F8),Y
        DEY
        LDA     #$80
        STA     (L00F8),Y
        DEY
        LDA     #$03
        STA     (L00F8),Y
.L80A7
        LDY     #$50
        LDA     (L00F8),Y
        STA     vduTempStoreDC
        INY
        LDA     (L00F8),Y
        STA     vduTempStoreDD
        INY
        LDA     (L00F8),Y
        BEQ     L80BF

        TAX
        LDA     #$00
        STA     (L00F8),Y
        JSR     LA671

.L80BF
        LDY     #$49
        LDA     (L00F8),Y
        AND     #$C0
        CMP     #$40
        BNE     L80E9

        ASL     A
        STA     (L00F8),Y
        INY
        LDA     (L00F8),Y
        BEQ     L80E9

        STA     vduTempStoreDF
        LDA     #$00
        STA     vduTempStoreDA
        STA     vduTempStoreDC
        STA     vduTempStoreDE
        CLC
        LDY     #$4E
        LDA     (L00F8),Y
        STA     vduTempStoreDD
        ADC     #$02
        STA     vduTempStoreDB
        JSR     L8D9E

.L80E9
        LDY     #$49
        LDA     (L00F8),Y
        ASL     A
        LDA     #$80
        ROL     A
        ROL     A
        ADC     L00F9
        LDY     #$4E
        STA     (L00F8),Y
        JSR     L8A6A

        ; Copy the code at L8955 into our workspace. Offset $48 is used for
        ; something else, so this code must not grow beyond the original
        ; length.
        assert (L899D - L8955) - 1 <= $47
        LDY     #(L899D - L8955) - 1
{
.L80FD
        LDA     L8955,Y
        STA     (L00F8),Y
        DEY
        BPL     L80FD
}

        ; Patch the copied code.
        LDY     #(jmp_old_wrchv_patch - L8955) + 1
        LDA     wrchv + 0
        PHA
        STA     (L00F8),Y
        INY
        LDA     wrchv + 1
        STA     (L00F8),Y
        LDY     #(jsr_old_wrchv_patch - L8955) + 2
        STA     (L00F8),Y
        DEY
        PLA
        STA     (L00F8),Y
        LDY     #(lda_imm_our_stub_wrchv_handler_rom_hi_patch - L8955) + 1
        LDA     L032A
        STA     (L00F8),Y
        LDY     #(lda_imm_our_rom_bank_patch - L8955) + 1
        LDA     L00F4
        STA     (L00F8),Y

        ; Save the original VDUV and XVDUV values in our workspace and install
        ; L8CB4_our_vduv_handler on VDUV.
        JSR     L88F9_swap_vduv_xvduv_with_copies
        LDA     #lo(extendedVectorTableVduV)
        STA     vduv + 0
        LDA     #hi(extendedVectorTableVduV)
        STA     vduv + 1
        LDA     #lo(L8CB4_our_vduv_handler)
        STA     xvduv + 0
        LDA     #hi(L8CB4_our_vduv_handler)
        STA     xvduv + 1
        LDA     L00F4
        STA     xvduv + 2

        JSR     L8D0E_get_mode_data

        LDA     #$00
        JSR     L8324_set_workspace_8c_to_97_using_a

        CLC
        LDA     #our_stub_wrchv_handler_rom - L8955
        STA     wrchv + 0
        LDA     L032A
        STA     wrchv + 1
        LDY     #$48
        ADC     (L00F8),Y
        LDY     #$4F
        STA     (L00F8),Y
        TAY
        LDX     L00F4
        LDA     L0328
        RTS
}

.L8167_handle_service_unrecognised_oscli
        PHA
        TYA
        PHA
        JSR     L8943_set_f8_f9_to_private_workspace

        LDX     #$00
        STX     vduTempStoreDC
        STY     vduTempStoreDA
.L8173
        LDY     vduTempStoreDA
        JSR     L8294

        BEQ     L818C

.L817A
        INX
        LDA     L820A,X
        BNE     L817A

        INC     vduTempStoreDC
        INX
        LDA     L820A,X
        BNE     L8173

.L8188
        JMP     L8467

.L818B
        INY
.L818C
        LDA     (L00F2),Y
        CMP     #$20
        BEQ     L818B

        ASL     vduTempStoreDC
        BEQ     L819D

        LDX     L00F4
        LDA     L0DF0,X
        BEQ     L8188

.L819D
        LDX     vduTempStoreDC
        CPX     #$0A
        BCC     L81B9

        STY     vduTempStoreDD
        JSR     L8943_set_f8_f9_to_private_workspace

        LDY     #$4A
        LDA     (L00F8),Y
        BEQ     L81DD

        LDY     vduTempStoreDD
        CPX     #$18
        BCC     L81B9

        LDA     L0361
        BEQ     L81F2

.L81B9
        LDX     vduTempStoreDC
        LDA     L8278,X
        STA     vduTempStoreDA
        LDA     L8279,X
        STA     vduTempStoreDB
        CLC
        TYA
        ADC     L00F2
        TAX
        LDY     L00F3
        BCC     L81CF

        INY
.L81CF
        JSR     L81DA

        LDX     L00F4
        PLA
        TAY
        PLA
        LDA     #$00
        RTS

.L81DA
        JMP     (vduTempStoreDA)

.L81DD
        JSR     generate_error

        EQUS    $80,"No sprite memory",$00

.L81F2
        JSR     generate_error

        EQUS    $81,"Not a graphics mode",$00

.L820A
        EQUS    "gxr",$00

        EQUS    "flood",$00

        EQUS    "noflood",$00

        EQUS    "nogxr",$00

        EQUS    "sspace",$00

        EQUS    "schoose",$00

        EQUS    "sdelete",$00

        EQUS    "sload",$00

        EQUS    "smerge",$00

        EQUS    "snew",$00

        EQUS    "srenumber",$00

        EQUS    "ssave",$00

        EQUS    "sedit",$00

        EQUS    "sget",$00

        EQUS    $00

        EQUS    "graphics",$00

        EQUS    "sprites",$00

.L8278
if not(BBC_INTEGRA_B)
        EQUW    L89C7
else
        EQUW    L89D4
endif
        EQUW    L89F5
        EQUW    L8A0C
        EQUW    L89EC
        EQUW    L8A44
        EQUW    LA74E
        EQUW    LAA96
        EQUW    LA638
        EQUW    LA656
        EQUW    L8A64
        EQUW    LA797
        EQUW    LA59D
        EQUW    LAB5D
        EQUW    LA40E

        L8279   = L8278 + 1
.L8294
        LDA     (L00F2),Y
        INY
        CMP     #$2E
        BEQ     L82A8

        ORA     #$20
        CMP     L820A,X
        BNE     L82A8

        INX
        LDA     L820A,X
        BNE     L8294

.L82A8
        RTS

.L82A9
        LDA     L0DF0,X
        BNE     L82B5

.L82AE
        STA     L00F0
        STA     L00F1
        TAX
        TAY
        RTS

.L82B5
        JSR     L8943_set_f8_f9_to_private_workspace

        LDA     L00F1
        CMP     #$41
        BNE     L82DC

        LDY     #$94
        LDA     (L00F8),Y
        AND     #$3F
        STA     L00F0
        LDY     #$49
        LDA     (L00F8),Y
        AND     #$80
        SEC
        ROR     A
        ORA     L00F0
        TAX
        INY
        LDA     (L00F8),Y
        TAY
.L82D5
        STX     L00F0
        STY     L00F1
        LDA     #$00
        RTS

.L82DC
        LDY     #$4C
        LDA     (L00F8),Y
        STA     vduTempStoreDA
        INY
        LDA     (L00F8),Y
        STA     vduTempStoreDB
        ORA     vduTempStoreDA
        BEQ     L82AE

        LDY     #$00
        LDA     (vduTempStoreDA),Y
        TAX
        INY
        LDA     (vduTempStoreDA),Y
        TAY
        INX
        INY
        BNE     L82D5

.L82F8
        LDA     #service_unrecognised_osbyte
        RTS

.L82FB_handle_service_unrecognised_osbyte
        LDA     L00EF
        CMP     #$A3
        BNE     L82F8

        LDA     L00F0
        CMP     #$F2
        BNE     L82F8

        LDA     L00F1
        CMP     #$41
        BEQ     L82A9

        CMP     #$42
        BEQ     L82A9

        BCS     L82F8

        LDA     L0DF0,X
        BEQ     L82F8

        LDA     L00F1
        JSR     L8324_set_workspace_8c_to_97_using_a

        LDX     L00F0
        LDY     L00F1
        LDA     #$00
        RTS

.L8324_set_workspace_8c_to_97_using_a
        JSR     L8943_set_f8_f9_to_private_workspace

        BNE     L8337

{
        LDY     #$8C
        LDX     #$07
        LDA     #$AA
.L832F
        STA     (L00F8),Y
        INY
        DEX
        BPL     L832F
}

        LDA     #$08
.L8337
        LDY     #$94
        STA     (L00F8),Y
        INY
        STA     (L00F8),Y
        INY
        LDA     #$80
        STA     (L00F8),Y
        INY
        LDA     #$00
        STA     (L00F8),Y
        RTS

.L8349_handle_service_help
        PHA
        TYA
        PHA
        JSR     L8943_set_f8_f9_to_private_workspace

        JSR     osnewl

        LDX     #$00
.L8354
        LDA     L8009,X
        JSR     oswrch

        INX
        CMP     #$00
        BNE     L8354

        LDA     (L00F2),Y
        CMP     #$0D
        BNE     L8383

        JSR     print_inline_counted

        EQUB    $17

        EQUS    "  Graphics",$0A,$0D,"  Sprites",$0A,$0D

.L8380
        JMP     L8467

.L8383
        TYA
        PHA
        LDX     #$5D
        JSR     L8294

        BNE     L83D9

        LDA     L00F9
        BNE     L83A0

        JSR     print_inline_counted

        EQUB    $09

        EQUS    "  GXR Off"

.L839D
        JMP     L83CC

.L83A0
        JSR     print_inline_counted

        EQUB    $10

        EQUS    "  GXR On, Flood "

.L83B4
        LDY     #$49
        LDA     (L00F8),Y
        AND     #$C0
        BNE     L83C6

        JSR     print_inline_counted

        EQUB    $03

        EQUS    "Off"

.L83C3
        JMP     L83CC

.L83C6
        JSR     print_inline_counted

        EQUB    $02

        EQUS    "On"

.L83CC
        JSR     osnewl

        JSR     osnewl

        LDX     #lo(L846D_graphics_help)
        LDY     #hi(L846D_graphics_help)
        JSR     L88C8_print_help_yx

.L83D9
        PLA
        TAY
        LDX     #$66
        JSR     L8294

        BEQ     L83E5

        JMP     L8467

.L83E5
        LDA     L00F9
        BEQ     L845D

        JSR     osnewl

        LDX     #lo(L882D_sprite_status)
        LDY     #hi(L882D_sprite_status)
        JSR     L88C8_print_help_yx

        LDY     #$4A
        LDA     (L00F8),Y
        PHA
        LDX     #$00
        JSR     LB98A

        JSR     print_inline_counted

        EQUB    $19

        EQUS    " page(s) sprite w/s",$0D,$0A,"    "

.L841A
        PLA
        BEQ     L845D

        JSR     LB804

        LDA     vduTempStoreDE
        LDX     vduTempStoreDF
        JSR     LB98C

        JSR     print_inline_counted

        EQUB    $13

        EQUS    " byte(s) free",$0D,$0A,"    "

.L843E
        LDY     #$4B
        LDA     (L00F8),Y
        JSR     LB98A

        JSR     print_inline_counted

        EQUB    $14

        EQUS    " sprite(s) defined",$0D,$0A

.L845D
        JSR     osnewl

        LDX     #lo(L883E_sprite_commands_help)
        LDY     #hi(L883E_sprite_commands_help)
        JSR     L88C8_print_help_yx

.L8467
        LDX     L00F4
        PLA
        TAY
        PLA
        RTS

.L846D_graphics_help
        EQUS    "  GXR commands",$0D,"GXR",$0D,"NOGXR",$0D,"FLOOD",$0D,"NOFLOOD",$0D,$0D,$08,$08,"Plot codes",$0D,"00 Line",$0D,"08 "
        EQUS    "Line (LPO)",$0D,"10 Dot-dash (R)",$0D,"18 Dot-dash (R,LPO)",$0D,"20 Line (FPO)",$0D,"28 "
        EQUS    "Line (BEO)",$0D,"30 Dot-dash (C,FPO)",$0D,"38 Dot-dash (C,BEO)",$0D,$0D,"40 Point",$0D,"48 "
        EQUS    "Fill L&R to Non-bg",$0D,"50 Triangle",$0D,"58 Fill R to bg",$0D,"60 Rectangle",$0D,"68 F"
        EQUS    "ill L&R to fg",$0D,"70 Parallelogram",$0D,"78 Fill R to Non-fg",$0D,$0D,"80 Flood to "
        EQUS    "Non-bg",$0D,"88 Flood to fg",$0D,"90 Circle outline",$0D,"98 Circle fill",$0D,"A0 Circul"
        EQUS    "ar arc",$0D,"A8 Circular segment",$0D,"B0 Circular sector",$0D,"B8 Block copy/move"
        EQUS    $0D,$0D,"C0 Ellipse outline",$0D,"C8 Ellipse fill",$0D,"D0",$0D,"D8",$0D,"E0",$0D,"E8 Sprite plot",$0D,"F0",$0D
        EQUS    "F8",$0D,$0D,$08,$08,"Set dot-dash repeat length",$0D,"*FX 163,242,k : k=0,1-64",$0D,$0D,$08,$08,"Def"
        EQUS    "ine patterns",$0D,"VDU 23,k,b,b,b,b,b,b,b,b with k=",$0D,"2,3,4,5 : full set"
        EQUS    "ting",$0D,"6       : dot-dash line",$0D,"11      : default setting",$0D,"12,13,14,"
        EQUS    "15 : simple setting",$0D,$0D,"VDU 23,27,0,n,0;0;0;",$0D,"  Choose sprite n for "
        EQUS    "plotting",$0D,"VDU 23,27,1,n,0;0;0;",$0D,"  Get sprite n from screen",$0D,$0D,$08,$08,"Sele"
        EQUS    "ct colour pattern",$0D,"GCOL a,c",$0D,"a<16 solid colour c",$0D,"a=16-21 : pattern"
        EQUS    " 1",$0D,"a=32-37 : pattern 2",$0D,"a=48-53 : pattern 3",$0D,"a=64-69 : pattern 4",$0D,$00

.L882D_sprite_status
        EQUS    "  Sprite status",$0D,$00

.L883E_sprite_commands_help
        EQUS    "  Sprite commands",$0D,"SSPACE n",$0D,"SCHOOSE n",$0D,"SDELETE n",$0D,"SEDIT n",$0D,"SEDIT n,m"
        EQUS    $0D,"SGET n",$0D,"SLOAD filename",$0D,"SMERGE filename",$0D,"SNEW",$0D,"SRENUMBER n,m",$0D,"SSAVE "
        EQUS    "filename",$0D,$00

.L88C8_print_help_yx
        STX     vduTempStoreDA
        STY     vduTempStoreDB
        LDY     #$00
.L88CE
        LDA     vduTempStoreDA
        PHA
        LDA     vduTempStoreDB
        PHA
        LDA     (vduTempStoreDA),Y
        CMP     #$0D
        BNE     L88E8

        JSR     osnewl

        LDA     #$20
        JSR     oswrch

        JSR     oswrch

        JSR     oswrch

.L88E8
        JSR     oswrch

        PLA
        STA     vduTempStoreDB
        PLA
        STA     vduTempStoreDA
        JSR     LB7A3_inc_vduTempStoreDA_DB

        LDA     (vduTempStoreDA),Y
        BNE     L88CE

        RTS

; Swap vduv and xvduv with the copies held in our private workspace.
.L88F9_swap_vduv_xvduv_with_copies
        TYA
        PHA
        JSR     L8943_set_f8_f9_to_private_workspace

        LDY     #$67
        LDA     vduv + 0
        PHA
        LDA     (L00F8),Y
        STA     vduv + 0
        PLA
        STA     (L00F8),Y
        INY
        LDA     vduv + 1
        PHA
        LDA     (L00F8),Y
        STA     vduv + 1
        PLA
        STA     (L00F8),Y
        INY
        LDA     xvduv + 0
        PHA
        LDA     (L00F8),Y
        STA     xvduv + 0
        PLA
        STA     (L00F8),Y
        INY
        LDA     xvduv + 1
        PHA
        LDA     (L00F8),Y
        STA     xvduv + 1
        PLA
        STA     (L00F8),Y
        INY
        LDA     xvduv + 2
        PHA
        LDA     (L00F8),Y
        STA     xvduv + 2
        PLA
        STA     (L00F8),Y
        PLA
        TAY
        RTS

; Preserves A, X, Y and carry flag. Returns with Z set to reflect value in A.
.L8943_set_f8_f9_to_private_workspace
        PHA
        TXA
        PHA
        LDX     L00F4
        LDA     L0DF0,X
        STA     L00F9
        LDA     #$00
        STA     L00F8
        PLA
        TAX
        PLA
        RTS

; The code from L8955 to L899D (exclusive) is copied into RAM by L08FD and
; patched afterwards. WRCHV is set to point to the RAM copy of
; our_stub_wrchv_handler_rom.
.L8955
.our_stub_wrchv_handler_rom
        assert  lo(vdu25EntryPoint) != lo(vdu22EntryPoint)
        PHA
        LDA     vduJumpVector + 0
        CMP     #lo(vdu25EntryPoint)
        BEQ     L8965

        CMP     #lo(vdu22EntryPoint)
        BEQ     L8978

.L8961
        PLA
.jmp_old_wrchv_patch
        JMP     LFFFF ; patched to JMP to original WRCHV

.L8965
        LDA     vduJumpVector + 1
        CMP     #hi(vdu25EntryPoint)
        BNE     L8961

        ; We're inside OSWRCH and vduJumpVector == vdu25EntryPoint, i.e. we're
        ; PLOTting something. Change vduJumpVector to the RAM copy of
        ; our_stuf_vdu25EntryPoint_rom and pass the call through to the original
        ; OSWRCH.
        LDA     #our_stub_vdu25EntryPoint_rom - L8955
        STA     vduJumpVector + 0
.lda_imm_our_stub_wrchv_handler_rom_hi_patch
        LDA     #$FF ; patched to LDA #hi(our_private_workspace)
        STA     vduJumpVector + 1
        BNE     L8961

.L8978
        LDA     vduJumpVector + 1
        CMP     #hi(vdu22EntryPoint)
        BNE     L8961

        ; We're inside OSWRCH and vduJumpVector == vdu22EntryPoint, i.e. we're
        ; changing mode. Pass the call through to the original OSWRCH and then
        ; enter L8BCE_our_vdu_22_25_entry_point with carry set.
        PLA
.jsr_old_wrchv_patch
        JSR     LFFFF ; patched to JSR to original WRCHV

        SEC
        BCS     L8987

; If we see vduJumpVector == vdu25EntryPoint, our WRCHV handler changes it to
; point to the RAM copy of our_stub_vdu25EntryPoint_rom.
.our_stub_vdu25EntryPoint_rom
        CLC
.L8987
        PHA
        LDA     L00F4
        PHA
.lda_imm_our_rom_bank_patch
        LDA     #$FF ; patched to LDA #our_rom_bank
if BBC_B or BBC_B_PLUS
        STA     L00F4
        STA     LFE30
elif ELECTRON
        JSR     selectRom
else
        unknown_machine
endif
if not(BBC_INTEGRA_B)
        JSR     L8BCE_our_vdu_22_25_entry_point
else
        JSR     L899D
endif

        PLA
if BBC_B or BBC_B_PLUS
        STA     L00F4
        STA     LFE30
elif ELECTRON
        JSR     selectRom
else
        unknown_machine
endif
        PLA
        RTS

.L899D
if not(BBC_INTEGRA_B)
        JSR     print_inline_counted
        EQUB    not_compatible_end - not_compatible_start
.not_compatible_start
        EQUS    "GXR "
if BBC_B
        EQUS    "1.20"
elif BBC_B_PLUS
        EQUS    "2.00"
elif ELECTRON
        EQUS    "1.00"
else
        unknown_machine
endif
        EQUS    " is not compatible with"
.not_compatible_end

.L89C0
        LDA     #$00
        LDX     #$00
        JMP     osbyte

.L89C7
        LDA     #$81
        LDX     #$00
        LDY     #$FF
        JSR     osbyte

if BBC_B
        INX
elif BBC_B_PLUS
        CPX     #$FB
elif ELECTRON
        CPX     #$01
else
        unknown_machine
endif
        BNE     L899D
else
        PHA
        PHA
        TXA
        PHA
        TSX
        LDA &037F
        STA &0103,X
        AND #$7F
        STA &037F
        STA &FE34
        PLA
        TAX
        PLA
        JSR L8BCE_our_vdu_22_25_entry_point
        PHA
        TXA
        PHA
        TSX
        LDA &0103,X
        STA &037F
        STA &FE34
        LDA &0102,X
        STA &0103,X
        LDA &0101,X
        STA &0102,X
        PLA
        PLA
        TAX
        PLA
        RTS
.L89D4
endif
        LDX     L00F4
        LDA     #$01
        STA     L0DF0,X
.L89DA
        JSR     print_inline_counted
if not(BBC_INTEGRA_B)
        EQUB    $0B
        EQUS    "press"
else
        EQUB    $0A
        EQUS    "Hit"
endif
        EQUS    " BREAK"
if BBC_INTEGRA_B
        EQUS    "."
endif

.L89E9
        JMP     L89E9

.L89EC
        LDX     L00F4
        LDA     #$00
        STA     L0DF0,X
        BEQ     L89DA

.L89F5
        LDY     #$49
        LDA     (L00F8),Y
        AND     #$C0
        BNE     L8A0B

        LDA     #$40
        STA     (L00F8),Y
        DEY
        CLC
        LDA     #$02
        ADC     (L00F8),Y
        STA     (L00F8),Y
        BNE     L89DA

.L8A0B
        RTS

.L8A0C
        LDY     #$49
        LDA     (L00F8),Y
        AND     #$C0
        BEQ     L8A0B

        LDA     #$00
        STA     (L00F8),Y
        LDY     #$48
        SEC
        LDA     (L00F8),Y
        SBC     #$02
        STA     (L00F8),Y
        SEC
        LDY     #$4E
        LDA     (L00F8),Y
        STA     vduTempStoreDD
        SBC     #$02
        STA     (L00F8),Y
        STA     vduTempStoreDB
        LDY     #$4A
        LDA     (L00F8),Y
        BEQ     L89DA

        STA     vduTempStoreDF
        LDA     #$00
        STA     vduTempStoreDA
        STA     vduTempStoreDC
        STA     vduTempStoreDE
        JSR     L8D83

        JMP     L89DA

.L8A44
        JSR     LB851

        LDY     #$4A
        CMP     (L00F8),Y
        STA     (L00F8),Y
        PHP
        DEY
        LDA     (L00F8),Y
        ASL     A
        LDA     #$80
        ROL     A
        ROL     A
        ADC     vduTempStoreDE
        DEY
        STA     (L00F8),Y
        PLP
        BCS     L8A61

        JSR     L8A64

.L8A61
        JMP     L89DA

.L8A64
        LDY     #$4B
        LDA     #$00
        STA     (L00F8),Y
.L8A6A
        LDY     #$4C
        LDA     #$00
        STA     (L00F8),Y
        INY
        STA     (L00F8),Y
        RTS

.generate_error
        PLA
        STA     vduTempStoreDA
        PLA
        STA     vduTempStoreDB
        LDY     #$00
.L8A7C
        INY
        LDA     (vduTempStoreDA),Y
        STA     L0100,Y
        BNE     L8A7C

        STA     L0100
.L8A87
        JMP     L0100

L8A89 = L8A87+2
        EQUB    $FF,$55,$FF,$77,$33,$11,$FF,$7F
        EQUB    $3F,$1F,$0F,$07,$03

.L8A97
        EQUB    $01,$AA,$00,$AA,$00,$AA,$00,$AA
        EQUB    $00,$AA,$55,$AA,$55,$AA,$55,$AA
        EQUB    $55,$FF,$55,$FF,$55,$FF,$55,$FF
        EQUB    $55,$11,$22,$44,$88,$11,$22,$44
        EQUB    $88,$A5,$0F,$A5,$0F,$A5,$0F,$A5
        EQUB    $0F,$A5,$5A,$A5,$5A,$A5,$5A,$A5
        EQUB    $5A,$F0,$5A,$F0,$5A,$F0,$5A,$F0
        EQUB    $5A,$F5,$FA,$F5,$FA,$F5,$FA,$F5
        EQUB    $FA,$0B,$07,$0B,$07,$0B,$07,$0B
        EQUB    $07,$23,$13,$23,$13,$23,$13,$23
        EQUB    $13,$0E,$0D,$0E,$0D,$0E,$0D,$0E
        EQUB    $0D,$1F,$2F,$1F,$2F,$1F,$2F,$1F
        EQUB    $2F,$CC,$00,$CC,$00,$CC,$00,$CC
        EQUB    $00,$CC,$33,$CC,$33,$CC,$33,$CC
        EQUB    $33,$FF,$33,$FF,$33,$FF,$33,$FF
        EQUB    $33,$03,$0C,$30,$C0,$03,$0C,$30
        EQUB    $C0

.L8B18
        EQUB    $02,$00,$01,$FF,$00,$01,$FF,$FF

.L8B20
        LDA     L0300,Y
        STA     L0314
        LDA     L0301,Y
        STA     L0315
        LDA     L0302,X
        STA     L0316
        LDA     L0303,X
        STA     L0317
        LDY     #$14
.L8B3A
        STY     vduTempStoreDE
        LDA     L0302,X
        EOR     #$07
        AND     #$07
        TAY
        JSR     L8B5D

        LDY     vduTempStoreDE
        JMP     fillRow

.L8B4C
        JSR     L8B55

        BNE     L8B54

        JMP     plotPointWithinBoundsAtY

.L8B54
        RTS

.L8B55
        JSR     checkPointXIsWithinGraphicsWindow

        BNE     L8B54

.L8B5A
        JSR     setScreenAddress

.L8B5D
        LDA     L0C00,Y
        PHA
        ORA     L00A8
        EOR     L00A9
        STA     vduGraphicsColourByteOR
        PLA
        ORA     L00AA
        EOR     L00AB
        STA     vduGraphicsColourByteEOR
        LDA     #$00
        RTS

.L8B71
L8B72 = L8B71 + 1
        EQUW    L9AEB
        EQUW    L9AEB
        EQUW    L9AEB
        EQUW    L9AEB
        EQUW    L9AEB
        EQUW    L9AEB
        EQUW    L9AEB
        EQUW    L9AEB
        EQUW    L8DD2
        EQUW    L9F36
        EQUW    L8E61
        EQUW    L9F5A
        EQUW    L8DDA
        EQUW    L9F54, L8E5B, L9F5F, L9CF3, L9CED
        EQUW    L9044, L9095, L9270, L93E2, L92EA
        EQUW    L9F8C, LB9EA, LBA6D, L8BB1, L8BB1
        EQUW    L8BB1, LA258, L8BB1, L8BB1

.L8BB1
        JSR     L8C80_restore_saved_udgs

.L8BB4
        LDA     L031F
        CLC
        JMP     (vduv)

.L8BBB_our_vdu_22_entry_point
        PHA
        TXA
        PHA
        TYA
        PHA
        JSR     L8D0E_get_mode_data

        LDA     #$00
        JSR     L8324_set_workspace_8c_to_97_using_a

        PLA
        TAY
        PLA
        TAX
        PLA
        RTS

; Our WRCHV handler arranged for this to be called with carry set after VDU 22
; (mode change) and carry clear during VDU 25 (PLOT).
.L8BCE_our_vdu_22_25_entry_point
        JSR     L8943_set_f8_f9_to_private_workspace

        BCS     L8BBB_our_vdu_22_entry_point

        LDX     L0361
        BEQ     L8BB4

        ; Copy $C99-$CFF (part of the UDG data) inclusive to the same offsets in
        ; our workspace so we can restore this later.
{
        LDA     #$99
        STA     L00F8
        LDY     #$66
.L8BDE
        LDA     L0C00,Y
        STA     (L00F8),Y
        DEY
        BPL     L8BDE
}

        ; Set b7 of workspace_98 to record that we've saved UDGs.
        INY
        STY     L00F8
        LDY     #workspace_98
        LDA     #$80
        STA     (L00F8),Y

        LDX     #$20
        JSR     plotConvertExternalRelativeCoordinatesToPixels

        LDY     #$05
        LDA     L031F
        AND     #$C3
        BEQ     L8C6F_restore_saved_cursors_and_udgs

        AND     #$03
        BEQ     L8C0D

        DEY
        LSR     A
        BCC     L8C0D

        TAX
        LDY     L035B,X
        LDA     L0359,X
        TAX
.L8C0D
        TYA
        PHA
        AND     #$0F
        TAY
        LDA     gcolPlotOptionsTable + 0,Y
        STA     L00A8
        LDA     gcolPlotOptionsTable + 1,Y
        STA     L00A9
        LDA     gcolPlotOptionsTable - 1,Y
        STA     L00AA
        LDA     gcolPlotOptionsTable + 4,Y
        STA     L00AB
        PLA
        AND     #$F0
        LSR     A
        BNE     L8C46

        STX     L0C00
        STX     L0C01
        STX     L0C02
        STX     L0C03
        STX     L0C04
        STX     L0C05
        STX     L0C06
        STX     L0C07
        BEQ     L8C57

.L8C46
        LDX     #$07
        TAY
        DEY
        LDA     #$6C
        STA     L00F8
.L8C4E
        LDA     (L00F8),Y
        STA     L0C00,X
        DEY
        DEX
        BPL     L8C4E

.L8C57
        LDA     L031F
        AND     #$F8
        LSR     A
        LSR     A
        TAX
        LDA     L8B71,X
        STA     vduTempStoreDA
        LDA     L8B72,X
        STA     vduTempStoreDB
        JSR     L8943_set_f8_f9_to_private_workspace

        JMP     (vduTempStoreDA)

.L8C6F_restore_saved_cursors_and_udgs
        LDX     #$03
{
.L8C71
        LDA     L0324,X
        STA     L0314,X
        LDA     L0320,X
        STA     L0324,X
        DEX
        BPL     L8C71
}

.L8C80_restore_saved_udgs
        JSR     L8943_set_f8_f9_to_private_workspace

        ; Copy workspace offset $99-$FF inclusive to page $C, restoring the
        ; original values from when we initialised ourselves.
        LDA     #$99
        STA     L00F8
        LDY     #$66
{
.L8C89
        LDA     (L00F8),Y
        STA     L0C00,Y
        DEY
        BPL     L8C89
}

        ; Zero workspace_98; this clears b7 to indicate we have no saved UDGs.
        INY
        STY     L00F8
        TYA
        LDY     #workspace_98
        STA     (L00F8),Y
        RTS

.L8C9A
        LDA     L031C
        BNE     L8CA5

        LDA     L031D
        JMP     LA751

.L8CA5
        CMP     #$01
        BNE     L8CAF

        LDA     L031D
        JMP     LA42D

.L8CAF
        LDA     #$1B
        JMP     L8CD2

.L8CB4_our_vduv_handler
        JSR     L8943_set_f8_f9_to_private_workspace

        BCC     L8CD3

        LDX     L0361
        BEQ     L8CD2

        CMP     #$06
        BEQ     L8CE6

        BCC     L8CF8

        CMP     #$0B
        BCC     L8CD2

        BEQ     L8D0E_get_mode_data

        CMP     #$10
        BCC     L8D31

        CMP     #$1B
        BEQ     L8C9A

.L8CD2
        SEC
.L8CD3
        PHP
        PHA
        JSR     L88F9_swap_vduv_xvduv_with_copies

        PLA
        PLP
        JSR     L8CE3

        PHA
        JSR     L88F9_swap_vduv_xvduv_with_copies

        PLA
        RTS

.L8CE3
        JMP     (vduv)

.L8CE6
        PHA
        LDY     #$94
        LDA     (L00F8),Y
        INY
        STA     (L00F8),Y
        INY
        LDA     #$80
        STA     (L00F8),Y
        INY
        ASL     A
        STA     (L00F8),Y
        PLA
.L8CF8
        SEC
        SBC     #$01
        ASL     A
        ASL     A
        ASL     A
        ADC     #$6C
        TAY
        DEY
        LDX     #$07
.L8D04
        LDA     L031C,X
        STA     (L00F8),Y
        DEY
        DEX
        BPL     L8D04

        RTS

.L8D0E_get_mode_data
{
        LDA     vduCurrentScreenMODE
        BNE     L8D16

        SEC
        SBC     #$01
.L8D16
        AND     #$03
        CLC
        ADC     #$01
        ASL     A
        ASL     A
        ASL     A
        ASL     A
        ASL     A
        TAX
        LDY     #$20
        LDA     #workspace_6c - 1
        STA     L00F8
.L8D27
        LDA     L8A97,X
        STA     (L00F8),Y
        DEX
        DEY
        BNE     L8D27

        RTS
}

.L8D31
        SBC     #$0B
        ASL     A
        ASL     A
        ASL     A
        ADC     #$03
        PHA
        LDX     #$07
.L8D3B
        LDA     L031C,X
        AND     L0360
        STA     vduTempStoreDA
        LDA     L0360
        AND     #$07
        ADC     vduTempStoreDA
        TAY
        LDA     twoColourMODEParameterTable - 1,Y
        STA     L031C,X
        DEX
        BPL     L8D3B

        LDA     #$55
        LDX     vduCurrentScreenMODE
        BNE     L8D5D

        LDA     #$33
.L8D5D
        STA     vduTempStoreDA
        PLA
        CLC
        ADC     #$6C
        TAY
        LDX     #$07
.L8D66
        LDA     L031C,X
        DEX
        EOR     L031C,X
        AND     vduTempStoreDA
        EOR     L031C,X
        STA     (L00F8),Y
        INY
        INY
        INY
        INY
        STA     (L00F8),Y
        DEY
        DEY
        DEY
        DEY
        DEY
        DEX
        BPL     L8D66

        RTS

.L8D83
        LDY     #$00
.L8D85
        LDA     (vduTempStoreDC),Y
        STA     (vduTempStoreDA),Y
        JSR     LB7A3_inc_vduTempStoreDA_DB

        JSR     LB7AA_inc_vduTempStoreDC_DD

        LDA     vduTempStoreDE
        BNE     L8D95

        DEC     vduTempStoreDF
.L8D95
        DEC     vduTempStoreDE
        LDA     vduTempStoreDE
        ORA     vduTempStoreDF
        BNE     L8D85

        RTS

.L8D9E
        CLC
        LDA     vduTempStoreDE
        ADC     vduTempStoreDA
        STA     vduTempStoreDA
        LDA     vduTempStoreDF
        ADC     vduTempStoreDB
        STA     vduTempStoreDB
        LDA     vduTempStoreDE
        ADC     vduTempStoreDC
        STA     vduTempStoreDC
        LDA     vduTempStoreDF
        ADC     vduTempStoreDD
        STA     vduTempStoreDD
        LDY     #$00
.L8DB9
        JSR     LB7B1

        JSR     LB7BA

        LDA     (vduTempStoreDC),Y
        STA     (vduTempStoreDA),Y
        LDA     vduTempStoreDE
        BNE     L8DC9

        DEC     vduTempStoreDF
.L8DC9
        DEC     vduTempStoreDE
        LDA     vduTempStoreDE
        ORA     vduTempStoreDF
        BNE     L8DB9

        RTS

.L8DD2
        LDX     #$20
        JSR     L8B4C

        JMP     L8C6F_restore_saved_cursors_and_udgs

.L8DDA
        LDX     #$20
        JSR     L8E0D

        JSR     L8DE5

        JMP     L8C6F_restore_saved_cursors_and_udgs

.L8DE5
        LDX     #$2A
        LDY     #$2E
        JSR     exchangeTwoVDUBytes

.L8DEC
        LDX     #$28
        LDY     #$2C
        JSR     L8B20

        LDA     L032A
        BNE     L8DFB

        DEC     L032B
.L8DFB
        DEC     L032A
        LDA     L032A
        CMP     L032E
        LDA     L032B
        SBC     L032F
        BPL     L8DEC

        RTS

.L8E0D
        LDY     #$24
        JSR     L9018

        TYA
        PHA
        TXA
        PHA
        JSR     L902D

        PLA
        STA     L0C16
        TYA
        PHA
        LDA     L0C16
        LDY     #$28
        JSR     L8E2A

        PLA
        TAX
        PLA
.L8E2A
        PHA
        JSR     copyTwoBytesWithinVDUVariables

        PLA
        TAX
        INX
        INX
        JMP     copyTwoBytesWithinVDUVariables

.L8E35
        LDA     L035B,X
        AND     #$F0
        LSR     A
        BNE     L8E49

        LDY     #$07
        LDA     L0359,X
.L8E42
        STA     L0C17,Y
        DEY
        BPL     L8E42

        RTS

.L8E49
        ADC     #$6B
        TAY
        JSR     L8943_set_f8_f9_to_private_workspace

        LDX     #$07
.L8E51
        LDA     (L00F8),Y
        STA     L0C17,X
        DEY
        DEX
        BPL     L8E51

        RTS

.L8E5B
        JSR     L8E67

        JMP     L8C6F_restore_saved_cursors_and_udgs

.L8E61
        JSR     L8EE1

        JMP     L8C6F_restore_saved_cursors_and_udgs

.L8E67
        LDX     #$01
        LDY     #$00
.L8E6B
        SEC
        LDA     L0320,Y
        SBC     L0324,Y
        STA     L0328,Y
        LDA     L0321,Y
        SBC     L0325,Y
        STA     L0329,Y
        CLC
        LDA     L0328,Y
        ADC     L0314,Y
        STA     L0328,Y
        LDA     L0329,Y
        ADC     L0315,Y
        STA     L0329,Y
        LDY     #$02
        DEX
        BPL     L8E6B

        LDY     #$14
        LDX     #$24
        JSR     L9018

        STX     L0C17
        LDX     #$20
        JSR     L9018

        STX     L0C18
        LDX     #$28
        JSR     L9018

        STY     L0C1A
        LDY     L0C18
        JSR     L9018

        STY     L0C19
        LDY     L0C17
        JSR     L8EFD

        LDA     L0C1A
        STA     L0C14
        LDX     #$34
        JSR     L9872

        LDY     L0C15
        JSR     L8F47

        LDY     L0C19
        LDA     L0C1A
        STA     L0C15
        LDX     #$3F
        JSR     L8F41

        JMP     L8EF6

.L8EE1
        LDY     #$14
        LDX     #$24
        JSR     L9018

        STY     L0C19
        LDY     #$20
        JSR     L8EFD

        LDA     L0C19
        JSR     L8F3C

.L8EF6
        LDY     #$2C
        LDX     #$30
        JMP     L8B3A

.L8EFD
        JSR     L9018

        STX     L0C17
        LDX     L0C19
        JSR     L9018

        STY     L0C19
        STX     L0C18
        LDY     L0C17
        LDX     #$FC
.L8F14
        LDA     L0300,Y
        STA     L0230,X
        STA     L0234,X
        INY
        INX
        BNE     L8F14

        LDY     L0C17
        LDA     L0C19
        STA     L0C15
        LDX     #$3F
        JSR     L9872

        LDY     L0C17
        LDA     L0C18
        JSR     L8F3C

        LDY     L0C18
        RTS

.L8F3C
        STA     L0C14
        LDX     #$34
.L8F41
        JSR     L9872

        LDY     L0C14
.L8F47
        STY     vduTempStoreDB
.L8F49
        LDA     L0302,Y
        CMP     L032E
        BNE     L8F59

        LDA     L0303,Y
        CMP     L032F
        BEQ     L8FA4

.L8F59
        LDX     #$34
        JSR     L8FDD

        LDX     #$3F
        JSR     L8FDD

        JSR     L8EF6

        LDX     #$34
        JSR     L992F

        LDX     #$3F
        JSR     L992F

        LDX     #$34
        LDY     #$3F
        JSR     L902D

        STA     L0C16
        TXA
        PHA
        LDA     L0C16
        LDX     #$FC
.L8F81
        LDA     L0300,Y
        STA     L0234,X
        INY
        INX
        BNE     L8F81

        STA     L0C16
        PLA
        TAX
        LDA     L0C16
        LDY     #$FC
.L8F95
        LDA     L0300,X
        STA     L0230,Y
        INX
        INY
        BNE     L8F95

        LDY     vduTempStoreDB
        JMP     L8F49

.L8FA4
        LDA     #$34
        LDX     L0C14
        JSR     L8FB3

        LDY     vduTempStoreDB
        LDA     #$3F
        LDX     L0C15
.L8FB3
        STA     vduTempStoreDE
        LDA     L0302,X
        CMP     L0302,Y
        BNE     L8FC5

        LDA     L0303,X
        CMP     L0303,Y
        BEQ     L8FE2

.L8FC5
        LDX     vduTempStoreDE
        JMP     L8FDD

.L8FCA
        STA     L0C16
        TXA
        PHA
        LDA     L0C16
        JSR     L992F

        STA     L0C16
        PLA
        TAX
        LDA     L0C16
.L8FDD
        LDA     L0309,X
        BPL     L8FCA

.L8FE2
        LDA     L0300,X
        CMP     L032C
        LDA     L0301,X
        SBC     L032D
        BPL     L8FFD

        LDA     L0300,X
        STA     L032C
        LDA     L0301,X
        STA     L032D
        RTS

.L8FFD
        LDA     L0330
        CMP     L0300,X
        LDA     L0331
        SBC     L0301,X
        BPL     L9017

        LDA     L0300,X
        STA     L0330
        LDA     L0301,X
        STA     L0331
.L9017
        RTS

.L9018
        SEC
        LDA     L0302,Y
        SBC     L0302,X
        STA     vduTempStoreDE
        LDA     L0303,Y
        SBC     L0303,X
        BMI     L903B

        ORA     vduTempStoreDE
        BNE     L9043

.L902D
        LDA     L0300,Y
        CMP     L0300,X
        LDA     L0301,Y
        SBC     L0301,X
        BPL     L9043

.L903B
        TXA
        STY     L0C16
        LDX     L0C16
        TAY
.L9043
        RTS

.L9044
        LDX     #$24
        LDY     #$14
        JSR     copyFourBytesWithinVDUVariables

        LDY     #$14
        LDX     #$20
        JSR     L90DC

        JSR     L914E

.L9055
        JSR     L94C6

        JSR     L94ED

        LDX     #$30
        JSR     L8B4C

        LDA     L0C30
        ORA     L0C31
        BEQ     L906D

        LDX     #$2C
        JSR     L8B4C

.L906D
        LDA     L0C32
        ORA     L0C33
        BEQ     L908A

        JSR     L9507

        LDX     #$30
        JSR     L8B4C

        LDA     L0C30
        ORA     L0C31
        BEQ     L908A

        LDX     #$2C
        JSR     L8B4C

.L908A
        JSR     L91DB

        LDA     L0C31
        BPL     L9055

        JMP     L8C6F_restore_saved_cursors_and_udgs

.L9095
        LDX     #$24
        LDY     #$14
        JSR     copyFourBytesWithinVDUVariables

        LDY     #$14
        LDX     #$20
        JSR     L90DC

        JSR     L914E

.L90A6
        JSR     L94C6

        JSR     L94ED

        LDY     #$30
        LDX     #$2C
        JSR     L8B3A

        LDA     L0C32
        ORA     L0C33
        BEQ     L90C5

        JSR     L9507

        LDY     #$30
        LDX     #$2C
        JSR     L8B3A

.L90C5
        LDA     #$00
        STA     L0C34
.L90CA
        JSR     L91DB

        LDA     L0C31
        BMI     L90D9

        LDA     L0C34
        BEQ     L90CA

        BNE     L90A6

.L90D9
        JMP     L8C6F_restore_saved_cursors_and_udgs

.L90DC
        STX     vduTempStoreDE
        STY     vduTempStoreDF
        SEC
        LDA     L0300,X
        SBC     L0300,Y
        STA     L0C17
        LDA     L0301,X
        SBC     L0301,Y
        STA     L0C18
        LDX     vduCurrentScreenMODE
        LDA     L8B18,X
        STA     L0C36
        AND     #$01
        BEQ     L9106

        ASL     L0C17
        ROL     L0C18
.L9106
        JSR     L9521

        LDX     #$03
.L910B
        LDA     L0C1A,X
        STA     L0C37,X
        DEX
        BPL     L910B

        LDX     vduTempStoreDE
        LDY     vduTempStoreDF
        SEC
        LDA     L0302,X
        SBC     L0302,Y
        STA     L0C17
        LDA     L0303,X
        SBC     L0303,Y
        STA     L0C18
        LDA     L0C36
        AND     #$02
        BEQ     L9138

        ASL     L0C17
        ROL     L0C18
.L9138
        JSR     L9521

        CLC
        LDX     #$FC
.L913E
        LDA     L0B3B,X
        ADC     L0B1E,X
        STA     L0B3B,X
        STA     L0B1E,X
        INX
        BMI     L913E

        RTS

.L914E
        JSR     LBEF6

        CLC
        LDA     L0C17
        ADC     L0C37
        STA     L0C37
        STA     L0C1A
        LDA     L0C18
        ADC     L0C38
        STA     L0C38
        STA     L0C1B
        LDA     #$00
        ADC     L0C39
        STA     L0C39
        STA     L0C1C
        LDA     #$00
        ADC     L0C3A
        STA     L0C3A
        STA     L0C1D
        JSR     LBEF6

        LDA     L0C17
        STA     L0C30
        ASL     A
        STA     L0C3D
        LDA     L0C18
        STA     L0C31
        ROL     A
        STA     L0C3E
        LDA     L0C3D
        BNE     L919F

        DEC     L0C3E
.L919F
        DEC     L0C3D
        JSR     L9521

        SEC
        LDA     L0C37
        SBC     L0C1A
        STA     L0C3F
        LDA     L0C38
        SBC     L0C1B
        STA     L0C40
        LDA     #$00
        STA     L0C33
        STA     L0C32
        STA     L0C42
        LDA     #$01
        STA     L0C41
        LDA     #$03
        STA     L0C35
        LDA     L0C36
        AND     #$01
        BEQ     L91DA

        LSR     L0C31
        ROR     L0C30
.L91DA
        RTS

.L91DB
        LDA     L0C35
        AND     L0C36
        STA     L0C35
.L91E4
        SEC
        LDA     L0C3F
        SBC     L0C41
        TAX
        LDA     L0C40
        SBC     L0C42
        BPL     L923C

        CLC
        LDA     L0C3F
        ADC     L0C3D
        STA     L0C3F
        LDA     L0C40
        ADC     L0C3E
        STA     L0C40
        SEC
        LDA     L0C3D
        SBC     #$02
        STA     L0C3D
        BCS     L9215

        DEC     L0C3E
.L9215
        LDA     L0C35
        EOR     #$01
        STA     L0C35
        AND     #$01
        BEQ     L922C

        LDA     L0C30
        BNE     L9229

        DEC     L0C31
.L9229
        DEC     L0C30
.L922C
        SEC
        LDA     L0C3F
        SBC     L0C41
        TAX
        LDA     L0C40
        SBC     L0C42
        BMI     L9267

.L923C
        STA     L0C40
        STX     L0C3F
        CLC
        LDA     L0C41
        ADC     #$02
        STA     L0C41
        BCC     L9250

        INC     L0C42
.L9250
        LDA     L0C35
        EOR     #$02
        STA     L0C35
        AND     #$02
        BEQ     L9267

        INC     L0C34
        INC     L0C32
        BNE     L9267

        INC     L0C33
.L9267
        LDA     L0C35
        BNE     L926F

        JMP     L91E4

.L926F
        RTS

.L9270
        LDA     #$00
        STA     L0C43
        JSR     L95ED

        LDY     #$14
        LDX     #$24
        JSR     L90DC

        JSR     L914E

.L9282
        JSR     L94C6

        JSR     L94ED

        LDY     #$00
        JSR     L96C5

        LDY     #$01
        JSR     L96EF

        LDX     L0C2F
        CPX     #$30
        BNE     L929C

        JSR     L8B4C

.L929C
        LDA     L0C30
        ORA     L0C31
        BEQ     L92AE

        LDX     L0C2C
        CPX     #$2C
        BNE     L92AE

        JSR     L8B4C

.L92AE
        LDA     L0C32
        ORA     L0C33
        BEQ     L92DF

        JSR     L9507

        LDY     #$03
        JSR     L96C5

        LDY     #$02
        JSR     L96EF

        LDX     L0C2F
        CPX     #$30
        BNE     L92CD

        JSR     L8B4C

.L92CD
        LDA     L0C30
        ORA     L0C31
        BEQ     L92DF

        LDX     L0C2C
        CPX     #$2C
        BNE     L92DF

        JSR     L8B4C

.L92DF
        JSR     L91DB

        LDA     L0C31
        BPL     L9282

        JMP     L8C6F_restore_saved_cursors_and_udgs

.L92EA
        LDA     #$00
        STA     L0C43
        LDA     #$01
        STA     L0C34
        JSR     L95ED

        LDY     #$14
        LDX     #$24
        JSR     L90DC

        JSR     L914E

.L9301
        JSR     L94C6

        JSR     L94ED

        LDY     #$00
        JSR     L96C5

        LDY     #$01
        JSR     L96EF

        LDA     L0C34
        BEQ     L9353

        LDA     L0C32
        ORA     L0C33
        BNE     L933B

        LDA     L0C2F
        BNE     L932E

        LDA     L0C2D
        PHA
        LDA     L0C2C
        PHA
        JMP     L9353

.L932E
        PHA
        LDA     L0C2C
        BNE     L9337

        LDA     L0C2E
.L9337
        PHA
        JMP     L9353

.L933B
        LDY     L0C2F
        BEQ     L9348

        LDX     L0C2E
        BEQ     L934B

        JSR     L8B3A

.L9348
        LDY     L0C2D
.L934B
        LDX     L0C2C
        BEQ     L9353

        JSR     L8B3A

.L9353
        JSR     L9507

        LDY     #$03
        JSR     L96C5

        LDY     #$02
        JSR     L96EF

        LDA     L0C34
        BEQ     L93CF

        LDA     L0C32
        ORA     L0C33
        BNE     L93B7

        PLA
        TAY
        LDA     L0C2F
        BNE     L937E

        LDA     L0C2D
        PHA
        LDX     L0C2C
        JMP     L9387

.L937E
        PHA
        LDX     L0C2C
        BNE     L9387

        LDX     L0C2E
.L9387
        BNE     L938F

        STY     L0C2C
        JMP     L939F

.L938F
        CPY     #$00
        BNE     L9399

        STX     L0C2C
        JMP     L939F

.L9399
        JSR     L9018

        STX     L0C2C
.L939F
        PLA
        TAX
        PLA
        TAY
        BNE     L93AA

        TXA
        TAY
        JMP     L93B1

.L93AA
        CPX     #$00
        BEQ     L93B1

        JSR     L9018

.L93B1
        LDX     L0C2C
        JMP     L93CC

.L93B7
        LDY     L0C2F
        BEQ     L93C4

        LDX     L0C2E
        BEQ     L93C7

        JSR     L8B3A

.L93C4
        LDY     L0C2D
.L93C7
        LDX     L0C2C
        BEQ     L93CF

.L93CC
        JSR     L8B3A

.L93CF
        LDA     #$00
        STA     L0C34
        JSR     L91DB

        LDA     L0C31
        BMI     L93DF

        JMP     L9301

.L93DF
        JMP     L8C6F_restore_saved_cursors_and_udgs

.L93E2
        LDA     #$00
        STA     L0C43
        LDA     #$01
        STA     L0C34
        JSR     L95ED

        LDY     #$14
        LDX     #$24
        JSR     L90DC

        JSR     L914E

        JSR     L9546

.L93FC
        JSR     L94C6

        JSR     L94ED

        LDY     #$00
        JSR     L96C5

        LDY     #$01
        JSR     L96EF

        LDY     L0C2F
        CPY     #$30
        BNE     L942D

        LDX     L0C2C
        CPX     #$2C
        BEQ     L9422

        JSR     L9831

        LDY     #$30
        LDX     L0C43
.L9422
        LDA     L0C34
        BEQ     L9444

        JSR     L8B3A

        JMP     L9444

.L942D
        LDX     L0C2C
        CPX     #$2C
        BNE     L9444

        JSR     L9831

        LDX     #$2C
        LDY     L0C43
        LDA     L0C34
        BEQ     L9444

        JSR     L8B3A

.L9444
        LDA     #$00
        STA     L0C34
        JSR     L91DB

        LDA     L0C31
        BPL     L93FC

        LDY     #$14
        LDX     #$24
        JSR     L90DC

        JSR     L914E

        LDA     #$00
        STA     L0C43
        JSR     L95B4

        LDA     L0C32
        ORA     L0C33
        BNE     L946E

        STA     L0C34
.L946E
        JSR     L94C6

        JSR     L9507

        LDY     #$03
        JSR     L96C5

        LDY     #$02
        JSR     L96EF

        LDY     L0C2F
        CPY     #$30
        BNE     L949F

        LDX     L0C2C
        CPX     #$2C
        BEQ     L9494

        JSR     L9831

        LDY     #$30
        LDX     L0C43
.L9494
        LDA     L0C34
        BEQ     L94B6

        JSR     L8B3A

        JMP     L94B6

.L949F
        LDX     L0C2C
        CPX     #$2C
        BNE     L94B6

        JSR     L9831

        LDX     #$2C
        LDY     L0C43
        LDA     L0C34
        BEQ     L94B6

        JSR     L8B3A

.L94B6
        LDA     #$00
        STA     L0C34
        JSR     L91DB

        LDA     L0C31
        BPL     L946E

        JMP     L8C6F_restore_saved_cursors_and_udgs

.L94C6
        CLC
        LDA     L0314
        ADC     L0C30
        STA     L0330
        LDA     L0315
        ADC     L0C31
        STA     L0331
        SEC
        LDA     L0314
        SBC     L0C30
        STA     L032C
        LDA     L0315
        SBC     L0C31
        STA     L032D
        RTS

.L94ED
        CLC
        LDA     L0316
        ADC     L0C32
        STA     L0332
        STA     L032E
        LDA     L0317
        ADC     L0C33
        STA     L0333
        STA     L032F
        RTS

.L9507
        SEC
        LDA     L0316
        SBC     L0C32
        STA     L0332
        STA     L032E
        LDA     L0317
        SBC     L0C33
        STA     L0333
        STA     L032F
        RTS

.L9521
        LDA     L0C18
        BPL     L9537

        SEC
        LDA     #$00
        SBC     L0C17
        STA     L0C17
        LDA     #$00
        SBC     L0C18
        STA     L0C18
.L9537
        LDA     L0C17
        STA     L0C1A
        LDA     L0C18
        STA     L0C1B
        JMP     LBEAD

.L9546
        LDY     #$03
.L9548
        LDA     L0C37,Y
        STA     L0C44,Y
        DEY
        BPL     L9548

.L9551
        LDY     #$03
.L9553
        LDA     L033F,Y
        STA     L0328,Y
        DEY
        BPL     L9553

        LDX     #$3F
        JSR     L992F

        LDX     #$3F
        LDY     #$14
        JSR     L90DC

        SEC
        LDX     #$03
        LDY     #$00
.L956D
        LDA     L0C44,Y
        SBC     L0C37,Y
        INY
        DEX
        BPL     L956D

        BCS     L9551

        LDY     #$14
        LDA     #$20
        LDX     #$3F
        JSR     L9872

        LDA     L0C48
        EOR     L0C49
        AND     #$02
        BEQ     L95B3

        LDA     L0C48
        LSR     A
        LSR     A
        LDY     #$24
        LDA     #$28
        LDX     #$34
        BCS     L959F

        LDY     #$28
        LDA     #$24
        LDX     #$3F
.L959F
        STX     L0C43
        STA     L0C4A
        JSR     L9872

        LDX     L0C48
        LDA     L0C4B,X
        AND     #$01
        STA     L0C52
.L95B3
        RTS

.L95B4
        LDA     L0C48
        EOR     L0C49
        AND     #$02
        BEQ     L95B3

        LDA     L0C48
        LSR     A
        LSR     A
        PHP
        LDY     #$14
        LDA     #$24
        LDX     #$34
        BCS     L95D2

        LDY     #$14
        LDA     #$20
        LDX     #$3F
.L95D2
        JSR     L9872

        PLP
        LDY     #$24
        LDA     #$28
        LDX     #$34
        BCC     L95E4

        LDY     #$28
        LDA     #$24
        LDX     #$3F
.L95E4
        STX     L0C43
        STA     L0C4A
        JMP     L9872

.L95ED
        LDY     #$03
        LDA     #$00
.L95F1
        STA     L0C4B,Y
        DEY
        BPL     L95F1

        LDY     #$14
        LDA     #$24
        LDX     #$34
        JSR     L9872

        LDX     #$34
        JSR     L96B5

        STA     L0C48
        LDY     #$14
        LDA     #$20
        LDX     #$3F
        JSR     L9872

        LDX     #$3F
        JSR     L96B5

        STA     L0C49
        CMP     L0C48
        BEQ     L9636

        TAY
        ROR     A
        LDA     #$07
        BCC     L9626

        EOR     #$09
.L9626
        STA     L0C4B,Y
        LDA     L0C48
        TAY
        ROR     A
        LDA     #$0A
        BCC     L96A2

        EOR     #$09
        BCS     L96A2

.L9636
        LDY     #$01
.L9638
        LDA     L033A,Y
        STA     L0C17,Y
        LDA     L0343,Y
        STA     L0C1A,Y
        DEY
        BPL     L9638

        JSR     LBEAD

        LDY     #$03
.L964C
        LDA     L0C1A,Y
        STA     L0C37,Y
        DEY
        BPL     L964C

        LDY     #$01
.L9657
        LDA     L0345,Y
        STA     L0C17,Y
        LDA     L0338,Y
        STA     L0C1A,Y
        DEY
        BPL     L9657

        JSR     LBEAD

        LDX     #$03
        LDY     #$00
        LDA     L0C48
        ROR     A
        BCS     L9680

        SEC
.L9674
        LDA     L0C1A,Y
        SBC     L0C37,Y
        INY
        DEX
        BPL     L9674

        BMI     L968A

.L9680
        LDA     L0C37,Y
        SBC     L0C1A,Y
        INY
        DEX
        BPL     L9680

.L968A
        LDA     #$3A
        BCS     L9690

        EOR     #$6D
.L9690
        ROR     L0C48
        BCC     L9697

        EOR     #$24
.L9697
        ROL     L0C48
        LDY     L0C48
        STA     L0C4B,Y
        BCS     L96B4

.L96A2
        STA     L0C4B,Y
        INY
        TYA
        AND     #$03
        CMP     L0C49
        BEQ     L96B4

        TAY
        LDA     #$01
        JMP     L96A2

.L96B4
        RTS

.L96B5
        LDA     L030A,X
        AND     #$C0
        ASL     A
        BCS     L96C0

        ROL     A
        ROL     A
        RTS

.L96C0
        ROL     A
        ROL     A
        EOR     #$01
        RTS

.L96C5
        LDA     #$30
        STA     L0C2C
        LDA     #$00
        STA     L0C2D
        STA     L0C2E
        JSR     L96EF

        LDA     L0C2C
        STA     L0C2F
        LDA     L0C2D
        PHA
        LDA     L0C2E
        STA     L0C2D
        PLA
        STA     L0C2E
        LDA     #$2C
        STA     L0C2C
        RTS

.L96EF
        LDA     #$00
        STA     L0C51
        LDA     L0C4B,Y
        LSR     A
        BNE     L9700

        BCS     L96FF

        STA     L0C2C
.L96FF
        RTS

.L9700
        PHP
        LSR     A
        LSR     A
        STY     L0C50
        LDX     #$34
        LDY     #$3F
        BCC     L9710

        LDX     #$3F
        LDY     #$34
.L9710
        STY     L0C4F
        LDY     L0C2C
        PLP
        BCS     L9749

        JSR     L97FE

        BPL     L9727

        JSR     L9783

        LDY     L0C50
        JMP     L96EF

.L9727
        BNE     L972C

        STX     L0C2C
.L972C
        LDX     L0C50
        LDA     L0C4B,X
        AND     #$F0
        BEQ     L9746

        LDX     L0C4F
        JSR     L97B5

        BEQ     L9743

        LDA     #$02
        STA     L0C51
.L9743
        STX     L0C2D
.L9746
        JMP     L9777

.L9749
        JSR     L97B5

        BPL     L9757

        JSR     L9783

        LDY     L0C50
        JMP     L96EF

.L9757
        STX     L0C2D
        LDX     L0C50
        LDA     L0C4B,X
        AND     #$F0
        BEQ     L9774

        LDX     L0C4F
        JSR     L97FE

        BEQ     L9771

        LDA     #$02
        STA     L0C51
.L9771
        STX     L0C2E
.L9774
        JMP     L9777

.L9777
        DEC     L0C51
        BMI     L9782

        JSR     L9783

        JMP     L9777

.L9782
        RTS

.L9783
        LDX     L0C50
        LDA     L0C4B,X
        LSR     A
        LSR     A
        LSR     A
        STA     L0C4B,X
        AND     #$01
        STA     L0C52
        LDA     L0C43
        BEQ     L979E

        LDA     #$00
        STA     L0C43
.L979E
        LDY     #$34
        LDA     #$28
        LDX     #$34
        BCC     L97AC

        LDY     #$3F
        LDA     #$24
        LDX     #$3F
.L97AC
        STX     L0C43
        STA     L0C4A
        JMP     L9872

.L97B5
        LDA     L0302,Y
        CMP     L0302,X
        BNE     L97DE

        LDA     L0303,Y
        CMP     L0303,X
        BNE     L97DE

        LDA     L0300,Y
        CMP     L0300,X
        BNE     L97DB

        LDA     L0301,Y
        CMP     L0301,X
        BNE     L97DB

        INC     L0C51
        LDA     #$01
        RTS

.L97DB
        LDA     #$00
        RTS

.L97DE
        LDA     L0300,Y
        CMP     L0300,X
        BNE     L97EE

        LDA     L0301,Y
        CMP     L0301,X
        BEQ     L97FC

.L97EE
        STX     vduTempStoreDE
        STY     vduTempStoreDF
        JSR     L992F

        LDX     vduTempStoreDE
        LDY     vduTempStoreDF
        JMP     L97B5

.L97FC
        ROR     A
        RTS

.L97FE
        JSR     L97B5

        BEQ     L9804

        RTS

.L9804
        LDA     L0300,Y
        CMP     L0300,X
        BNE     L9819

        LDA     L0301,Y
        CMP     L0301,X
        BNE     L9819

        ROL     A
        INC     L0C51
        RTS

.L9819
        CLC
        LDA     L0309,X
        AND     #$80
        ROL     A
        BCS     L9830

        STX     vduTempStoreDE
        STY     vduTempStoreDF
        JSR     L992F

        LDX     vduTempStoreDE
        LDY     vduTempStoreDF
        JMP     L9804

.L9830
        RTS

.L9831
        LDX     L0C43
        LDA     L0302,X
        CMP     L032E
        BNE     L9844

        LDA     L0303,X
        CMP     L032F
        BEQ     L984A

.L9844
        JSR     L992F

        JMP     L9831

.L984A
        LDA     L0C52
        BEQ     L9871

.L984F
        LDY     L0C4A
        LDA     L0300,X
        CMP     L0300,Y
        BNE     L9862

        LDA     L0301,X
        CMP     L0301,Y
        BEQ     L9871

.L9862
        LDA     L0309,X
        ROL     A
        BCS     L9871

        JSR     L992F

        LDX     L0C43
        JMP     L984F

.L9871
        RTS

.L9872
        PHA
        STA     L0C16
        TYA
        PHA
        LDA     L0C16
        JSR     L98F5

        PLA
        TAY
        PLA
        INY
        INY
        CLC
        ADC     #$02
        INX
        INX
        JSR     L98F5

        DEX
        DEX
        LDA     L0306,X
        CMP     L0304,X
        LDA     L0307,X
        SBC     L0305,X
        PHP
        LDA     L0305,X
        ASL     A
        ROR     L030A,X
        LDA     L0307,X
        ASL     A
        ROR     L030A,X
        BPL     L98B1

        INX
        INX
        JSR     L991B

        DEX
        DEX
.L98B1
        LDA     L030A,X
        ROL     A
        BPL     L98BA

        JSR     L991B

.L98BA
        LDA     L0306,X
        CMP     L0304,X
        LDA     L0307,X
        SBC     L0305,X
        BMI     L98D1

        LDA     L0307,X
        LDY     L0306,X
        JMP     L98D7

.L98D1
        LDA     L0305,X
        LDY     L0304,X
.L98D7
        PLP
        BMI     L98E2

        INY
        DEY
        BNE     L98E1

        SEC
        SBC     #$01
.L98E1
        DEY
.L98E2
        LSR     A
        PHA
        TYA
        ROR     A
        SEC
        SBC     L0306,X
        STA     L0308,X
        PLA
        SBC     L0307,X
        STA     L0309,X
        RTS

.L98F5
        STA     L0C16
        LDA     L0300,Y
        STA     L0300,X
        LDA     L0301,Y
        STA     L0301,X
        LDY     L0C16
        SEC
        LDA     L0300,Y
        SBC     L0300,X
        STA     L0304,X
        LDA     L0301,Y
        SBC     L0301,X
        STA     L0305,X
        RTS

.L991B
        SEC
        LDA     #$00
        SBC     L0304,X
        TAY
        LDA     #$00
        SBC     L0305,X
        STA     L0305,X
        TYA
        STA     L0304,X
        RTS

.L992F
        LDA     L0309,X
        BPL     L995C

.L9934
        CLC
        LDA     L0308,X
        ADC     L0304,X
        STA     L0308,X
        LDA     L0309,X
        ADC     L0305,X
        STA     L0309,X
        BMI     L994C

        JSR     L995C

.L994C
        INX
        INX
        LDA     L0308,X
        BMI     L9975

.L9953
        INC     L0300,X
        BNE     L995B

        INC     L0301,X
.L995B
        RTS

.L995C
        SEC
        LDA     L0308,X
        SBC     L0306,X
        STA     L0308,X
        LDA     L0309,X
        SBC     L0307,X
        STA     L0309,X
        LDA     L030A,X
        ASL     A
        BPL     L9953

.L9975
        LDA     L0300,X
        BNE     L997D

        DEC     L0301,X
.L997D
        DEC     L0300,X
        RTS

.L9981
        JSR     L99B8

        LDA     L030A,X
        ASL     A
        ASL     A
        LDA     L030A,X
        ROR     A
        STA     vduTempStoreDA
        CLC
        BPL     L99A2

        LDA     L0302,X
        SBC     L0304
        TAY
        LDA     L0303,X
        SBC     L0305
        JMP     L99AF

.L99A2
        LDA     L0300
        SBC     L0302,X
        TAY
        LDA     L0301
        SBC     L0303,X
.L99AF
        JSR     L9A0A

        JSR     L99B8

        JMP     L995C

.L99B8
        INX
        TXA
        PHA
        INX
        TXA
        DEX
        DEX
        TAY
        JSR     exchangeTwoVDUBytes

        INX
        INX
        INY
        INY
        JSR     exchangeTwoVDUBytes

        STA     L0C16
        PLA
        TAX
        LDA     L0C16
        JSR     L99D6

        DEX
.L99D6
        LDA     L0308,X
        EOR     #$FF
        STA     L0308,X
        RTS

.L99DF
        CLC
        LDA     L030A,X
        STA     vduTempStoreDA
        BPL     L99F7

        LDA     L0302,X
        SBC     L0306
        TAY
        LDA     L0303,X
        SBC     L0307
        JMP     L9A04

.L99F7
        LDA     L0302
        SBC     L0302,X
        TAY
        LDA     L0303
        SBC     L0303,X
.L9A04
        JSR     L9A0A

        JMP     L9934

.L9A0A
        STY     vduTempStoreDE
        STA     vduTempStoreDF
        LDA     L0302,X
        LDY     L0303,X
        ASL     vduTempStoreDA
        BCS     L9A23

        ADC     vduTempStoreDE
        STA     L0302,X
        TYA
        ADC     vduTempStoreDF
        JMP     L9A2B

.L9A23
        SBC     vduTempStoreDE
        STA     L0302,X
        TYA
        SBC     vduTempStoreDF
.L9A2B
        STA     L0303,X
        LDA     L0309,X
        PHP
        LDA     #$00
        PLP
        BPL     L9A3A

        SEC
        SBC     #$01
.L9A3A
        STA     vduTempStoreDC
        LSR     A
        STA     vduTempStoreDD
        LDY     #$10
.L9A41
        LDA     vduTempStoreDD
        ASL     A
        ROL     L0308,X
        ROL     L0309,X
        ROL     vduTempStoreDC
        ROL     vduTempStoreDD
        ASL     vduTempStoreDE
        ROL     vduTempStoreDF
        BCC     L9A6D

        CLC
        LDA     vduTempStoreDC
        ADC     L0304,X
        STA     vduTempStoreDC
        LDA     vduTempStoreDD
        ADC     L0305,X
        STA     vduTempStoreDD
        BCC     L9A6D

        INC     L0308,X
        BNE     L9A6D

        INC     L0309,X
.L9A6D
        DEY
        BNE     L9A41

        STA     L0C16
        LDA     L0309,X
        ASL     A
        PHP
        LDA     L0C16
        PLP
        BPL     L9A89

        LDA     vduTempStoreDC
        STA     L0308,X
        LDA     vduTempStoreDD
        STA     L0309,X
        RTS

.L9A89
        LDY     #$10
.L9A8B
        ROL     vduTempStoreDC
        ROL     vduTempStoreDD
        ROL     L0308,X
        ROL     L0309,X
        SEC
        LDA     L0308,X
        SBC     L0306,X
        STA     vduTempStoreDE
        LDA     L0309,X
        SBC     L0307,X
        BCC     L9AAE

        STA     L0309,X
        LDA     vduTempStoreDE
        STA     L0308,X
.L9AAE
        DEY
        BNE     L9A8B

        ROL     vduTempStoreDC
        ROL     vduTempStoreDD
        SEC
        LDA     L0308,X
        SBC     L0306,X
        STA     L0308,X
        LDA     L0309,X
        SBC     L0307,X
        STA     L0309,X
        LDA     L0300,X
        LDY     L0301,X
        ASL     vduTempStoreDA
        BCS     L9ADE

        SEC
        ADC     vduTempStoreDC
        STA     L0300,X
        TYA
        ADC     vduTempStoreDD
        JMP     L9AE7

.L9ADE
        CLC
        SBC     vduTempStoreDC
        STA     L0300,X
        TYA
        SBC     vduTempStoreDD
.L9AE7
        STA     L0301,X
.L9AEA
        RTS

.L9AEB
        JSR     L9CCB

        LDA     L031F
        JSR     L9AFA

        JSR     L9CDC

        JMP     L8C6F_restore_saved_cursors_and_udgs

.L9AFA
        ASL     A
        ASL     A
        STA     vduTempStoreDB
        AND     #$C0
        EOR     #$40
        BNE     L9B14

        LDA     #$80
        STA     L0C12
        LDA     #$00
        STA     L0C13
        LDA     L0C10
        STA     L0C11
.L9B14
        LDX     #$24
        JSR     checkPointXIsWithinGraphicsWindow

        STA     vduTempStoreDC
        BEQ     L9B23

        LDA     #$7F
        AND     vduTempStoreDB
        STA     vduTempStoreDB
.L9B23
        LDX     #$20
        JSR     checkPointXIsWithinGraphicsWindow

        STA     L0C14
        BEQ     L9B39

        TAX
        LDA     #$DF
        AND     vduTempStoreDB
        STA     vduTempStoreDB
        TXA
        BIT     vduTempStoreDC
.L9B37
        BNE     L9AEA

.L9B39
        LDY     #$24
        LDA     #$20
        LDX     #$28
        JSR     L9872

        LDA     vduTempStoreDC
        AND     #$0C
        PHP
        LDA     vduTempStoreDC
        PLP
        BEQ     L9B5B

        LDX     #$28
        JSR     L99DF

        LDX     #$28
        JSR     checkPointXIsWithinGraphicsWindow

        BIT     L0C14
        BNE     L9B37

.L9B5B
        STA     L0C16
        AND     #$03
        PHP
        LDA     L0C16
        PLP
        BEQ     L9B71

        LDX     #$28
        JSR     L9981

        LDX     #$28
        JSR     checkPointXIsWithinGraphicsWindow

.L9B71
        TAY
        BNE     L9B37

        LDY     #$20
        LDX     #$22
        LDA     L0C14
        BEQ     L9B8C

        LDY     #$04
        LDX     #$06
        BIT     L0332
        BPL     L9B88

        LDX     #$02
.L9B88
        BVC     L9B8C

        LDY     #$00
.L9B8C
        CLC
        LDA     L0300,X
        SBC     L032A
        BCC     L9B99

        ADC     #$00
        EOR     #$FF
.L9B99
        STA     vduTempStoreDC
        CLC
        LDA     L0300,Y
        SBC     L0328
        TAX
        LDA     L0301,Y
        SBC     L0329
        BMI     L9BB9

        INX
        BNE     L9BB1

        CLC
        ADC     #$01
.L9BB1
        EOR     #$FF
        TAY
        TXA
        EOR     #$FF
        TAX
        TYA
.L9BB9
        STA     vduTempStoreDD
        STX     L0C14
        LDX     #$28
        JSR     L8B5A

        ASL     vduTempStoreDB
        BCS     L9C1E

.L9BC7
        BIT     vduTempStoreDB
        BVC     L9BD9

        LDA     L0C14
        AND     vduTempStoreDC
        AND     vduTempStoreDD
        CLC
        ADC     #$01
        BEQ     L9C35

        BIT     vduTempStoreDB
.L9BD9
        BPL     L9C0E

        STX     L0C16
        LDX     L0C13
        LDA     L0C08,X
        AND     L0C12
        PHP
        LSR     L0C12
        BCC     L9BF3

        ROR     L0C12
        INC     L0C13
.L9BF3
        DEC     L0C11
        BNE     L9C08

        LDA     L0C10
        STA     L0C11
        LDA     #$80
        STA     L0C12
        LDA     #$00
        STA     L0C13
.L9C08
        LDX     L0C16
        PLP
        BEQ     L9C1E

.L9C0E
if BBC_B or ELECTRON
        LDA     vduCurrentPlotByteMask
        AND     vduGraphicsColourByteOR
        ORA     (vduScreenAddressOfGraphicsCursorCellLow),Y
        STA     vduTempStoreDA
        LDA     vduCurrentPlotByteMask
        AND     vduGraphicsColourByteEOR
        EOR     vduTempStoreDA
        STA     (vduScreenAddressOfGraphicsCursorCellLow),Y
elif BBC_B_PLUS
        JSR     plotPointWithinBoundsAtY
else
        unknown_machine
endif
.L9C1E
        LDA     L0331
        BPL     L9C59

        INC     vduTempStoreDC
        BEQ     L9C35

        BIT     L0332
        BMI     L9C36

        DEY
        BPL     L9C3E

        JSR     moveGraphicsCursorAddressUpOneCharacterCell

        JMP     L9C3E

.L9C35
        RTS

.L9C36
        INY
        CPY     #$08
        BNE     L9C3E

        JSR     L9CB3

.L9C3E
        JSR     L8B5D

        CLC
        LDA     L0330
        ADC     L032C
        STA     L0330
        LDA     L0331
        ADC     L032D
        STA     L0331
        BPL     L9C59

        JMP     L9BC7

.L9C59
        INC     L0C14
        BNE     L9C62

        INC     vduTempStoreDD
        BEQ     L9C35

.L9C62
        BIT     L0332
        BVS     L9C71

        LSR     vduCurrentPlotByteMask
        BCC     L9C78

        JSR     moveGraphicsCursorAddressTotheRightAndUpdateMask

        JMP     L9C78

.L9C71
        ASL     vduCurrentPlotByteMask
        BCC     L9C78

        JSR     moveGraphicsCursorAddressTotheLeftAndUpdateMask

.L9C78
        SEC
        LDA     L0330
        SBC     L032E
        STA     L0330
        LDA     L0331
        SBC     L032F
        STA     L0331
        JMP     L9BC7

        BMI     L9C99

        INC     L0328,X
        BNE     L9CA4

        INC     L0329,X
        RTS

.L9C99
        LDA     L0328,X
        BNE     L9CA1

        DEC     L0329,X
.L9CA1
        DEC     L0328,X
.L9CA4
        RTS

        LDY     #$04
.L9CA7
        LDA     L0327,Y
        CMP     L032B,Y
        BNE     L9CB2

        DEY
        BNE     L9CA7

.L9CB2
        RTS

.L9CB3
        CLC
        LDA     vduScreenAddressOfGraphicsCursorCellLow
        ADC     L0352
        STA     vduScreenAddressOfGraphicsCursorCellLow
        LDA     vduScreenAddressofGraphicsCursorCellHigh
        ADC     L0353
        BPL     L9CC6

        SEC
        SBC     L0354
.L9CC6
        STA     vduScreenAddressofGraphicsCursorCellHigh
        LDY     #$00
        RTS

.L9CCB
        JSR     L8943_set_f8_f9_to_private_workspace

        LDY     #$97
        LDX     #$0B
.L9CD2
        LDA     (L00F8),Y
        STA     L0C08,X
        DEY
        DEX
        BPL     L9CD2

        RTS

.L9CDC
        JSR     L8943_set_f8_f9_to_private_workspace

        LDY     #$97
        LDX     #$02
.L9CE3
        LDA     L0C11,X
        STA     (L00F8),Y
        DEY
        DEX
        BPL     L9CE3

        RTS

.L9CED
        LDA     #$01
        LDX     #$00
        BEQ     L9CF7

.L9CF3
        LDA     #$00
        LDX     #$01
.L9CF7
        STA     L0330
        JSR     L8E35

        LDY     #$49
        LDA     (L00F8),Y
        BPL     L9D4F

        LDX     #$20
        JSR     L9F1D

        BNE     L9D4F

        LDA     #$00
        STA     L032D
        STA     L032E
        LDA     L0320
        LDX     L0321
        LDY     L0322
        JSR     L9DD1

        JSR     L9D52

.L9D21
        BIT     L00FF
        BMI     L9D4F

        JSR     L9D93

        LDY     L032A
        INY
        BEQ     L9D39

        STY     L032A
        JSR     L9EE1

        BCC     L9D4F

        DEC     L032A
.L9D39
        LDY     L032A
        BEQ     L9D47

        DEY
        STY     L032A
        JSR     L9EE1

        BCC     L9D4F

.L9D47
        LDX     L032E
        CPX     L032D
        BNE     L9D21

.L9D4F
        JMP     L8C6F_restore_saved_cursors_and_udgs

.L9D52
        LDX     L032E
        INX
        TXA
        AND     #$7F
        CMP     L032D
        BEQ     L9D91

        STA     L032E
        TAY
        LDA     L00F9
        STA     vduTempStoreDD
        INC     vduTempStoreDD
        LDA     #$00
        STA     vduTempStoreDC
        LDA     L0314
        STA     (vduTempStoreDC),Y
        INC     vduTempStoreDD
        LDA     L0324
        STA     (vduTempStoreDC),Y
        LDA     #$80
        STA     vduTempStoreDC
        LDA     L0325
        ASL     A
        ASL     A
        ASL     A
        ASL     A
        ORA     L0315
        STA     (vduTempStoreDC),Y
        DEC     vduTempStoreDD
        LDA     L0316
        STA     (vduTempStoreDC),Y
        SEC
        RTS

.L9D91
        CLC
        RTS

.L9D93
        INC     L032D
        LDA     L032D
        AND     #$7F
        STA     L032D
        TAY
        LDA     L00F9
        STA     vduTempStoreDD
        INC     vduTempStoreDD
        LDA     #$00
        STA     vduTempStoreDC
        LDA     (vduTempStoreDC),Y
        STA     L0328
        INC     vduTempStoreDD
        LDA     (vduTempStoreDC),Y
        STA     L032B
        LDA     #$80
        STA     vduTempStoreDC
        LDA     (vduTempStoreDC),Y
        LSR     A
        LSR     A
        LSR     A
        LSR     A
        STA     L032C
        LDA     (vduTempStoreDC),Y
        AND     #$0F
        STA     L0329
        DEC     vduTempStoreDD
        LDA     (vduTempStoreDC),Y
        STA     L032A
        RTS

.L9DD1
        STA     L0324
        STA     L0314
        STX     L0325
        STX     L0315
        STY     L0326
        STY     L0316
        LDA     #$00
        STA     L0327
        STA     L0317
.L9DEB
        LDX     #$14
        JSR     L8B55

        BEQ     L9DF3

        RTS

.L9DF3
        JSR     L9F24

        BEQ     L9E03

        RTS

.L9DF9
        JSR     L9F24

        BNE     L9E34

        LDA     vduCurrentPlotByteMask
        ORA     L032F
.L9E03
        STA     L032F
        LDA     L0315
        CMP     L0301
        BNE     L9E16

        LDA     L0314
        CMP     L0300
        BEQ     L9E3C

.L9E16
        LDA     L0314
        BNE     L9E1E

        DEC     L0315
.L9E1E
        DEC     L0314
        ASL     vduCurrentPlotByteMask
        BCC     L9DF9

        JSR     L9E8E

        LDA     #$00
        STA     L032F
        SEC
        JSR     moveGraphicsCursorAddressTotheLeftAndUpdateMask

        JMP     L9DF9

.L9E34
        INC     L0314
        BNE     L9E3C

        INC     L0315
.L9E3C
        JSR     L9E8E

.L9E3F
        LDA     #$00
        STA     L032F
        LDX     #$24
        JSR     L8B55

        BNE     L9EA0

.L9E4B
        JSR     L9F24

        BNE     L9E83

        LDA     vduCurrentPlotByteMask
        ORA     L032F
        STA     L032F
        LDA     L0325
        CMP     L0305
        BNE     L9E68

        LDA     L0324
        CMP     L0304
        BEQ     L9E8E

.L9E68
        INC     L0324
        BNE     L9E70

        INC     L0325
.L9E70
        LSR     vduCurrentPlotByteMask
        BCC     L9E4B

        JSR     L9E8E

        LDA     #$00
        STA     L032F
        SEC
        JSR     moveGraphicsCursorAddressTotheRightAndUpdateMask

        JMP     L9E4B

.L9E83
        LDA     L0324
        BNE     L9E8B

        DEC     L0325
.L9E8B
        DEC     L0324
.L9E8E
if BBC_B or ELECTRON
        LDA     L032F
        AND     vduGraphicsColourByteOR
        ORA     (vduScreenAddressOfGraphicsCursorCellLow),Y
        STA     vduTempStoreDA
        LDA     vduGraphicsColourByteEOR
        AND     L032F
        EOR     vduTempStoreDA
        STA     (vduScreenAddressOfGraphicsCursorCellLow),Y
elif BBC_B_PLUS
        LDX     vduCurrentPlotByteMask
        LDA     L032F
        STA     vduCurrentPlotByteMask
        JSR     plotPointWithinBoundsAtY
        STX     vduCurrentPlotByteMask
else
        unknown_machine
endif
.L9EA0
        RTS

.L9EA1
        STA     L0320
        STX     L0321
        STY     L0322
        LDA     #$00
        STA     L0323
        LDX     #$20
        JSR     L8B55

        BNE     L9EDF

.L9EB6
        JSR     L9F24

        BEQ     L9EDD

        LDY     L0320
        CPY     L032B
        BNE     L9ECB

        LDY     L0321
        CPY     L032C
        BEQ     L9EDF

.L9ECB
        INC     L0320
        BNE     L9ED3

        INC     L0321
.L9ED3
        LSR     vduCurrentPlotByteMask
        BCC     L9EB6

        JSR     moveGraphicsCursorAddressTotheRightAndUpdateMask

        JMP     L9EB6

.L9EDD
        CLC
        RTS

.L9EDF
        SEC
        RTS

.L9EE1
        LDA     L0328
        LDX     L0329
        LDY     L032A
        JSR     L9EA1

        BCS     L9F1C

.L9EEF
        LDA     L0320
        LDX     L0321
        LDY     L0322
        JSR     L9DD1

        JSR     L9D52

        BCC     L9F1C

        LDA     L0324
        CMP     L032B
        LDA     L0325
        SBC     L032C
        BCS     L9F1C

        LDA     L0324
        LDX     L0325
        LDY     L0326
        JSR     L9EA1

        BCC     L9EEF

.L9F1C
        RTS

.L9F1D
        LDX     #$20
        JSR     L8B55

        BNE     L9F35

.L9F24
        LDY     L031A
if BBC_B or ELECTRON
        LDA     (vduScreenAddressOfGraphicsCursorCellLow),Y
elif BBC_B_PLUS
        JSR     b_plus_lda_d6_indirect_y_eor_35a_sta_da
        EOR     L035A ; undo the unwanted eor from subroutine call
else
        unknown_machine
endif
        EOR     L0C17,Y
        AND     vduCurrentPlotByteMask
        BEQ     L9F32

        LDA     #$01
.L9F32
        EOR     L0330
.L9F35
        RTS

.L9F36
        LDA     #$00
        LDX     #$01
.L9F3A
        STA     L0330
        JSR     L8E35

        LDY     #$03
.L9F42
        LDA     L0320,Y
        STA     L0314,Y
        STA     L0324,Y
        DEY
        BPL     L9F42

        JSR     L9DEB

        JMP     L8C80_restore_saved_udgs

.L9F54
        LDA     #$01
        LDX     #$00
        BEQ     L9F3A

.L9F5A
        LDA     #$01
        TAX
        BNE     L9F62

.L9F5F
        LDA     #$00
        TAX
.L9F62
        STA     L0330
        JSR     L8E35

        LDY     #$03
.L9F6A
        LDA     L0320,Y
        STA     L0314,Y
        STA     L0324,Y
        DEY
        BPL     L9F6A

        JSR     L9E3F

        JMP     L8C80_restore_saved_udgs

.L9F7C
        LDY     #$02
.L9F7E
        LDA     #$00
        STA     vduTempStoreDA
        DEX
        DEX
        JSR     checkPointIsWithinWindowHorizontalOrVertical

        INX
        INX
        LDA     vduTempStoreDA
        RTS

.L9F8C
        LDA     L031F
        JSR     L9F95

        JMP     L8C6F_restore_saved_cursors_and_udgs

.L9F95
        AND     #$02
        STA     L0345
        LDA     gcolPlotOptionsTable
        STA     L00A8
        LDA     gcolPlotOptionsTable + 1
        STA     L00A9
        LDA     gcolPlotOptionsTable - 1
        STA     L00AA
        LDA     gcolPlotOptionsTable+4
        STA     L00AB
        LDX     #$01
        JSR     L8E35

        LDX     #$07
.L9FB5
        LDA     L0C17,X
        STA     L0C00,X
        DEX
        BPL     L9FB5

        LDX     #$14
        JSR     L8E0D

        LDY     #$34
        LDX     #$20
        JSR     copyFourBytesWithinVDUVariables

        STY     vduTempStoreDA
        LDX     #$34
        LDY     #$2C
        LDA     #$28
        JSR     LA1C2

        LDX     #$28
        LDY     #$34
        JSR     L902D

        STA     L0C16
        TYA
        PHA
        TXA
        PHA
        LDA     L0C16
        LDY     #$00
        JSR     L9F7E

        BEQ     L9FF5

        LSR     A
        BEQ     L9FF3

        PLA
.L9FF1
        PLA
        RTS

.L9FF3
        LDX     #$00
.L9FF5
        PLA
        LDY     #$30
        STY     vduTempStoreDA
        LDY     #$28
        JSR     LA1D0

        LDY     #$3C
        STY     vduTempStoreDA
        LDY     #$34
        JSR     LA1D0

        PLA
        CLC
        ADC     #$04
        TAX
        PHA
        LDY     #$00
        JSR     L9F7E

        BEQ     LA01A

        LSR     A
        BEQ     L9FF1

        LDX     #$04
.LA01A
        PLA
        LDY     #$40
        STY     vduTempStoreDA
        LDY     #$38
        JSR     LA1D0

        LDA     L0340
        CMP     L033C
        LDA     L0341
        SBC     L033D
        BPL     LA044

        LDA     L0345
        BNE     LA03A

        JSR     L8DE5

.LA03A
        LDX     #$34
        LDY     #$28
        JSR     copyEightBytesWithinVDUVariables

        JMP     L8DE5

.LA044
        LDA     #$00
        STA     L0347
        LDA     L0330
        AND     L0361
        STA     vduTempStoreDA
        LDA     L033C
        AND     L0361
        SEC
        SBC     vduTempStoreDA
        BPL     LA062

        DEC     L0347
        AND     L0361
.LA062
        STA     L0343
        PHA
        EOR     #$FF
        CLC
        ADC     #$01
        AND     L0361
        STA     L0342
        PLA
        CLC
        ADC     L0361
        TAX
        LDA     L8A89,X
        STA     L0C15
        LDX     #$3C
        LDY     #$40
        JSR     LA210

        STA     L0344
        LDA     vduCurrentPlotByteMask
        STA     L0346
        LDA     vduTempStoreDC
        STA     L0C14
        LDX     #$00
        JSR     LA1B3

        BEQ     LA0D9

        LDA     L032A
        CMP     L0336
        LDA     L032B
        SBC     L0337
        BVC     LA0A8

        EOR     #$80
.LA0A8
        BMI     LA0BC

.LA0AA
        JSR     LA0D9

        LDX     #$00
        JSR     LA19D

        LDX     #$0C
        JSR     LA19D

        BNE     LA0AA

        JMP     LA0D9

.LA0BC
        LDX     #$2A
        LDY     #$2E
        JSR     exchangeTwoVDUBytes

        LDX     #$36
        LDY     #$3A
        JSR     exchangeTwoVDUBytes

.LA0CA
        JSR     LA0D9

        LDX     #$00
        JSR     LA1A8

        LDX     #$0C
        JSR     LA1A8

        BNE     LA0CA

.LA0D9
        LDX     #$2A
        LDY     #$32
        JSR     copyTwoBytesWithinVDUVariables

        LDX     #$36
        LDY     #$3E
        JSR     copyTwoBytesWithinVDUVariables

        LDX     #$2A
        JSR     L9F7C

        PHA
        LDX     #$36
        JSR     L9F7C

        BEQ     LA104

        PLA
        BNE     LA0FC

        LDA     L0345
        BEQ     LA0FD

.LA0FC
        RTS

.LA0FD
        LDX     #$28
        LDY     #$2C
        JMP     LA10B

.LA104
        PLA
        BEQ     LA10E

        LDX     #$34
        LDY     #$38
.LA10B
        JMP     L8B20

.LA10E
        LDX     #$30
        JSR     L8B5A

        BIT     L0347
        BMI     LA123

        SEC
        LDA     vduScreenAddressOfGraphicsCursorCellLow
        SBC     #$08
        STA     vduScreenAddressOfGraphicsCursorCellLow
        BCS     LA123

        DEC     vduScreenAddressofGraphicsCursorCellHigh
.LA123
        LDA     L0344
        STA     vduTempStoreDD
.LA128
if BBC_B or ELECTRON
        LDA     (vduScreenAddressOfGraphicsCursorCellLow),Y
elif BBC_B_PLUS
        JSR     b_plus_lda_d6_indirect_y_eor_35a_sta_da
        EOR     L035A ; undo the unwanted eor from subroutine call
else
        unknown_machine
endif
        LDX     L0342
        BEQ     LA133

.LA12F
        ASL     A
        DEX
        BNE     LA12F

.LA133
        STA     vduTempStoreDA
        SEC
        JSR     moveGraphicsCursorAddressTotheRight

if BBC_B or ELECTRON
        LDA     (vduScreenAddressOfGraphicsCursorCellLow),Y
elif BBC_B_PLUS
        LDX     vduTempStoreDA
        JSR     b_plus_lda_d6_indirect_y_eor_35a_sta_da

        EOR     L035A ; undo the unwanted eor from subroutine call
        STX     vduTempStoreDA ; undo the unwanted sta from subroutine call
else
        unknown_machine
endif
        LDX     L0343
        BEQ     LA144

.LA140
        LSR     A
        DEX
        BNE     LA140

.LA144
        EOR     vduTempStoreDA
        AND     L0C15
        EOR     vduTempStoreDA
        LDX     vduTempStoreDD
        STA     L0C17,X
        DEC     vduTempStoreDD
        BPL     LA128

        LDX     #$34
        LDY     #$38
        JSR     L8B20

        LDA     L0345
        BNE     LA163

        JSR     LA0FD

.LA163
        LDX     #$3C
        JSR     L8B5A

        LDA     L0346
        STA     vduTempStoreDA
        LDX     L0344
        BEQ     LA188

        JSR     LA191

        LDA     #$FF
        STA     vduTempStoreDA
        JMP     LA181

.LA17C
        LDA     L0C17,X
if BBC_B or ELECTRON
        STA     (vduScreenAddressOfGraphicsCursorCellLow),Y
elif BBC_B_PLUS
        JSR     b_plus_sta_d6_indirect_y
else
        unknown_machine
endif
.LA181
        SEC
        JSR     moveGraphicsCursorAddressTotheRight

        DEX
        BNE     LA17C

.LA188
        LDA     L0C14
        EOR     #$FF
        AND     vduTempStoreDA
        STA     vduTempStoreDA
.LA191
if BBC_B or ELECTRON
        LDA     L0C17,X
        EOR     (vduScreenAddressOfGraphicsCursorCellLow),Y
        AND     vduTempStoreDA
        EOR     (vduScreenAddressOfGraphicsCursorCellLow),Y
        STA     (vduScreenAddressOfGraphicsCursorCellLow),Y
        RTS
elif BBC_B_PLUS
        LDA     vduTempStoreDA ; stash value at &DA which subroutine call will corrupt
        STA     vduTempStoreDB
        JSR     b_plus_lda_d6_indirect_y_eor_35a_sta_da

        EOR     L035A ; undo the unwanted eor from subroutine call
        STA     vduTempStoreDA ; set &DA to (&D6),Y
        EOR     L0C17,X
        AND     vduTempStoreDB
        EOR     vduTempStoreDA
        JMP     b_plus_sta_d6_indirect_y
else
        unknown_machine
endif

.LA19D
        INC     L032A,X
        BNE     LA1B3

        INC     L032B,X
        JMP     LA1B3

.LA1A8
        LDA     L032A,X
        BNE     LA1B0

        DEC     L032B,X
.LA1B0
        DEC     L032A,X
.LA1B3
        LDA     L032A,X
        CMP     L032E,X
        BNE     LA1C1

        LDA     L032B,X
        CMP     L032F,X
.LA1C1
        RTS

.LA1C2
        JSR     LA1D0

        INY
        INY
        INX
        INX
        CLC
        ADC     #$02
        INC     vduTempStoreDA
        INC     vduTempStoreDA
.LA1D0
        STA     L0C16
        TXA
        PHA
        TYA
        PHA
        LDA     L0C16
        PHA
        CLC
        LDA     L0300,X
        ADC     L0300,Y
        STA     vduTempStoreDE
        LDA     L0301,X
        ADC     L0301,Y
        STA     L0C16
        PLA
        TAX
        LDA     L0C16
        PHA
        LDY     vduTempStoreDA
        SEC
        LDA     vduTempStoreDE
        SBC     L0300,X
        STA     L0300,Y
        PLA
        SBC     L0301,X
        STA     L0301,Y
        STX     L0C16
        PLA
        TAY
        PLA
        TAX
        LDA     L0C16
        RTS

.LA210
        LDA     L0301,Y
        PHA
        LDA     L0300,Y
        PHA
        AND     L0361
        CLC
        ADC     L0361
        TAY
        LDA     sixteenColourMODEMaskTable - 1,Y
        EOR     L8A89,Y
        STA     vduTempStoreDC
        LDA     L0300,X
        AND     L0361
        ADC     L0361
        TAY
        LDA     L8A89,Y
        STA     vduCurrentPlotByteMask
        SEC
        PLA
        ORA     L0361
        SBC     L0300,X
        TAY
        PLA
        SBC     L0301,X
        STA     vduTempStoreDD
        TYA
        LDY     L0361
        CPY     #$03
        BEQ     LA253

        BCC     LA256

        LSR     vduTempStoreDD
        ROR     A
.LA253
        LSR     vduTempStoreDD
        ROR     A
.LA256
        LSR     A
        RTS

.LA258
        LDY     #$4C
        LDA     (L00F8),Y
        INY
        ORA     (L00F8),Y
        BNE     LA264

        JMP     L8C6F_restore_saved_cursors_and_udgs

.LA264
        LDA     (L00F8),Y
        TAX
        DEY
        LDA     (L00F8),Y
        STA     L00F8
        STX     L00F9
        LDY     #$05
.LA270
        LDA     (L00F8),Y
        STA     L0328,Y
        DEY
        BPL     LA270

        CLC
        LDA     L00F8
        ADC     #$06
        STA     L032A
        LDA     L00F9
        ADC     #$00
        STA     L032B
        LDY     #$07
        LDA     #$00
.LA28B
        STA     L032C,Y
        DEY
        BPL     LA28B

        LDA     L0328
        STA     L0330
        LDA     L0329
        STA     L0332
        LDA     L0361
.LA2A0
        ASL     L0330
        ROL     L0331
        LSR     A
        BNE     LA2A0

        LDA     L0361
        ORA     L0330
        STA     L0330
        LDX     #$20
        LDY     #$34
        JSR     copyFourBytesWithinVDUVariables

        STY     vduTempStoreDA
        LDA     L0361
        EOR     #$FF
        AND     L0334
        STA     L0334
        LDX     #$34
        LDY     #$30
        LDA     #$2C
        JSR     LA1C2

        LDX     #$34
        JSR     checkPointXIsWithinGraphicsWindow

        BEQ     LA30D

        AND     #$0A
        BEQ     LA2DD

.LA2DA
        JMP     L8C6F_restore_saved_cursors_and_udgs

.LA2DD
        LDA     vduTempStoreDA
        PHA
        AND     #$01
        BEQ     LA2F6

        LDX     #$00
        LDY     #$2C
        STY     vduTempStoreDA
        LDA     #$34
        JSR     LA1D0

        LDY     #$34
        STY     vduTempStoreDA
        JSR     LA1D0

.LA2F6
        PLA
        AND     #$04
        BEQ     LA30D

        LDX     #$02
        LDY     #$2E
        STY     vduTempStoreDA
        LDA     #$36
        JSR     LA1D0

        LDY     #$36
        STY     vduTempStoreDA
        JSR     LA1D0

.LA30D
        LDX     #$38
        JSR     checkPointXIsWithinGraphicsWindow

        BEQ     LA348

        AND     #$05
        BNE     LA2DA

        LDA     vduTempStoreDA
        PHA
        AND     #$02
        BEQ     LA331

        LDX     #$04
        LDY     #$30
        STY     vduTempStoreDA
        LDA     #$38
        JSR     LA1D0

        LDY     #$38
        STY     vduTempStoreDA
        JSR     LA1D0

.LA331
        PLA
        AND     #$08
        BEQ     LA348

        LDX     #$06
        LDY     #$32
        STY     vduTempStoreDA
        LDA     #$3A
        JSR     LA1D0

        LDY     #$3A
        STY     vduTempStoreDA
        JSR     LA1D0

.LA348
        LDA     L0361
.LA34B
        LSR     L0331
        ROR     L0330
        LSR     L032D
        ROR     L032C
        LSR     A
        BNE     LA34B

        LDX     #$38
        JSR     setScreenAddress

        SEC
        LDA     L0329
        SBC     L0332
        TAX
        BEQ     LA37B

.LA369
        SEC
        LDA     L032A
        ADC     L0328
        STA     L032A
        BCC     LA378

        INC     L032B
.LA378
        DEX
        BNE     LA369

.LA37B
        SEC
        LDA     L0328
        SBC     L0330
        CLC
        ADC     L032A
        STA     L032A
        BCC     LA38E

        INC     L032B
.LA38E
        SEC
        LDA     L0332
        SBC     L032E
        STA     L032E
        INC     L032E
        SEC
        LDA     L0330
        SBC     L032C
        STA     L032C
        INC     L032C
.LA3A8
        LDA     vduScreenAddressOfGraphicsCursorCellLow
        PHA
        LDA     vduScreenAddressofGraphicsCursorCellHigh
        PHA
        LDA     L032A
        STA     L00F8
        LDA     L032B
        STA     L00F9
        LDX     L032C
.LA3BB
        LDY     #$00
        LDA     (L00F8),Y
        PHA
        ORA     L00AA
        EOR     L00AB
        STA     vduGraphicsColourByteEOR
        PLA
        ORA     L00A8
        EOR     L00A9
        LDY     L031A
if BBC_B or ELECTRON
        ORA     (vduScreenAddressOfGraphicsCursorCellLow),Y
        EOR     vduGraphicsColourByteEOR
        STA     (vduScreenAddressOfGraphicsCursorCellLow),Y
elif BBC_B_PLUS
        STA     vduGraphicsColourByteOR
        JSR     b_plus_modify_d6_indirect_y_by_ora_d4_eor_d5
else
        unknown_machine
endif
        INC     L00F8
        BNE     LA3DA

        INC     L00F9
.LA3DA
        SEC
        JSR     moveGraphicsCursorAddressTotheLeftAndUpdateMask

        DEX
        BNE     LA3BB

        PLA
        STA     vduScreenAddressofGraphicsCursorCellHigh
        PLA
        STA     vduScreenAddressOfGraphicsCursorCellLow
        SEC
        LDA     L032A
        ADC     L0328
        STA     L032A
        BCC     LA3F6

        INC     L032B
.LA3F6
        INC     L031A
        LDY     L031A
        CPY     #$08
        BCC     LA406

        JSR     L9CB3

        STY     L031A
.LA406
        DEC     L032E
        BNE     LA3A8

        JMP     L8C6F_restore_saved_cursors_and_udgs

.LA40E
        JSR     LB851

        PHA
        JSR     print_inline_counted

        EQUB    $03

        EQUS    $17,$1B,$01

.LA419
        PLA
        JSR     oswrch

        JSR     print_inline_counted

        EQUB    $06

        EQUS    $00,$00,$00,$00,$00,$00

.LA427
        RTS

.LA428
        JMP     L81DD

.LA42B
        PLA
        RTS

.LA42D
        PHA
        LDY     #$4A
        LDA     (L00F8),Y
        BEQ     LA428

        LDX     #$14
        JSR     L8E0D

        LDX     #$28
        JSR     checkPointXIsWithinGraphicsWindow

        BEQ     LA45E

        AND     #$0A
        BNE     LA42B

        LDA     vduTempStoreDA
        PHA
        AND     #$01
        BEQ     LA452

        LDX     #$00
        LDY     #$28
        JSR     copyTwoBytesWithinVDUVariables

.LA452
        PLA
        AND     #$04
        BEQ     LA45E

        LDX     #$02
        LDY     #$2A
        JSR     copyTwoBytesWithinVDUVariables

.LA45E
        LDX     #$2C
        JSR     checkPointXIsWithinGraphicsWindow

        BEQ     LA483

        AND     #$05
        BNE     LA42B

        LDA     vduTempStoreDA
        PHA
        AND     #$02
        BEQ     LA477

        LDX     #$04
        LDY     #$2C
        JSR     copyTwoBytesWithinVDUVariables

.LA477
        PLA
        AND     #$08
        BEQ     LA483

        LDX     #$06
        LDY     #$2E
        JSR     copyTwoBytesWithinVDUVariables

.LA483
        LDX     #$2C
        JSR     setScreenAddress

        SEC
        LDA     L032C
        SBC     L0328
        STA     L0328
        LDA     L032D
        SBC     L0329
        STA     L0329
        LDA     L0361
.LA49E
        LSR     L0329
        ROR     L0328
        LSR     A
        BNE     LA49E

        LDX     L0328
        INX
        SEC
        LDA     L032E
        SBC     L032A
        STA     L0329
        TAY
        INY
        BNE     LA4BD

        DEY
        DEC     L0329
.LA4BD
        JSR     LB8D4

        CLC
        LDA     vduTempStoreDE
        STA     L032A
        LDA     vduTempStoreDF
        STA     L032B
        JSR     LB804

        PLA
        PHA
        JSR     LB7C3

        BEQ     LA4EF

        CLC
        LDY     #$02
        LDA     (vduTempStoreDC),Y
        ADC     vduTempStoreDE
        STA     vduTempStoreDE
        INY
        LDA     (vduTempStoreDC),Y
        ADC     vduTempStoreDF
        STA     vduTempStoreDF
        LDA     #$06
        ADC     vduTempStoreDE
        STA     vduTempStoreDE
        BCC     LA4EF

        INC     vduTempStoreDF
.LA4EF
        SEC
        LDA     vduTempStoreDE
        SBC     #$06
        BCS     LA4F8

        DEC     vduTempStoreDF
.LA4F8
        CMP     L032A
        LDA     vduTempStoreDF
        SBC     L032B
        BMI     LA574

        PLA
        PHA
        JSR     LAAB6

        CLC
        LDA     vduTempStoreDA
        STA     vduTempStoreDC
        ADC     #$06
        STA     vduTempStoreDA
        LDA     vduTempStoreDB
        STA     vduTempStoreDD
        BCC     LA518

        INC     vduTempStoreDB
.LA518
        LDY     #$05
        PLA
        PHA
        STA     (vduTempStoreDC),Y
        DEY
        LDA     vduCurrentScreenMODE
        STA     (vduTempStoreDC),Y
        DEY
.LA525
        LDA     L0328,Y
        STA     (vduTempStoreDC),Y
        DEY
        BPL     LA525

        INC     L0328
        INC     L0329
.LA533
        LDX     L0328
        LDA     vduScreenAddressOfGraphicsCursorCellLow
        PHA
        LDA     vduScreenAddressofGraphicsCursorCellHigh
        PHA
.LA53C
        LDY     L031A
if BBC_B or ELECTRON
        LDA     (vduScreenAddressOfGraphicsCursorCellLow),Y
elif BBC_B_PLUS
        LDA     vduTempStoreDA ; stash value at &DA which subroutine call will corrupt
        PHA
        JSR     b_plus_lda_d6_indirect_y_eor_35a_sta_da

        EOR     L035A ; undo the unwanted eor from subroutine call
        TAY           ; restore &DA, preserving A
        PLA
        STA     vduTempStoreDA
        TYA
else
        unknown_machine
endif
        LDY     #$00
        STA     (vduTempStoreDA),Y
        INC     vduTempStoreDA
        BNE     LA54B

        INC     vduTempStoreDB
.LA54B
        SEC
        JSR     moveGraphicsCursorAddressTotheLeftAndUpdateMask

        DEX
        BNE     LA53C

        PLA
        STA     vduScreenAddressofGraphicsCursorCellHigh
        PLA
        STA     vduScreenAddressOfGraphicsCursorCellLow
        INC     L031A
        LDY     L031A
        CPY     #$08
        BCC     LA568

        JSR     L9CB3

        STY     L031A
.LA568
        DEC     L0329
        BNE     LA533

        JSR     LAAEA

        PLA
        JMP     LA770

.LA574
        JSR     generate_error

        EQUS    $82,"No room to get sprite",$00

.LA58E
        JSR     generate_error

        EQUS    $83,"No Sprites",$00

.LA59D
        JSR     LA72E

        TYA
        LDY     #$54
        STA     (L00F8),Y
        TXA
        DEY
        STA     (L00F8),Y
        LDY     #$4B
        LDA     (L00F8),Y
        BEQ     LA58E

        JSR     LB804

        LDY     #$4E
        LDA     (L00F8),Y
        STA     vduTempStoreDB
        LDA     #$00
        STA     vduTempStoreDA
        LDY     #$4B
        LDA     (L00F8),Y
        LDY     #$02
        STA     (vduTempStoreDA),Y
        LDY     #$00
        SEC
        LDA     vduTempStoreDC
        STA     (vduTempStoreDA),Y
        INY
        LDA     vduTempStoreDD
        SBC     vduTempStoreDB
        STA     (vduTempStoreDA),Y
        LDY     #$64
        LDX     #$06
        LDA     #$FF
.LA5D8
        STA     (L00F8),Y
        DEY
        DEX
        BNE     LA5D8

        LDY     #$5D
        LDA     #$00
        STA     (L00F8),Y
        INY
        LDA     vduTempStoreDB
        STA     (L00F8),Y
        LDY     #$62
        STA     (L00F8),Y
        DEY
        LDA     #$02
        STA     (L00F8),Y
        LDX     #$53
        LDY     L00F9
        LDA     #$00
        JSR     osfile

        JSR     L8943_set_f8_f9_to_private_workspace

        JSR     LB804

        LDY     #$4E
        LDA     (L00F8),Y
        STA     vduTempStoreDB
        LDA     #$00
        STA     vduTempStoreDA
        LDY     #$64
        LDX     #$06
        LDA     #$FF
.LA611
        STA     (L00F8),Y
        DEY
        DEX
        BNE     LA611

        LDY     #$5D
        LDA     vduTempStoreDA
        STA     (L00F8),Y
        INY
        LDA     vduTempStoreDB
        LDY     #$5E
        STA     (L00F8),Y
        LDY     #$61
        LDA     vduTempStoreDC
        STA     (L00F8),Y
        INY
        LDA     vduTempStoreDD
        STA     (L00F8),Y
        LDX     #$53
        LDY     L00F9
        LDA     #$00
        JMP     osfile

.LA638
        JSR     LA72E

        STX     vduTempStoreDA
        STY     vduTempStoreDB
        LDY     #$4E
        LDA     (L00F8),Y
        STA     vduTempStoreDD
        LDA     #$00
        STA     vduTempStoreDC
        JSR     LA690

        BCS     LA655

        LDY     #$4B
        STA     (L00F8),Y
        JMP     L8A6A

.LA655
        RTS

.LA656
        JSR     LA72E

        STX     vduTempStoreDA
        STY     vduTempStoreDB
        JSR     LB804

        JSR     LA690

        BCS     LA67B

        TAX
        CLC
        LDA     vduTempStoreDC
        ADC     #$03
        STA     vduTempStoreDC
        BCC     LA671

        INC     vduTempStoreDD
.LA671
        TXA
        PHA
        JSR     LAAEA

        PLA
        TAX
        DEX
        BNE     LA671

.LA67B
        RTS

.LA67C
        JSR     generate_error

        EQUS    $85,"Can't open file",$00

.LA690
        LDY     #$53
        LDA     vduTempStoreDA
        STA     (L00F8),Y
        INY
        LDA     vduTempStoreDB
        STA     (L00F8),Y
        INY
        LDA     vduTempStoreDC
        STA     (L00F8),Y
        INY
        LDA     vduTempStoreDD
        STA     (L00F8),Y
        INY
        LDA     #$FF
        STA     (L00F8),Y
        INY
        STA     (L00F8),Y
        INY
        LDA     #$00
        STA     (L00F8),Y
        LDY     #$65
        LDA     vduTempStoreDC
        STA     (L00F8),Y
        INY
        LDA     vduTempStoreDD
        STA     (L00F8),Y
        LDX     vduTempStoreDA
        LDY     vduTempStoreDB
        LDA     #$40
        JSR     osfind

        CMP     #$00
        BEQ     LA67C

        TAY
        JSR     osbget

        PHA
        JSR     osbget

        PHA
        LDA     #$00
        JSR     osfind

        JSR     L8943_set_f8_f9_to_private_workspace

        PLA
        STA     vduTempStoreDD
        PLA
        STA     vduTempStoreDC
        CLC
        LDY     #$65
        LDA     (L00F8),Y
        ADC     vduTempStoreDC
        STA     vduTempStoreDC
        INY
        LDA     (L00F8),Y
        ADC     vduTempStoreDD
        STA     vduTempStoreDD
        LDY     #$4F
        LDA     #$00
        CMP     vduTempStoreDC
        LDA     (L00F8),Y
        SBC     vduTempStoreDD
        BCC     LA71A

        LDX     #$53
        LDY     L00F9
        LDA     #$FF
        JSR     osfile

        JSR     L8943_set_f8_f9_to_private_workspace

        LDY     #$65
        LDA     (L00F8),Y
        STA     vduTempStoreDC
        INY
        LDA     (L00F8),Y
        STA     vduTempStoreDD
        LDY     #$02
        LDA     (vduTempStoreDC),Y
        CLC
        RTS

.LA71A
        JSR     generate_error

        EQUS    $85,"Not enough room",$00

.LA72E
        TXA
        PHA
        TYA
        PHA
        LDA     #$00
        TAY
        LDX     #$A8
        JSR     osargs

        AND     #$FC
        BNE     LA747

        LDA     #$8B
        LDX     #$01
        LDY     #$01
        JSR     osbyte

.LA747
        PLA
        TAY
        PLA
        TAX
        JMP     L8943_set_f8_f9_to_private_workspace

.LA74E
        JSR     LB851

.LA751
        JSR     LA770

        BEQ     LA757

        RTS

.LA757
        JSR     generate_error

        EQUS    $86,"Sprite doesn't exist",$00

.LA770
        PHA
        LDY     #$4A
        LDA     (L00F8),Y
        BEQ     LA794

        PLA
        JSR     LB7C3

        BEQ     LA789

        LDY     #$4C
        STA     (L00F8),Y
        INY
        LDA     vduTempStoreDD
        STA     (L00F8),Y
        CPX     #$00
        RTS

.LA789
        LDY     #$4C
        TXA
        STA     (L00F8),Y
        INY
        STA     (L00F8),Y
        CPX     #$00
        RTS

.LA794
        JMP     L81DD

.LA797
        JSR     LB851

        PHA
        JSR     LB835

        STX     vduTempStoreDE
        STY     vduTempStoreDF
        PLA
        PHA
        JSR     LB7C3

        BEQ     LA7D6

        LDY     #$00
        LDA     (vduTempStoreDE),Y
        CMP     #$2C
        BNE     LA7D9

        LDX     vduTempStoreDE
        LDY     vduTempStoreDF
        INX
        BNE     LA7B9

        INY
.LA7B9
        JSR     LB851

        PLA
        PHA
        CMP     vduTempStoreDE
        BEQ     LA7EB

        LDA     vduTempStoreDE
        PHA
        JSR     LAAB6

        PLA
        STA     vduTempStoreDE
        PLA
        JSR     LB7C3

        LDY     #$05
        LDA     vduTempStoreDE
        STA     (vduTempStoreDC),Y
        RTS

.LA7D6
        JMP     LA757

.LA7D9
        JSR     generate_error

        EQUS    $87,"Missing comma",$00

.LA7EB
        JSR     generate_error

        EQUS    $88,"Sprite numbers are equal",$00

.LA808
        LDY     #$00
        BEQ     LA80E

.LA80C
        LDY     #$07
.LA80E
        LDX     #$00
        JSR     LB8C7

        JSR     LA849

        JSR     print_inline_counted

        EQUB    $08

        EQUS    $19,$04,$0F,$00,$07,$00,$19,$05

.LA822
        JSR     LB8AF

        JSR     print_inline_counted

        EQUB    $04

        EQUS    $07,$00,$19,$05

.LA82D
        JSR     LB8AF

        JSR     LB8BB

        JSR     print_inline_counted

        EQUB    $04

        EQUS    $19,$05,$0F,$00

.LA83B
        JSR     LB8BB

        JSR     print_inline_counted

        EQUB    $06

        EQUS    $19,$05,$0F,$00,$07,$00

.LA848
        RTS

.LA849
        LDA     L033D
        PHA
        LDA     L033C
        PHA
        LDA     L0342
        STA     L033D
        LDA     L0340
        STA     L033C
        INC     L033C
        INC     L033D
        JSR     LAA48

        PLA
        STA     L033C
        PLA
        STA     L033D
        RTS

.LA86F
        LDA     #$00
        STA     L035B
        STA     L033C
        JSR     LAA48

        JSR     LA9DF

        LDA     #$00
        STA     L033C
.LA882
        LDA     L0362
        STA     L033E
        LDY     #$00
        LDA     (L00AE),Y
        STA     L0330
.LA88F
        LDA     L0330
        AND     L0362
        STA     L0359
        LDX     L0361
.LA89B
        LSR     L0359
        ORA     L0359
        DEX
        BNE     LA89B

        STA     L0359
        LDX     #$04
        JSR     LB8A6

        JSR     LB8AF

        JSR     LA9BE

        SEC
        LDX     vduCurrentScreenMODE
        LDA     LAA3C,X
        ADC     L0344
        STA     L0344
        BCC     LA8C4

        INC     L0345
.LA8C4
        ASL     L0330
        LSR     L033E
        BCC     LA88F

        LDA     L00AE
        BNE     LA8D2

        DEC     L00AF
.LA8D2
        DEC     L00AE
        INC     L033C
        LDA     L0340
        CMP     L033C
        BCS     LA882

        RTS

.LA8E0
        LDA     #$00
        STA     L035B
        STA     L033D
        JSR     LAA48

        JSR     LA9DF

.LA8EE
        JSR     LB4A7

        STA     L0359
        JSR     LA9A3

        SEC
        LDX     vduCurrentScreenMODE
        LDA     LAA38,X
        ADC     L0346
        STA     L0346
        BCC     LA909

        INC     L0347
.LA909
        LDY     #$00
        CLC
        LDA     L00AE
        SBC     (L00AC),Y
        STA     L00AE
        BCS     LA916

        DEC     L00AF
.LA916
        INC     L033D
        LDA     L0342
        CMP     L033D
        BCS     LA8EE

        RTS

.LA922
        LDA     L033D
        PHA
        LDA     L033C
        PHA
        LDA     L033E
        PHA
        LDA     #$00
        STA     L033D
.LA933
        JSR     LA86F

        INC     L033D
        LDA     L0342
        CMP     L033D
        BCS     LA933

        PLA
        STA     L033E
        PLA
        STA     L033C
        PLA
        STA     L033D
        RTS

.LA94E
        JSR     LA957

.LA951
        JSR     LAB2D

.LA954
        JSR     LA922

.LA957
        LDX     #$04
        JSR     LB8A6

        JSR     LAA48

        LDX     vduCurrentScreenMODE
        LDA     LAA3C,X
        LSR     A
        CLC
        ADC     L0343
        LDY     L0345
        BCC     LA970

        INY
.LA970
        CLC
        ADC     L0344
        BCC     LA977

        INY
.LA977
        JSR     oswrch

        TYA
        JSR     oswrch

        LDA     LAA38,X
        LSR     A
        CLC
        ADC     L0346
        LDY     L0347
        BCC     LA98C

        INY
.LA98C
        JSR     oswrch

        TYA
        JSR     oswrch

        JSR     print_inline_counted

        EQUB    $09

        EQUS    $12,$03,$07,$19,$91,$00,$00,$07,$00

.LA9A0
        JMP     LA9DF

.LA9A3
        LDX     #$04
        JSR     LB8A6

        LDA     L0344
        CLC
        ADC     L0343
        TAX
        LDA     L0345
        ADC     #$00
        TAY
        TXA
        JSR     oswrch

        TYA
        JSR     oswrch

.LA9BE
        JSR     LB8BB

        LDX     #$61
        JSR     LB8A6

        LDX     vduCurrentScreenMODE
        LDA     LAA3C,X
        JSR     oswrch

        LDA     #$00
        JSR     oswrch

        LDA     LAA38,X
        JSR     oswrch

        LDA     #$00
        JMP     oswrch

.LA9DF
        LDY     #$00
        LDA     (L00AC),Y
        TAX
        INX
        CLC
        LDA     L033D
        ADC     L0341
        TAY
        JSR     LB8D4

        CLC
        LDA     vduTempStoreDE
        ADC     L033C
        LDX     vduTempStoreDF
        BCC     LA9FB

        INX
.LA9FB
        CLC
        ADC     L033F
        STA     vduTempStoreDE
        BCC     LAA04

        INX
.LAA04
        STX     vduTempStoreDF
        CLC
        LDY     #$02
        LDA     (L00AC),Y
        ADC     L00AC
        PHA
        INY
        LDA     (L00AC),Y
        ADC     L00AD
        TAX
        PLA
        CLC
        ADC     #$05
        BCC     LAA1B

        INX
.LAA1B
        SEC
        SBC     vduTempStoreDE
        STA     L00AE
        TXA
        SBC     vduTempStoreDF
        STA     L00AF
        RTS

.LAA26
        EQUB    $08,$07,$07,$FF,$08,$08

.LAA2C
        EQUB    $0B,$17,$17,$FF,$17,$17

.LAA32
        EQUB    $02,$05,$05,$FF,$02,$02

.LAA38
        EQUB    $3F,$1F,$1F,$FF

.LAA3C
        EQUB    $1F,$1F,$3F,$FF,$1F,$3F

.LAA42
        EQUB    $E0,$60,$40,$FF,$E0,$C0

.LAA48
        LDA     #$00
        STA     L0345
        STA     L0347
        LDX     vduCurrentScreenMODE
        LDA     LAA26,X
        TAX
        LDA     L033C
.LAA5A
        ASL     A
        ROL     L0345
        DEX
        BNE     LAA5A

        ADC     #$10
        STA     L0344
        LDA     L0345
        ADC     #$00
        STA     L0345
        LDX     #$05
        LDA     vduCurrentScreenMODE
        BNE     LAA77

        LDX     #$06
.LAA77
        LDA     L033D
.LAA7A
        ASL     A
        ROL     L0347
        DEX
        BNE     LAA7A

        ADC     #$08
        STA     L0346
        LDA     L0347
        ADC     #$00
        STA     L0347
        RTS

.LAA8F
        JSR     LB7A3_inc_vduTempStoreDA_DB

        LDX     vduTempStoreDA
        LDY     vduTempStoreDB
.LAA96
        JSR     LB851

        TXA
        PHA
        TYA
        PHA
        LDA     vduTempStoreDE
        JSR     LAAB6

        PLA
        TAY
        PLA
        TAX
        JSR     LB835

        STX     vduTempStoreDA
        STY     vduTempStoreDB
        LDY     #$00
        LDA     (vduTempStoreDA),Y
        CMP     #$2C
        BEQ     LAA8F

        RTS

.LAAB6
        JSR     LB7C3

        STA     vduTempStoreDA
        STY     vduTempStoreDB
        CPX     #$00
        BEQ     LAAE9

        JSR     L8A6A

        SEC
        LDY     #$4B
        LDA     (L00F8),Y
        SBC     #$01
        STA     (L00F8),Y
        DEX
        BEQ     LAAE9

        JSR     LB7EB

.LAAD3
        CLC
        LDY     #$02
        LDA     (vduTempStoreDC),Y
        ADC     #$06
        STA     vduTempStoreDE
        INY
        LDA     (vduTempStoreDC),Y
        ADC     #$00
        STA     vduTempStoreDF
        JSR     L8D83

        DEX
        BNE     LAAD3

.LAAE9
        RTS

.LAAEA
        JSR     L8943_set_f8_f9_to_private_workspace

        LDA     vduTempStoreDC
        PHA
        LDA     vduTempStoreDD
        PHA
        LDY     #$05
        LDA     (vduTempStoreDC),Y
        JSR     LAAB6

        PLA
        STA     vduTempStoreDD
        PLA
        STA     vduTempStoreDC
        CLC
        LDY     #$02
        LDA     (vduTempStoreDC),Y
        ADC     #$06
        STA     vduTempStoreDE
        INY
        LDA     (vduTempStoreDC),Y
        ADC     #$00
        STA     vduTempStoreDF
        JSR     L8D83

        CLC
        LDY     #$4B
        LDA     (L00F8),Y
        ADC     #$01
        STA     (L00F8),Y
        RTS

.LAB1D
        JSR     print_inline_counted

        EQUB    $0C

        EQUS    $19,$04,$98,$03,$C8,$00,$19,"g",$C4,$04," ",$03

.LAB2D
        JSR     L8943_set_f8_f9_to_private_workspace

        LDY     #$4C
        LDA     L00AC
        STA     (L00F8),Y
        INY
        LDA     L00AD
        STA     (L00F8),Y
        JSR     print_inline_counted

        EQUB    $13

        EQUS    $18,$A8,$03,$C8,$00,$B0,$04," ",$03,$12,$00,$07,$19,$ED,$A8,$03,$C8,$00,$1A

.LAB52
        RTS

.LAB53
        EQUB    $00,$00,$01,$00,$02,$00,$00

.LAB5A
        JMP     LA71A

.LAB5D
        JSR     LB851

        STA     L0329
        STA     L032A
        JSR     LB835

        STX     vduTempStoreDA
        STY     vduTempStoreDB
        LDY     #$00
        LDA     (vduTempStoreDA),Y
        CMP     #$2C
        BNE     LAB82

        JSR     LB7A3_inc_vduTempStoreDA_DB

        LDX     vduTempStoreDA
        LDY     vduTempStoreDB
        JSR     LB851

        STA     L032A
.LAB82
        LDA     L032A
        CMP     L0329
        BEQ     LAB8D

        JSR     LAAB6

.LAB8D
        JSR     L8943_set_f8_f9_to_private_workspace

        JSR     LB804

        LDA     vduTempStoreDC
        STA     vduTempStoreDA
        LDA     vduTempStoreDD
        STA     vduTempStoreDB
        LDA     L0329
        JSR     LB7C3

        BEQ     LABC8

        LDA     L0329
        CMP     L032A
        BNE     LABD0

        STX     L032B
        SEC
        LDY     #$4B
        LDA     (L00F8),Y
        SBC     L032B
        STA     (L00F8),Y
        SEC
        LDA     vduTempStoreDA
        SBC     vduTempStoreDC
        STA     vduTempStoreDE
        LDA     vduTempStoreDB
        SBC     vduTempStoreDD
        STA     vduTempStoreDF
        JMP     LABF6

.LABC8
        LDA     #lo(LAB53)
        STA     vduTempStoreDC
        LDA     #hi(LAB53)
        STA     vduTempStoreDD
.LABD0
        LDA     vduTempStoreDF
        PHA
        LDA     vduTempStoreDE
        PHA
        CLC
        LDY     #$02
        LDA     (vduTempStoreDC),Y
        ADC     #$06
        STA     vduTempStoreDE
        INY
        LDA     (vduTempStoreDC),Y
        ADC     #$00
        STA     vduTempStoreDF
        PLA
        CMP     vduTempStoreDE
        PLA
        SBC     vduTempStoreDF
        BCS     LABF1

        JMP     LAB5A

.LABF1
        LDA     #$01
        STA     L032B
.LABF6
        SEC
        LDY     #$4F
        LDA     #$00
        SBC     vduTempStoreDE
        STA     vduTempStoreDA
        STA     L00AC
        LDA     (L00F8),Y
        SBC     vduTempStoreDF
        STA     vduTempStoreDB
        STA     L00AD
        JSR     L8D9E

        LDA     L032A
        LDY     #$05
        STA     (L00AC),Y
        JSR     L8943_set_f8_f9_to_private_workspace

        JSR     LB15B

        LDA     vduCurrentScreenMODE
        LDY     #$04
        STA     (L00AC),Y
        LDY     #$49
        LDA     (L00F8),Y
        AND     #$FE
        STA     (L00F8),Y
        LDA     #$00
        STA     L033F
        STA     L0341
        STA     L033C
        STA     L033D
        STA     L0343
        LDA     L0362
        STA     L033E
        LDA     #$07
        STA     L0348
        LDX     vduCurrentScreenMODE
        LDY     #$00
        LDA     (L00AC),Y
        CMP     LAA32,X
        BCC     LAC53

        LDA     LAA32,X
.LAC53
        STA     L0340
        INY
        LDA     (L00AC),Y
        CMP     LAA2C,X
        BCC     LAC61

        LDA     LAA2C,X
.LAC61
        STA     L0342
        JSR     print_inline_counted

        EQUB    $0F

        EQUS    $04,$1A,$11,$80,$0C,$17,$01,$00,$00,$00,$00,$00,$00,$00,$00

.LAC77
        LDA     #$04
        LDX     #$02
        JSR     osbyte

        LDA     #$E1
        LDX     #$90
        LDY     #$00
        JSR     osbyte

        LDA     #$E2
        LDX     #$80
        LDY     #$00
        JSR     osbyte

        LDA     #$E3
        LDX     #$A0
        LDY     #$00
        JSR     osbyte

        JSR     LB8EE

        JSR     LA80C

        JSR     LA951

.LACA2
        JSR     LB8EE

        LDA     #$0F
        TAX
        JSR     osbyte

        JSR     osrdch

        BCS     LACFA

        CMP     #$0D
        BNE     LACBA

        JSR     LADCF

        JMP     LACA2

.LACBA
        CMP     #$7F
        BNE     LACC4

        JSR     LADAF

        JMP     LACA2

.LACC4
        CMP     #$30
        BCC     LACA2

        CMP     #$3A
        BCC     LACE1

        CMP     #$41
        BCC     LACA2

        CMP     #$47
        BCC     LACDE

        CMP     #$61
        BCC     LACA2

        CMP     #$67
        BCS     LACEA

        SBC     #$1F
.LACDE
        SEC
        SBC     #$07
.LACE1
        SEC
        SBC     #$30
        STA     L0348
        JMP     LACA2

.LACEA
        CMP     #$80
        BCC     LACA2

        CMP     #$B0
        BCS     LACA2

        ASL     A
        TAX
        JSR     LAD42

        JMP     LACA2

.LACFA
        LDY     #$05
        LDA     (L00AC),Y
        PHA
        LDA     L00AC
        STA     vduTempStoreDC
        LDA     L00AD
        STA     vduTempStoreDD
        JSR     LB14B

        LDX     L032B
        JSR     LA671

        PLA
        JSR     LA770

        LDA     #$7C
        JSR     osbyte

        LDA     #$E1
        LDX     #$01
        LDY     #$00
        JSR     osbyte

        LDA     #$E2
        LDX     #$80
        LDY     #$00
        JSR     osbyte

        LDA     #$E3
        LDX     #$90
        LDY     #$00
        JSR     osbyte

        LDA     #$04
        JSR     oswrch

        LDA     #$04
        LDX     #$00
        LDY     #$00
        JMP     osbyte

.LAD42
        LDA     LAD4F,X
        STA     vduTempStoreDA
        LDA     LAD50,X
        STA     vduTempStoreDB
        JMP     (vduTempStoreDA)

.LAD4F
LAD50 = LAD4F + 1
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LB1F7
        EQUW    LB245
        EQUW    LB52D
        EQUW    LB643
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LB016
        EQUW    LB064
        EQUW    LB0C2
        EQUW    LB107
        EQUW    LB3AB
        EQUW    LB421
        EQUW    LB3B4
        EQUW    LB16D
        EQUW    LB1AF
        EQUW    LB4DF
        EQUW    LB5BA
        EQUW    LB6ED
        EQUW    LB743
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LADB7
        EQUW    LAEF6
        EQUW    LAF55
        EQUW    LAFB5
        EQUW    LAFDA
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LADFC
        EQUW    LB008
        EQUW    LB050
        EQUW    LB0B4
        EQUW    LB0F3

.LADAF
        LDA     L0348
        PHA
        LDA     #$00
        BEQ     LADBD

.LADB7
        LDA     L0348
        PHA
        LDA     #$07
.LADBD
        STA     L0348
        JSR     LADCF

        PLA
        STA     L0348
.LADC7
        RTS

.LADC8
        LDY     #$49
        LDA     (L00F8),Y
        LSR     A
        BCC     LADC7

.LADCF
        JSR     LA957

        JSR     LADDE

        JSR     LA9A3

        JSR     LAB2D

        JMP     LA957

.LADDE
        LDX     #$00
        LDY     L0348
        JSR     LB8C7

        LDA     L0359
        AND     L033E
        STA     vduTempStoreDA
        LDY     #$00
        LDA     (L00AE),Y
        ORA     L033E
        EOR     L033E
        ORA     vduTempStoreDA
        STA     (L00AE),Y
.LADFC
        RTS

.LADFD
        LDA     L033C
        PHA
        LDA     L033D
        PHA
        LDA     L033E
        PHA
        TXA
        PHA
        TYA
        PHA
        LDY     #$00
        JSR     LAEC4

        PLA
        TAX
        LDY     L0342
        INY
        JSR     LAE9D

        PLA
        PHA
        EOR     #$01
        TAX
        LDY     #$00
        JSR     LAED8

        PLA
        TAX
        BEQ     LAE2C

        LDX     L0340
.LAE2C
        STX     L033C
        LDA     L0343
        PHA
        LDA     #$00
        STA     L0343
        LDA     L0362
        STA     L033E
.LAE3E
        JSR     LA8E0

        SEC
        LDX     vduCurrentScreenMODE
        LDA     LAA3C,X
        ADC     L0343
        STA     L0343
        LSR     L033E
        BCC     LAE3E

        PLA
        STA     L0343
        JMP     LAE8E

.LAE5A
        LDA     L033C
        PHA
        LDA     L033D
        PHA
        LDA     L033E
        PHA
        TXA
        PHA
        LDX     L0340
        INX
        JSR     LAE9D

        PLA
        PHA
        TAY
        LDX     #$00
        JSR     LAEC4

        PLA
        PHA
        EOR     #$01
        TAY
        LDX     #$00
        JSR     LAED8

        PLA
        TAY
        BEQ     LAE88

        LDY     L0342
.LAE88
        STY     L033D
        JSR     LA86F

.LAE8E
        PLA
        STA     L033E
        PLA
        STA     L033D
        PLA
        STA     L033C
        JMP     LA957

.LAE9D
        STX     L033C
        STY     L033D
        LDX     #$04
        JSR     LB8A6

        JSR     LAA48

        LDA     L0344
        BNE     LAEB3

        DEC     L0345
.LAEB3
        DEC     L0344
        LDA     L0346
        BNE     LAEBE

        DEC     L0347
.LAEBE
        DEC     L0346
        JMP     LAED2

.LAEC4
        STX     L033C
        LDX     #$04
.LAEC9
        STY     L033D
        JSR     LB8A6

        JSR     LAA48

.LAED2
        JSR     LB8AF

        JMP     LB8BB

.LAED8
        STX     L033C
        LDX     #$05
.LAEDD
        LDA     L033E,X
        PHA
        DEX
        BPL     LAEDD

        LDX     #$BE
        JSR     LAEC9

        LDX     #$00
        LDY     #$05
.LAEED
        PLA
        STA     L033E,X
        INX
        DEY
        BPL     LAEED

        RTS

.LAEF6
        JSR     LADC8

        LDA     L033E
        ASL     A
        BCS     LAF15

        STA     L033E
        JSR     LA957

        CLC
        LDX     vduCurrentScreenMODE
        LDA     L0343
        SBC     LAA3C,X
        STA     L0343
        JMP     LA957

.LAF15
        LDA     L033C
        BEQ     LAF32

        JSR     LA957

        DEC     L033C
        LDA     L0363
        STA     L033E
        LDX     vduCurrentScreenMODE
        LDA     LAA42,X
        STA     L0343
        JMP     LA957

.LAF32
        LDA     L033F
        BNE     LAF38

        RTS

.LAF38
        JSR     LA957

        DEC     L033F
        LDA     L0363
        STA     L033E
        LDX     vduCurrentScreenMODE
        LDA     LAA42,X
        STA     L0343
        LDX     #$00
        LDY     L0340
        JMP     LADFD

.LAF55
        JSR     LADC8

        LDA     L033E
        LSR     A
        BCS     LAF74

        STA     L033E
        JSR     LA957

        SEC
        LDX     vduCurrentScreenMODE
        LDA     L0343
        ADC     LAA3C,X
        STA     L0343
        JMP     LA957

.LAF74
        LDA     L033C
        CMP     L0340
        BEQ     LAF90

        JSR     LA957

        INC     L033C
        LDA     L0362
        STA     L033E
        LDA     #$00
        STA     L0343
        JMP     LA957

.LAF90
        CLC
        ADC     L033F
        LDY     #$00
        CMP     (L00AC),Y
        BNE     LAF9B

        RTS

.LAF9B
        JSR     LA957

        INC     L033F
        LDA     L0362
        STA     L033E
        LDA     #$00
        STA     L0343
        LDX     #$01
        LDY     L0340
        INY
        JMP     LADFD

.LAFB5
        JSR     LADC8

        LDA     L033D
        BEQ     LAFC6

        JSR     LA957

        DEC     L033D
        JMP     LA957

.LAFC6
        LDA     L0341
        BNE     LAFCC

        RTS

.LAFCC
        JSR     LA957

        DEC     L0341
        LDX     #$00
        LDY     L0342
        JMP     LAE5A

.LAFDA
        JSR     LADC8

        LDA     L033D
        CMP     L0342
        BEQ     LAFEE

        JSR     LA957

        INC     L033D
        JMP     LA957

.LAFEE
        CLC
        ADC     L0341
        LDY     #$01
        CMP     (L00AC),Y
        BNE     LAFF9

        RTS

.LAFF9
        JSR     LA957

        INC     L0341
        LDX     #$01
        LDY     L0342
        INY
        JMP     LAE5A

.LB008
        JSR     LA957

        LDA     #$00
        STA     L033F
        JSR     LA922

        JMP     LB03F

.LB016
        JSR     LA957

        SEC
        LDA     L033F
        SBC     #$02
        LDX     L033F
        BEQ     LB036

        BCC     LB02C

        STA     L033F
        JMP     LA954

.LB02C
        PHA
        LDA     #$00
        STA     L033F
        JSR     LA922

        PLA
.LB036
        CLC
        ADC     L033C
        STA     L033C
        BPL     LB04D

.LB03F
        LDA     #$00
        STA     L033C
        STA     L0343
        LDA     L0362
.LB04A
        STA     L033E
.LB04D
        JMP     LA957

.LB050
        JSR     LA957

        SEC
        LDY     #$00
        LDA     (L00AC),Y
        SBC     L0340
        STA     L033F
        JSR     LA922

        JMP     LB0A0

.LB064
        JSR     LA957

        SEC
        LDY     #$00
        LDA     (L00AC),Y
        SBC     L0340
        TAX
        CLC
        LDA     L033F
        ADC     #$02
        CPX     L033F
        BEQ     LB08E

        STX     L033F
        CMP     L033F
        BCS     LB089

        STA     L033F
        JMP     LA954

.LB089
        PHA
        JSR     LA922

        PLA
.LB08E
        SEC
        SBC     L033F
        CLC
        ADC     L033C
        STA     L033C
        CMP     L0340
        BEQ     LB04D

        BCC     LB04D

.LB0A0
        LDA     L0340
        STA     L033C
        LDX     vduCurrentScreenMODE
        LDA     LAA42,X
        STA     L0343
        LDA     L0363
        BNE     LB04A

.LB0B4
        JSR     LA957

        LDA     #$00
        STA     L0341
        JSR     LA922

        JMP     LB0EB

.LB0C2
        JSR     LA957

        SEC
        LDA     L0341
        SBC     #$08
        LDX     L0341
        BEQ     LB0E2

        BCC     LB0D8

        STA     L0341
        JMP     LA954

.LB0D8
        PHA
        LDA     #$00
        STA     L0341
        JSR     LA922

        PLA
.LB0E2
        CLC
        ADC     L033D
        STA     L033D
        BPL     LB0F0

.LB0EB
        LDA     #$00
        STA     L033D
.LB0F0
        JMP     LA957

.LB0F3
        JSR     LA957

        SEC
        LDY     #$01
        LDA     (L00AC),Y
        SBC     L0342
        STA     L0341
        JSR     LA922

        JMP     LB142

.LB107
        JSR     LA957

        SEC
        LDY     #$01
        LDA     (L00AC),Y
        SBC     L0342
        TAX
        LDA     L0341
        ADC     #$07
        CPX     L0341
        BEQ     LB130

        STX     L0341
        CMP     L0341
        BCS     LB12B

        STA     L0341
        JMP     LA954

.LB12B
        PHA
        JSR     LA922

        PLA
.LB130
        SEC
        SBC     L0341
        CLC
        ADC     L033D
        STA     L033D
        CMP     L0342
        BEQ     LB148

        BCC     LB148

.LB142
        LDA     L0342
        STA     L033D
.LB148
        JMP     LA957

.LB14B
        TYA
        PHA
        LDY     #$52
        LDA     (L00F8),Y
        STA     L032B
        LDA     #$00
        STA     (L00F8),Y
        PLA
        TAY
        RTS

.LB15B
        LDY     #$50
        LDA     L00AC
        STA     (L00F8),Y
        INY
        LDA     L00AD
        STA     (L00F8),Y
        INY
        LDA     L032B
        STA     (L00F8),Y
        RTS

.LB16D
        LDY     #$01
        LDA     (L00AC),Y
        CMP     #$FE
        BCS     LB19D

        DEY
        JSR     LB2DA

        BCS     LB19D

        LDY     #$00
        LDA     (L00AC),Y
        TAX
        INX
        TYA
.LB182
        STA     (vduTempStoreDA),Y
        INY
        DEX
        BNE     LB182

        LDX     vduCurrentScreenMODE
        LDA     L0342
        CMP     LAA2C,X
        BCS     LB19C

        JSR     LA808

        INC     L0342
        JSR     LA80C

.LB19C
        CLC
.LB19D
        RTS

.LB19E
        JSR     LA849

        LDX     #$67
        JSR     LB8A6

        JSR     LB8AF

        JSR     LB8BB

        JMP     LA80C

.LB1AF
        LDY     #$00
        LDA     (L00AC),Y
        CMP     #$FE
        BCS     LB1F6

        INY
        JSR     LB2DA

        BCS     LB1F6

        LDY     #$01
        LDA     (L00AC),Y
        TAX
        INX
        DEY
.LB1C4
        TYA
        STA     (vduTempStoreDA),Y
        JSR     LB7A3_inc_vduTempStoreDA_DB

        TXA
        PHA
        LDA     (L00AC),Y
        TAX
.LB1CF
        LDA     (vduTempStoreDC),Y
        STA     (vduTempStoreDA),Y
        JSR     LB7AA_inc_vduTempStoreDC_DD

        JSR     LB7A3_inc_vduTempStoreDA_DB

        DEX
        BNE     LB1CF

        PLA
        TAX
        DEX
        BNE     LB1C4

        LDX     vduCurrentScreenMODE
        LDA     L0340
        CMP     LAA32,X
        BCS     LB1F5

        JSR     LA808

        INC     L0340
        JSR     LA80C

.LB1F5
        CLC
.LB1F6
        RTS

.LB1F7
        SEC
.LB1F8
        LDY     #$01
        LDA     (L00AC),Y
        BEQ     LB244

        DEY
        JSR     LB364

        JSR     LA957

        JSR     LAB1D

        SEC
        LDY     #$01
        LDA     (L00AC),Y
        SBC     L0341
        CMP     L033D
        BCS     LB218

        DEC     L033D
.LB218
        CMP     L0342
        BCS     LB23F

        LDA     L0341
        BNE     LB235

        DEC     L0342
        JSR     print_inline_counted

        EQUB    $06

        EQUS    $19,$04,$00,$00," ",$03

.LB22F
        JSR     LB19E

        SEC
        BCS     LB23F

.LB235
        DEC     L0341
        INC     L033D
        JSR     LA922

        CLC
.LB23F
        PHP
        JSR     LA957

        PLP
.LB244
        RTS

.LB245
        LDY     #$00
        LDA     (L00AC),Y
        BEQ     LB244

        LDA     L00AC
        STA     vduTempStoreDC
        LDA     L00AD
        STA     vduTempStoreDD
        JSR     LB7EB

        JSR     LB7BA

        LDA     vduTempStoreDC
        STA     vduTempStoreDA
        LDA     vduTempStoreDD
        STA     vduTempStoreDB
        LDY     #$01
        LDA     (L00AC),Y
        TAX
        INX
        LDY     #$00
.LB269
        TXA
        PHA
        LDY     #$00
        LDA     (L00AC),Y
        TAX
.LB270
        LDA     (vduTempStoreDC),Y
        STA     (vduTempStoreDA),Y
        JSR     LB7BA

        JSR     LB7B1

        DEX
        BNE     LB270

        JSR     LB7BA

        PLA
        TAX
        DEX
        BNE     LB269

        LDY     #$01
        JSR     LB364

        JSR     LA957

        JSR     LAB1D

        SEC
        LDY     #$00
        LDA     (L00AC),Y
        SBC     L033F
        PHA
        CMP     L033C
        BCS     LB2B0

        DEC     L033C
        LDA     L0363
        STA     L033E
        LDX     vduCurrentScreenMODE
        LDA     LAA42,X
        STA     L0343
.LB2B0
        PLA
        CMP     L0340
        BCS     LB2D7

        LDA     L033F
        BNE     LB2CE

        DEC     L0340
        JSR     print_inline_counted

        EQUB    $06

        EQUS    $19,$04,$84,$03,$00,$00

.LB2C8
        JSR     LB19E

        JMP     LB2D7

.LB2CE
        DEC     L033F
        INC     L033C
        JSR     LA922

.LB2D7
        JMP     LA957

.LB2DA
        JSR     L8943_set_f8_f9_to_private_workspace

        JSR     LB14B

        JSR     LB804

        TYA
        TAX
        CLC
        LDA     L00AC
        SBC     (L00AC),Y
        STA     vduTempStoreDA
        LDA     L00AD
        SBC     #$00
        STA     vduTempStoreDB
        LDA     vduTempStoreDA
        CMP     vduTempStoreDC
        LDA     vduTempStoreDB
        SBC     vduTempStoreDD
        BCC     LB338

        SEC
        LDA     (L00AC),Y
        LDY     #$02
        ADC     (L00AC),Y
        STA     (L00AC),Y
        INY
        LDA     #$00
        ADC     (L00AC),Y
        STA     (L00AC),Y
        TXA
        EOR     #$01
        TAY
        CLC
        LDA     #$01
        ADC     (L00AC),Y
        STA     (L00AC),Y
        LDY     #$01
.LB319
        LDA     L00AC,Y
        STA     vduTempStoreDC,Y
        LDA     vduTempStoreDA,Y
        STA     L00AC,Y
        DEY
        BPL     LB319

        LDA     #$06
        STA     vduTempStoreDE
        LDA     #$00
        STA     vduTempStoreDF
        JSR     L8D83

        JSR     LB15B

        CLC
        RTS

.LB338
        JSR     LB15B

        JSR     print_inline_counted

        EQUB    $09

        EQUS    $07,"No room",$0D

.LB348
        LDA     #$0F
        TAX
        JSR     osbyte

        LDA     #$81
        LDX     #$96
        LDY     #$00
        JSR     osbyte

        JSR     print_inline_counted

        EQUB    $07

        EQUS    "       "

.LB362
        SEC
        RTS

.LB364
        JSR     LB14B

        TYA
        TAX
        CLC
        LDA     (L00AC),Y
        STA     vduTempStoreDA
        LDY     #$02
        LDA     (L00AC),Y
        SBC     vduTempStoreDA
        STA     (L00AC),Y
        INY
        LDA     (L00AC),Y
        SBC     #$00
        STA     (L00AC),Y
        SEC
        LDA     L00AC
        STA     vduTempStoreDC
        ADC     vduTempStoreDA
        STA     vduTempStoreDA
        STA     L00AC
        LDA     L00AD
        STA     vduTempStoreDD
        ADC     #$00
        STA     vduTempStoreDB
        STA     L00AD
        LDA     #$06
        STA     vduTempStoreDE
        LDA     #$00
        STA     vduTempStoreDF
        JSR     L8D9E

        TXA
        EOR     #$01
        TAY
        SEC
        LDA     (L00AC),Y
        SBC     #$01
        STA     (L00AC),Y
        JMP     LB15B

.LB3AB
        LDY     #$49
        LDA     (L00F8),Y
        EOR     #$01
        STA     (L00F8),Y
        RTS

.LB3B4
        JSR     LA957

        LDA     L033D
        PHA
        CLC
        LDA     L0341
        ADC     L033D
        STA     L033D
        PHA
        LDA     L00AE
        PHA
        LDA     L00AF
        PHA
        JSR     LB4A7

        JSR     LADDE

.LB3D2
        LDY     #$01
        LDA     L033D
        CMP     (L00AC),Y
        LDY     #$00
        BCS     LB3F0

        INC     L033D
        CLC
        LDA     L00AE
        SBC     (L00AC),Y
        STA     L00AE
        BCS     LB3EB

        DEC     L00AF
.LB3EB
        JSR     LB4CD

        BCC     LB3D2

.LB3F0
        PLA
        STA     L00AF
        PLA
        STA     L00AE
        PLA
        STA     L033D
.LB3FA
        LDY     #$00
        LDA     L033D
        BEQ     LB414

        DEC     L033D
        SEC
        LDA     L00AE
        ADC     (L00AC),Y
        STA     L00AE
        BCC     LB40F

        INC     L00AF
.LB40F
        JSR     LB4CD

        BCC     LB3FA

.LB414
        JSR     LAB2D

        JSR     LA8E0

        PLA
        STA     L033D
        JMP     LA957

.LB421
        JSR     LA957

        LDA     L033C
        PHA
        LDA     L033E
        PHA
        PHA
        CLC
        LDA     L033F
        ADC     L033C
        STA     L033C
        PHA
        LDA     L00AE
        PHA
        LDA     L00AF
        PHA
        JSR     LB4A7

        JSR     LADDE

.LB444
        LSR     L033E
        BCC     LB463

        LDA     L0362
        STA     L033E
        LDY     #$00
        LDA     L033C
        CMP     (L00AC),Y
        BCS     LB468

        INC     L033C
        LDA     L00AE
        BNE     LB461

        DEC     L00AF
.LB461
        DEC     L00AE
.LB463
        JSR     LB4CD

        BCC     LB444

.LB468
        PLA
        STA     L00AF
        PLA
        STA     L00AE
        PLA
        STA     L033C
        PLA
        STA     L033E
.LB476
        ASL     L033E
        BCC     LB491

        LDA     L0363
        STA     L033E
        LDY     #$00
        LDA     L033C
        BEQ     LB496

        DEC     L033C
        INC     L00AE
        BNE     LB491

        INC     L00AF
.LB491
        JSR     LB4CD

        BCC     LB476

.LB496
        JSR     LAB2D

        JSR     LA86F

        PLA
        STA     L033E
        PLA
        STA     L033C
        JMP     LA957

.LB4A7
        LDY     #$00
        LDA     (L00AE),Y
        AND     L033E
        STA     L0328
        LDA     L033E
        BMI     LB4BC

.LB4B6
        ASL     L0328
        ASL     A
        BPL     LB4B6

.LB4BC
        LDX     L0361
        LDA     L0328
.LB4C2
        LSR     A
        ORA     L0328
        DEX
        BNE     LB4C2

        STA     L0328
        RTS

.LB4CD
        LDY     #$00
        LDA     (L00AE),Y
        EOR     L0328
        AND     L033E
        SEC
        BNE     LB4DE

        JSR     LADDE

        CLC
.LB4DE
        RTS

.LB4DF
        JSR     LB16D

        BCS     LB52C

        CLC
        LDA     L00AC
        ADC     #$05
        STA     vduTempStoreDC
        LDA     L00AD
        ADC     #$00
        STA     vduTempStoreDD
        LDY     #$01
        SEC
        LDA     (L00AC),Y
        SBC     L0341
        SEC
        SBC     L033D
        DEY
        TAX
.LB4FF
        LDA     vduTempStoreDC
        STA     vduTempStoreDA
        SEC
        LDA     (L00AC),Y
        TAY
        INY
        ADC     vduTempStoreDC
        STA     vduTempStoreDC
        LDA     vduTempStoreDD
        STA     vduTempStoreDB
        BCC     LB514

        INC     vduTempStoreDD
.LB514
        LDA     (vduTempStoreDC),Y
        STA     (vduTempStoreDA),Y
        DEY
        BNE     LB514

        DEX
        BNE     LB4FF

        LDA     (L00AC),Y
        TAY
        INY
.LB522
        LDA     #$00
        STA     (vduTempStoreDC),Y
        DEY
        BNE     LB522

        JMP     LA94E

.LB52C
        RTS

.LB52D
        LDY     #$01
        LDA     (L00AC),Y
        BEQ     LB586

        SEC
        SBC     L0341
        SEC
        SBC     L033D
        BEQ     LB57E

        TAX
        DEY
        LDA     (L00AC),Y
        TAY
        INY
        JSR     LB8D4

        CLC
        LDA     L00AC
        ADC     vduTempStoreDE
        STA     vduTempStoreDC
        LDA     L00AD
        ADC     vduTempStoreDF
        STA     vduTempStoreDD
        LDA     vduTempStoreDC
        ADC     #$05
        STA     vduTempStoreDC
        BCC     LB55D

        INC     vduTempStoreDD
.LB55D
        LDY     #$00
.LB55F
        CLC
        LDA     vduTempStoreDC
        STA     vduTempStoreDA
        SBC     (L00AC),Y
        STA     vduTempStoreDC
        LDA     vduTempStoreDD
        STA     vduTempStoreDB
        SBC     #$00
        STA     vduTempStoreDD
        LDA     (L00AC),Y
        TAY
        INY
.LB574
        LDA     (vduTempStoreDC),Y
        STA     (vduTempStoreDA),Y
        DEY
        BNE     LB574

        DEX
        BNE     LB55F

.LB57E
        JSR     LB1F7

        BCC     LB586

        JMP     LA94E

.LB586
        RTS

.print_inline_counted
{
        PLA
        STA     vduTempStoreDA
        PLA
        STA     vduTempStoreDB
        TXA
        PHA
        TYA
        PHA
        JSR     LB7A3_inc_vduTempStoreDA_DB

        LDY     #$00
        LDA     (vduTempStoreDA),Y
        TAX
        JSR     LB7A3_inc_vduTempStoreDA_DB

.LB59C
        LDA     vduTempStoreDA
        PHA
        LDA     vduTempStoreDB
        PHA
        LDA     (vduTempStoreDA),Y
        JSR     oswrch

        PLA
        STA     vduTempStoreDB
        PLA
        STA     vduTempStoreDA
        JSR     LB7A3_inc_vduTempStoreDA_DB

        DEX
        BNE     LB59C

        PLA
        TAY
        PLA
        TAX
        JMP     (vduTempStoreDA)
}

.LB5BA
        JSR     LB6C5

        STA     vduTempStoreDC
        LDY     #$01
        LDA     (L00AC),Y
        TAX
        INX
        CLC
        LDA     L00AC
        ADC     #$05
        STA     vduTempStoreDA
        LDA     L00AD
        ADC     #$00
        STA     vduTempStoreDB
        SEC
        LDY     #$00
        LDA     (L00AC),Y
        SBC     L033F
        SEC
        SBC     L033C
        STA     vduTempStoreDF
        INC     vduTempStoreDF
.LB5E2
        TXA
        PHA
        LDY     vduTempStoreDF
        LDA     (vduTempStoreDA),Y
        PHA
        ORA     vduTempStoreDC
        EOR     vduTempStoreDC
        STA     vduTempStoreDE
        LDA     (vduTempStoreDA),Y
        AND     vduTempStoreDC
        ORA     L0363
        EOR     L0363
        LSR     A
        ORA     vduTempStoreDE
        STA     (vduTempStoreDA),Y
        PLA
        AND     L0363
        LDX     L0361
.LB605
        ASL     A
        DEX
        BNE     LB605

        STA     vduTempStoreDE
        DEY
        BEQ     LB62C

.LB60E
        LDA     (vduTempStoreDA),Y
        PHA
        ORA     L0363
        EOR     L0363
        LSR     A
        ORA     vduTempStoreDE
        STA     (vduTempStoreDA),Y
        PLA
        AND     L0363
        LDX     L0361
.LB623
        ASL     A
        DEX
        BNE     LB623

        STA     vduTempStoreDE
        DEY
        BNE     LB60E

.LB62C
        LDY     #$00
        SEC
        LDA     vduTempStoreDA
        ADC     (L00AC),Y
        STA     vduTempStoreDA
        LDA     vduTempStoreDB
        ADC     #$00
        STA     vduTempStoreDB
        PLA
        TAX
        DEX
        BNE     LB5E2

        JMP     LA94E

.LB643
        JSR     LB6C5

        STA     vduTempStoreDC
        LDY     #$01
        LDA     (L00AC),Y
        TAX
        INX
        CLC
        LDA     L00AC
        ADC     #$06
        STA     vduTempStoreDA
        LDA     L00AD
        ADC     #$00
        STA     vduTempStoreDB
        SEC
        LDY     #$00
        LDA     (L00AC),Y
        SBC     L033F
        SEC
        SBC     L033C
        STA     vduTempStoreDF
.LB669
        TXA
        PHA
        LDA     #$00
        STA     vduTempStoreDE
        LDY     vduTempStoreDF
        BEQ     LB695

        LDY     #$00
.LB675
        LDA     (vduTempStoreDA),Y
        PHA
        ORA     L0362
        EOR     L0362
        ASL     A
        ORA     vduTempStoreDE
        STA     (vduTempStoreDA),Y
        PLA
        AND     L0362
        LDX     L0361
.LB68A
        LSR     A
        DEX
        BNE     LB68A

        STA     vduTempStoreDE
        INY
        CPY     vduTempStoreDF
        BNE     LB675

.LB695
        LDA     (vduTempStoreDA),Y
        ORA     vduTempStoreDC
        EOR     vduTempStoreDC
        ORA     vduTempStoreDE
        STA     vduTempStoreDE
        LDA     (vduTempStoreDA),Y
        AND     vduTempStoreDC
        ORA     L033E
        EOR     L033E
        ASL     A
        ORA     vduTempStoreDE
        STA     (vduTempStoreDA),Y
        LDY     #$00
        SEC
        LDA     vduTempStoreDA
        ADC     (L00AC),Y
        STA     vduTempStoreDA
        LDA     vduTempStoreDB
        ADC     #$00
        STA     vduTempStoreDB
        PLA
        TAX
        DEX
        BNE     LB669

        JMP     LA94E

.LB6C5
        LDA     L033E
        STA     vduTempStoreDC
.LB6CA
        ORA     vduTempStoreDC
        STA     vduTempStoreDC
        LSR     A
        BCC     LB6CA

        LDA     vduTempStoreDC
        RTS

.LB6D4
        LDY     #$00
        STY     vduTempStoreDE
        LDY     L0361
.LB6DB
        ASL     vduTempStoreDE
        PHA
        AND     L0363
        ORA     vduTempStoreDE
        STA     vduTempStoreDE
        PLA
        LSR     A
        DEY
        BPL     LB6DB

        LDA     vduTempStoreDE
        RTS

.LB6ED
        CLC
        LDA     L00AC
        ADC     #$05
        STA     vduTempStoreDA
        LDA     L00AD
        ADC     #$00
        STA     vduTempStoreDB
        LDY     #$01
        LDA     (L00AC),Y
        CLC
        ADC     #$01
        TAX
.LB702
        CLC
        LDY     #$00
        LDA     (L00AC),Y
        ADC     #$02
        STA     vduTempStoreDD
        LSR     A
        STA     vduTempStoreDC
        INC     vduTempStoreDD
        LSR     vduTempStoreDD
.LB712
        LDY     vduTempStoreDC
        LDA     (vduTempStoreDA),Y
        JSR     LB6D4

        PHA
        LDY     vduTempStoreDD
        LDA     (vduTempStoreDA),Y
        JSR     LB6D4

        LDY     vduTempStoreDC
        STA     (vduTempStoreDA),Y
        PLA
        LDY     vduTempStoreDD
        STA     (vduTempStoreDA),Y
        INC     vduTempStoreDD
        DEC     vduTempStoreDC
        BNE     LB712

        SEC
        LDY     #$00
        LDA     vduTempStoreDA
        ADC     (L00AC),Y
        STA     vduTempStoreDA
        BCC     LB73D

        INC     vduTempStoreDB
.LB73D
        DEX
        BNE     LB702

        JMP     LA94E

.LB743
        CLC
        LDA     L00AC
        STA     vduTempStoreDC
        ADC     #$05
        STA     vduTempStoreDA
        LDA     L00AD
        STA     vduTempStoreDD
        ADC     #$00
        STA     vduTempStoreDB
        JSR     LB7EB

        JSR     LB7BA

        CLC
        LDY     #$00
        LDA     vduTempStoreDC
        SBC     (L00AC),Y
        STA     vduTempStoreDC
        BCS     LB767

        DEC     vduTempStoreDD
.LB767
        LDY     #$01
        LDA     (L00AC),Y
        BEQ     LB7A0

        CLC
        ADC     #$01
        LSR     A
        TAX
.LB772
        LDY     #$00
        LDA     (L00AC),Y
        TAY
        INY
.LB778
        LDA     (vduTempStoreDA),Y
        PHA
        LDA     (vduTempStoreDC),Y
        STA     (vduTempStoreDA),Y
        PLA
        STA     (vduTempStoreDC),Y
        DEY
        BNE     LB778

        SEC
        LDY     #$00
        LDA     vduTempStoreDA
        ADC     (L00AC),Y
        STA     vduTempStoreDA
        BCC     LB792

        INC     vduTempStoreDB
.LB792
        CLC
        LDA     vduTempStoreDC
        SBC     (L00AC),Y
        STA     vduTempStoreDC
        BCS     LB79D

        DEC     vduTempStoreDD
.LB79D
        DEX
        BNE     LB772

.LB7A0
        JMP     LA94E

.LB7A3_inc_vduTempStoreDA_DB
        INC     vduTempStoreDA
        BNE     LB7A9

        INC     vduTempStoreDB
.LB7A9
        RTS

.LB7AA_inc_vduTempStoreDC_DD
        INC     vduTempStoreDC
        BNE     LB7A9

        INC     vduTempStoreDD
        RTS

.LB7B1
        LDA     vduTempStoreDA
        BNE     LB7B7

        DEC     vduTempStoreDB
.LB7B7
        DEC     vduTempStoreDA
        RTS

.LB7BA
        LDA     vduTempStoreDC
        BNE     LB7C0

        DEC     vduTempStoreDD
.LB7C0
        DEC     vduTempStoreDC
        RTS

.LB7C3
        PHA
        LDY     #$4E
        LDA     (L00F8),Y
        STA     vduTempStoreDD
        LDA     #$03
        STA     vduTempStoreDC
        LDY     #$4B
        LDA     (L00F8),Y
        TAX
        BEQ     LB7E3

.LB7D5
        LDY     #$05
        PLA
        PHA
        CMP     (vduTempStoreDC),Y
        BEQ     LB7E3

        JSR     LB7EB

        DEX
        BNE     LB7D5

.LB7E3
        PLA
        LDA     vduTempStoreDC
        LDY     vduTempStoreDD
        CPX     #$00
        RTS

.LB7EB
        CLC
        LDY     #$02
        LDA     (vduTempStoreDC),Y
        ADC     vduTempStoreDC
        PHA
        INY
        LDA     (vduTempStoreDC),Y
        ADC     vduTempStoreDD
        STA     vduTempStoreDD
        PLA
        ADC     #$06
        STA     vduTempStoreDC
        BCC     LB803

        INC     vduTempStoreDD
.LB803
        RTS

.LB804
        PHA
        TXA
        PHA
        TYA
        PHA
        LDY     #$4E
        LDA     (L00F8),Y
        STA     vduTempStoreDD
        LDA     #$03
        STA     vduTempStoreDC
        LDY     #$4B
        LDA     (L00F8),Y
        BEQ     LB820

        TAX
.LB81A
        JSR     LB7EB

        DEX
        BNE     LB81A

.LB820
        SEC
        LDY     #$4F
        LDA     #$00
        SBC     vduTempStoreDC
        STA     vduTempStoreDE
        LDA     (L00F8),Y
        SBC     vduTempStoreDD
        STA     vduTempStoreDF
        PLA
        TAY
        PLA
        TAX
        PLA
        RTS

.LB835
        STX     L00F8
        STY     L00F9
        LDY     #$00
.LB83B
        LDA     (L00F8),Y
        CMP     #$20
        BNE     LB84A

        INC     L00F8
        BNE     LB83B

        INC     L00F9
        JMP     LB83B

.LB84A
        LDX     L00F8
        LDY     L00F9
        JMP     L8943_set_f8_f9_to_private_workspace

.LB851
        JSR     LB835

        STX     L00F8
        STY     L00F9
        LDY     #$00
        STY     vduTempStoreDE
        LDA     (L00F8),Y
        SEC
        SBC     #$30
        CMP     #$0A
        BCS     LB897

.LB865
        TAX
        ASL     vduTempStoreDE
        BCS     LB897

        LDA     vduTempStoreDE
        ASL     A
        BCS     LB897

        ASL     A
        BCS     LB897

        ADC     vduTempStoreDE
        STA     vduTempStoreDE
        BCS     LB897

        TXA
        ADC     vduTempStoreDE
        STA     vduTempStoreDE
        BCS     LB897

        INC     L00F8
        BNE     LB885

        INC     L00F9
.LB885
        LDA     (L00F8),Y
        SEC
        SBC     #$30
        CMP     #$0A
        BCC     LB865

        LDA     vduTempStoreDE
        LDX     L00F8
        LDY     L00F9
        JMP     L8943_set_f8_f9_to_private_workspace

.LB897
        JSR     generate_error

        EQUS    $89,"Bad number",$00

.LB8A6
        LDA     #$19
        JSR     oswrch

        TXA
        JMP     oswrch

.LB8AF
        LDA     L0344
        JSR     oswrch

        LDA     L0345
        JMP     oswrch

.LB8BB
        LDA     L0346
        JSR     oswrch

        LDA     L0347
        JMP     oswrch

.LB8C7
        LDA     #$12
        JSR     oswrch

        TXA
        JSR     oswrch

        TYA
        JMP     oswrch

.LB8D4
        LDA     #$00
        STA     vduTempStoreDF
        TYA
        LSR     A
        STA     vduTempStoreDE
        LDY     #$08
.LB8DE
        BCC     LB8E6

        CLC
        TXA
        ADC     vduTempStoreDF
        STA     vduTempStoreDF
.LB8E6
        ROR     vduTempStoreDF
        ROR     vduTempStoreDE
        DEY
        BNE     LB8DE

        RTS

.LB8EE
        JSR     print_inline_counted

        EQUB    $06

        EQUS    $1E,"Mode "

.LB8F8
        LDA     vduCurrentScreenMODE
        JSR     LB98A

        JSR     print_inline_counted

        EQUB    $09

        EQUS    $0D,$0A,"Sprite "

.LB90B
        LDY     #$05
        LDA     (L00AC),Y
        JSR     LB98A

        JSR     print_inline_counted

        EQUB    $04

        EQUS    $1F,$0B,$01,"["

.LB91A
        CLC
        LDY     #$00
        LDA     (L00AC),Y
        ADC     #$01
        JSR     LB98A

        LDA     #$2C
        JSR     oswrch

        CLC
        LDY     #$01
        LDA     (L00AC),Y
        ADC     #$01
        JSR     LB98A

        JSR     print_inline_counted

        EQUB    $05

        EQUS    "] ",$1F,$00,$02

.LB93C
        LDY     #$49
        LDA     (L00F8),Y
        LSR     A
        BCC     LB947

        LDA     #$44
        BNE     LB949

.LB947
        LDA     #$55
.LB949
        JSR     oswrch

        JSR     print_inline_counted

        EQUB    $02

        EQUS    " ",$11

.LB952
        CLC
        LDA     L0348
        ADC     #$80
        JSR     oswrch

        JSR     print_inline_counted

        EQUB    $07

        EQUS    " ",$11,$80,$1F,$0B,$02,"("

.LB966
        CLC
        LDA     L033C
        ADC     L033F
        JSR     LB98A

        LDA     #$2C
        JSR     oswrch

        CLC
        LDA     L033D
        ADC     L0341
        JSR     LB98A

        JSR     print_inline_counted

        EQUB    $06

        EQUS    ")  ",$1F,$00,$04

.LB989
        RTS

.LB98A
        LDX     #$00
.LB98C
        LDY     #$00
        STY     L00AA
        STA     L00A8
        STX     L00A9
        ORA     L00A9
        BEQ     LB9B1

        LDX     #$00
.LB99A
        LDY     #$00
.LB99C
        INY
        LDA     L00A8
        SEC
        SBC     LB9E0,X
        STA     L00A8
        LDA     L00A9
        SBC     LB9E1,X
        STA     L00A9
        BCC     LB9B8

        JMP     LB99C

.LB9B1
        TYA
        CLC
        ADC     #$30
        JMP     oswrch

.LB9B8
        LDA     L00A8
        CLC
        ADC     LB9E0,X
        STA     L00A8
        LDA     L00A9
        ADC     LB9E1,X
        STA     L00A9
        DEY
        BNE     LB9CE

        LDA     L00AA
        BEQ     LB9D5

.LB9CE
        LDA     #$FF
        STA     L00AA
        JSR     LB9B1

.LB9D5
        INX
        INX
        TXA
        CMP     #$0A
        BEQ     LB9DF

        JMP     LB99A

.LB9DF
        RTS

.LB9E0
        EQUB    $10

.LB9E1
        EQUB    $27,$E8,$03,$64,$00,$0A,$00,$01,$00

.LB9EA
        JSR     LBAB6
        JMP     LB9F3

.LB9F0
        JSR     LBB87

.LB9F3
        LDX     #$34
        LDY     #$3C
        JSR     L902D

        LDX     #$38
        LDA     L0339
        STA     L0343
        LDX     L0338
.LBA05
        STX     L0342
        JSR     LBCC4

        INX
        BNE     LBA11

        INC     L0343
.LBA11
        TXA
        CMP     L0300,Y
        LDA     L0343
        SBC     L0301,Y
        BMI     LBA05

        LDY     L0343
        TXA
        BNE     LBA24

        DEY
.LBA24
        DEX
        STX     L0334
        STY     L0335
        TXA
        CMP     L033A
        TYA
        SBC     L033B
        BPL     LBA65

        LDX     #$36
        LDY     #$3E
        JSR     L902D

        LDY     #$34
        JSR     L902D

        LDA     L033B
        STA     L0343
        LDA     L033A
        TAX
.LBA4B
        STX     L0342
        JSR     LBCC4

        TXA
        BNE     LBA57

        DEC     L0343
.LBA57
        DEX
        CLC
        TXA
        SBC     L0300,Y
        LDA     L0343
        SBC     L0301,Y
        BPL     LBA4B

.LBA65
        LDA     L032F
        BPL     LB9F0

        JMP     LBA82

.LBA6D
        JSR     LBAB6

        JMP     LBA76

.LBA73
        JSR     LBB87

.LBA76
        LDX     #$3A
        LDY     #$38
        JSR     LBD2F

        LDA     L032F
        BPL     LBA73

.LBA82
        INC     L0C44
        BNE     LBA8A

        INC     L0C45
.LBA8A
        LDX     #$3E
        LDY     #$3C
        JSR     LBD2F

        JMP     L8C6F_restore_saved_cursors_and_udgs

.LBA94
        PLA
        PLA
        LDA     #$00
        STA     L0C44
        STA     L0C45
        LDX     #$29
        LDY     #$40
        JSR     LBE9B

        LDX     #$29
        LDY     #$44
        JSR     copyTwoBytesWithinVDUVariables

        LDX     #$44
        LDY     #$40
        JSR     LBD2F

        JMP     L8C6F_restore_saved_cursors_and_udgs

.LBAB6
        LDY     #$24
        LDX     #$14
        LDA     #$29
        JSR     LBE6B

        LDA     #$00
        STA     L0328
        LDY     #$22
        LDX     #$16
        LDA     #$2E
        JSR     LBE6B

        LDA     L032E
        ORA     L032F
        BEQ     LBA94

        LDA     #$00
        ROL     A
        STA     L0C38
        LDY     #$20
        LDX     #$14
        LDA     #$2C
        JSR     LBE6B

        LDA     #$00
        STA     L032B
        ROL     A
        EOR     L0C38
        STA     L0C38
        LDX     #$28
        LDY     #$2E
        JSR     LBDD0

        LDX     #$2B
        LDY     #$2E
        JSR     LBDD0

        LDA     L0C38
        BEQ     LBB11

        SEC
        LDY     #$FD
.LBB06
        LDA     #$00
        SBC     L022E,Y
        STA     L022E,Y
        INY
        BNE     LBB06

.LBB11
        LDA     L032E
        STA     L0C17
        LDA     L032F
        STA     L0C18
        JSR     L9521

        LDY     #$03
.LBB22
        LDA     L0C1A,Y
        STA     L0330,Y
        DEY
        BPL     LBB22

        LDY     #$0A
        LDA     #$00
.LBB2F
        STA     L0C39,Y
        DEY
        BPL     LBB2F

        INC     L0C3C
        JSR     LBBBA

        JSR     LBBBA

        LDA     #$00
        STA     L0C44
        STA     L0C45
        LDX     #$3C
        LDY     #$36
        JSR     LBE9B

        LDX     #$3E
        LDY     #$34
        JSR     LBE9B

        LDY     #$3A
        LDX     #$3C
        JSR     L902D

        CPY     #$3A
        BEQ     LBB6D

        LDX     #$3C
        LDY     #$3A
        JSR     copyTwoBytesWithinVDUVariables

        LDX     #$36
        LDY     #$38
        JMP     copyTwoBytesWithinVDUVariables

.LBB6D
        LDX     #$38
        LDY     #$3E
        JSR     L902D

        CPX     #$38
        BEQ     LBB86

        LDX     #$3E
        LDY     #$38
        JSR     copyTwoBytesWithinVDUVariables

        LDX     #$34
        LDY     #$3A
        JMP     copyTwoBytesWithinVDUVariables

.LBB86
        RTS

.LBB87
        JSR     LBBBA

        LDY     #$3A
        LDX     #$3C
        JSR     L902D

        CPY     #$3A
        BEQ     LBBA2

        LDA     L033C
        STA     L033A
        LDA     L033D
        STA     L033B
        RTS

.LBBA2
        LDX     #$38
        LDY     #$3E
        JSR     L902D

        CPX     #$38
        BEQ     LBBB9

        LDA     L033E
        STA     L0338
        LDA     L033F
        STA     L0339
.LBBB9
        RTS

.LBBBA
        LDX     #$38
        LDY     #$34
        JSR     copyFourBytesWithinVDUVariables

        LDX     #$3C
        LDY     #$38
        JSR     copyFourBytesWithinVDUVariables

        SEC
        LDA     L0330
        SBC     L0C40
        STA     L0C1C
        LDA     L0331
        SBC     L0C41
        STA     L0C1D
        LDA     L0332
        SBC     L0C42
        STA     L0C1E
        LDA     L0333
        SBC     L0C43
        STA     L0C1F
        LDA     #$00
        STA     L0C1B
        STA     L0C1A
        JSR     LBEFE

        LDA     L0328
        STA     L0C1A
        LDA     L0329
        STA     L0C1B
        LDA     L032A
        STA     L0C1C
        JSR     LBEB5

        CLC
        LDA     L0C39
        ADC     L0C1B
        PHP
        LDA     L0C3A
        ADC     L0C1C
        STA     L033E
        LDA     L0C3B
        ADC     L0C1D
        STA     L033F
        PLP
        BPL     LBC32

        INC     L033E
        BNE     LBC32

        INC     L033F
.LBC32
        SEC
        LDA     L0C39
        SBC     L0C1B
        PHP
        LDA     L0C3A
        SBC     L0C1C
        STA     L033C
        LDA     L0C3B
        SBC     L0C1D
        STA     L033D
        PLP
        BPL     LBC57

        INC     L033C
        BNE     LBC57

        INC     L033D
.LBC57
        CLC
        LDA     L0C3C
        ADC     L0C40
        STA     L0C40
        LDA     L0C3D
        ADC     L0C41
        STA     L0C41
        LDA     L0C3E
        ADC     L0C42
        STA     L0C42
        LDA     L0C3F
        ADC     L0C43
        STA     L0C43
        CLC
        LDA     #$02
        ADC     L0C3C
        STA     L0C3C
        BCC     LBC94

        INC     L0C3D
        BNE     LBC94

        INC     L0C3E
        BNE     LBC94

        INC     L0C3F
.LBC94
        CLC
        LDA     L0C39
        ADC     L032B
        STA     L0C39
        LDA     L0C3A
        ADC     L032C
        STA     L0C3A
        LDA     L0C3B
        ADC     L032D
        STA     L0C3B
        INC     L0C44
        BNE     LBCB8

        INC     L0C45
.LBCB8
        LDA     L032E
        BNE     LBCC0

        DEC     L032F
.LBCC0
        DEC     L032E
        RTS

.LBCC4
        STY     L0C46
        STX     L0C47
        CLC
        LDA     L0314
        ADC     L0342
        STA     L0344
        LDA     L0315
        ADC     L0343
        STA     L0345
        CLC
        LDA     L0316
        ADC     L0C44
        STA     L0346
        LDA     L0317
        ADC     L0C45
        STA     L0347
        LDX     #$44
        JSR     L8B4C

        LDA     L0C44
        ORA     L0C45
        BEQ     LBD28

        SEC
        LDA     L0314
        SBC     L0342
        STA     L0344
        LDA     L0315
        SBC     L0343
        STA     L0345
        SEC
        LDA     L0316
        SBC     L0C44
        STA     L0346
        LDA     L0317
        SBC     L0C45
        STA     L0347
        LDX     #$44
        JSR     L8B4C

.LBD28
        LDY     L0C46
        LDX     L0C47
        RTS

.LBD2F
        STY     L0C46
        STX     L0C47
        CLC
        LDA     L0314
        ADC     L0300,Y
        STA     L0340
        LDA     L0315
        ADC     L0301,Y
        STA     L0341
        CLC
        LDA     L0314
        ADC     L0300,X
        STA     L0344
        LDA     L0315
        ADC     L0301,X
        STA     L0345
        CLC
        LDA     L0316
        ADC     L0C44
        STA     L0346
        STA     L0342
        LDA     L0317
        ADC     L0C45
        STA     L0347
        STA     L0343
        LDX     #$44
        LDY     #$40
        JSR     L8B3A

        LDA     L0C44
        ORA     L0C45
        BEQ     LBDCF

        LDX     L0C47
        LDY     L0C46
        SEC
        LDA     L0314
        SBC     L0300,X
        STA     L0340
        LDA     L0315
        SBC     L0301,X
        STA     L0341
        SEC
        LDA     L0314
        SBC     L0300,Y
        STA     L0344
        LDA     L0315
        SBC     L0301,Y
        STA     L0345
        SEC
        LDA     L0316
        SBC     L0C44
        STA     L0346
        STA     L0342
        LDA     L0317
        SBC     L0C45
        STA     L0347
        STA     L0343
        LDX     #$44
        LDY     #$40
        JSR     L8B3A

.LBDCF
        RTS

.LBDD0
        STX     vduTempStoreDE
        LDA     L0300,X
        STA     L0C2C
        LDA     L0301,X
        STA     L0C2D
        LDA     L0302,X
        STA     L0C2E
        LDA     L0300,Y
        STA     L0C30
        LDA     L0301,Y
        STA     L0C31
        LDX     #$08
        LDY     #$10
        LDA     L0C31
        BMI     LBE09

.LBDF9
        INX
        ASL     L0C30
        ROL     L0C31
        BMI     LBE09

        DEY
        BNE     LBDF9

        SEC
        JMP     LBE56

.LBE09
        LDA     #$00
        STA     L0C2F
        STA     L0C32
        STA     L0C33
        STA     L0C34
.LBE17
        SEC
        LDA     L0C2C
        SBC     L0C2F
        STA     L0C35
        LDA     L0C2D
        SBC     L0C30
        STA     L0C36
        LDA     L0C2E
        SBC     L0C31
        STA     L0C37
        BCC     LBE40

        LDY     #$02
.LBE37
        LDA     L0C35,Y
        STA     L0C2C,Y
        DEY
        BPL     LBE37

.LBE40
        ROL     L0C32
        ROL     L0C33
        ROL     L0C34
        LSR     L0C31
        ROR     L0C30
        ROR     L0C2F
        DEX
        BPL     LBE17

        CLC
.LBE56
        LDX     vduTempStoreDE
        LDA     L0C32
        STA     L0300,X
        LDA     L0C33
        STA     L0301,X
        LDA     L0C34
        STA     L0302,X
        RTS

.LBE6B
        STA     vduTempStoreDF
        SEC
        LDA     L0300,Y
        SBC     L0300,X
        STA     vduTempStoreDE
        LDA     L0301,Y
        SBC     L0301,X
        LDX     vduTempStoreDF
        STA     L0301,X
        ROL     A
        LDA     vduTempStoreDE
        STA     L0300,X
        BCC     LBE9A

        LDA     #$00
        SBC     L0300,X
        STA     L0300,X
        LDA     #$00
        SBC     L0301,X
        STA     L0301,X
        SEC
.LBE9A
        RTS

.LBE9B
        SEC
        LDA     #$00
        SBC     L0300,X
        STA     L0300,Y
        LDA     #$00
        SBC     L0301,X
        STA     L0301,Y
        RTS

.LBEAD
        LDA     #$00
        STA     L0C1C
        STA     L0C19
.LBEB5
        LSR     L0C1C
        ROR     L0C1B
        ROR     L0C1A
        LDA     #$00
        STA     L0C1F
        STA     L0C1E
        STA     L0C1D
        LDY     #$17
.LBECB
        BCC     LBEE9

        CLC
        LDA     L0C17
        ADC     L0C1D
        STA     L0C1D
        LDA     L0C18
        ADC     L0C1E
        STA     L0C1E
        LDA     L0C19
        ADC     L0C1F
        STA     L0C1F
.LBEE9
        CLC
        LDX     #$05
.LBEEC
        ROR     L0C1A,X
        DEX
        BPL     LBEEC

        DEY
        BPL     LBECB

        RTS

.LBEF6
        LDA     #$00
        STA     L0C1E
        STA     L0C1F
.LBEFE
        LDA     #$00
        STA     L0C17
        STA     L0C18
        STA     L0C19
        STA     L0C20
        STA     L0C21
        STA     L0C22
        STA     L0C23
        LDX     #$18
.LBF17
        ASL     L0C1A
        ROL     L0C1B
        ROL     L0C1C
        ROL     L0C1D
        ROL     L0C1E
        ROL     L0C1F
        ROL     L0C20
        ROL     L0C21
        ROL     L0C22
        ROL     L0C23
        ASL     L0C1A
        ROL     L0C1B
        ROL     L0C1C
        ROL     L0C1D
        ROL     L0C1E
        ROL     L0C1F
        ROL     L0C20
        ROL     L0C21
        ROL     L0C22
        ROL     L0C23
        LDA     L0C17
        ASL     A
        STA     L0C24
        LDA     L0C18
        ROL     A
        STA     L0C25
        LDA     L0C19
        ROL     A
        STA     L0C26
        LDA     #$00
        ROL     A
        STA     L0C27
        SEC
        ROL     L0C24
        ROL     L0C25
        ROL     L0C26
        ROL     L0C27
        SEC
        LDA     L0C20
        SBC     L0C24
        STA     L0C24
        LDA     L0C21
        SBC     L0C25
        STA     L0C25
        LDA     L0C22
        SBC     L0C26
        STA     L0C26
        LDA     L0C23
        SBC     L0C27
        STA     L0C27
        BCC     LBFB7

        STA     L0C23
        LDA     L0C26
        STA     L0C22
        LDA     L0C25
        STA     L0C21
        LDA     L0C24
        STA     L0C20
.LBFB7
        ROL     L0C17
        ROL     L0C18
        ROL     L0C19
        DEX
        BEQ     LBFC6

        JMP     LBF17

.LBFC6
        RTS

if ELECTRON
        ; Make it relatively obvious this isn't an original 1980s Acorn version
        ; for the Electron.
        EQUS    "Steve 2020"
endif

        skipto  $bfdb
        EQUS    " Richard,Sam,Tutu,Tim,Paul & Sharron "

.BeebDisEndAddr
if BBC_B
    if not(BBC_INTEGRA_B)
        SAVE "gxr120.rom",BeebDisStartAddr,BeebDisEndAddr
    else
        ; The conversion program on the Integra-B support disc chops off the
        ; last byte of the ROM, so we do the same here.
        SAVE "gxr12i.rom",BeebDisStartAddr,BeebDisEndAddr-1
    endif
elif BBC_B_PLUS
        SAVE "gxr200.rom",BeebDisStartAddr,BeebDisEndAddr
elif ELECTRON
        SAVE "gxr100.rom",BeebDisStartAddr,BeebDisEndAddr
else
        unknown_machine
endif
