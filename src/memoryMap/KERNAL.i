#importonce

/*
 *  KERNAL mapping
 */

.namespace KERNAL {
.label /* $E000 - 57344 */ E000_exp_continued_from_basic_rom = $E000
//  start of the kernal ROM
//
//                                 EXP() continued
// .:E000 85 56    STA $56         save FAC2 rounding byte
// .:E002 20 0F BC JSR $BC0F       copy FAC1 to FAC2
// .:E005 A5 61    LDA $61         get FAC1 exponent
// .:E007 C9 88    CMP #$88        compare with EXP limit (256d)
// .:E009 90 03    BCC $E00E       branch if less
// .:E00B 20 D4 BA JSR $BAD4       handle overflow and underflow
// .:E00E 20 CC BC JSR $BCCC       perform INT()
// .:E011 A5 07    LDA $07         get mantissa 4 from INT()
// .:E013 18       CLC             clear carry for add
// .:E014 69 81    ADC #$81        normalise +1
// .:E016 F0 F3    BEQ $E00B       if $00 result has overflowed so go handle it
// .:E018 38       SEC             set carry for subtract
// .:E019 E9 01    SBC #$01        exponent now correct
// .:E01B 48       PHA             save FAC2 exponent
//                                 swap FAC1 and FAC2
// .:E01C A2 05    LDX #$05        4 bytes to do
// .:E01E B5 69    LDA $69,X       get FAC2,X
// .:E020 B4 61    LDY $61,X       get FAC1,X
// .:E022 95 61    STA $61,X       save FAC1,X
// .:E024 94 69    STY $69,X       save FAC2,X
// .:E026 CA       DEX             decrement count/index
// .:E027 10 F5    BPL $E01E       loop if not all done
// .:E029 A5 56    LDA $56         get FAC2 rounding byte
// .:E02B 85 70    STA $70         save as FAC1 rounding byte
// .:E02D 20 53 B8 JSR $B853       perform subtraction, FAC2 from FAC1
// .:E030 20 B4 BF JSR $BFB4       do - FAC1
// .:E033 A9 C4    LDA #$C4        set counter pointer low byte
// .:E035 A0 BF    LDY #$BF        set counter pointer high byte
// .:E037 20 59 E0 JSR $E059       go do series evaluation
// .:E03A A9 00    LDA #$00        clear A
// .:E03C 85 6F    STA $6F         clear sign compare (FAC1 EOR FAC2)
// .:E03E 68       PLA             get saved FAC2 exponent
// .:E03F 20 B9 BA JSR $BAB9       test and adjust accumulators
// .:E042 60       RTS

.label /* $E043 - 57411 */ E043_series_evaluation = $E043
//                                 ^2 then series evaluation
// .:E043 85 71    STA $71         save count pointer low byte
// .:E045 84 72    STY $72         save count pointer high byte
// .:E047 20 CA BB JSR $BBCA       pack FAC1 into $57
// .:E04A A9 57    LDA #$57        set pointer low byte (Y already $00)
// .:E04C 20 28 BA JSR $BA28       do convert AY, FCA1*(AY)
// .:E04F 20 5D E0 JSR $E05D       go do series evaluation
// .:E052 A9 57    LDA #$57        pointer to original # low byte
// .:E054 A0 00    LDY #$00        pointer to original # high byte
// .:E056 4C 28 BA JMP $BA28       do convert AY, FCA1*(AY)
//                                 do series evaluation
// .:E059 85 71    STA $71         save count pointer low byte
// .:E05B 84 72    STY $72         save count pointer high byte
//                                 do series evaluation
// .:E05D 20 C7 BB JSR $BBC7       pack FAC1 into $5C
// .:E060 B1 71    LDA ($71),Y     get constants count
// .:E062 85 67    STA $67         save constants count
// .:E064 A4 71    LDY $71         get count pointer low byte
// .:E066 C8       INY             increment it (now constants pointer)
// .:E067 98       TYA             copy it
// .:E068 D0 02    BNE $E06C       skip next if no overflow
// .:E06A E6 72    INC $72         else increment high byte
// .:E06C 85 71    STA $71         save low byte
// .:E06E A4 72    LDY $72         get high byte
// .:E070 20 28 BA JSR $BA28       do convert AY, FCA1*(AY)
// .:E073 A5 71    LDA $71         get constants pointer low byte
// .:E075 A4 72    LDY $72         get constants pointer high byte
// .:E077 18       CLC             clear carry for add
// .:E078 69 05    ADC #$05        +5 to low pointer (5 bytes per constant)
// .:E07A 90 01    BCC $E07D       skip next if no overflow
// .:E07C C8       INY             increment high byte
// .:E07D 85 71    STA $71         save pointer low byte
// .:E07F 84 72    STY $72         save pointer high byte
// .:E081 20 67 B8 JSR $B867       add (AY) to FAC1
// .:E084 A9 5C    LDA #$5C        set pointer low byte to partial
// .:E086 A0 00    LDY #$00        set pointer high byte to partial
// .:E088 C6 67    DEC $67         decrement constants count
// .:E08A D0 E4    BNE $E070       loop until all done
// .:E08C 60       RTS

.label /* $E08D - 57485 */ E08D_constants_for_rnd = $E08D
// RND values
//
// .:E08D 98 35 44 7A 00           11879546            multiplier
// .:E092 68 28 B1 46 00           3.927677739E-8      offset

.label /* $E097 - 57495 */ E097_evaluate_rnd = $E097
// perform RND()
//
// .:E097 20 2B BC JSR $BC2B       get FAC1 sign
//                                 return A = $FF -ve, A = $01 +ve
// .:E09A 30 37    BMI $E0D3       if n<0 copy byte swapped FAC1 into RND() seed
// .:E09C D0 20    BNE $E0BE       if n>0 get next number in RND() sequence
//                                 else n=0 so get the RND() number from VIA 1 timers
// .:E09E 20 F3 FF JSR $FFF3       return base address of I/O devices
// .:E0A1 86 22    STX $22         save pointer low byte
// .:E0A3 84 23    STY $23         save pointer high byte
// .:E0A5 A0 04    LDY #$04        set index to T1 low byte
// .:E0A7 B1 22    LDA ($22),Y     get T1 low byte
// .:E0A9 85 62    STA $62         save FAC1 mantissa 1
// .:E0AB C8       INY             increment index
// .:E0AC B1 22    LDA ($22),Y     get T1 high byte
// .:E0AE 85 64    STA $64         save FAC1 mantissa 3
// .:E0B0 A0 08    LDY #$08        set index to T2 low byte
// .:E0B2 B1 22    LDA ($22),Y     get T2 low byte
// .:E0B4 85 63    STA $63         save FAC1 mantissa 2
// .:E0B6 C8       INY             increment index
// .:E0B7 B1 22    LDA ($22),Y     get T2 high byte
// .:E0B9 85 65    STA $65         save FAC1 mantissa 4
// .:E0BB 4C E3 E0 JMP $E0E3       set exponent and exit
// .:E0BE A9 8B    LDA #$8B        set seed pointer low address
// .:E0C0 A0 00    LDY #$00        set seed pointer high address
// .:E0C2 20 A2 BB JSR $BBA2       unpack memory (AY) into FAC1
// .:E0C5 A9 8D    LDA #$8D        set 11879546 pointer low byte
// .:E0C7 A0 E0    LDY #$E0        set 11879546 pointer high byte
// .:E0C9 20 28 BA JSR $BA28       do convert AY, FCA1*(AY)
// .:E0CC A9 92    LDA #$92        set 3.927677739E-8 pointer low byte
// .:E0CE A0 E0    LDY #$E0        set 3.927677739E-8 pointer high byte
// .:E0D0 20 67 B8 JSR $B867       add (AY) to FAC1
// .:E0D3 A6 65    LDX $65         get FAC1 mantissa 4
// .:E0D5 A5 62    LDA $62         get FAC1 mantissa 1
// .:E0D7 85 65    STA $65         save FAC1 mantissa 4
// .:E0D9 86 62    STX $62         save FAC1 mantissa 1
// .:E0DB A6 63    LDX $63         get FAC1 mantissa 2
// .:E0DD A5 64    LDA $64         get FAC1 mantissa 3
// .:E0DF 85 63    STA $63         save FAC1 mantissa 2
// .:E0E1 86 64    STX $64         save FAC1 mantissa 3
// .:E0E3 A9 00    LDA #$00        clear byte
// .:E0E5 85 66    STA $66         clear FAC1 sign (always +ve)
// .:E0E7 A5 61    LDA $61         get FAC1 exponent
// .:E0E9 85 70    STA $70         save FAC1 rounding byte
// .:E0EB A9 80    LDA #$80        set exponent = $80
// .:E0ED 85 61    STA $61         save FAC1 exponent
// .:E0EF 20 D7 B8 JSR $B8D7       normalise FAC1
// .:E0F2 A2 8B    LDX #$8B        set seed pointer low address
// .:E0F4 A0 00    LDY #$00        set seed pointer high address
//
// pack FAC1 into (XY)
//
// .:E0F6 4C D4 BB JMP $BBD4       pack FAC1 into (XY)

.label /* $E0F9 - 57593 */ E0F9_handle_io_error_in_basic = $E0F9
// handle BASIC I/O error
//
// .:E0F9 C9 F0    CMP #$F0        compare error with $F0
// .:E0FB D0 07    BNE $E104       branch if not $F0
// .:E0FD 84 38    STY $38         set end of memory high byte
// .:E0FF 86 37    STX $37         set end of memory low byte
// .:E101 4C 63 A6 JMP $A663       clear from start to end and return
//	                                error was not $F0
// .:E104 AA       TAX             copy error #
// .:E105 D0 02    BNE $E109       branch if not $00
// .:E107 A2 1E    LDX #$1E        else error $1E, break error
// .:E109 4C 37 A4 JMP $A437       do error #X then warm start

.label /* $E10C - 57612 */ E10C_output_character = $E10C
// output character to channel with error check
//
// .:E10C 20 D2 FF JSR $FFD2       output character to channel
// .:E10F B0 E8    BCS $E0F9       if error go handle BASIC I/O error
// .:E111 60       RTS

.label /* $E112 - 57618 */ E112_input_character = $E112
// input character from channel with error check
//
// .:E112 20 CF FF JSR $FFCF       input character from channel
// .:E115 B0 E2    BCS $E0F9       if error go handle BASIC I/O error
// .:E117 60       RTS

.label /* $E118 - 57624 */ E118_set_up_for_output = $E118
// open channel for output with error check
//
// .:E118 20 AD E4 JSR $E4AD       open channel for output
// .:E11B B0 DC    BCS $E0F9       if error go handle BASIC I/O error
// .:E11D 60       RTS

.label /* $E11E - 57630 */ E11E_set_up_for_input = $E11E
// open channel for input with error check
//
// .:E11E 20 C6 FF JSR $FFC6       open channel for input
// .:E121 B0 D6    BCS $E0F9       if error go handle BASIC I/O error
// .:E123 60       RTS

.label /* $E124 - 57636 */ E124_get_one_character = $E124
// get character from input device with error check
//
// .:E124 20 E4 FF JSR $FFE4       get character from input device
// .:E127 B0 D0    BCS $E0F9       if error go handle BASIC I/O error
// .:E129 60       RTS

.label /* $E12A - 57642 */ E12A_perform_sys = $E12A
// perform SYS
//
// .:E12A 20 8A AD JSR $AD8A       evaluate expression and check is numeric, else do
//                                 type mismatch
// .:E12D 20 F7 B7 JSR $B7F7       convert FAC_1 to integer in temporary integer
// .:E130 A9 E1    LDA #$E1        get return address high byte
// .:E132 48       PHA             push as return address
// .:E133 A9 46    LDA #$46        get return address low byte
// .:E135 48       PHA             push as return address
// .:E136 AD 0F 03 LDA $030F       get saved status register
// .:E139 48       PHA             put on stack
// .:E13A AD 0C 03 LDA $030C       get saved A
// .:E13D AE 0D 03 LDX $030D       get saved X
// .:E140 AC 0E 03 LDY $030E       get saved Y
// .:E143 28       PLP             pull processor status
// .:E144 6C 14 00 JMP ($0014)     call SYS address
//                                 tail end of SYS code
// .:E147 08       PHP             save status
// .:E148 8D 0C 03 STA $030C       save returned A
// .:E14B 8E 0D 03 STX $030D       save returned X
// .:E14E 8C 0E 03 STY $030E       save returned Y
// .:E151 68       PLA             restore saved status
// .:E152 8D 0F 03 STA $030F       save status
// .:E155 60       RTS

.label /* $E156 - 57686 */ E156_perform_save = $E156
// perform SAVE
//
// .:E156 20 D4 E1 JSR $E1D4       get parameters for LOAD/SAVE
// .:E159 A6 2D    LDX $2D         get start of variables low byte
// .:E15B A4 2E    LDY $2E         get start of variables high byte
// .:E15D A9 2B    LDA #$2B        index to start of program memory
// .:E15F 20 D8 FF JSR $FFD8       save RAM to device, A = index to start address, XY = end
//	                               address low/high
// .:E162 B0 95    BCS $E0F9       if error go handle BASIC I/O error
// .:E164 60       RTS

.label /* $E165 - 57701 */ E165_perform_verify = $E165
// perform VERIFY
//
// .:E165 A9 01    LDA #$01        flag verify
// .:E167 2C       .BYTE $2C       makes next line BIT $00A9

.label /* $E168 - 57704 */ E168_perform_load = $E168
// perform LOAD
//
// .:E168 A9 00    LDA #$00        flag load
// .:E16A 85 0A    STA $0A         set load/verify flag
// .:E16C 20 D4 E1 JSR $E1D4       get parameters for LOAD/SAVE
// .:E16F A5 0A    LDA $0A         get load/verify flag
// .:E171 A6 2B    LDX $2B         get start of memory low byte
// .:E173 A4 2C    LDY $2C         get start of memory high byte
// .:E175 20 D5 FF JSR $FFD5       load RAM from a device
// .:E178 B0 57    BCS $E1D1       if error go handle BASIC I/O error
// .:E17A A5 0A    LDA $0A         get load/verify flag
// .:E17C F0 17    BEQ $E195       branch if load
// .:E17E A2 1C    LDX #$1C        error $1C, verify error
// .:E180 20 B7 FF JSR $FFB7       read I/O status word
// .:E183 29 10    AND #$10        mask for tape read error
// .:E185 D0 17    BNE $E19E       branch if no read error
// .:E187 A5 7A    LDA $7A         get the BASIC execute pointer low byte
//                                 is this correct ?? won't this mean the "OK" prompt
//                                 when doing a load from within a program ?
// .:E189 C9 02    CMP #$02
// .:E18B F0 07    BEQ $E194       if ?? skip "OK" prompt
// .:E18D A9 64    LDA #$64        set "OK" pointer low byte
// .:E18F A0 A3    LDY #$A3        set "OK" pointer high byte
// .:E191 4C 1E AB JMP $AB1E       print null terminated string
// .:E194 60       RTS
//
// do READY return to BASIC
//
// .:E195 20 B7 FF JSR $FFB7       read I/O status word
// .:E198 29 BF    AND #$BF        mask x0xx xxxx, clear read error
// .:E19A F0 05    BEQ $E1A1       branch if no errors
// .:E19C A2 1D    LDX #$1D        error $1D, load error
// .:E19E 4C 37 A4 JMP $A437       do error #X then warm start
// .:E1A1 A5 7B    LDA $7B         get BASIC execute pointer high byte
// .:E1A3 C9 02    CMP #$02        compare with $02xx
// .:E1A5 D0 0E    BNE $E1B5       branch if not immediate mode
// .:E1A7 86 2D    STX $2D         set start of variables low byte
// .:E1A9 84 2E    STY $2E         set start of variables high byte
// .:E1AB A9 76    LDA #$76        set "READY." pointer low byte
// .:E1AD A0 A3    LDY #$A3        set "READY." pointer high byte
// .:E1AF 20 1E AB JSR $AB1E       print null terminated string
// .:E1B2 4C 2A A5 JMP $A52A       reset execution, clear variables, flush stack,
//                                 rebuild BASIC chain and do warm start
// .:E1B5 20 8E A6 JSR $A68E       set BASIC execute pointer to start of memory - 1
// .:E1B8 20 33 A5 JSR $A533       rebuild BASIC line chaining
// .:E1BB 4C 77 A6 JMP $A677       rebuild BASIC line chaining, do RESTORE and return

.label /* $E1BE - 57790 */ E1BE_perform_open = $E1BE
// perform OPEN
//
// .:E1BE 20 19 E2 JSR $E219       get parameters for OPEN/CLOSE
// .:E1C1 20 C0 FF JSR $FFC0       open a logical file
// .:E1C4 B0 0B    BCS $E1D1       branch if error
// .:E1C6 60       RTS

.label /* $E1C7 - 57799 */ E1C7_perform_close = $E1C7
// perform CLOSE
//
// .:E1C7 20 19 E2 JSR $E219       get parameters for OPEN/CLOSE
// .:E1CA A5 49    LDA $49         get logical file number
// .:E1CC 20 C3 FF JSR $FFC3       close a specified logical file
// .:E1CF 90 C3    BCC $E194       exit if no error
// .:E1D1 4C F9 E0 JMP $E0F9       go handle BASIC I/O error

.label /* $E1D4 - 57812 */ E1D4_get_parameters_for_load_save = $E1D4
// get parameters for LOAD/SAVE
//
// .:E1D4 A9 00    LDA #$00        clear file name length
// .:E1D6 20 BD FF JSR $FFBD       clear the filename
// .:E1D9 A2 01    LDX #$01        set default device number, cassette
// .:E1DB A0 00    LDY #$00        set default command
// .:E1DD 20 BA FF JSR $FFBA       set logical, first and second addresses
// .:E1E0 20 06 E2 JSR $E206       exit function if [EOT] or ":"
// .:E1E3 20 57 E2 JSR $E257       set filename
// .:E1E6 20 06 E2 JSR $E206       exit function if [EOT] or ":"
// .:E1E9 20 00 E2 JSR $E200       scan and get byte, else do syntax error then warm start
// .:E1EC A0 00    LDY #$00        clear command
// .:E1EE 86 49    STX $49         save device number
// .:E1F0 20 BA FF JSR $FFBA       set logical, first and second addresses
// .:E1F3 20 06 E2 JSR $E206       exit function if [EOT] or ":"
// .:E1F6 20 00 E2 JSR $E200       scan and get byte, else do syntax error then warm start
// .:E1F9 8A       TXA             copy command to A
// .:E1FA A8       TAY             copy command to Y
// .:E1FB A6 49    LDX $49         get device number back
// .:E1FD 4C BA FF JMP $FFBA       set logical, first and second addresses and return

.label /* $E200 - 57856 */ E200_get_next_one_byte_parameter = $E200
// scan and get byte, else do syntax error then warm start
//
// .:E200 20 0E E2 JSR $E20E       scan for ",byte", else do syntax error then warm start
// .:E203 4C 9E B7 JMP $B79E       get byte parameter and return

.label /* $E206 - 57862 */ E206_check_default_parameters = $E206
//                                 exit function if [EOT] or ":"
// .:E206 20 79 00 JSR $0079       scan memory
// .:E209 D0 02    BNE $E20D       branch if not [EOL] or ":"
// .:E20B 68       PLA             dump return address low byte
// .:E20C 68       PLA             dump return address high byte
// .:E20D 60       RTS

.label /* $E20E - 57870 */ E20E_check_for_comma = $E20E
// scan for ",valid byte", else do syntax error then warm start
//
// .:E20E 20 FD AE JSR $AEFD       scan for ",", else do syntax error then warm start
//
// scan for valid byte, not [EOL] or ":", else do syntax error then warm start
//
// .:E211 20 79 00 JSR $0079       scan memory
// .:E214 D0 F7    BNE $E20D       exit if following byte
// .:E216 4C 08 AF JMP $AF08       else do syntax error then warm start

.label /* $E219 - 57881 */ E219_get_parameters_for_open_close = $E219
// get parameters for OPEN/CLOSE
//
// .:E219 A9 00    LDA #$00        clear the filename length
// .:E21B 20 BD FF JSR $FFBD       clear the filename
// .:E21E 20 11 E2 JSR $E211       scan for valid byte, else do syntax error then warm start
// .:E221 20 9E B7 JSR $B79E       get byte parameter, logical file number
// .:E224 86 49    STX $49         save logical file number
// .:E226 8A       TXA             copy logical file number to A
// .:E227 A2 01    LDX #$01        set default device number, cassette
// .:E229 A0 00    LDY #$00        set default command
// .:E22B 20 BA FF JSR $FFBA       set logical, first and second addresses
// .:E22E 20 06 E2 JSR $E206       exit function if [EOT] or ":"
// .:E231 20 00 E2 JSR $E200       scan and get byte, else do syntax error then warm start
// .:E234 86 4A    STX $4A         save device number
// .:E236 A0 00    LDY #$00        clear command
// .:E238 A5 49    LDA $49         get logical file number
// .:E23A E0 03    CPX #$03        compare device number with screen
// .:E23C 90 01    BCC $E23F       branch if less than screen
// .:E23E 88       DEY             else decrement command
// .:E23F 20 BA FF JSR $FFBA       set logical, first and second addresses
// .:E242 20 06 E2 JSR $E206       exit function if [EOT] or ":"
// .:E245 20 00 E2 JSR $E200       scan and get byte, else do syntax error then warm start
// .:E248 8A       TXA             copy command to A
// .:E249 A8       TAY             copy command to Y
// .:E24A A6 4A    LDX $4A         get device number
// .:E24C A5 49    LDA $49         get logical file number
// .:E24E 20 BA FF JSR $FFBA       set logical, first and second addresses
// .:E251 20 06 E2 JSR $E206       exit function if [EOT] or ":"
// .:E254 20 0E E2 JSR $E20E       scan for ",byte", else do syntax error then warm start
//
// set filename
//
// .:E257 20 9E AD JSR $AD9E       evaluate expression
// .:E25A 20 A3 B6 JSR $B6A3       evaluate string
// .:E25D A6 22    LDX $22         get string pointer low byte
// .:E25F A4 23    LDY $23         get string pointer high byte
// .:E261 4C BD FF JMP $FFBD       set the filename and return

.label /* $E264 - 57956 */ E264_evaluate_cos = $E264
// perform COS()
//
// .:E264 A9 E0    LDA #$E0        set pi/2 pointer low byte
// .:E266 A0 E2    LDY #$E2        set pi/2 pointer high byte
// .:E268 20 67 B8 JSR $B867       add (AY) to FAC1

.label /* $E26B - 57963 */ E26B_evaluate_sin = $E26B
// perform SIN()
//
// .:E26B 20 0C BC JSR $BC0C       round and copy FAC1 to FAC2
// .:E26E A9 E5    LDA #$E5        set 2*pi pointer low byte
// .:E270 A0 E2    LDY #$E2        set 2*pi pointer high byte
// .:E272 A6 6E    LDX $6E         get FAC2 sign (b7)
// .:E274 20 07 BB JSR $BB07       divide by (AY) (X=sign)
// .:E277 20 0C BC JSR $BC0C       round and copy FAC1 to FAC2
// .:E27A 20 CC BC JSR $BCCC       perform INT()
// .:E27D A9 00    LDA #$00        clear byte
// .:E27F 85 6F    STA $6F         clear sign compare (FAC1 EOR FAC2)
// .:E281 20 53 B8 JSR $B853       perform subtraction, FAC2 from FAC1
// .:E284 A9 EA    LDA #$EA        set 0.25 pointer low byte
// .:E286 A0 E2    LDY #$E2        set 0.25 pointer high byte
// .:E288 20 50 B8 JSR $B850       perform subtraction, FAC1 from (AY)
// .:E28B A5 66    LDA $66         get FAC1 sign (b7)
// .:E28D 48       PHA             save FAC1 sign
// .:E28E 10 0D    BPL $E29D       branch if +ve
//                                 FAC1 sign was -ve
// .:E290 20 49 B8 JSR $B849       add 0.5 to FAC1 (round FAC1)
// .:E293 A5 66    LDA $66         get FAC1 sign (b7)
// .:E295 30 09    BMI $E2A0       branch if -ve
// .:E297 A5 12    LDA $12         get the comparison evaluation flag
// .:E299 49 FF    EOR #$FF        toggle flag
// .:E29B 85 12    STA $12         save the comparison evaluation flag
// .:E29D 20 B4 BF JSR $BFB4       do - FAC1
// .:E2A0 A9 EA    LDA #$EA        set 0.25 pointer low byte
// .:E2A2 A0 E2    LDY #$E2        set 0.25 pointer high byte
// .:E2A4 20 67 B8 JSR $B867       add (AY) to FAC1
// .:E2A7 68       PLA             restore FAC1 sign
// .:E2A8 10 03    BPL $E2AD       branch if was +ve
//                                 else correct FAC1
// .:E2AA 20 B4 BF JSR $BFB4       do - FAC1
// .:E2AD A9 EF    LDA #$EF        set pointer low byte to counter
// .:E2AF A0 E2    LDY #$E2        set pointer high byte to counter
// .:E2B1 4C 43 E0 JMP $E043       ^2 then series evaluation and return

.label /* $E2B4 - 58036 */ E2B4_evaluate_tan = $E2B4
// perform TAN()
//
// .:E2B4 20 CA BB JSR $BBCA       pack FAC1 into $57
// .:E2B7 A9 00    LDA #$00        clear A
// .:E2B9 85 12    STA $12         clear the comparison evaluation flag
// .:E2BB 20 6B E2 JSR $E26B       perform SIN()
// .:E2BE A2 4E    LDX #$4E        set sin(n) pointer low byte
// .:E2C0 A0 00    LDY #$00        set sin(n) pointer high byte
// .:E2C2 20 F6 E0 JSR $E0F6       pack FAC1 into (XY)
// .:E2C5 A9 57    LDA #$57        set n pointer low byte
// .:E2C7 A0 00    LDY #$00        set n pointer high byte
// .:E2C9 20 A2 BB JSR $BBA2       unpack memory (AY) into FAC1
// .:E2CC A9 00    LDA #$00        clear byte
// .:E2CE 85 66    STA $66         clear FAC1 sign (b7)
// .:E2D0 A5 12    LDA $12         get the comparison evaluation flag
// .:E2D2 20 DC E2 JSR $E2DC       save flag and go do series evaluation
// .:E2D5 A9 4E    LDA #$4E        set sin(n) pointer low byte
// .:E2D7 A0 00    LDY #$00        set sin(n) pointer high byte
// .:E2D9 4C 0F BB JMP $BB0F       convert AY and do (AY)/FAC1
//
// save comparison flag and do series evaluation
//
// .:E2DC 48       PHA             save comparison flag
// .:E2DD 4C 9D E2 JMP $E29D       add 0.25, ^2 then series evaluation

.label /* $E2E0 - 58080 */ E2E0_table_of_trig_constants_1_570796327 = $E2E0
// constants and series for SIN/COS(n)
//
// .:E2E0 81 49 0F DA A2           1.570796371, pi/2, as floating number

.label /* $E2E5 - 58085 */ E2E5_table_of_trig_constants_6_28318531 = $E2E5
// .:E2E5 83 49 0F DA A2           6.28319, 2*pi, as floating number

.label /* $E2EA - 58090 */ E2EA_table_of_trig_constants_0_25 = $E2EA
// .:E2EA 7F 00 00 00 00           0.25

.label /* $E2EF - 58095 */ E2EF_table_of_trig_constants_05 = $E2EF
// .:E2EF 05                       series counter

.label /* $E2F0 - 58096 */ E2F0_table_of_trig_constants_minus_14_3813907 = $E2F0
// .:E2F0 84 E6 1A 2D 1B           -14.3813907

.label /* $E2F5 - 58101 */ E2F5_table_of_trig_constants_42_0077971 = $E2F5
// .:E2F5 86 28 07 FB F8            42.0077971

.label /* $E2FA - 58106 */ E2FA_table_of_trig_constants_minus_76_7041703 = $E2FA
// .:E2FA 87 99 68 89 01           -76.7041703

.label /* $E2FF - 58111 */ E2FF_table_of_trig_constants_81_6052237 = $E2FF
// .:E2FF 87 23 35 DF E1            81.6052237

.label /* $E304 - 58116 */ E304_table_of_trig_constants_minus_41_3417021 = $E304
// .:E304 86 A5 5D E7 28           -41.3147021

.label /* $E309 - 58121 */ E309_table_of_trig_constants_6_28318531 = $E309
// .:E309 83 49 0F DA A2             6.28318531   2*pi

.label /* $E30E - 58126 */ E30E_evaluate_atn = $E30E
// perform ATN()
//
// .:E30E A5 66    LDA $66         get FAC1 sign (b7)
// .:E310 48       PHA             save sign
// .:E311 10 03    BPL $E316       branch if +ve
// .:E313 20 B4 BF JSR $BFB4       else do - FAC1
// .:E316 A5 61    LDA $61         get FAC1 exponent
// .:E318 48       PHA             push exponent
// .:E319 C9 81    CMP #$81        compare with 1
// .:E31B 90 07    BCC $E324       branch if FAC1 < 1
// .:E31D A9 BC    LDA #$BC        pointer to 1 low byte
// .:E31F A0 B9    LDY #$B9        pointer to 1 high byte
// .:E321 20 0F BB JSR $BB0F       convert AY and do (AY)/FAC1
// .:E324 A9 3E    LDA #$3E        pointer to series low byte
// .:E326 A0 E3    LDY #$E3        pointer to series high byte
// .:E328 20 43 E0 JSR $E043       ^2 then series evaluation
// .:E32B 68       PLA             restore old FAC1 exponent
// .:E32C C9 81    CMP #$81        compare with 1
// .:E32E 90 07    BCC $E337       branch if FAC1 < 1
// .:E330 A9 E0    LDA #$E0        pointer to (pi/2) low byte
// .:E332 A0 E2    LDY #$E2        pointer to (pi/2) low byte
// .:E334 20 50 B8 JSR $B850       perform subtraction, FAC1 from (AY)
// .:E337 68       PLA             restore FAC1 sign
// .:E338 10 03    BPL $E33D       exit if was +ve
// .:E33A 4C B4 BF JMP $BFB4       else do - FAC1 and return
// .:E33D 60       RTS

.label /* $E33E - 58174 */ E33E_table_of_atn_constants_0b = $E33E
// series for ATN(n)
//
// .:E33E 0B                       series counter

.label /* $E33F - 58175 */ E33F_table_of_atn_constants_minus_0_00068479391 = $E33F
// .:E33F 76 B3 83 BD D3           -6.84793912E-04

.label /* $E344 - 58180 */ E344_table_of_atn_constants_0_00485094216 = $E344
// .:E344 79 1E F4 A6 F5            4.85094216E-03

.label /* $E349 - 58185 */ E349_table_of_atn_constants_minus_0_161117018 = $E349
// .:E349 7B 83 FC B0 10            -.0161117015

.label /* $E34E - 58190 */ E34E_table_of_atn_constants_0_034209638 = $E34E
// .:E34E 7C 0C 1F 67 CA             .034209638

.label /* $E353 - 58195 */ E353_table_of_atn_constants_minus_0_0542791328 = $E353
// .:E353 7C DE 53 CB C1            -.054279133

.label /* $E358 - 58200 */ E358_table_of_atn_constants_0_0724571965 = $E358
// .:E358 7D 14 64 70 4C             .0724571965

.label /* $E35D - 58205 */ E35D_table_of_atn_constants_minus_0_0898023954 = $E35D
// .:E35D 7D B7 EA 51 7A            -.0898019185

.label /* $E362 - 58210 */ E362_table_of_atn_constants_0_110932413 = $E362
// .:E362 7D 63 30 88 7E             .110932413

.label /* $E367 - 58215 */ E367_table_of_atn_constants_minus_0_142839808 = $E367
// .:E367 7E 92 44 99 3A            -.142839808

.label /* $E36C - 58220 */ E36C_table_of_atn_constants_0_19999912 = $E36C
// .:E36C 7E 4C CC 91 C7             .19999912

.label /* $E371 - 58225 */ E371_table_of_atn_constants_minus_0_333333316 = $E371
// .:E371 7F AA AA AA 13            -.333333316

.label /* $E376 - 58230 */ E376_table_of_atn_constants_1_00 = $E376
// .:E376 81 00 00 00 00            1

.label /* $E37B - 58235 */ E37B_basic_warm_start_runstop_restore = $E37B
// BASIC warm start entry point
//
// .:E37B 20 CC FF JSR $FFCC       close input and output channels
// .:E37E A9 00    LDA #$00        clear A
// .:E380 85 13    STA $13         set current I/O channel, flag default
// .:E382 20 7A A6 JSR $A67A       flush BASIC stack and clear continue pointer
// .:E385 58       CLI             enable the interrupts
// .:E386 A2 80    LDX #$80        set -ve error, just do warm start
// .:E388 6C 00 03 JMP ($0300)     go handle error message, normally $E38B
// .:E38B 8A       TXA             copy the error number
// .:E38C 30 03    BMI $E391       if -ve go do warm start
// .:E38E 4C 3A A4 JMP $A43A       else do error #X then warm start
// .:E391 4C 74 A4 JMP $A474       do warm start

.label /* $E394 - 58260 */ E394_basic_cold_start = $E394
// BASIC cold start entry point
//
// .:E394 20 53 E4 JSR $E453       initialise the BASIC vector table
// .:E397 20 BF E3 JSR $E3BF       initialise the BASIC RAM locations
// .:E39A 20 22 E4 JSR $E422       print the start up message and initialise the memory
//	                               pointers
//	                               not ok ??
// .:E39D A2 FB    LDX #$FB        value for start stack
// .:E39F 9A       TXS             set stack pointer
// .:E3A0 D0 E4    BNE $E386       do "READY." warm start, branch always

.label /* $E3A2 - 58274 */ E3A2_chrget_for_zero_page = $E3A2
// character get subroutine for zero page
//
//                                 the target address for the LDA $EA60 becomes the BASIC execute pointer once the
//                                 block is copied to its destination, any non zero page address will do at assembly
//                                 time, to assemble a three byte instruction. $EA60 is RTS, NOP.
//                                 page 0 initialisation table from $0073
//                                 increment and scan memory
// .:E3A2 E6 7A    INC $7A         increment BASIC execute pointer low byte
// .:E3A4 D0 02    BNE $E3A8       branch if no carry
//                                 else
// .:E3A6 E6 7B    INC $7B         increment BASIC execute pointer high byte
//                                 page 0 initialisation table from $0079
//                                 scan memory
// .:E3A8 AD 60 EA LDA $EA60       get byte to scan, address set by call routine
// .:E3AB C9 3A    CMP #$3A        compare with ":"
// .:E3AD B0 0A    BCS $E3B9       exit if>=
//                                 page 0 initialisation table from $0080
//                                 clear Cb if numeric
// .:E3AF C9 20    CMP #$20        compare with " "
// .:E3B1 F0 EF    BEQ $E3A2       if " " go do next
// .:E3B3 38       SEC             set carry for SBC
// .:E3B4 E9 30    SBC #$30        subtract "0"
// .:E3B6 38       SEC             set carry for SBC
// .:E3B7 E9 D0    SBC #$D0        subtract -"0"
//                                 clear carry if byte = "0"-"9"
// .:E3B9 60       RTS

.label /* $E3BA - 58298 */ E3BA_rnd_seed_for_zero_page = $E3BA
// spare bytes, not referenced
//
// .:E3BA 80 4F C7 52 58           0.811635157

.label /* $E3BF - 58303 */ E3BF_initialize_basic_ram = $E3BF
// initialise BASIC RAM locations
//
// .:E3BF A9 4C    LDA #$4C        opcode for JMP
// .:E3C1 85 54    STA $54         save for functions vector jump
// .:E3C3 8D 10 03 STA $0310       save for USR() vector jump
//                                 set USR() vector to illegal quantity error
// .:E3C6 A9 48    LDA #$48        set USR() vector low byte
// .:E3C8 A0 B2    LDY #$B2        set USR() vector high byte
// .:E3CA 8D 11 03 STA $0311       save USR() vector low byte
// .:E3CD 8C 12 03 STY $0312       save USR() vector high byte
// .:E3D0 A9 91    LDA #$91        set fixed to float vector low byte
// .:E3D2 A0 B3    LDY #$B3        set fixed to float vector high byte
// .:E3D4 85 05    STA $05         save fixed to float vector low byte
// .:E3D6 84 06    STY $06         save fixed to float vector high byte
// .:E3D8 A9 AA    LDA #$AA        set float to fixed vector low byte
// .:E3DA A0 B1    LDY #$B1        set float to fixed vector high byte
// .:E3DC 85 03    STA $03         save float to fixed vector low byte
// .:E3DE 84 04    STY $04         save float to fixed vector high byte
//                                 copy the character get subroutine from $E3A2 to $0074
// .:E3E0 A2 1C    LDX #$1C        set the byte count
// .:E3E2 BD A2 E3 LDA $E3A2,X     get a byte from the table
// .:E3E5 95 73    STA $73,X       save the byte in page zero
// .:E3E7 CA       DEX             decrement the count
// .:E3E8 10 F8    BPL $E3E2       loop if not all done
//                                 clear descriptors, strings, program area and mamory pointers
// .:E3EA A9 03    LDA #$03        set the step size, collecting descriptors
// .:E3EC 85 53    STA $53         save the garbage collection step size
// .:E3EE A9 00    LDA #$00        clear A
// .:E3F0 85 68    STA $68         clear FAC1 overflow byte
// .:E3F2 85 13    STA $13         clear the current I/O channel, flag default
// .:E3F4 85 18    STA $18         clear the current descriptor stack item pointer high byte
// .:E3F6 A2 01    LDX #$01        set X
// .:E3F8 8E FD 01 STX $01FD       set the chain link pointer low byte
// .:E3FB 8E FC 01 STX $01FC       set the chain link pointer high byte
// .:E3FE A2 19    LDX #$19        initial the value for descriptor stack
// .:E400 86 16    STX $16         set descriptor stack pointer
// .:E402 38       SEC             set Cb = 1 to read the bottom of memory
// .:E403 20 9C FF JSR $FF9C       read/set the bottom of memory
// .:E406 86 2B    STX $2B         save the start of memory low byte
// .:E408 84 2C    STY $2C         save the start of memory high byte
// .:E40A 38       SEC             set Cb = 1 to read the top of memory
// .:E40B 20 99 FF JSR $FF99       read/set the top of memory
// .:E40E 86 37    STX $37         save the end of memory low byte
// .:E410 84 38    STY $38         save the end of memory high byte
// .:E412 86 33    STX $33         set the bottom of string space low byte
// .:E414 84 34    STY $34         set the bottom of string space high byte
// .:E416 A0 00    LDY #$00        clear the index
// .:E418 98       TYA             clear the A
// .:E419 91 2B    STA ($2B),Y     clear the the first byte of memory
// .:E41B E6 2B    INC $2B         increment the start of memory low byte
// .:E41D D0 02    BNE $E421       if no rollover skip the high byte increment
// .:E41F E6 2C    INC $2C         increment start of memory high byte
// .:E421 60       RTS

.label /* $E422 - 58402 */ E422_output_power_up_message = $E422
// print the start up message and initialise the memory pointers
//
// .:E422 A5 2B    LDA $2B         get the start of memory low byte
// .:E424 A4 2C    LDY $2C         get the start of memory high byte
// .:E426 20 08 A4 JSR $A408       check available memory, do out of memory error if no room
// .:E429 A9 73    LDA #$73        set "**** COMMODORE 64 BASIC V2 ****" pointer low byte
// .:E42B A0 E4    LDY #$E4        set "**** COMMODORE 64 BASIC V2 ****" pointer high byte
// .:E42D 20 1E AB JSR $AB1E       print a null terminated string
// .:E430 A5 37    LDA $37         get the end of memory low byte
// .:E432 38       SEC             set carry for subtract
// .:E433 E5 2B    SBC $2B         subtract the start of memory low byte
// .:E435 AA       TAX             copy the result to X
// .:E436 A5 38    LDA $38         get the end of memory high byte
// .:E438 E5 2C    SBC $2C         subtract the start of memory high byte
// .:E43A 20 CD BD JSR $BDCD       print XA as unsigned integer
// .:E43D A9 60    LDA #$60        set " BYTES FREE" pointer low byte
// .:E43F A0 E4    LDY #$E4        set " BYTES FREE" pointer high byte
// .:E441 20 1E AB JSR $AB1E       print a null terminated string
// .:E444 4C 44 A6 JMP $A644       do NEW, CLEAR, RESTORE and return

.label /* $E447 - 58439 */ E447_table_of_basic_vectors_for_0300 = $E447
// BASIC vectors, these are copied to RAM from $0300 onwards
//
// .:E447 8B E3                    error message          $0300
// .:E449 83 A4                    BASIC warm start       $0302
// .:E44B 7C A5                    crunch BASIC tokens    $0304
// .:E44D 1A A7                    uncrunch BASIC tokens  $0306
// .:E44F E4 A7                    start new BASIC code   $0308
// .:E451 86 AE                    get arithmetic element $030A

.label /* $E453 - 58451 */ E453_initialize_vectors = $E453
// initialise the BASIC vectors
//
// .:E453 A2 0B    LDX #$0B        set byte count
// .:E455 BD 47 E4 LDA $E447,X     get byte from table
// .:E458 9D 00 03 STA $0300,X     save byte to RAM
// .:E45B CA       DEX             decrement index
// .:E45C 10 F7    BPL $E455       loop if more to do
// .:E45E 60       RTS

.label /* $E45F - 58463 */ E45F_power_up_message = $E45F
// BASIC startup messages
//
// .:E45F 00 20 42 41 53 49 43 20  basic bytes free
// .:E467 42 59 54 45 53 20 46 52
// .:E46F 45 45 0D 00 93 0D 20 20
// .:E473 93 0D 20 20 20 20 2A 2A  (clr) **** commodore 64 basic v2 ****
// .:E47B 2A 2A 20 43 4F 4D 4D 4F  (cr) (cr) 64k ram system
// .:E483 44 4F 52 45 20 36 34 20
// .:E48B 42 41 53 49 43 20 56 32
// .:E493 20 2A 2A 2A 2A 0D 0D 20
// .:E49B 36 34 4B 20 52 41 4D 20
// .:E4A3 53 59 53 54 45 4D 20 20
// .:E4AB 00

.label /* $E4AC - 58540 */ E4AC_version_indicator = $E4AC
// unused
//
// .:E4AC 5C

.label /* $E4AD - 58541 */ E4AD_patch_for_basic_call_to_chkout = $E4AD
// open channel for output
//
// .:E4AD 48       PHA             save the flag byte
// .:E4AE 20 C9 FF JSR $FFC9       open channel for output
// .:E4B1 AA       TAX             copy the returned flag byte
// .:E4B2 68       PLA             restore the alling flag byte
// .:E4B3 90 01    BCC $E4B6       if there is no error skip copying the error flag
// .:E4B5 8A       TXA             else copy the error flag
// .:E4B6 60       RTS

.label /* $E4B7 - 58551 */ E4B7_unused_bytes_for_future_patches = $E4B7
// unused bytes
//
// .:E4B7 AA AA AA AA AA AA AA AA
// .:E4BF AA AA AA AA AA AA AA AA
// .:E4C7 AA AA AA AA AA AA AA AA
// .:E4CF AA AA AA AA AA

.label /* $E4D3 - 58579 */ E4D3_patch_for_rs232_routines = $E4D3
// flag the RS232 start bit and set the parity
//
// .:E4D3 85 A9    STA $A9         save the start bit check flag, set start bit received
// .:E4D5 A9 01    LDA #$01        set the initial parity state
// .:E4D7 85 AB    STA $AB         save the receiver parity bit
// .:E4D9 60       RTS

.label /* $E4DA - 58586 */ E4DA_reset_character_color = $E4DA
// save the current colour to the colour RAM
//
// .:E4DA AD 21 D0 LDA $D021       get the current colour code
// .:E4DD 91 F3    STA ($F3),Y     save it to the colour RAM
// .:E4DF 60       RTS

.label /* $E4E0 - 58592 */ E4E0_pause_after_finding_tape_file = $E4E0
// wait ~8.5 seconds for any key from the STOP key column
//
// .:E4E0 69 02    ADC #$02        set the number of jiffies to wait
// .:E4E2 A4 91    LDY $91         read the stop key column
// .:E4E4 C8       INY             test for $FF, no keys pressed
// .:E4E5 D0 04    BNE $E4EB       if any keys were pressed just exit
// .:E4E7 C5 A1    CMP $A1         compare the wait time with the jiffy clock mid byte
// .:E4E9 D0 F7    BNE $E4E2       if not there yet go wait some more
// .:E4EB 60       RTS

.label /* $E4EC - 58604 */ E4EC_rs232_timing_table_pal = $E4EC
// baud rate tables for PAL C64
//                                baud rate word is calculated from ..
//                                (system clock / baud rate) / 2 - 100
//
//                                    system clock
//                                    ------------
//                                PAL       985248 Hz
//                                NTSC     1022727 Hz
// .:E4EC 19 26                      50   baud   985300
// .:E4EE 44 19                      75   baud   985200
// .:E4F0 1A 11                     110   baud   985160
// .:E4F2 E8 0D                     134.5 baud   984540
// .:E4F4 70 0C                     150   baud   985200
// .:E4F6 06 06                     300   baud   985200
// .:E4F8 D1 02                     600   baud   985200
// .:E4FA 37 01                    1200   baud   986400
// .:E4FC AE 00                    1800   baud   986400
// .:E4FE 69 00                    2400   baud   984000

.label /* $E500 - 58624 */ E500_get_io_address = $E500
// return the base address of the I/O devices
//
// .:E500 A2 00    LDX #$00        get the I/O base address low byte
// .:E502 A0 DC    LDY #$DC        get the I/O base address high byte
// .:E504 60       RTS

.label /* $E505 - 58629 */ E505_get_screen_size = $E505
// return the x,y organization of the screen
//
// .:E505 A2 28    LDX #$28        get the x size
// .:E507 A0 19    LDY #$19        get the y size
// .:E509 60       RTS

.label /* $E50A - 58634 */ E50A_put_get_row_and_column = $E50A
// read/set the x,y cursor position
//
// .:E50A B0 07    BCS $E513       if read cursor go do read
// .:E50C 86 D6    STX $D6         save the cursor row
// .:E50E 84 D3    STY $D3         save the cursor column
// .:E510 20 6C E5 JSR $E56C       set the screen pointers for the cursor row, column
// .:E513 A6 D6    LDX $D6         get the cursor row
// .:E515 A4 D3    LDY $D3         get the cursor column
// .:E517 60       RTS

.label /* $E518 - 58648 */ E518_initialize_io = $E518
// initialise the screen and keyboard
//
// .:E518 20 A0 E5 JSR $E5A0       initialise the vic chip
// .:E51B A9 00    LDA #$00        clear A
// .:E51D 8D 91 02 STA $0291       clear the shift mode switch
// .:E520 85 CF    STA $CF         clear the cursor blink phase
// .:E522 A9 48    LDA #$48        get the keyboard decode logic pointer low byte
// .:E524 8D 8F 02 STA $028F       save the keyboard decode logic pointer low byte
// .:E527 A9 EB    LDA #$EB        get the keyboard decode logic pointer high byte
// .:E529 8D 90 02 STA $0290       save the keyboard decode logic pointer high byte
// .:E52C A9 0A    LDA #$0A        set the maximum size of the keyboard buffer
// .:E52E 8D 89 02 STA $0289       save the maximum size of the keyboard buffer
// .:E531 8D 8C 02 STA $028C       save the repeat delay counter
// .:E534 A9 0E    LDA #$0E        set light blue
// .:E536 8D 86 02 STA $0286       save the current colour code
// .:E539 A9 04    LDA #$04        speed 4
// .:E53B 8D 8B 02 STA $028B       save the repeat speed counter
// .:E53E A9 0C    LDA #$0C        set the cursor flash timing
// .:E540 85 CD    STA $CD         save the cursor timing countdown
// .:E542 85 CC    STA $CC         save the cursor enable, $00 = flash cursor

.label /* $E544 - 58692 */ E544_clear_screen = $E544
// clear the screen
//
// .:E544 AD 88 02 LDA $0288       get the screen memory page
// .:E547 09 80    ORA #$80        set the high bit, flag every line is a logical line start
// .:E549 A8       TAY             copy to Y
// .:E54A A9 00    LDA #$00        clear the line start low byte
// .:E54C AA       TAX             clear the index
// .:E54D 94 D9    STY $D9,X       save the start of line X pointer high byte
// .:E54F 18       CLC             clear carry for add
// .:E550 69 28    ADC #$28        add the line length to the low byte
// .:E552 90 01    BCC $E555       if no rollover skip the high byte increment
// .:E554 C8       INY             else increment the high byte
// .:E555 E8       INX             increment the line index
// .:E556 E0 1A    CPX #$1A        compare it with the number of lines + 1
// .:E558 D0 F3    BNE $E54D       loop if not all done
// .:E55A A9 FF    LDA #$FF        set the end of table marker
// .:E55C 95 D9    STA $D9,X       mark the end of the table
// .:E55E A2 18    LDX #$18        set the line count, 25 lines to do, 0 to 24
// .:E560 20 FF E9 JSR $E9FF       clear screen line X
// .:E563 CA       DEX             decrement the count
// .:E564 10 FA    BPL $E560       loop if more to do

.label /* $E566 - 58726 */ E566_home_cursor = $E566
// home the cursor
//
// .:E566 A0 00    LDY #$00        clear Y
// .:E568 84 D3    STY $D3         clear the cursor column
// .:E56A 84 D6    STY $D6         clear the cursor row

.label /* $E56C - 58732 */ E56C_set_screen_pointers = $E56C
// set screen pointers for cursor row, column
//
// .:E56C A6 D6    LDX $D6         get the cursor row
// .:E56E A5 D3    LDA $D3         get the cursor column
// .:E570 B4 D9    LDY $D9,X       get start of line X pointer high byte
// .:E572 30 08    BMI $E57C       if it is the logical line start continue
// .:E574 18       CLC             else clear carry for add
// .:E575 69 28    ADC #$28        add one line length
// .:E577 85 D3    STA $D3         save the cursor column
// .:E579 CA       DEX             decrement the cursor row
// .:E57A 10 F4    BPL $E570       loop, branch always
// .:E57C 20 F0 E9 JSR $E9F0       fetch a screen address
// .:E57F A9 27    LDA #$27        set the line length
// .:E581 E8       INX             increment the cursor row
// .:E582 B4 D9    LDY $D9,X       get the start of line X pointer high byte
// .:E584 30 06    BMI $E58C       if logical line start exit
// .:E586 18       CLC             else clear carry for add
// .:E587 69 28    ADC #$28        add one line length to the current line length
// .:E589 E8       INX             increment the cursor row
// .:E58A 10 F6    BPL $E582       loop, branch always
// .:E58C 85 D5    STA $D5         save current screen line length
// .:E58E 4C 24 EA JMP $EA24       calculate the pointer to colour RAM and return
// .:E591 E4 C9    CPX $C9         compare it with the input cursor row
// .:E593 F0 03    BEQ $E598       if there just exit
// .:E595 4C ED E6 JMP $E6ED       else go ??
// .:E598 60       RTS
//
// orphan bytes ??
//
// .:E599 EA       NOP             huh

.label /* $E59A - 58778 */ E59A_set_io_defaults_unused_entry = $E59A
// .:E59A 20 A0 E5 JSR $E5A0       initialise the vic chip
// .:E59D 4C 66 E5 JMP $E566       home the cursor and return

.label /* $E5A0 - 58784 */ E5A0_set_io_defaults = $E5A0
// initialise the vic chip
//
// .:E5A0 A9 03    LDA #$03        set the screen as the output device
// .:E5A2 85 9A    STA $9A         save the output device number
// .:E5A4 A9 00    LDA #$00        set the keyboard as the input device
// .:E5A6 85 99    STA $99         save the input device number
// .:E5A8 A2 2F    LDX #$2F        set the count/index
// .:E5AA BD B8 EC LDA $ECB8,X     get a vic ii chip initialisation value
// .:E5AD 9D FF CF STA $CFFF,X     save it to the vic ii chip
// .:E5B0 CA       DEX             decrement the count/index
// .:E5B1 D0 F7    BNE $E5AA       loop if more to do
// .:E5B3 60       RTS

.label /* $E5B4 - 58804 */ E5B4_get_character_from_keyboard_buffer = $E5B4
// input from the keyboard buffer
//
// .:E5B4 AC 77 02 LDY $0277       get the current character from the buffer
// .:E5B7 A2 00    LDX #$00        clear the index
// .:E5B9 BD 78 02 LDA $0278,X     get the next character,X from the buffer
// .:E5BC 9D 77 02 STA $0277,X     save it as the current character,X in the buffer
// .:E5BF E8       INX             increment the index
// .:E5C0 E4 C6    CPX $C6         compare it with the keyboard buffer index
// .:E5C2 D0 F5    BNE $E5B9       loop if more to do
// .:E5C4 C6 C6    DEC $C6         decrement keyboard buffer index
// .:E5C6 98       TYA             copy the key to A
// .:E5C7 58       CLI             enable the interrupts
// .:E5C8 18       CLC             flag got byte
// .:E5C9 60       RTS

.label /* $E5CA - 58826 */ E5CA_input_from_keyboard = $E5CA
// write character and wait for key
//
// .:E5CA 20 16 E7 JSR $E716       output character
//
// wait for a key from the keyboard
//
// .:E5CD A5 C6    LDA $C6         get the keyboard buffer index
// .:E5CF 85 CC    STA $CC         cursor enable, $00 = flash cursor, $xx = no flash
// .:E5D1 8D 92 02 STA $0292       screen scrolling flag, $00 = scroll, $xx = no scroll
//                                 this disables both the cursor flash and the screen scroll
//                                 while there are characters in the keyboard buffer
// .:E5D4 F0 F7    BEQ $E5CD       loop if the buffer is empty
// .:E5D6 78       SEI             disable the interrupts
// .:E5D7 A5 CF    LDA $CF         get the cursor blink phase
// .:E5D9 F0 0C    BEQ $E5E7       if cursor phase skip the overwrite
//                                 else it is the character phase
// .:E5DB A5 CE    LDA $CE         get the character under the cursor
// .:E5DD AE 87 02 LDX $0287       get the colour under the cursor
// .:E5E0 A0 00    LDY #$00        clear Y
// .:E5E2 84 CF    STY $CF         clear the cursor blink phase
// .:E5E4 20 13 EA JSR $EA13       print character A and colour X
// .:E5E7 20 B4 E5 JSR $E5B4       input from the keyboard buffer
// .:E5EA C9 83    CMP #$83        compare with [SHIFT][RUN]
// .:E5EC D0 10    BNE $E5FE       if not [SHIFT][RUN] skip the buffer fill
//                                 keys are [SHIFT][RUN] so put "LOAD",$0D,"RUN",$0D into
//                                 the buffer
// .:E5EE A2 09    LDX #$09        set the byte count
// .:E5F0 78       SEI             disable the interrupts
// .:E5F1 86 C6    STX $C6         set the keyboard buffer index
// .:E5F3 BD E6 EC LDA $ECE6,X     get byte from the auto load/run table
// .:E5F6 9D 76 02 STA $0276,X     save it to the keyboard buffer
// .:E5F9 CA       DEX             decrement the count/index
// .:E5FA D0 F7    BNE $E5F3       loop while more to do
// .:E5FC F0 CF    BEQ $E5CD       loop for the next key, branch always
//                                 was not [SHIFT][RUN]
// .:E5FE C9 0D    CMP #$0D        compare the key with [CR]
// .:E600 D0 C8    BNE $E5CA       if not [CR] print the character and get the next key
//                                 else it was [CR]
// .:E602 A4 D5    LDY $D5         get the current screen line length
// .:E604 84 D0    STY $D0         input from keyboard or screen, $xx = screen,
//                                 $00 = keyboard
// .:E606 B1 D1    LDA ($D1),Y     get the character from the current screen line
// .:E608 C9 20    CMP #$20        compare it with [SPACE]
// .:E60A D0 03    BNE $E60F       if not [SPACE] continue
// .:E60C 88       DEY             else eliminate the space, decrement end of input line
// .:E60D D0 F7    BNE $E606       loop, branch always
// .:E60F C8       INY             increment past the last non space character on line
// .:E610 84 C8    STY $C8         save the input [EOL] pointer
// .:E612 A0 00    LDY #$00        clear A
// .:E614 8C 92 02 STY $0292       clear the screen scrolling flag, $00 = scroll
// .:E617 84 D3    STY $D3         clear the cursor column
// .:E619 84 D4    STY $D4         clear the cursor quote flag, $xx = quote, $00 = no quote
// .:E61B A5 C9    LDA $C9         get the input cursor row
// .:E61D 30 1B    BMI $E63A
// .:E61F A6 D6    LDX $D6         get the cursor row
// .:E621 20 ED E6 JSR $E6ED       find and set the pointers for the start of logical line
// .:E624 E4 C9    CPX $C9         compare with input cursor row
// .:E626 D0 12    BNE $E63A
// .:E628 A5 CA    LDA $CA         get the input cursor column
// .:E62A 85 D3    STA $D3         save the cursor column
// .:E62C C5 C8    CMP $C8         compare the cursor column with input [EOL] pointer
// .:E62E 90 0A    BCC $E63A       if less, cursor is in line, go ??
// .:E630 B0 2B    BCS $E65D       else the cursor is beyond the line end, branch always

.label /* $E632 - 58930 */ E632_input_from_screen_or_keyboard = $E632
// input from screen or keyboard
//
// .:E632 98       TYA             copy Y
// .:E633 48       PHA             save Y
// .:E634 8A       TXA             copy X
// .:E635 48       PHA             save X
// .:E636 A5 D0    LDA $D0         input from keyboard or screen, $xx = screen,
//                                 $00 = keyboard
// .:E638 F0 93    BEQ $E5CD       if keyboard go wait for key
// .:E63A A4 D3    LDY $D3         get the cursor column
// .:E63C B1 D1    LDA ($D1),Y     get character from the current screen line
// .:E63E 85 D7    STA $D7         save temporary last character
// .:E640 29 3F    AND #$3F        mask key bits
// .:E642 06 D7    ASL $D7         << temporary last character
// .:E644 24 D7    BIT $D7         test it
// .:E646 10 02    BPL $E64A       branch if not [NO KEY]
// .:E648 09 80    ORA #$80
// .:E64A 90 04    BCC $E650
// .:E64C A6 D4    LDX $D4         get the cursor quote flag, $xx = quote, $00 = no quote
// .:E64E D0 04    BNE $E654       if in quote mode go ??
// .:E650 70 02    BVS $E654
// .:E652 09 40    ORA #$40
// .:E654 E6 D3    INC $D3         increment the cursor column
// .:E656 20 84 E6 JSR $E684       if open quote toggle the cursor quote flag
// .:E659 C4 C8    CPY $C8         compare ?? with input [EOL] pointer
// .:E65B D0 17    BNE $E674       if not at line end go ??
// .:E65D A9 00    LDA #$00        clear A
// .:E65F 85 D0    STA $D0         clear input from keyboard or screen, $xx = screen,
//                                 $00 = keyboard
// .:E661 A9 0D    LDA #$0D        set character [CR]
// .:E663 A6 99    LDX $99         get the input device number
// .:E665 E0 03    CPX #$03        compare the input device with the screen
// .:E667 F0 06    BEQ $E66F       if screen go ??
// .:E669 A6 9A    LDX $9A         get the output device number
// .:E66B E0 03    CPX #$03        compare the output device with the screen
// .:E66D F0 03    BEQ $E672       if screen go ??
// .:E66F 20 16 E7 JSR $E716       output the character
// .:E672 A9 0D    LDA #$0D        set character [CR]
// .:E674 85 D7    STA $D7         save character
// .:E676 68       PLA             pull X
// .:E677 AA       TAX             restore X
// .:E678 68       PLA             pull Y
// .:E679 A8       TAY             restore Y
// .:E67A A5 D7    LDA $D7         restore character
// .:E67C C9 DE    CMP #$DE
// .:E67E D0 02    BNE $E682
// .:E680 A9 FF    LDA #$FF
// .:E682 18       CLC             flag ok
// .:E683 60       RTS

.label /* $E684 - 59012 */ E684_quotes_test = $E684
// if open quote toggle cursor quote flag
//
// .:E684 C9 22    CMP #$22        comapre byte with "
// .:E686 D0 08    BNE $E690       exit if not "
// .:E688 A5 D4    LDA $D4         get cursor quote flag, $xx = quote, $00 = no quote
// .:E68A 49 01    EOR #$01        toggle it
// .:E68C 85 D4    STA $D4         save cursor quote flag
// .:E68E A9 22    LDA #$22        restore the "
// .:E690 60       RTS

.label /* $E691 - 59025 */ E691_set_up_screen_print = $E691
// insert uppercase/graphic character
//
// .:E691 09 40    ORA #$40        change to uppercase/graphic
// .:E693 A6 C7    LDX $C7         get the reverse flag
// .:E695 F0 02    BEQ $E699       branch if not reverse
//                                 else ..
//                                 insert reversed character
// .:E697 09 80    ORA #$80        reverse character
// .:E699 A6 D8    LDX $D8         get the insert count
// .:E69B F0 02    BEQ $E69F       branch if none
// .:E69D C6 D8    DEC $D8         else decrement the insert count
// .:E69F AE 86 02 LDX $0286       get the current colour code
// .:E6A2 20 13 EA JSR $EA13       print character A and colour X
// .:E6A5 20 B6 E6 JSR $E6B6       advance the cursor
//                                 restore the registers, set the quote flag and exit
// .:E6A8 68       PLA             pull Y
// .:E6A9 A8       TAY             restore Y
// .:E6AA A5 D8    LDA $D8         get the insert count
// .:E6AC F0 02    BEQ $E6B0       skip quote flag clear if inserts to do
// .:E6AE 46 D4    LSR $D4         clear cursor quote flag, $xx = quote, $00 = no quote
// .:E6B0 68       PLA             pull X
// .:E6B1 AA       TAX             restore X
// .:E6B2 68       PLA             restore A
// .:E6B3 18       CLC
// .:E6B4 58       CLI             enable the interrupts
// .:E6B5 60       RTS

.label /* $E6B6 - 59062 */ E6B6_advance_cursor = $E6B6
// advance the cursor
//
// .:E6B6 20 B3 E8 JSR $E8B3       test for line increment
// .:E6B9 E6 D3    INC $D3         increment the cursor column
// .:E6BB A5 D5    LDA $D5         get current screen line length
// .:E6BD C5 D3    CMP $D3         compare ?? with the cursor column
// .:E6BF B0 3F    BCS $E700       exit if line length >= cursor column
// .:E6C1 C9 4F    CMP #$4F        compare with max length
// .:E6C3 F0 32    BEQ $E6F7       if at max clear column, back cursor up and do newline
// .:E6C5 AD 92 02 LDA $0292       get the autoscroll flag
// .:E6C8 F0 03    BEQ $E6CD       branch if autoscroll on
// .:E6CA 4C 67 E9 JMP $E967       else open space on screen
// .:E6CD A6 D6    LDX $D6         get the cursor row
// .:E6CF E0 19    CPX #$19        compare with max + 1
// .:E6D1 90 07    BCC $E6DA       if less than max + 1 go add this row to the current
//                                 logical line
// .:E6D3 20 EA E8 JSR $E8EA       else scroll the screen
// .:E6D6 C6 D6    DEC $D6         decrement the cursor row
// .:E6D8 A6 D6    LDX $D6         get the cursor row
//                                 add this row to the current logical line
// .:E6DA 16 D9    ASL $D9,X       shift start of line X pointer high byte
// .:E6DC 56 D9    LSR $D9,X       shift start of line X pointer high byte back,
//                                 make next screen line start of logical line, increment line length and set pointers
//                                 clear b7, start of logical line
// .:E6DE E8       INX             increment screen row
// .:E6DF B5 D9    LDA $D9,X       get start of line X pointer high byte
// .:E6E1 09 80    ORA #$80        mark as start of logical line
// .:E6E3 95 D9    STA $D9,X       set start of line X pointer high byte
// .:E6E5 CA       DEX             restore screen row
// .:E6E6 A5 D5    LDA $D5         get current screen line length
//                                 add one line length and set the pointers for the start of the line
// .:E6E8 18       CLC             clear carry for add
// .:E6E9 69 28    ADC #$28        add one line length
// .:E6EB 85 D5    STA $D5         save current screen line length

.label /* $E6ED - 59117 */ E6ED_retreat_cursor = $E6ED
// .:E6ED B5 D9    LDA $D9,X       get start of line X pointer high byte
// .:E6EF 30 03    BMI $E6F4       exit loop if start of logical line
// .:E6F1 CA       DEX             else back up one line
// .:E6F2 D0 F9    BNE $E6ED       loop if not on first line
// .:E6F4 4C F0 E9 JMP $E9F0       fetch a screen address
// .:E6F7 C6 D6    DEC $D6         decrement the cursor row
// .:E6F9 20 7C E8 JSR $E87C       do newline
// .:E6FC A9 00    LDA #$00        clear A
// .:E6FE 85 D3    STA $D3         clear the cursor column
// .:E700 60       RTS

.label /* $E701 - 59137 */ E701_back_on_to_previous_line = $E701
// back onto the previous line if possible
//
// .:E701 A6 D6    LDX $D6         get the cursor row
// .:E703 D0 06    BNE $E70B       branch if not top row
// .:E705 86 D3    STX $D3         clear cursor column
// .:E707 68       PLA             dump return address low byte
// .:E708 68       PLA             dump return address high byte
// .:E709 D0 9D    BNE $E6A8       restore registers, set quote flag and exit, branch always
// .:E70B CA       DEX             decrement the cursor row
// .:E70C 86 D6    STX $D6         save the cursor row
// .:E70E 20 6C E5 JSR $E56C       set the screen pointers for cursor row, column
// .:E711 A4 D5    LDY $D5         get current screen line length
// .:E713 84 D3    STY $D3         save the cursor column
// .:E715 60       RTS

.label /* $E716 - 59158 */ E716_output_to_screen = $E716
// output a character to the screen
//
// .:E716 48       PHA             save character
// .:E717 85 D7    STA $D7         save temporary last character
// .:E719 8A       TXA             copy X
// .:E71A 48       PHA             save X
// .:E71B 98       TYA             copy Y
// .:E71C 48       PHA             save Y
// .:E71D A9 00    LDA #$00        clear A
// .:E71F 85 D0    STA $D0         clear input from keyboard or screen, $xx = screen,
//                                 $00 = keyboard
// .:E721 A4 D3    LDY $D3         get cursor column
// .:E723 A5 D7    LDA $D7         restore last character
// .:E725 10 03    BPL $E72A       branch if unshifted
// .:E727 4C D4 E7 JMP $E7D4       do shifted characters and return

.label /* $E72A - 59178 */ E72A_unshifted_characters = $E72A
// .:E72A C9 0D    CMP #$0D        compare with [CR]
// .:E72C D0 03    BNE $E731       branch if not [CR]
// .:E72E 4C 91 E8 JMP $E891       else output [CR] and return
// .:E731 C9 20    CMP #$20        compare with [SPACE]
// .:E733 90 10    BCC $E745       branch if < [SPACE]
// .:E735 C9 60    CMP #$60
// .:E737 90 04    BCC $E73D       branch if $20 to $5F
//                                 character is $60 or greater
// .:E739 29 DF    AND #$DF
// .:E73B D0 02    BNE $E73F
// .:E73D 29 3F    AND #$3F
// .:E73F 20 84 E6 JSR $E684       if open quote toggle cursor direct/programmed flag
// .:E742 4C 93 E6 JMP $E693
//                                 character was < [SPACE] so is a control character
//                                 of some sort
// .:E745 A6 D8    LDX $D8         get the insert count
// .:E747 F0 03    BEQ $E74C       if no characters to insert continue
// .:E749 4C 97 E6 JMP $E697       insert reversed character
// .:E74C C9 14    CMP #$14        compare the character with [INSERT]/[DELETE]
// .:E74E D0 2E    BNE $E77E       if not [INSERT]/[DELETE] go ??
// .:E750 98       TYA
// .:E751 D0 06    BNE $E759
// .:E753 20 01 E7 JSR $E701       back onto the previous line if possible
// .:E756 4C 73 E7 JMP $E773
// .:E759 20 A1 E8 JSR $E8A1       test for line decrement
//                                 now close up the line
// .:E75C 88       DEY             decrement index to previous character
// .:E75D 84 D3    STY $D3         save the cursor column
// .:E75F 20 24 EA JSR $EA24       calculate the pointer to colour RAM
// .:E762 C8       INY             increment index to next character
// .:E763 B1 D1    LDA ($D1),Y     get character from current screen line
// .:E765 88       DEY             decrement index to previous character
// .:E766 91 D1    STA ($D1),Y     save character to current screen line
// .:E768 C8       INY             increment index to next character
// .:E769 B1 F3    LDA ($F3),Y     get colour RAM byte
// .:E76B 88       DEY             decrement index to previous character
// .:E76C 91 F3    STA ($F3),Y     save colour RAM byte
// .:E76E C8       INY             increment index to next character
// .:E76F C4 D5    CPY $D5         compare with current screen line length
// .:E771 D0 EF    BNE $E762       loop if not there yet
// .:E773 A9 20    LDA #$20        set [SPACE]
// .:E775 91 D1    STA ($D1),Y     clear last character on current screen line
// .:E777 AD 86 02 LDA $0286       get the current colour code
// .:E77A 91 F3    STA ($F3),Y     save to colour RAM
// .:E77C 10 4D    BPL $E7CB       branch always
// .:E77E A6 D4    LDX $D4         get cursor quote flag, $xx = quote, $00 = no quote
// .:E780 F0 03    BEQ $E785       branch if not quote mode
// .:E782 4C 97 E6 JMP $E697       insert reversed character
// .:E785 C9 12    CMP #$12        compare with [RVS ON]
// .:E787 D0 02    BNE $E78B       if not [RVS ON] skip setting the reverse flag
// .:E789 85 C7    STA $C7         else set the reverse flag
// .:E78B C9 13    CMP #$13        compare with [CLR HOME]
// .:E78D D0 03    BNE $E792       if not [CLR HOME] continue
// .:E78F 20 66 E5 JSR $E566       home the cursor
// .:E792 C9 1D    CMP #$1D        compare with [CURSOR RIGHT]
// .:E794 D0 17    BNE $E7AD       if not [CURSOR RIGHT] go ??
// .:E796 C8       INY             increment the cursor column
// .:E797 20 B3 E8 JSR $E8B3       test for line increment
// .:E79A 84 D3    STY $D3         save the cursor column
// .:E79C 88       DEY             decrement the cursor column
// .:E79D C4 D5    CPY $D5         compare cursor column with current screen line length
// .:E79F 90 09    BCC $E7AA       exit if less
//                                 else the cursor column is >= the current screen line
//                                 length so back onto the current line and do a newline
// .:E7A1 C6 D6    DEC $D6         decrement the cursor row
// .:E7A3 20 7C E8 JSR $E87C       do newline
// .:E7A6 A0 00    LDY #$00        clear cursor column
// .:E7A8 84 D3    STY $D3         save the cursor column
// .:E7AA 4C A8 E6 JMP $E6A8       restore the registers, set the quote flag and exit
// .:E7AD C9 11    CMP #$11        compare with [CURSOR DOWN]
// .:E7AF D0 1D    BNE $E7CE       if not [CURSOR DOWN] go ??
// .:E7B1 18       CLC             clear carry for add
// .:E7B2 98       TYA             copy the cursor column
// .:E7B3 69 28    ADC #$28        add one line
// .:E7B5 A8       TAY             copy back to Y
// .:E7B6 E6 D6    INC $D6         increment the cursor row
// .:E7B8 C5 D5    CMP $D5         compare cursor column with current screen line length
// .:E7BA 90 EC    BCC $E7A8       if less go save cursor column and exit
// .:E7BC F0 EA    BEQ $E7A8       if equal go save cursor column and exit
//                                 else the cursor has moved beyond the end of this line
//                                 so back it up until it's on the start of the logical line
// .:E7BE C6 D6    DEC $D6         decrement the cursor row
// .:E7C0 E9 28    SBC #$28        subtract one line
// .:E7C2 90 04    BCC $E7C8       if on previous line exit the loop
// .:E7C4 85 D3    STA $D3         else save the cursor column
// .:E7C6 D0 F8    BNE $E7C0       loop if not at the start of the line
// .:E7C8 20 7C E8 JSR $E87C       do newline
// .:E7CB 4C A8 E6 JMP $E6A8       restore the registers, set the quote flag and exit
// .:E7CE 20 CB E8 JSR $E8CB       set the colour code
// .:E7D1 4C 44 EC JMP $EC44       go check for special character codes

.label /* $E7D4 - 59348 */ E7D4_shifted_characters = $E7D4
// .:E7D4 29 7F    AND #$7F        mask 0xxx xxxx, clear b7
// .:E7D6 C9 7F    CMP #$7F        was it $FF before the mask
// .:E7D8 D0 02    BNE $E7DC       branch if not
// .:E7DA A9 5E    LDA #$5E        else make it $5E
// .:E7DC C9 20    CMP #$20        compare the character with [SPACE]
// .:E7DE 90 03    BCC $E7E3       if < [SPACE] go ??
// .:E7E0 4C 91 E6 JMP $E691       insert uppercase/graphic character and return
//                                 character was $80 to $9F and is now $00 to $1F
// .:E7E3 C9 0D    CMP #$0D        compare with [CR]
// .:E7E5 D0 03    BNE $E7EA       if not [CR] continue
// .:E7E7 4C 91 E8 JMP $E891       else output [CR] and return
//                                 was not [CR]
// .:E7EA A6 D4    LDX $D4         get the cursor quote flag, $xx = quote, $00 = no quote
// .:E7EC D0 3F    BNE $E82D       branch if quote mode
// .:E7EE C9 14    CMP #$14        compare with [INSERT DELETE]
// .:E7F0 D0 37    BNE $E829       if not [INSERT DELETE] go ??
// .:E7F2 A4 D5    LDY $D5         get current screen line length
// .:E7F4 B1 D1    LDA ($D1),Y     get character from current screen line
// .:E7F6 C9 20    CMP #$20        compare the character with [SPACE]
// .:E7F8 D0 04    BNE $E7FE       if not [SPACE] continue
// .:E7FA C4 D3    CPY $D3         compare the current column with the cursor column
// .:E7FC D0 07    BNE $E805       if not cursor column go open up space on line
// .:E7FE C0 4F    CPY #$4F        compare current column with max line length
// .:E800 F0 24    BEQ $E826       if at line end just exit
// .:E802 20 65 E9 JSR $E965       else open up a space on the screen
//                                 now open up space on the line to insert a character
// .:E805 A4 D5    LDY $D5         get current screen line length
// .:E807 20 24 EA JSR $EA24       calculate the pointer to colour RAM
// .:E80A 88       DEY             decrement the index to previous character
// .:E80B B1 D1    LDA ($D1),Y     get the character from the current screen line
// .:E80D C8       INY             increment the index to next character
// .:E80E 91 D1    STA ($D1),Y     save the character to the current screen line
// .:E810 88       DEY             decrement the index to previous character
// .:E811 B1 F3    LDA ($F3),Y     get the current screen line colour RAM byte
// .:E813 C8       INY             increment the index to next character
// .:E814 91 F3    STA ($F3),Y     save the current screen line colour RAM byte
// .:E816 88       DEY             decrement the index to the previous character
// .:E817 C4 D3    CPY $D3         compare the index with the cursor column
// .:E819 D0 EF    BNE $E80A       loop if not there yet
// .:E81B A9 20    LDA #$20        set [SPACE]
// .:E81D 91 D1    STA ($D1),Y     clear character at cursor position on current screen line
// .:E81F AD 86 02 LDA $0286       get current colour code
// .:E822 91 F3    STA ($F3),Y     save to cursor position on current screen line colour RAM
// .:E824 E6 D8    INC $D8         increment insert count
// .:E826 4C A8 E6 JMP $E6A8       restore the registers, set the quote flag and exit
// .:E829 A6 D8    LDX $D8         get the insert count
// .:E82B F0 05    BEQ $E832       branch if no insert space
// .:E82D 09 40    ORA #$40        change to uppercase/graphic
// .:E82F 4C 97 E6 JMP $E697       insert reversed character
// .:E832 C9 11    CMP #$11        compare with [CURSOR UP]
// .:E834 D0 16    BNE $E84C       branch if not [CURSOR UP]
// .:E836 A6 D6    LDX $D6         get the cursor row
// .:E838 F0 37    BEQ $E871       if on the top line go restore the registers, set the
//                                 quote flag and exit
// .:E83A C6 D6    DEC $D6         decrement the cursor row
// .:E83C A5 D3    LDA $D3         get the cursor column
// .:E83E 38       SEC             set carry for subtract
// .:E83F E9 28    SBC #$28        subtract one line length
// .:E841 90 04    BCC $E847       branch if stepped back to previous line
// .:E843 85 D3    STA $D3         else save the cursor column ..
// .:E845 10 2A    BPL $E871       .. and exit, branch always
// .:E847 20 6C E5 JSR $E56C       set the screen pointers for cursor row, column ..
// .:E84A D0 25    BNE $E871       .. and exit, branch always
// .:E84C C9 12    CMP #$12        compare with [RVS OFF]
// .:E84E D0 04    BNE $E854       if not [RVS OFF] continue
// .:E850 A9 00    LDA #$00        else clear A
// .:E852 85 C7    STA $C7         clear the reverse flag
// .:E854 C9 1D    CMP #$1D        compare with [CURSOR LEFT]
// .:E856 D0 12    BNE $E86A       if not [CURSOR LEFT] go ??
// .:E858 98       TYA             copy the cursor column
// .:E859 F0 09    BEQ $E864       if at start of line go back onto the previous line
// .:E85B 20 A1 E8 JSR $E8A1       test for line decrement
// .:E85E 88       DEY             decrement the cursor column
// .:E85F 84 D3    STY $D3         save the cursor column
// .:E861 4C A8 E6 JMP $E6A8       restore the registers, set the quote flag and exit
// .:E864 20 01 E7 JSR $E701       back onto the previous line if possible
// .:E867 4C A8 E6 JMP $E6A8       restore the registers, set the quote flag and exit
// .:E86A C9 13    CMP #$13        compare with [CLR]
// .:E86C D0 06    BNE $E874       if not [CLR] continue
// .:E86E 20 44 E5 JSR $E544       clear the screen
// .:E871 4C A8 E6 JMP $E6A8       restore the registers, set the quote flag and exit
// .:E874 09 80    ORA #$80        restore b7, colour can only be black, cyan, magenta
//                                 or yellow
// .:E876 20 CB E8 JSR $E8CB       set the colour code
// .:E879 4C 4F EC JMP $EC4F       go check for special character codes except fro switch
//                                 to lower case

.label /* $E87C - 59516 */ E87C_go_to_next_line = $E87C
// do newline
//
// .:E87C 46 C9    LSR $C9         shift >> input cursor row
// .:E87E A6 D6    LDX $D6         get the cursor row
// .:E880 E8       INX             increment the row
// .:E881 E0 19    CPX #$19        compare it with last row + 1
// .:E883 D0 03    BNE $E888       if not last row + 1 skip the screen scroll
// .:E885 20 EA E8 JSR $E8EA       else scroll the screen
// .:E888 B5 D9    LDA $D9,X       get start of line X pointer high byte
// .:E88A 10 F4    BPL $E880       loop if not start of logical line
// .:E88C 86 D6    STX $D6         save the cursor row
// .:E88E 4C 6C E5 JMP $E56C       set the screen pointers for cursor row, column and return

.label /* $E891 - 59537 */ E891_output_cr = $E891
// output [CR]
//
// .:E891 A2 00    LDX #$00        clear X
// .:E893 86 D8    STX $D8         clear the insert count
// .:E895 86 C7    STX $C7         clear the reverse flag
// .:E897 86 D4    STX $D4         clear the cursor quote flag, $xx = quote, $00 = no quote
// .:E899 86 D3    STX $D3         save the cursor column
// .:E89B 20 7C E8 JSR $E87C       do newline
// .:E89E 4C A8 E6 JMP $E6A8       restore the registers, set the quote flag and exit

.label /* $E8A1 - 59553 */ E8A1_check_line_decrement = $E8A1
// test for line decrement
//
// .:E8A1 A2 02    LDX #$02        set the count
// .:E8A3 A9 00    LDA #$00        set the column
// .:E8A5 C5 D3    CMP $D3         compare the column with the cursor column
// .:E8A7 F0 07    BEQ $E8B0       if at the start of the line go decrement the cursor row
//	                                and exit
// .:E8A9 18       CLC             else clear carry for add
// .:E8AA 69 28    ADC #$28        increment to next line
// .:E8AC CA       DEX             decrement loop count
// .:E8AD D0 F6    BNE $E8A5       loop if more to test
// .:E8AF 60       RTS
// .:E8B0 C6 D6    DEC $D6         else decrement the cursor row
// .:E8B2 60       RTS

.label /* $E8B3 - 59571 */ E8B3_check_line_increment = $E8B3
// test for line increment
//
//	                               if at end of the line, but not at end of the last line, increment the cursor row
// .:E8B3 A2 02    LDX #$02        set the count
// .:E8B5 A9 27    LDA #$27        set the column
// .:E8B7 C5 D3    CMP $D3         compare the column with the cursor column
// .:E8B9 F0 07    BEQ $E8C2       if at end of line test and possibly increment cursor row
// .:E8BB 18       CLC             else clear carry for add
// .:E8BC 69 28    ADC #$28        increment to the next line
// .:E8BE CA       DEX             decrement the loop count
// .:E8BF D0 F6    BNE $E8B7       loop if more to test
// .:E8C1 60       RTS
//                                 cursor is at end of line
// .:E8C2 A6 D6    LDX $D6         get the cursor row
// .:E8C4 E0 19    CPX #$19        compare it with the end of the screen
// .:E8C6 F0 02    BEQ $E8CA       if at the end of screen just exit
// .:E8C8 E6 D6    INC $D6         else increment the cursor row
// .:E8CA 60       RTS

.label /* $E8CB - 59595 */ E8CB_set_color_code = $E8CB
// set the colour code. enter with the colour character in A. if A does not contain a
//
//                                 colour character this routine exits without changing the colour
// .:E8CB A2 0F    LDX #$0F
//	                               set the colour code count
// .:E8CD DD DA E8 CMP $E8DA,X     compare the character with a table code
// .:E8D0 F0 04    BEQ $E8D6       if a match go save the colour and exit
// .:E8D2 CA       DEX             else decrement the index
// .:E8D3 10 F8    BPL $E8CD       loop if more to do
// .:E8D5 60       RTS
// .:E8D6 8E 86 02 STX $0286       save the current colour code
// .:E8D9 60       RTS

.label /* $E8DA - 59610 */ E8DA_color_code_table = $E8DA
// ASCII colour code table
//
//                                 CHR$()  colour
//                                 ------  ------
// .:E8DA 90                        144    black
// .:E8DB 05                          5    white
// .:E8DC 1C                         28    red
// .:E8DD 9F                        159    cyan
// .:E8DE 9C                        156    purple
// .:E8DF 1E                         30    green
// .:E8E0 1F                         31    blue
// .:E8E1 9E                        158    yellow
// .:E8E2 81                        129    orange
// .:E8E3 95                        149    brown
// .:E8E4 96                        150    light red
// .:E8E5 97                        151    dark grey
// .:E8E6 98                        152    medium grey
// .:E8E7 99                        153    light green
// .:E8E8 9A                        154    light blue
// .:E8E9 9B                        155    light grey

.label /* $E8EA - 59626 */ E8EA_scroll_screen = $E8EA
// scroll the screen
//
// .:E8EA A5 AC    LDA $AC         copy the tape buffer start pointer
// .:E8EC 48       PHA             save it
// .:E8ED A5 AD    LDA $AD         copy the tape buffer start pointer
// .:E8EF 48       PHA             save it
// .:E8F0 A5 AE    LDA $AE         copy the tape buffer end pointer
// .:E8F2 48       PHA             save it
// .:E8F3 A5 AF    LDA $AF         copy the tape buffer end pointer
// .:E8F5 48       PHA             save it
// .:E8F6 A2 FF    LDX #$FF        set to -1 for pre increment loop
// .:E8F8 C6 D6    DEC $D6         decrement the cursor row
// .:E8FA C6 C9    DEC $C9         decrement the input cursor row
// .:E8FC CE A5 02 DEC $02A5       decrement the screen row marker
// .:E8FF E8       INX             increment the line number
// .:E900 20 F0 E9 JSR $E9F0       fetch a screen address, set the start of line X
// .:E903 E0 18    CPX #$18        compare with last line
// .:E905 B0 0C    BCS $E913       branch if >= $16
// .:E907 BD F1 EC LDA $ECF1,X     get the start of the next line pointer low byte
// .:E90A 85 AC    STA $AC         save the next line pointer low byte
// .:E90C B5 DA    LDA $DA,X       get the start of the next line pointer high byte
// .:E90E 20 C8 E9 JSR $E9C8       shift the screen line up
// .:E911 30 EC    BMI $E8FF       loop, branch always
// .:E913 20 FF E9 JSR $E9FF       clear screen line X
//                                 now shift up the start of logical line bits
// .:E916 A2 00    LDX #$00        clear index
// .:E918 B5 D9    LDA $D9,X       get the start of line X pointer high byte
// .:E91A 29 7F    AND #$7F        clear the line X start of logical line bit
// .:E91C B4 DA    LDY $DA,X       get the start of the next line pointer high byte
// .:E91E 10 02    BPL $E922       if next line is not a start of line skip the start set
// .:E920 09 80    ORA #$80        set line X start of logical line bit
// .:E922 95 D9    STA $D9,X       set start of line X pointer high byte
// .:E924 E8       INX             increment line number
// .:E925 E0 18    CPX #$18        compare with last line
// .:E927 D0 EF    BNE $E918       loop if not last line
// .:E929 A5 F1    LDA $F1         get start of last line pointer high byte
// .:E92B 09 80    ORA #$80        mark as start of logical line
// .:E92D 85 F1    STA $F1         set start of last line pointer high byte
// .:E92F A5 D9    LDA $D9         get start of first line pointer high byte
// .:E931 10 C3    BPL $E8F6       if not start of logical line loop back and
//                                 scroll the screen up another line
// .:E933 E6 D6    INC $D6         increment the cursor row
// .:E935 EE A5 02 INC $02A5       increment screen row marker
// .:E938 A9 7F    LDA #$7F        set keyboard column c7
// .:E93A 8D 00 DC STA $DC00       save VIA 1 DRA, keyboard column drive
// .:E93D AD 01 DC LDA $DC01       read VIA 1 DRB, keyboard row port
// .:E940 C9 FB    CMP #$FB        compare with row r2 active, [CTL]
// .:E942 08       PHP             save status
// .:E943 A9 7F    LDA #$7F        set keyboard column c7
// .:E945 8D 00 DC STA $DC00       save VIA 1 DRA, keyboard column drive
// .:E948 28       PLP             restore status
// .:E949 D0 0B    BNE $E956       skip delay if ??
//                                 first time round the inner loop X will be $16
// .:E94B A0 00    LDY #$00        clear delay outer loop count, do this 256 times
// .:E94D EA       NOP             waste cycles
// .:E94E CA       DEX             decrement inner loop count
// .:E94F D0 FC    BNE $E94D       loop if not all done
// .:E951 88       DEY             decrement outer loop count
// .:E952 D0 F9    BNE $E94D       loop if not all done
// .:E954 84 C6    STY $C6         clear the keyboard buffer index
// .:E956 A6 D6    LDX $D6         get the cursor row
//                                 restore the tape buffer pointers and exit
// .:E958 68       PLA             pull tape buffer end pointer
// .:E959 85 AF    STA $AF         restore it
// .:E95B 68       PLA             pull tape buffer end pointer
// .:E95C 85 AE    STA $AE         restore it
// .:E95E 68       PLA             pull tape buffer pointer
// .:E95F 85 AD    STA $AD         restore it
// .:E961 68       PLA             pull tape buffer pointer
// .:E962 85 AC    STA $AC         restore it
// .:E964 60       RTS

.label /* $E965 - 59749 */ E965_open_a_space_on_the_screen = $E965
// open up a space on the screen
//
// .:E965 A6 D6    LDX $D6         get the cursor row
// .:E967 E8       INX             increment the row
// .:E968 B5 D9    LDA $D9,X       get the start of line X pointer high byte
// .:E96A 10 FB    BPL $E967       loop if not start of logical line
// .:E96C 8E A5 02 STX $02A5       save the screen row marker
// .:E96F E0 18    CPX #$18        compare it with the last line
// .:E971 F0 0E    BEQ $E981       if = last line go ??
// .:E973 90 0C    BCC $E981       if < last line go ??
//                                 else it was > last line
// .:E975 20 EA E8 JSR $E8EA       scroll the screen
// .:E978 AE A5 02 LDX $02A5       get the screen row marker
// .:E97B CA       DEX             decrement the screen row marker
// .:E97C C6 D6    DEC $D6         decrement the cursor row
// .:E97E 4C DA E6 JMP $E6DA       add this row to the current logical line and return
// .:E981 A5 AC    LDA $AC         copy tape buffer pointer
// .:E983 48       PHA             save it
// .:E984 A5 AD    LDA $AD         copy tape buffer pointer
// .:E986 48       PHA             save it
// .:E987 A5 AE    LDA $AE         copy tape buffer end pointer
// .:E989 48       PHA             save it
// .:E98A A5 AF    LDA $AF         copy tape buffer end pointer
// .:E98C 48       PHA             save it
// .:E98D A2 19    LDX #$19        set to end line + 1 for predecrement loop
// .:E98F CA       DEX             decrement the line number
// .:E990 20 F0 E9 JSR $E9F0       fetch a screen address
// .:E993 EC A5 02 CPX $02A5       compare it with the screen row marker
// .:E996 90 0E    BCC $E9A6       if < screen row marker go ??
// .:E998 F0 0C    BEQ $E9A6       if = screen row marker go ??
// .:E99A BD EF EC LDA $ECEF,X     else get the start of the previous line low byte from the
//                                 ROM table
// .:E99D 85 AC    STA $AC         save previous line pointer low byte
// .:E99F B5 D8    LDA $D8,X       get the start of the previous line pointer high byte
// .:E9A1 20 C8 E9 JSR $E9C8       shift the screen line down
// .:E9A4 30 E9    BMI $E98F       loop, branch always
// .:E9A6 20 FF E9 JSR $E9FF       clear screen line X
// .:E9A9 A2 17    LDX #$17
// .:E9AB EC A5 02 CPX $02A5       compare it with the screen row marker
// .:E9AE 90 0F    BCC $E9BF
// .:E9B0 B5 DA    LDA $DA,X
// .:E9B2 29 7F    AND #$7F
// .:E9B4 B4 D9    LDY $D9,X       get start of line X pointer high byte
// .:E9B6 10 02    BPL $E9BA
// .:E9B8 09 80    ORA #$80
// .:E9BA 95 DA    STA $DA,X
// .:E9BC CA       DEX
// .:E9BD D0 EC    BNE $E9AB
// .:E9BF AE A5 02 LDX $02A5       get the screen row marker
// .:E9C2 20 DA E6 JSR $E6DA       add this row to the current logical line
// .:E9C5 4C 58 E9 JMP $E958       restore the tape buffer pointers and exit

.label /* $E9C8 - 59848 */ E9C8_move_a_screen_line = $E9C8
// shift screen line up/down
//
// .:E9C8 29 03    AND #$03        mask 0000 00xx, line memory page
// .:E9CA 0D 88 02 ORA $0288       OR with screen memory page
// .:E9CD 85 AD    STA $AD         save next/previous line pointer high byte
// .:E9CF 20 E0 E9 JSR $E9E0       calculate pointers to screen lines colour RAM
// .:E9D2 A0 27    LDY #$27        set the column count
// .:E9D4 B1 AC    LDA ($AC),Y     get character from next/previous screen line
// .:E9D6 91 D1    STA ($D1),Y     save character to current screen line
// .:E9D8 B1 AE    LDA ($AE),Y     get colour from next/previous screen line colour RAM
// .:E9DA 91 F3    STA ($F3),Y     save colour to current screen line colour RAM
// .:E9DC 88       DEY             decrement column index/count
// .:E9DD 10 F5    BPL $E9D4       loop if more to do
// .:E9DF 60       RTS

.label /* $E9E0 - 59872 */ E9E0_syncronise_color_transfer = $E9E0
// calculate pointers to screen lines colour RAM
//
// .:E9E0 20 24 EA JSR $EA24       calculate the pointer to the current screen line colour
//                                 RAM
// .:E9E3 A5 AC    LDA $AC         get the next screen line pointer low byte
// .:E9E5 85 AE    STA $AE         save the next screen line colour RAM pointer low byte
// .:E9E7 A5 AD    LDA $AD         get the next screen line pointer high byte
// .:E9E9 29 03    AND #$03        mask 0000 00xx, line memory page
// .:E9EB 09 D8    ORA #$D8        set  1101 01xx, colour memory page
// .:E9ED 85 AF    STA $AF         save the next screen line colour RAM pointer high byte
// .:E9EF 60       RTS

.label /* $E9F0 - 59888 */ E9F0_set_start_of_line = $E9F0
// fetch a screen address
//
// .:E9F0 BD F0 EC LDA $ECF0,X     get the start of line low byte from the ROM table
// .:E9F3 85 D1    STA $D1         set the current screen line pointer low byte
// .:E9F5 B5 D9    LDA $D9,X       get the start of line high byte from the RAM table
// .:E9F7 29 03    AND #$03        mask 0000 00xx, line memory page
// .:E9F9 0D 88 02 ORA $0288       OR with the screen memory page
// .:E9FC 85 D2    STA $D2         save the current screen line pointer high byte
// .:E9FE 60       RTS

.label /* $E9FF - 59903 */ E9FF_clear_screen_line = $E9FF
// clear screen line X
//
// .:E9FF A0 27    LDY #$27        set number of columns to clear
// .:EA01 20 F0 E9 JSR $E9F0       fetch a screen address
// .:EA04 20 24 EA JSR $EA24       calculate the pointer to colour RAM
// .:EA07 20 DA E4 JSR $E4DA       save the current colour to the colour RAM
// .:EA0A A9 20    LDA #$20        set [SPACE]
// .:EA0C 91 D1    STA ($D1),Y     clear character in current screen line
// .:EA0E 88       DEY             decrement index
// .:EA0F 10 F6    BPL $EA07       loop if more to do
// .:EA11 60       RTS
//
// orphan byte
//
// .:EA12 EA       NOP             unused

.label /* $EA13 - 59923 */ EA13_print_to_screen = $EA13
// print character A and colour X
//
// .:EA13 A8       TAY             copy the character
// .:EA14 A9 02    LDA #$02set the count to $02, usually $14 ??
// .:EA16 85 CD    STA $CD         save the cursor countdown
// .:EA18 20 24 EA JSR $EA24       calculate the pointer to colour RAM
// .:EA1B 98       TYA             get the character back
//
// save the character and colour to the screen @ the cursor
//
// .:EA1C A4 D3    LDY $D3         get the cursor column
// .:EA1E 91 D1    STA ($D1),Y     save the character from current screen line
// .:EA20 8A       TXA             copy the colour to A
// .:EA21 91 F3    STA ($F3),Y     save to colour RAM
// .:EA23 60       RTS

.label /* $EA24 - 59940 */ EA24_syncronise_color_pointer = $EA24
// calculate the pointer to colour RAM
//
// .:EA24 A5 D1    LDA $D1         get current screen line pointer low byte
// .:EA26 85 F3    STA $F3         save pointer to colour RAM low byte
// .:EA28 A5 D2    LDA $D2         get current screen line pointer high byte
// .:EA2A 29 03    AND #$03        mask 0000 00xx, line memory page
// .:EA2C 09 D8    ORA #$D8        set  1101 01xx, colour memory page
// .:EA2E 85 F4    STA $F4         save pointer to colour RAM high byte
// .:EA30 60       RTS

.label /* $EA31 - 59953 */ EA31_main_irq_entry_point = $EA31
// IRQ vector
//
// .:EA31 20 EA FF JSR $FFEA       increment the real time clock
// .:EA34 A5 CC    LDA $CC         get the cursor enable, $00 = flash cursor
// .:EA36 D0 29    BNE $EA61       if flash not enabled skip the flash
// .:EA38 C6 CD    DEC $CD         decrement the cursor timing countdown
// .:EA3A D0 25    BNE $EA61       if not counted out skip the flash
// .:EA3C A9 14    LDA #$14        set the flash count
// .:EA3E 85 CD    STA $CD         save the cursor timing countdown
// .:EA40 A4 D3    LDY $D3         get the cursor column
// .:EA42 46 CF    LSR $CF         shift b0 cursor blink phase into carry
// .:EA44 AE 87 02 LDX $0287       get the colour under the cursor
// .:EA47 B1 D1    LDA ($D1),Y     get the character from current screen line
// .:EA49 B0 11    BCS $EA5C       branch if cursor phase b0 was 1
// .:EA4B E6 CF    INC $CF         set the cursor blink phase to 1
// .:EA4D 85 CE    STA $CE         save the character under the cursor
// .:EA4F 20 24 EA JSR $EA24       calculate the pointer to colour RAM
// .:EA52 B1 F3    LDA ($F3),Y     get the colour RAM byte
// .:EA54 8D 87 02 STA $0287       save the colour under the cursor
// .:EA57 AE 86 02 LDX $0286       get the current colour code
// .:EA5A A5 CE    LDA $CE         get the character under the cursor
// .:EA5C 49 80    EOR #$80        toggle b7 of character under cursor
// .:EA5E 20 1C EA JSR $EA1C       save the character and colour to the screen @ the cursor
// .:EA61 A5 01    LDA $01         read the 6510 I/O port
// .:EA63 29 10    AND #$10        mask 000x 0000, the cassette switch sense
// .:EA65 F0 0A    BEQ $EA71       if the cassette sense is low skip the motor stop
//                                 the cassette sense was high, the switch was open, so turn
//                                 off the motor and clear the interlock
// .:EA67 A0 00    LDY #$00        clear Y
// .:EA69 84 C0    STY $C0         clear the tape motor interlock
// .:EA6B A5 01    LDA $01         read the 6510 I/O port
// .:EA6D 09 20    ORA #$20        mask xxxx xx1x, turn off the motor
// .:EA6F D0 08    BNE $EA79       go save the port value, branch always
//                                 the cassette sense was low so turn the motor on, perhaps
// .:EA71 A5 C0    LDA $C0         get the tape motor interlock
// .:EA73 D0 06    BNE $EA7B       if the cassette interlock <> 0 don't turn on motor
// .:EA75 A5 01    LDA $01         read the 6510 I/O port
// .:EA77 29 1F    AND #$1F        mask xxxx xx0x, turn on the motor
// .:EA79 85 01    STA $01         save the 6510 I/O port
// .:EA7B 20 87 EA JSR $EA87       scan the keyboard
// .:EA7E AD 0D DC LDA $DC0D       read VIA 1 ICR, clear the timer interrupt flag

.label /* $EA81 - 60033 */ EA81_restore_a_x_y_and_end_irq = $EA81
// .:EA81 68       PLA             pull Y
// .:EA82 A8       TAY             restore Y
// .:EA83 68       PLA             pull X
// .:EA84 AA       TAX             restore X
// .:EA85 68       PLA             restore A
// .:EA86 40       RTI

.label /* $EA87 - 60039 */ EA87_scan_keyboard = $EA87
// scan keyboard performs the following ..
//
//                                 1) check if key pressed, if not then exit the routine
//
//                                 2) init I/O ports of VIA ?? for keyboard scan and set pointers to decode table 1.
//                                 clear the character counter
//
//                                 3) set one line of port B low and test for a closed key on port A by shifting the
//                                 byte read from the port. if the carry is clear then a key is closed so save the
//                                 count which is incremented on each shift. check for shift/stop/cbm keys and
//                                 flag if closed
//
//                                 4) repeat step 3 for the whole matrix
//
//                                 5) evaluate the SHIFT/CTRL/C= keys, this may change the decode table selected
//
//                                 6) use the key count saved in step 3 as an index into the table selected in step 5
//
//                                 7) check for key repeat operation
//
//                                 8) save the decoded key to the buffer if first press or repeat
//                                 scan the keyboard
// .:EA87 A9 00    LDA #$00        clear A
// .:EA89 8D 8D 02 STA $028D       clear the keyboard shift/control/c= flag
// .:EA8C A0 40    LDY #$40        set no key
// .:EA8E 84 CB    STY $CB         save which key
// .:EA90 8D 00 DC STA $DC00       clear VIA 1 DRA, keyboard column drive
// .:EA93 AE 01 DC LDX $DC01       read VIA 1 DRB, keyboard row port
// .:EA96 E0 FF    CPX #$FF        compare with all bits set
// .:EA98 F0 61    BEQ $EAFB       if no key pressed clear current key and exit (does
//                                 further BEQ to $EBBA)
// .:EA9A A8       TAY             clear the key count
// .:EA9B A9 81    LDA #$81get the decode table low byte
// .:EA9D 85 F5    STA $F5         save the keyboard pointer low byte
// .:EA9F A9 EB    LDA #$EB        get the decode table high byte
// .:EAA1 85 F6    STA $F6save the keyboard pointer high byte
// .:EAA3 A9 FE    LDA #$FE        set column 0 low
// .:EAA5 8D 00 DC STA $DC00       save VIA 1 DRA, keyboard column drive
// .:EAA8 A2 08    LDX #$08        set the row count
// .:EAAA 48       PHA             save the column
// .:EAAB AD 01 DC LDA $DC01       read VIA 1 DRB, keyboard row port
// .:EAAE CD 01 DC CMP $DC01       compare it with itself
// .:EAB1 D0 F8    BNE $EAAB       loop if changing
// .:EAB3 4A       LSR             shift row to Cb
// .:EAB4 B0 16    BCS $EACC       if no key closed on this row go do next row
// .:EAB6 48       PHA             save row
// .:EAB7 B1 F5    LDA ($F5),Y     get character from decode table
// .:EAB9 C9 05    CMP #$05        compare with $05, there is no $05 key but the control
//                                 keys are all less than $05
// .:EABB B0 0C    BCS $EAC9       if not shift/control/c=/stop go save key count
//                                 else was shift/control/c=/stop key
// .:EABD C9 03    CMP #$03        compare with $03, stop
// .:EABF F0 08    BEQ $EAC9       if stop go save key count and continue
//                                 character is $01 - shift, $02 - c= or $04 - control
// .:EAC1 0D 8D 02 ORA $028D       OR it with the keyboard shift/control/c= flag
// .:EAC4 8D 8D 02 STA $028D       save the keyboard shift/control/c= flag
// .:EAC7 10 02    BPL $EACB       skip save key, branch always
// .:EAC9 84 CB    STY $CB         save key count
// .:EACB 68       PLA             restore row
// .:EACC C8       INY             increment key count
// .:EACD C0 41    CPY #$41        compare with max+1
// .:EACF B0 0B    BCS $EADC       exit loop if >= max+1
//                                 else still in matrix
// .:EAD1 CA       DEX             decrement row count
// .:EAD2 D0 DF    BNE $EAB3       loop if more rows to do
// .:EAD4 38       SEC             set carry for keyboard column shift
// .:EAD5 68       PLA             restore the column
// .:EAD6 2A       ROL             shift the keyboard column
// .:EAD7 8D 00 DC STA $DC00       save VIA 1 DRA, keyboard column drive
// .:EADA D0 CC    BNE $EAA8       loop for next column, branch always
// .:EADC 68       PLA             dump the saved column

.label /* $EADD - 60125 */ EADD_process_key_image = $EADD
// .:EADD 6C 8F 02 JMP ($028F)     evaluate the SHIFT/CTRL/C= keys, $EBDC
//                                key decoding continues here after the SHIFT/CTRL/C= keys are evaluated
// .:EAE0 A4 CB    LDY $CB         get saved key count
// .:EAE2 B1 F5    LDA ($F5),Y     get character from decode table
// .:EAE4 AA       TAX             copy character to X
// .:EAE5 C4 C5    CPY $C5         compare key count with last key count
// .:EAE7 F0 07    BEQ $EAF0       if this key = current key, key held, go test repeat
// .:EAE9 A0 10    LDY #$10        set the repeat delay count
// .:EAEB 8C 8C 02 STY $028C       save the repeat delay count
// .:EAEE D0 36    BNE $EB26       go save key to buffer and exit, branch always
// .:EAF0 29 7F    AND #$7F        clear b7
// .:EAF2 2C 8A 02 BIT $028A       test key repeat
// .:EAF5 30 16    BMI $EB0D       if repeat all go ??
// .:EAF7 70 49    BVS $EB42       if repeat none go ??
// .:EAF9 C9 7F    CMP #$7F        compare with end marker
// .:EAFB F0 29    BEQ $EB26       if $00/end marker go save key to buffer and exit
// .:EAFD C9 14    CMP #$14        compare with [INSERT]/[DELETE]
// .:EAFF F0 0C    BEQ $EB0D       if [INSERT]/[DELETE] go test for repeat
// .:EB01 C9 20    CMP #$20        compare with [SPACE]
// .:EB03 F0 08    BEQ $EB0D       if [SPACE] go test for repeat
// .:EB05 C9 1D    CMP #$1D        compare with [CURSOR RIGHT]
// .:EB07 F0 04    BEQ $EB0D       if [CURSOR RIGHT] go test for repeat
// .:EB09 C9 11    CMP #$11        compare with [CURSOR DOWN]
// .:EB0B D0 35    BNE $EB42       if not [CURSOR DOWN] just exit
//                                 was one of the cursor movement keys, insert/delete
//                                 key or the space bar so always do repeat tests
// .:EB0D AC 8C 02 LDY $028C       get the repeat delay counter
// .:EB10 F0 05    BEQ $EB17       if delay expired go ??
// .:EB12 CE 8C 02 DEC $028C       else decrement repeat delay counter
// .:EB15 D0 2B    BNE $EB42       if delay not expired go ??
//                                 repeat delay counter has expired
// .:EB17 CE 8B 02 DEC $028B       decrement the repeat speed counter
// .:EB1A D0 26    BNE $EB42       branch if repeat speed count not expired
// .:EB1C A0 04    LDY #$04        set for 4/60ths of a second
// .:EB1E 8C 8B 02 STY $028B       save the repeat speed counter
// .:EB21 A4 C6    LDY $C6         get the keyboard buffer index
// .:EB23 88       DEY             decrement it
// .:EB24 10 1C    BPL $EB42       if the buffer isn't empty just exit
//                                 else repeat the key immediately
//                                 possibly save the key to the keyboard buffer. if there was no key pressed or the key
//                                 was not found during the scan (possibly due to key bounce) then X will be $FF here
// .:EB26 A4 CB    LDY $CB         get the key count
// .:EB28 84 C5    STY $C5         save it as the current key count
// .:EB2A AC 8D 02 LDY $028D       get the keyboard shift/control/c= flag
// .:EB2D 8C 8E 02 STY $028E       save it as last keyboard shift pattern
// .:EB30 E0 FF    CPX #$FF        compare the character with the table end marker or no key
// .:EB32 F0 0E    BEQ $EB42       if it was the table end marker or no key just exit
// .:EB34 8A       TXA             copy the character to A
// .:EB35 A6 C6    LDX $C6         get the keyboard buffer index
// .:EB37 EC 89 02 CPX $0289       compare it with the keyboard buffer size
// .:EB3A B0 06    BCS $EB42       if the buffer is full just exit
// .:EB3C 9D 77 02 STA $0277,X     save the character to the keyboard buffer
// .:EB3F E8       INX             increment the index
// .:EB40 86 C6    STX $C6         save the keyboard buffer index
// .:EB42 A9 7F    LDA #$7F        enable column 7 for the stop key
// .:EB44 8D 00 DC STA $DC00       save VIA 1 DRA, keyboard column drive
// .:EB47 60       RTS

.label /* $EB48 - 60232 */ EB48_check_for_shift = $EB48
// evaluate the SHIFT/CTRL/C= keys
//
// .:EB48 AD 8D 02 LDA $028D       get the keyboard shift/control/c= flag
// .:EB4B C9 03    CMP #$03        compare with [SHIFT][C=]
// .:EB4D D0 15    BNE $EB64       if not [SHIFT][C=] go ??
// .:EB4F CD 8E 02 CMP $028E       compare with last
// .:EB52 F0 EE    BEQ $EB42       exit if still the same
// .:EB54 AD 91 02 LDA $0291       get the shift mode switch $00 = enabled, $80 = locked
// .:EB57 30 1D    BMI $EB76       if locked continue keyboard decode
//                                 toggle text mode
// .:EB59 AD 18 D0 LDA $D018       get the start of character memory address
// .:EB5C 49 02    EOR #$02        toggle address b1
// .:EB5E 8D 18 D0 STA $D018       save the start of character memory address
// .:EB61 4C 76 EB JMP $EB76       continue the keyboard decode
//                                 select keyboard table
// .:EB64 0A       ASL             << 1
// .:EB65 C9 08    CMP #$08        compare with [CTRL]
// .:EB67 90 02    BCC $EB6B       if [CTRL] is not pressed skip the index change
// .:EB69 A9 06    LDA #$06        else [CTRL] was pressed so make the index = $06
// .:EB6B AA       TAX             copy the index to X
// .:EB6C BD 79 EB LDA $EB79,X     get the decode table pointer low byte
// .:EB6F 85 F5    STA $F5         save the decode table pointer low byte
// .:EB71 BD 7A EB LDA $EB7A,X     get the decode table pointer high byte
// .:EB74 85 F6    STA $F6         save the decode table pointer high byte
// .:EB76 4C E0 EA JMP $EAE0       continue the keyboard decode

.label /* $EB79 - 60281 */ EB79_pointers_to_keyboard_decoding_tables = $EB79
// table addresses
//
// .:EB79 81 EB                    standard
// .:EB7B C2 EB                    shift
// .:EB7D 03 EC                    commodore
// .:EB7F 78 EC                    control

.label /* $EB81 - 60289 */ EB81_keyboard_1_unshifted = $EB81
// standard keyboard table
//
// .:EB81 14 0D 1D 88 85 86 87 11
// .:EB89 33 57 41 34 5A 53 45 01
// .:EB91 35 52 44 36 43 46 54 58
// .:EB99 37 59 47 38 42 48 55 56
// .:EBA1 39 49 4A 30 4D 4B 4F 4E
// .:EBA9 2B 50 4C 2D 2E 3A 40 2C
// .:EBB1 5C 2A 3B 13 01 3D 5E 2F
// .:EBB9 31 5F 04 32 20 02 51 03
// .:EBC1 FF

.label /* $EBC2 - 60354 */ EBC2_keyboard_2_shifted = $EBC2
// shifted keyboard table
//
// .:EBC2 94 8D 9D 8C 89 8A 8B 91
// .:EBCA 23 D7 C1 24 DA D3 C5 01
// .:EBD2 25 D2 C4 26 C3 C6 D4 D8
// .:EBDA 27 D9 C7 28 C2 C8 D5 D6
// .:EBE2 29 C9 CA 30 CD CB CF CE
// .:EBEA DB D0 CC DD 3E 5B BA 3C
// .:EBF2 A9 C0 5D 93 01 3D DE 3F
// .:EBFA 21 5F 04 22 A0 02 D1 83
// .:EC02 FF

.label /* $EC03 - 60419 */ EC03_keyboard_3_commodore = $EC03
// CBM key keyboard table
//
// .:EC03 94 8D 9D 8C 89 8A 8B 91
// .:EC0B 96 B3 B0 97 AD AE B1 01
// .:EC13 98 B2 AC 99 BC BB A3 BD
// .:EC1B 9A B7 A5 9B BF B4 B8 BE
// .:EC23 29 A2 B5 30 A7 A1 B9 AA
// .:EC2B A6 AF B6 DC 3E 5B A4 3C
// .:EC33 A8 DF 5D 93 01 3D DE 3F
// .:EC3B 81 5F 04 95 A0 02 AB 83
// .:EC43 FF

.label /* $EC44 - 60484 */ EC44_graphics_text_control = $EC44
// check for special character codes
//
// .:EC44 C9 0E    CMP #$0E        compare with [SWITCH TO LOWER CASE]
// .:EC46 D0 07    BNE $EC4F       if not [SWITCH TO LOWER CASE] skip the switch
// .:EC48 AD 18 D0 LDA $D018       get the start of character memory address
// .:EC4B 09 02    ORA #$02        mask xxxx xx1x, set lower case characters
// .:EC4D D0 09    BNE $EC58       go save the new value, branch always
//                                 check for special character codes except fro switch to lower case
// .:EC4F C9 8E    CMP #$8E        compare with [SWITCH TO UPPER CASE]
// .:EC51 D0 0B    BNE $EC5E       if not [SWITCH TO UPPER CASE] go do the [SHIFT]+[C=] key
//                                 check
// .:EC53 AD 18 D0 LDA $D018       get the start of character memory address
// .:EC56 29 FD    AND #$FD        mask xxxx xx0x, set upper case characters
// .:EC58 8D 18 D0 STA $D018       save the start of character memory address
// .:EC5B 4C A8 E6 JMP $E6A8       restore the registers, set the quote flag and exit
//                                 do the [SHIFT]+[C=] key check
// .:EC5E C9 08    CMP #$08        compare with disable [SHIFT][C=]
// .:EC60 D0 07    BNE $EC69       if not disable [SHIFT][C=] skip the set
// .:EC62 A9 80    LDA #$80        set to lock shift mode switch
// .:EC64 0D 91 02 ORA $0291       OR it with the shift mode switch
// .:EC67 30 09    BMI $EC72       go save the value, branch always
// .:EC69 C9 09    CMP #$09        compare with enable [SHIFT][C=]
// .:EC6B D0 EE    BNE $EC5B       exit if not enable [SHIFT][C=]
// .:EC6D A9 7F    LDA #$7F        set to unlock shift mode switch
// .:EC6F 2D 91 02 AND $0291       AND it with the shift mode switch
// .:EC72 8D 91 02 STA $0291       save the shift mode switch $00 = enabled, $80 = locked
// .:EC75 4C A8 E6 JMP $E6A8       restore the registers, set the quote flag and exit

.label /* $EC78 - 60536 */ EC78_keyboard_4_control = $EC78
// control keyboard table
//
// .:EC78 FF FF FF FF FF FF FF FF
// .:EC80 1C 17 01 9F 1A 13 05 FF
// .:EC88 9C 12 04 1E 03 06 14 18
// .:EC90 1F 19 07 9E 02 08 15 16
// .:EC98 12 09 0A 92 0D 0B 0F 0E
// .:ECA0 FF 10 0C FF FF 1B 00 FF
// .:ECA8 1C FF 1D FF FF 1F 1E FF
// .:ECB0 90 06 FF 05 FF FF 11 FF
// .:ECB8 FF

.label /* $ECB9 - 60601 */ ECB9_video_chip_setup_table = $ECB9
// vic ii chip initialisation values
//
// .:ECB9 00 00                    sprite 0 x,y
// .:ECBB 00 00                    sprite 1 x,y
// .:ECBD 00 00                    sprite 2 x,y
// .:ECBF 00 00                    sprite 3 x,y
// .:ECC1 00 00                    sprite 4 x,y
// .:ECC3 00 00                    sprite 5 x,y
// .:ECC5 00 00                    sprite 6 x,y
// .:ECC7 00 00                    sprite 7 x,y
// .:ECC9 00                       sprites 0 to 7 x bit 8
// .:ECCA 9B                       enable screen, enable 25 rows
//                                 vertical fine scroll and control
//                                 bit function
//                                 --- -------
//                                 7  raster compare bit 8
//                                 6  1 = enable extended color text mode
//                                 5  1 = enable bitmap graphics mode
//                                 4  1 = enable screen, 0 = blank screen
//                                 3  1 = 25 row display, 0 = 24 row display
//                                 2-0 vertical scroll count
// .:ECCB 37                       raster compare
// .:ECCC 00                       light pen x
// .:ECCD 00                       light pen y
// .:ECCE 00                       sprite 0 to 7 enable
// .:ECCF 08                       enable 40 column display
//                                 horizontal fine scroll and control
//                                 bit function
//                                 --- -------
//                                 7-6 unused
//                                 5  1 = vic reset, 0 = vic on
//                                 4  1 = enable multicolor mode
//                                 3  1 = 40 column display, 0 = 38 column display
//                                 2-0 horizontal scroll count
// .:ECC0 00                       sprite 0 to 7 y expand
// .:ECD1 14                       memory control
//                                 bit function
//                                 --- -------
//                                 7-4 video matrix base address
//                                 3-1 character data base address
//                                 0  unused
// .:ECD2 0F                       clear all interrupts
//                                 interrupt flags
//                                 7 1 = interrupt
//                                 6-4 unused
//                                 3  1 = light pen interrupt
//                                 2  1 = sprite to sprite collision interrupt
//                                 1  1 = sprite to foreground collision interrupt
//                                 0  1 = raster compare interrupt
// .:ECD3 00                       all vic IRQs disabeld
//                                 IRQ enable
//                                 bit function
//                                 --- -------
//                                 7-4 unused
//                                 3  1 = enable light pen
//                                 2  1 = enable sprite to sprite collision
//                                 1  1 = enable sprite to foreground collision
//                                 0  1 = enable raster compare
// .:ECD4 00                       sprite 0 to 7 foreground priority
// .:ECD5 00                       sprite 0 to 7 multicolour
// .:ECD6 00                       sprite 0 to 7 x expand
// .:ECD7 00                       sprite 0 to 7 sprite collision
// .:ECD8 00                       sprite 0 to 7 foreground collision
// .:ECD9 0E                       border colour
// .:ECDA 06                       background colour 0
// .:ECDB 01                       background colour 1
// .:ECDC 02                       background colour 2
// .:ECDD 03                       background colour 3
// .:ECDE 04                       sprite multicolour 0
// .:ECDF 00                       sprite multicolour 1
// .:ECD0 01                       sprite 0 colour
// .:ECE1 02                       sprite 1 colour
// .:ECE2 03                       sprite 2 colour
// .:ECE3 04                       sprite 3 colour
// .:ECE4 05                       sprite 4 colour
// .:ECE5 06                       sprite 5 colour
// .:ECE6 07                       sprite 6 colour
//                                 sprite 7 colour is actually the first character of "LOAD" ($4C)

.label /* $ECE7 - 60647 */ ECE7_shift_run_equivalent = $ECE7
// keyboard buffer for auto load/run
//
// .:ECE7 4C 4F 41 44 0D 52 55 4E  'load (cr) run (cr)'
// .:ECEA 44 0D 52 55 4E 0D

.label /* $ECF0 - 60656 */ ECF0_low_byte_screen_line_addresses = $ECF0
// low bytes of screen line addresses
//
// .:ECF0 00 28 50 78 A0 C8 F0 18
// .:ECF8 40 68 90 B8 E0 08 30 58
// .:ED00 80 A8 D0 F8 20 48 70 98
// .:ED08 C0

.label /* $ED09 - 60681 */ ED09_send_talk_command_on_serial_bus = $ED09
// command serial bus device to TALK
//
// .:ED09 09 40    ORA #$40        OR with the TALK command
// .:ED0B 2C       .BYTE $2C       makes next line BIT $2009

.label /* $ED0C - 60684 */ ED0C_send_listen_command_on_serial_bus = $ED0C
// command devices on the serial bus to LISTEN
//
// .:ED0C 09 20    ORA #$20        OR with the LISTEN command
// .:ED0E 20 A4 F0 JSR $F0A4       check RS232 bus idle
//
// send a control character
//
// .:ED11 48       PHA             save device address
// .:ED12 24 94    BIT $94         test deferred character flag
// .:ED14 10 0A    BPL $ED20       if no defered character continue
// .:ED16 38       SEC             else flag EOI
// .:ED17 66 A3    ROR $A3         rotate into EOI flag byte
// .:ED19 20 40 ED JSR $ED40       Tx byte on serial bus
// .:ED1C 46 94    LSR $94         clear deferred character flag
// .:ED1E 46 A3    LSR $A3         clear EOI flag
// .:ED20 68       PLA             restore the device address
//
// defer a command
//
// .:ED21 85 95    STA $95         save as serial defered character
// .:ED23 78       SEI             disable the interrupts
// .:ED24 20 97 EE JSR $EE97       set the serial data out high
// .:ED27 C9 3F    CMP #$3F        compare read byte with $3F
// .:ED29 D0 03    BNE $ED2E       branch if not $3F, this branch will always be taken as
//                                 after VIA 2's PCR is read it is ANDed with $DF, so the
//                                 result can never be $3F ??
// .:ED2B 20 85 EE JSR $EE85       set the serial clock out high
// .:ED2E AD 00 DD LDA $DD00       read VIA 2 DRA, serial port and video address
// .:ED31 09 08    ORA #$08        mask xxxx 1xxx, set serial ATN low
// .:ED33 8D 00 DD STA $DD00       save VIA 2 DRA, serial port and video address
//                                 if the code drops through to here the serial clock is low and the serial data has been
//                                 released so the following code will have no effect apart from delaying the first byte
//                                 by 1ms
//                                 set the serial clk/data, wait and Tx byte on the serial bus
// .:ED36 78       SEI             disable the interrupts
// .:ED37 20 8E EE JSR $EE8E       set the serial clock out low
// .:ED3A 20 97 EE JSR $EE97       set the serial data out high
// .:ED3D 20 B3 EE JSR $EEB3       1ms delay
.label /* $ED40 - 60736 */ ED40_send_data_on_serial_bus = $ED40
// Tx byte on serial bus
//
// .:ED40 78       SEI             disable the interrupts
// .:ED41 20 97 EE JSR $EE97       set the serial data out high
// .:ED44 20 A9 EE JSR $EEA9       get the serial data status in Cb
// .:ED47 B0 64    BCS $EDAD       if the serial data is high go do 'device not present'
// .:ED49 20 85 EE JSR $EE85       set the serial clock out high
// .:ED4C 24 A3    BIT $A3         test the EOI flag
// .:ED4E 10 0A    BPL $ED5A       if not EOI go ??
//                                 I think this is the EOI sequence so the serial clock has been released and the serial
//                                 data is being held low by the peripheral. first up wait for the serial data to rise
// .:ED50 20 A9 EE JSR $EEA9       get the serial data status in Cb
// .:ED53 90 FB    BCC $ED50       loop if the data is low
//                                 now the data is high, EOI is signalled by waiting for at least 200us without pulling
//                                 the serial clock line low again. the listener should respond by pulling the serial
//                                 data line low
// .:ED55 20 A9 EE JSR $EEA9       get the serial data status in Cb
// .:ED58 B0 FB    BCS $ED55       loop if the data is high
//                                 the serial data has gone low ending the EOI sequence, now just wait for the serial
//                                 data line to go high again or, if this isn't an EOI sequence, just wait for the serial
//                                 data to go high the first time
// .:ED5A 20 A9 EE JSR $EEA9       get the serial data status in Cb
// .:ED5D 90 FB    BCC $ED5A       loop if the data is low
//                                 serial data is high now pull the clock low, preferably within 60us
// .:ED5F 20 8E EE JSR $EE8E       set the serial clock out low
//                                 now the C64 has to send the eight bits, LSB first. first it sets the serial data line
//                                 to reflect the bit in the byte, then it sets the serial clock to high. The serial
//                                 clock is left high for 26 cycles, 23us on a PAL Vic, before it is again pulled low
//                                 and the serial data is allowed high again
// .:ED62 A9 08    LDA #$08        eight bits to do
// .:ED64 85 A5    STA $A5         set serial bus bit count
// .:ED66 AD 00 DD LDA $DD00       read VIA 2 DRA, serial port and video address
// .:ED69 CD 00 DD CMP $DD00       compare it with itself
// .:ED6C D0 F8    BNE $ED66       if changed go try again
// .:ED6E 0A       ASL             shift the serial data into Cb
// .:ED6F 90 3F    BCC $EDB0       if the serial data is low go do serial bus timeout
// .:ED71 66 95    ROR $95         rotate the transmit byte
// .:ED73 B0 05    BCS $ED7A       if the bit = 1 go set the serial data out high
// .:ED75 20 A0 EE JSR $EEA0       else set the serial data out low
// .:ED78 D0 03    BNE $ED7D       continue, branch always
// .:ED7A 20 97 EE JSR $EE97       set the serial data out high
// .:ED7D 20 85 EE JSR $EE85       set the serial clock out high
// .:ED80 EA       NOP             waste ..
// .:ED81 EA       NOP             .. a ..
// .:ED82 EA       NOP             .. cycle ..
// .:ED83 EA       NOP             .. or two
// .:ED84 AD 00 DD LDA $DD00       read VIA 2 DRA, serial port and video address
// .:ED87 29 DF    AND #$DF        mask xx0x xxxx, set the serial data out high
// .:ED89 09 10    ORA #$10        mask xxx1 xxxx, set the serial clock out low
// .:ED8B 8D 00 DD STA $DD00       save VIA 2 DRA, serial port and video address
// .:ED8E C6 A5    DEC $A5         decrement the serial bus bit count
// .:ED90 D0 D4    BNE $ED66       loop if not all done
//                                 now all eight bits have been sent it's up to the peripheral to signal the byte was
//                                 received by pulling the serial data low. this should be done within one milisecond
// .:ED92 A9 04    LDA #$04        wait for up to about 1ms
// .:ED94 8D 07 DC STA $DC07       save VIA 1 timer B high byte
// .:ED97 A9 19    LDA #$19        load timer B, timer B single shot, start timer B
// .:ED99 8D 0F DC STA $DC0F       save VIA 1 CRB
// .:ED9C AD 0D DC LDA $DC0D       read VIA 1 ICR
// .:ED9F AD 0D DC LDA $DC0D       read VIA 1 ICR
// .:EDA2 29 02    AND #$02        mask 0000 00x0, timer A interrupt
// .:EDA4 D0 0A    BNE $EDB0       if timer A interrupt go do serial bus timeout
// .:EDA6 20 A9 EE JSR $EEA9       get the serial data status in Cb
// .:EDA9 B0 F4    BCS $ED9F       if the serial data is high go wait some more
// .:EDAB 58       CLI             enable the interrupts
// .:EDAC 60       RTS

.label /* $EDAD - 60845 */ EDAD_flag_errors_status_80_device_not_present = $EDAD
//                                 device not present
// .:EDAD A9 80    LDA #$80        error $80, device not present
// .:EDAF 2C       .BYTE $2C       makes next line BIT $03A9
//                                 timeout on serial bus

.label /* $EDB0 - 60848 */ EDB0_flag_errors_status_03_write_timeout = $EDB0
// .:EDB0 A9 03    LDA #$03        error $03, read timeout, write timeout
// .:EDB2 20 1C FE JSR $FE1C       OR into the serial status byte
// .:EDB5 58       CLI             enable the interrupts
// .:EDB6 18       CLC             clear for branch
// .:EDB7 90 4A    BCC $EE03       ATN high, delay, clock high then data high, branch always

.label /* $EDB9 - 60857 */ EDB9_send_listen_secondary_address = $EDB9
// send secondary address after LISTEN
//
// .:EDB9 85 95    STA $95         save the defered Tx byte
// .:EDBB 20 36 ED JSR $ED36       set the serial clk/data, wait and Tx the byte

.label /* $EDBE - 60862 */ EDBE_clear_atn = $EDBE
// set serial ATN high
//
// .:EDBE AD 00 DD LDA $DD00       read VIA 2 DRA, serial port and video address
// .:EDC1 29 F7    AND #$F7        mask xxxx 0xxx, set serial ATN high
// .:EDC3 8D 00 DD STA $DD00       save VIA 2 DRA, serial port and video address
// .:EDC6 60       RTS

.label /* $EDC7 - 60871 */ EDC7_send_talk_secondary_address = $EDC7
// send secondary address after TALK
//
// .:EDC7 85 95    STA $95         save the defered Tx byte
// .:EDC9 20 36 ED JSR $ED36       set the serial clk/data, wait and Tx the byte

.label /* $EDCC - 60876 */ EDCC_wait_for_clock = $EDCC
// wait for the serial bus end after send
//
//	                                return address from patch 6
// .:EDCC 78       SEI             disable the interrupts
// .:EDCD 20 A0 EE JSR $EEA0       set the serial data out low
// .:EDD0 20 BE ED JSR $EDBE       set serial ATN high
// .:EDD3 20 85 EE JSR $EE85       set the serial clock out high
// .:EDD6 20 A9 EE JSR $EEA9       get the serial data status in Cb
// .:EDD9 30 FB    BMI $EDD6       loop if the clock is high
// .:EDDB 58       CLI             enable the interrupts
// .:EDDC 60       RTS

.label /* $EDDD - 60893 */ EDDD_send_serial_deferred = $EDDD
// output a byte to the serial bus
//
// .:EDDD 24 94    BIT $94         test the deferred character flag
// .:EDDF 30 05    BMI $EDE6       if there is a defered character go send it
// .:EDE1 38       SEC             set carry
// .:EDE2 66 94    ROR $94         shift into the deferred character flag
// .:EDE4 D0 05    BNE $EDEB       save the byte and exit, branch always
// .:EDE6 48       PHA             save the byte
// .:EDE7 20 40 ED JSR $ED40       Tx byte on serial bus
// .:EDEA 68       PLA             restore the byte
// .:EDEB 85 95    STA $95         save the defered Tx byte
// .:EDED 18       CLC             flag ok
// .:EDEE 60       RTS

.label /* $EDEF - 60911 */ EDEF_send_untalk = $EDEF
// command serial bus to UNTALK
//
//	.:EDEF 78       SEI             disable the interrupts
//	.:EDF0 20 8E EE JSR $EE8E       set the serial clock out low
//	.:EDF3 AD 00 DD LDA $DD00       read VIA 2 DRA, serial port and video address
//	.:EDF6 09 08    ORA #$08        mask xxxx 1xxx, set the serial ATN low
//	.:EDF8 8D 00 DD STA $DD00       save VIA 2 DRA, serial port and video address
//	.:EDFB A9 5F    LDA #$5F        set the UNTALK command
//	.:EDFD 2C       .BYTE $2C       makes next line BIT $3FA9

.label /* $EDFE - 60926 */ EDFE_send_unlisten = $EDFE
// command serial bus to UNLISTEN
//
// .:EDFE A9 3F    LDA #$3F        set the UNLISTEN command
// .:EE00 20 11 ED JSR $ED11       send a control character
// .:EE03 20 BE ED JSR $EDBE       set serial ATN high
//                                 1ms delay, clock high then data high
// .:EE06 8A       TXA             save the device number
// .:EE07 A2 0A    LDX #$0A        short delay
// .:EE09 CA       DEX             decrement the count
// .:EE0A D0 FD    BNE $EE09       loop if not all done
// .:EE0C AA       TAX             restore the device number
// .:EE0D 20 85 EE JSR $EE85       set the serial clock out high
// .:EE10 4C 97 EE JMP $EE97       set the serial data out high and return

.label /* $EE13 - 60947 */ EE13_receive_from_serial_bus = $EE13
// input a byte from the serial bus
//
// .:EE13 78       SEI             disable the interrupts
// .:EE14 A9 00    LDA #$00        set 0 bits to do, will flag EOI on timeour
// .:EE16 85 A5    STA $A5         save the serial bus bit count
// .:EE18 20 85 EE JSR $EE85       set the serial clock out high
// .:EE1B 20 A9 EE JSR $EEA9       get the serial data status in Cb
// .:EE1E 10 FB    BPL $EE1B       loop if the serial clock is low
// .:EE20 A9 01    LDA #$01        set the timeout count high byte
// .:EE22 8D 07 DC STA $DC07       save VIA 1 timer B high byte
// .:EE25 A9 19    LDA #$19        load timer B, timer B single shot, start timer B
// .:EE27 8D 0F DC STA $DC0F       save VIA 1 CRB
// .:EE2A 20 97 EE JSR $EE97       set the serial data out high
// .:EE2D AD 0D DC LDA $DC0D       read VIA 1 ICR
// .:EE30 AD 0D DC LDA $DC0D       read VIA 1 ICR
// .:EE33 29 02    AND #$02        mask 0000 00x0, timer A interrupt
// .:EE35 D0 07    BNE $EE3E       if timer A interrupt go ??
// .:EE37 20 A9 EE JSR $EEA9       get the serial data status in Cb
// .:EE3A 30 F4    BMI $EE30       loop if the serial clock is low
// .:EE3C 10 18    BPL $EE56       else go set 8 bits to do, branch always
//                                 timer A timed out
// .:EE3E A5 A5    LDA $A5         get the serial bus bit count
// .:EE40 F0 05    BEQ $EE47       if not already EOI then go flag EOI
// .:EE42 A9 02    LDA #$02        else error $02, read timeour
// .:EE44 4C B2 ED JMP $EDB2       set the serial status and exit
// .:EE47 20 A0 EE JSR $EEA0       set the serial data out low
// .:EE4A 20 85 EE JSR $EE85       set the serial clock out high
// .:EE4D A9 40    LDA #$40        set EOI
// .:EE4F 20 1C FE JSR $FE1C       OR into the serial status byte
// .:EE52 E6 A5    INC $A5         increment the serial bus bit count, do error on the next
//                                 timeout
// .:EE54 D0 CA    BNE $EE20       go try again, branch always
// .:EE56 A9 08    LDA #$08        set 8 bits to do
// .:EE58 85 A5    STA $A5         save the serial bus bit count
// .:EE5A AD 00 DD LDA $DD00       read VIA 2 DRA, serial port and video address
// .:EE5D CD 00 DD CMP $DD00       compare it with itself
// .:EE60 D0 F8    BNE $EE5A       if changing go try again
// .:EE62 0A       ASL             shift the serial data into the carry
// .:EE63 10 F5    BPL $EE5A       loop while the serial clock is low
// .:EE65 66 A4    ROR $A4         shift the data bit into the receive byte
// .:EE67 AD 00 DD LDA $DD00       read VIA 2 DRA, serial port and video address
// .:EE6A CD 00 DD CMP $DD00       compare it with itself
// .:EE6D D0 F8    BNE $EE67       if changing go try again
// .:EE6F 0A       ASL             shift the serial data into the carry
// .:EE70 30 F5    BMI $EE67       loop while the serial clock is high
// .:EE72 C6 A5    DEC $A5         decrement the serial bus bit count
// .:EE74 D0 E4    BNE $EE5A       loop if not all done
// .:EE76 20 A0 EE JSR $EEA0       set the serial data out low
// .:EE79 24 90    BIT $90         test the serial status byte
// .:EE7B 50 03    BVC $EE80       if EOI not set skip the bus end sequence
// .:EE7D 20 06 EE JSR $EE06       1ms delay, clock high then data high
// .:EE80 A5 A4    LDA $A4         get the receive byte
// .:EE82 58       CLI             enable the interrupts
// .:EE83 18       CLC             flag ok
// .:EE84 60       RTS

.label /* $EE85 - 61061 */ EE85_serial_clock_on = $EE85
// set the serial clock out high
//
// .:EE85 AD 00 DD LDA $DD00       read VIA 2 DRA, serial port and video address
// .:EE88 29 EF    AND #$EF        mask xxx0 xxxx, set serial clock out high
// .:EE8A 8D 00 DD STA $DD00       save VIA 2 DRA, serial port and video address
// .:EE8D 60       RTS

.label /* $EE8E - 61070 */ EE8E_serial_clock_off = $EE8E
// set the serial clock out low
//
// .:EE8E AD 00 DD LDA $DD00       read VIA 2 DRA, serial port and video address
// .:EE91 09 10    ORA #$10        mask xxx1 xxxx, set serial clock out low
// .:EE93 8D 00 DD STA $DD00       save VIA 2 DRA, serial port and video address
// .:EE96 60       RTS

.label /* $EE97 - 61079 */ EE97_serial_output_1 = $EE97
// set the serial data out high
//
// .:EE97 AD 00 DD LDA $DD00       read VIA 2 DRA, serial port and video address
// .:EE9A 29 DF    AND #$DF        mask xx0x xxxx, set serial data out high
// .:EE9C 8D 00 DD STA $DD00       save VIA 2 DRA, serial port and video address
// .:EE9F 60       RTS

.label /* $EEA0 - 61088 */ EEA0_serial_output_0 = $EEA0
// set the serial data out low
//
// .:EEA0 AD 00 DD LDA $DD00       read VIA 2 DRA, serial port and video address
// .:EEA3 09 20    ORA #$20        mask xx1x xxxx, set serial data out low
// .:EEA5 8D 00 DD STA $DD00       save VIA 2 DRA, serial port and video address
// .:EEA8 60       RTS

.label /* $EEA9 - 61097 */ EEA9_get_serial_data_and_clock_in = $EEA9
// get the serial data status in Cb
//
// .:EEA9 AD 00 DD LDA $DD00       read VIA 2 DRA, serial port and video address
// .:EEAC CD 00 DD CMP $DD00       compare it with itself
// .:EEAF D0 F8    BNE $EEA9       if changing got try again
// .:EEB1 0A       ASL             shift the serial data into Cb
// .:EEB2 60       RTS

.label /* $EEB3 - 61107 */ EEB3_delay_1_ms = $EEB3
// 1ms delay
//
// .:EEB3 8A       TXA             save X
// .:EEB4 A2 B8    LDX #$B8        set the loop count
// .:EEB6 CA       DEX             decrement the loop count
// .:EEB7 D0 FD    BNE $EEB6       loop if more to do
// .:EEB9 AA       TAX             restore X
// .:EEBA 60       RTS

.label /* $EEBB - 61115 */ EEBB_rs232_send = $EEBB
//RS232 Tx NMI routine
//
// .:EEBB A5 B4    LDA $B4         get RS232 bit count
// .:EEBD F0 47    BEQ $EF06       if zero go setup next RS232 Tx byte and return
// .:EEBF 30 3F    BMI $EF00       if -ve go do stop bit(s)
//                                 else bit count is non zero and +ve
// .:EEC1 46 B6    LSR $B6         shift RS232 output byte buffer
// .:EEC3 A2 00    LDX #$00        set $00 for bit = 0
// .:EEC5 90 01    BCC $EEC8       branch if bit was 0
// .:EEC7 CA       DEX             set $FF for bit = 1
// .:EEC8 8A       TXA             copy bit to A
// .:EEC9 45 BD    EOR $BD         EOR with RS232 parity byte
// .:EECB 85 BD    STA $BD         save RS232 parity byte
// .:EECD C6 B4    DEC $B4         decrement RS232 bit count
// .:EECF F0 06    BEQ $EED7       if RS232 bit count now zero go do parity bit
//                                 save bit and exit
// .:EED1 8A       TXA             copy bit to A
// .:EED2 29 04    AND #$04        mask 0000 0x00, RS232 Tx DATA bit
// .:EED4 85 B5    STA $B5         save the next RS232 data bit to send
// .:EED6 60       RTS
//
// do RS232 parity bit, enters with RS232 bit count = 0
//
// .:EED7 A9 20    LDA #$20        mask 00x0 0000, parity enable bit
// .:EED9 2C 94 02 BIT $0294       test the pseudo 6551 command register
// .:EEDC F0 14    BEQ $EEF2       if parity disabled go ??
// .:EEDE 30 1C    BMI $EEFC       if fixed mark or space parity go ??
// .:EEE0 70 14    BVS $EEF6       if even parity go ??
//                                 else odd parity
// .:EEE2 A5 BD    LDA $BD         get RS232 parity byte
// .:EEE4 D0 01    BNE $EEE7       if parity not zero leave parity bit = 0
// .:EEE6 CA       DEX             make parity bit = 1
// .:EEE7 C6 B4    DEC $B4         decrement RS232 bit count, 1 stop bit
// .:EEE9 AD 93 02 LDA $0293       get pseudo 6551 control register
// .:EEEC 10 E3    BPL $EED1       if 1 stop bit save parity bit and exit
//                                 else two stop bits ..
// .:EEEE C6 B4    DEC $B4         decrement RS232 bit count, 2 stop bits
// .:EEF0 D0 DF    BNE $EED1       save bit and exit, branch always
//                                 parity is disabled so the parity bit becomes the first,
//                                 and possibly only, stop bit. to do this increment the bit
//                                 count which effectively decrements the stop bit count.
// .:EEF2 E6 B4    INC $B4         increment RS232 bit count, = -1 stop bit
// .:EEF4 D0 F0    BNE $EEE6       set stop bit = 1 and exit
//                                 do even parity
// .:EEF6 A5 BD    LDA $BD         get RS232 parity byte
// .:EEF8 F0 ED    BEQ $EEE7       if parity zero leave parity bit = 0
// .:EEFA D0 EA    BNE $EEE6       else make parity bit = 1, branch always
//                                 fixed mark or space parity
// .:EEFC 70 E9    BVS $EEE7       if fixed space parity leave parity bit = 0
// .:EEFE 50 E6    BVC $EEE6       else fixed mark parity make parity bit = 1, branch always
//                                 decrement stop bit count, set stop bit = 1 and exit. $FF is one stop bit, $FE is two
//                                 stop bits
// .:EF00 E6 B4    INC $B4         decrement RS232 bit count
// .:EF02 A2 FF    LDX #$FF        set stop bit = 1
// .:EF04 D0 CB    BNE $EED1       save stop bit and exit, branch always

.label /* $EF06 - 61190 */ EF06_send_new_rs232_byte = $EF06
// setup next RS232 Tx byte
//
// .:EF06 AD 94 02 LDA $0294       read the 6551 pseudo command register
// .:EF09 4A       LSR             handshake bit inot Cb
// .:EF0A 90 07    BCC $EF13       if 3 line interface go ??
// .:EF0C 2C 01 DD BIT $DD01       test VIA 2 DRB, RS232 port
// .:EF0F 10 1D    BPL $EF2E       if DSR = 0 set DSR signal not present and exit
// .:EF11 50 1E    BVC $EF31       if CTS = 0 set CTS signal not present and exit
//                                 was 3 line interface
// .:EF13 A9 00    LDA #$00        clear A
// .:EF15 85 BD    STA $BD         clear the RS232 parity byte
// .:EF17 85 B5    STA $B5         clear the RS232 next bit to send
// .:EF19 AE 98 02 LDX $0298       get the number of bits to be sent/received
// .:EF1C 86 B4    STX $B4         set the RS232 bit count
// .:EF1E AC 9D 02 LDY $029D       get the index to the Tx buffer start
// .:EF21 CC 9E 02 CPY $029E       compare it with the index to the Tx buffer end
// .:EF24 F0 13    BEQ $EF39       if all done go disable T?? interrupt and return
// .:EF26 B1 F9    LDA ($F9),Y     else get a byte from the buffer
// .:EF28 85 B6    STA $B6         save it to the RS232 output byte buffer
// .:EF2A EE 9D 02 INC $029D       increment the index to the Tx buffer start
// .:EF2D 60       RTS

.label /* $EF2E - 61230 */ EF2E_no_dsr_no_cts_error = $EF2E
// set DSR signal not present
//
// .:EF2E A9 40    LDA #$40        set DSR signal not present
// .:EF30 2C       .BYTE $2C       makes next line BIT $10A9
//
// set CTS signal not present
//
// .:EF31 A9 10    LDA #$10        set CTS signal not present
// .:EF33 0D 97 02 ORA $0297       OR it with the RS232 status register
// .:EF36 8D 97 02 STA $0297       save the RS232 status register

.label /* $EF39 - 61241 */ EF39_disable_timer = $EF39
// disable timer A interrupt
//
// .:EF39 A9 01    LDA #$01        disable timer A interrupt
//
// set VIA 2 ICR from A
//
// .:EF3B 8D 0D DD STA $DD0D       save VIA 2 ICR
// .:EF3E 4D A1 02 EOR $02A1       EOR with the RS-232 interrupt enable byte
// .:EF41 09 80    ORA #$80        set the interrupts enable bit
// .:EF43 8D A1 02 STA $02A1       save the RS-232 interrupt enable byte
// .:EF46 8D 0D DD STA $DD0D       save VIA 2 ICR
// .:EF49 60       RTS

.label /* $EF4A - 61258 */ EF4A_compute_bit_count = $EF4A
// compute bit count
//
// .:EF4A A2 09    LDX #$09        set bit count to 9, 8 data + 1 stop bit
// .:EF4C A9 20    LDA #$20        mask for 8/7 data bits
// .:EF4E 2C 93 02 BIT $0293       test pseudo 6551 control register
// .:EF51 F0 01    BEQ $EF54       branch if 8 bits
// .:EF53 CA       DEX             else decrement count for 7 data bits
// .:EF54 50 02    BVC $EF58       branch if 7 bits
// .:EF56 CA       DEX             else decrement count ..
// .:EF57 CA       DEX             .. for 5 data bits
// .:EF58 60       RTS

.label /* $EF59 - 61273 */ EF59_rs232_receive = $EF59
// RS232 Rx NMI
//
// .:EF59 A6 A9    LDX $A9         get start bit check flag
// .:EF5B D0 33    BNE $EF90       if no start bit received go ??
// .:EF5D C6 A8    DEC $A8         decrement receiver bit count in
// .:EF5F F0 36    BEQ $EF97       if the byte is complete go add it to the buffer
// .:EF61 30 0D    BMI $EF70
// .:EF63 A5 A7    LDA $A7         get the RS232 received data bit
// .:EF65 45 AB    EOR $AB         EOR with the receiver parity bit
// .:EF67 85 AB    STA $AB         save the receiver parity bit
// .:EF69 46 A7    LSR $A7         shift the RS232 received data bit
// .:EF6B 66 AA    ROR $AA
// .:EF6D 60       RTS
// .:EF6E C6 A8    DEC $A8         decrement receiver bit count in
// .:EF70 A5 A7    LDA $A7         get the RS232 received data bit
// .:EF72 F0 67    BEQ $EFDB
// .:EF74 AD 93 02 LDA $0293       get pseudo 6551 control register
// .:EF77 0A       ASL             shift the stop bit flag to Cb
// .:EF78 A9 01    LDA #$01        + 1
// .:EF7A 65 A8    ADC $A8         add receiver bit count in
// .:EF7C D0 EF    BNE $EF6D       exit, branch always

.label /* $EF7E - 61310 */ EF7E_set_up_to_receive = $EF7E
// setup to receive an RS232 bit
//
// .:EF7E A9 90    LDA #$90        enable FLAG interrupt
// .:EF80 8D 0D DD STA $DD0D       save VIA 2 ICR
// .:EF83 0D A1 02 ORA $02A1       OR with the RS-232 interrupt enable byte
// .:EF86 8D A1 02 STA $02A1       save the RS-232 interrupt enable byte
// .:EF89 85 A9    STA $A9         set start bit check flag, set no start bit received
// .:EF8B A9 02    LDA #$02        disable timer B interrupt
// .:EF8D 4C 3B EF JMP $EF3B       set VIA 2 ICR from A and return

.label /* $EF90 - 61328 */ EF90_process_rs232_byte = $EF90
// no RS232 start bit received
//
// .:EF90 A5 A7    LDA $A7         get the RS232 received data bit
// .:EF92 D0 EA    BNE $EF7E       if ?? go setup to receive an RS232 bit and return
// .:EF94 4C D3 E4 JMP $E4D3       flag the RS232 start bit and set the parity
//
// received a whole byte, add it to the buffer
//
//
// .:EF97 AC 9B 02 LDY $029B       get index to Rx buffer end
// .:EF9A C8       INY             increment index
// .:EF9B CC 9C 02 CPY $029C       compare with index to Rx buffer start
// .:EF9E F0 2A    BEQ $EFCA       if buffer full go do Rx overrun error
// .:EFA0 8C 9B 02 STY $029B       save index to Rx buffer end
// .:EFA3 88       DEY             decrement index
// .:EFA4 A5 AA    LDA $AA         get assembled byte
// .:EFA6 AE 98 02 LDX $0298       get bit count
// .:EFA9 E0 09    CPX #$09        compare with byte + stop
// .:EFAB F0 04    BEQ $EFB1       branch if all nine bits received
// .:EFAD 4A       LSR             else shift byte
// .:EFAE E8       INX             increment bit count
// .:EFAF D0 F8    BNE $EFA9       loop, branch always
// .:EFB1 91 F7    STA ($F7),Y     save received byte to Rx buffer
// .:EFB3 A9 20    LDA #$20        mask 00x0 0000, parity enable bit
// .:EFB5 2C 94 02 BIT $0294       test the pseudo 6551 command register
// .:EFB8 F0 B4    BEQ $EF6E       branch if parity disabled
// .:EFBA 30 B1    BMI $EF6D       branch if mark or space parity
// .:EFBC A5 A7    LDA $A7         get the RS232 received data bit
// .:EFBE 45 AB    EOR $AB         EOR with the receiver parity bit
// .:EFC0 F0 03    BEQ $EFC5
// .:EFC2 70 A9    BVS $EF6D       if ?? just exit
// .:EFC4 2C       .BYTE $2C       makes next line BIT $A650
// .:EFC5 50 A6    BVC $EF6D       if ?? just exit
// .:EFC7 A9 01    LDA #$01        set Rx parity error
// .:EFC9 2C       .BYTE $2C       makes next line BIT $04A9
// .:EFCA A9 04    LDA #$04        set Rx overrun error
// .:EFCC 2C       .BYTE $2C       makes next line BIT $80A9
// .:EFCD A9 80    LDA #$80        set Rx break error
// .:EFCF 2C       .BYTE $2C       makes next line BIT $02A9
// .:EFD0 A9 02    LDA #$02        set Rx frame error
// .:EFD2 0D 97 02 ORA $0297       OR it with the RS232 status byte
// .:EFD5 8D 97 02 STA $0297       save the RS232 status byte
// .:EFD8 4C 7E EF JMP $EF7E       setup to receive an RS232 bit and return
// .:EFDB A5 AA    LDA $AA
// .:EFDD D0 F1    BNE $EFD0       if ?? do frame error
// .:EFDF F0 EC    BEQ $EFCD       else do break error, branch always

.label /* $EFE1 - 61409 */ EFE1_submit_to_rs232 = $EFE1
// open RS232 channel for output
//
// .:EFE1 85 9A    STA $9A         save the output device number
// .:EFE3 AD 94 02 LDA $0294       read the pseudo 6551 command register
// .:EFE6 4A       LSR             shift handshake bit to carry
// .:EFE7 90 29    BCC $F012       if 3 line interface go ??
// .:EFE9 A9 02    LDA #$02        mask 0000 00x0, RTS out
// .:EFEB 2C 01 DD BIT $DD01       test VIA 2 DRB, RS232 port
// .:EFEE 10 1D    BPL $F00D       if DSR = 0 set DSR not present and exit
// .:EFF0 D0 20    BNE $F012       if RTS = 1 just exit
// .:EFF2 AD A1 02 LDA $02A1       get the RS-232 interrupt enable byte
// .:EFF5 29 02    AND #$02        mask 0000 00x0, timer B interrupt
// .:EFF7 D0 F9    BNE $EFF2       loop while the timer B interrupt is enebled
// .:EFF9 2C 01 DD BIT $DD01       test VIA 2 DRB, RS232 port
// .:EFFC 70 FB    BVS $EFF9       loop while CTS high
// .:EFFE AD 01 DD LDA $DD01       read VIA 2 DRB, RS232 port
// .:F001 09 02    ORA #$02        mask xxxx xx1x, set RTS high
// .:F003 8D 01 DD STA $DD01       save VIA 2 DRB, RS232 port
// .:F006 2C 01 DD BIT $DD01       test VIA 2 DRB, RS232 port
// .:F009 70 07    BVS $F012       exit if CTS high
// .:F00B 30 F9    BMI $F006       loop while DSR high

.label /* $F00D - 61453 */ F00D_no_dsr_data_set_ready_error = $F00D
//                                 set no DSR and exit
// .:F00D A9 40    LDA #$40        set DSR signal not present
// .:F00F 8D 97 02 STA $0297       save the RS232 status register
// .:F012 18       CLC             flag ok
// .:F013 60       RTS
//
//	send byte to the RS232 buffer
//
// .:F014 20 28 F0 JSR $F028       setup for RS232 transmit

.label /* $F017 - 61463 */ F017_send_to_rs232_buffer = $F017
//                                 send byte to the RS232 buffer, no setup
// .:F017 AC 9E 02 LDY $029E       get index to Tx buffer end
// .:F01A C8       INY             + 1
// .:F01B CC 9D 02 CPY $029D       compare with index to Tx buffer start
// .:F01E F0 F4    BEQ $F014       loop while buffer full
// .:F020 8C 9E 02 STY $029E       set index to Tx buffer end
// .:F023 88       DEY             index to available buffer byte
// .:F024 A5 9E    LDA $9E         read the RS232 character buffer
// .:F026 91 F9    STA ($F9),Y     save the byte to the buffer
//
// setup for RS232 transmit
//
// .:F028 AD A1 02 LDA $02A1       get the RS-232 interrupt enable byte
// .:F02B 4A       LSR             shift the enable bit to Cb
// .:F02C B0 1E    BCS $F04C       if interrupts are enabled just exit
// .:F02E A9 10    LDA #$10        start timer A
// .:F030 8D 0E DD STA $DD0E       save VIA 2 CRA
// .:F033 AD 99 02 LDA $0299       get the baud rate bit time low byte
// .:F036 8D 04 DD STA $DD04       save VIA 2 timer A low byte
// .:F039 AD 9A 02 LDA $029A       get the baud rate bit time high byte
// .:F03C 8D 05 DD STA $DD05       save VIA 2 timer A high byte
// .:F03F A9 81    LDA #$81        enable timer A interrupt
// .:F041 20 3B EF JSR $EF3B       set VIA 2 ICR from A
// .:F044 20 06 EF JSR $EF06       setup next RS232 Tx byte
// .:F047 A9 11    LDA #$11        load timer A, start timer A
// .:F049 8D 0E DD STA $DD0E       save VIA 2 CRA
// .:F04C 60       RTS

.label /* $F04D - 61517 */ F04D_input_from_rs232 = $F04D
// input from RS232 buffer
//
// .:F04D 85 99    STA $99         save the input device number
// .:F04F AD 94 02 LDA $0294       get pseudo 6551 command register
// .:F052 4A       LSR             shift the handshake bit to Cb
// .:F053 90 28    BCC $F07D       if 3 line interface go ??
// .:F055 29 08    AND #$08        mask the duplex bit, pseudo 6551 command is >> 1
// .:F057 F0 24    BEQ $F07D       if full duplex go ??
// .:F059 A9 02    LDA #$02        mask 0000 00x0, RTS out
// .:F05B 2C 01 DD BIT $DD01       test VIA 2 DRB, RS232 port
// .:F05E 10 AD    BPL $F00D       if DSR = 0 set no DSR and exit
// .:F060 F0 22    BEQ $F084       if RTS = 0 just exit
// .:F062 AD A1 02 LDA $02A1       get the RS-232 interrupt enable byte
// .:F065 4A       LSR             shift the timer A interrupt enable bit to Cb
// .:F066 B0 FA    BCS $F062       loop while the timer A interrupt is enabled
// .:F068 AD 01 DD LDA $DD01       read VIA 2 DRB, RS232 port
// .:F06B 29 FD    AND #$FD        mask xxxx xx0x, clear RTS out
// .:F06D 8D 01 DD STA $DD01       save VIA 2 DRB, RS232 port
// .:F070 AD 01 DD LDA $DD01       read VIA 2 DRB, RS232 port
// .:F073 29 04    AND #$04        mask xxxx x1xx, DTR in
// .:F075 F0 F9    BEQ $F070       loop while DTR low
// .:F077 A9 90    LDA #$90        enable the FLAG interrupt
// .:F079 18       CLC             flag ok
// .:F07A 4C 3B EF JMP $EF3B       set VIA 2 ICR from A and return
// .:F07D AD A1 02 LDA $02A1       get the RS-232 interrupt enable byte
// .:F080 29 12    AND #$12        mask 000x 00x0
// .:F082 F0 F3    BEQ $F077       if FLAG or timer B bits set go enable the FLAG inetrrupt
// .:F084 18       CLC             flag ok
// .:F085 60       RTS

.label /* $F086 - 61574 */ F086_get_from_rs232 = $F086
// get byte from RS232 buffer
//
// .:F086 AD 97 02 LDA $0297       get the RS232 status register
// .:F089 AC 9C 02 LDY $029C       get index to Rx buffer start
// .:F08C CC 9B 02 CPY $029B       compare with index to Rx buffer end
// .:F08F F0 0B    BEQ $F09C       return null if buffer empty
// .:F091 29 F7    AND #$F7        clear the Rx buffer empty bit
// .:F093 8D 97 02 STA $0297       save the RS232 status register
// .:F096 B1 F7    LDA ($F7),Y     get byte from Rx buffer
// .:F098 EE 9C 02 INC $029C       increment index to Rx buffer start
// .:F09B 60       RTS
// .:F09C 09 08    ORA #$08        set the Rx buffer empty bit
// .:F09E 8D 97 02 STA $0297       save the RS232 status register
// .:F0A1 A9 00    LDA #$00        return null
// .:F0A3 60       RTS

.label /* $F0A4 - 61604 */ F0A4_serial_bus_idle = $F0A4
// check RS232 bus idle
//
// .:F0A4 48       PHA             save A
// .:F0A5 AD A1 02 LDA $02A1       get the RS-232 interrupt enable byte
// .:F0A8 F0 11    BEQ $F0BB       if no interrupts enabled just exit
// .:F0AA AD A1 02 LDA $02A1       get the RS-232 interrupt enable byte
// .:F0AD 29 03    AND #$03        mask 0000 00xx, the error bits
// .:F0AF D0 F9    BNE $F0AA       if there are errors loop
// .:F0B1 A9 10    LDA #$10        disable FLAG interrupt
// .:F0B3 8D 0D DD STA $DD0D       save VIA 2 ICR
// .:F0B6 A9 00    LDA #$00        clear A
// .:F0B8 8D A1 02 STA $02A1       clear the RS-232 interrupt enable byte
// .:F0BB 68       PLA             restore A
// .:F0BC 60       RTS

.label /* $F0BD - 61629 */ F0BD_table_of_io_messages = $F0BD
// kernel I/O messages
//
// .:F0BD 0D 49 2F 4F 20 45 52 52  I/O ERROR #
// .:F0C6 52 20 A3 0D 53 45 41 52
// .:F0C9 0D 53 45 41 52 43 48 49  SEARCHING
// .:F0D1 4E 47 A0 46 4F 52 A0 0D
// .:F0D4 46 4F 52 A0 0D 50 52 45  FOR
// .:F0D8 0D 50 52 45 53 53 20 50  PRESS PLAY ON TAPE
// .:F0E0 4C 41 59 20 4F 4E 20 54
// .:F0E8 41 50 C5 50 52 45 53 53
// .:F0EB 50 52 45 53 53 20 52 45  PRESS RECORD & PLAY ON TAPE
// .:F0F3 43 4F 52 44 20 26 20 50
// .:F0FB 4C 41 59 20 4F 4E 20 54
// .:F103 41 50 C5 0D 4C 4F 41 44
// .:F106 0D 4C 4F 41 44 49 4E C7  LOADING
// .:F10E 0D 53 41 56 49 4E 47 A0  SAVING
// .:F116 0D 56 45 52 49 46 59 49  VERIFYING
// .:F11E 4E C7 0D 46 4F 55 4E 44
// .:F120 0D 46 4F 55 4E 44 A0 0D  FOUND
// .:F127 0D 4F 4B 8D              OK

.label /* $F12B - 61739 */ F12B_print_message_if_direct = $F12B
// display control I/O message if in direct mode
//
// .:F12B 24 9D    BIT $9D         test message mode flag
// .:F12D 10 0D    BPL $F13C       exit if control messages off

.label /* $F12F - 61743 */ F12F_print_message = $F12F
//	                               display kernel I/O message
// .:F12F B9 BD F0 LDA $F0BD,Y     get byte from message table
// .:F132 08       PHP             save status
// .:F133 29 7F    AND #$7F        clear b7
// .:F135 20 D2 FF JSR $FFD2       output character to channel
// .:F138 C8       INY             increment index
// .:F139 28       PLP             restore status
// .:F13A 10 F3    BPL $F12F       loop if not end of message
// .:F13C 18       CLC
// .:F13D 60       RTS

.label /* $F13E - 61758 */ F13E_get_a_byte = $F13E
// get character from the input device
//
// .:F13E A5 99    LDA $99         get the input device number
// .:F140 D0 08    BNE $F14A       if not the keyboard go handle other devices
//                                 the input device was the keyboard
// .:F142 A5 C6    LDA $C6         get the keyboard buffer index
// .:F144 F0 0F    BEQ $F155       if the buffer is empty go flag no byte and return
// .:F146 78       SEI             disable the interrupts
// .:F147 4C B4 E5 JMP $E5B4       get input from the keyboard buffer and return
//                                 the input device was not the keyboard
// .:F14A C9 02    CMP #$02        compare the device with the RS232 device
// .:F14C D0 18    BNE $F166       if not the RS232 device go ??
//	                               the input device is the RS232 device
// .:F14E 84 97    STY $97         save Y
// .:F150 20 86 F0 JSR $F086       get a byte from RS232 buffer
// .:F153 A4 97    LDY $97         restore Y
// .:F155 18       CLC             flag no error
// .:F156 60       RTS

.label /* $F157 - 61783 */ F157_input_a_byte = $F157
// input a character from channel
//
// .:F157 A5 99    LDA $99         get the input device number
// .:F159 D0 0B    BNE $F166       if not the keyboard continue
//                                 the input device was the keyboard
// .:F15B A5 D3    LDA $D3         get the cursor column
// .:F15D 85 CA    STA $CA         set the input cursor column
// .:F15F A5 D6    LDA $D6         get the cursor row
// .:F161 85 C9    STA $C9         set the input cursor row
// .:F163 4C 32 E6 JMP $E632       input from screen or keyboard
//                                 the input device was not the keyboard
// .:F166 C9 03    CMP #$03        compare device number with screen
// .:F168 D0 09    BNE $F173       if not screen continue
//                                 the input device was the screen
// .:F16A 85 D0    STA $D0         input from keyboard or screen, $xx = screen,
//                                 $00 = keyboard
// .:F16C A5 D5    LDA $D5         get current screen line length
// .:F16E 85 C8    STA $C8         save input [EOL] pointer
// .:F170 4C 32 E6 JMP $E632       input from screen or keyboard
//                                 the input device was not the screen
// .:F173 B0 38    BCS $F1AD       if input device > screen go do IEC devices
//                                 the input device was < screen
// .:F175 C9 02    CMP #$02        compare the device with the RS232 device
// .:F177 F0 3F    BEQ $F1B8       if RS232 device go get a byte from the RS232 device
//                                 only the tape device left ..
// .:F179 86 97    STX $97         save X
// .:F17B 20 99 F1 JSR $F199       get a byte from tape
// .:F17E B0 16    BCS $F196       if error just exit
// .:F180 48       PHA             save the byte
// .:F181 20 99 F1 JSR $F199       get the next byte from tape
// .:F184 B0 0D    BCS $F193       if error just exit
// .:F186 D0 05    BNE $F18D       if end reached ??
// .:F188 A9 40    LDA #$40        set EOI
// .:F18A 20 1C FE JSR $FE1C       OR into the serial status byte
// .:F18D C6 A6    DEC $A6         decrement tape buffer index
// .:F18F A6 97    LDX $97         restore X
// .:F191 68       PLA             restore the saved byte
// .:F192 60       RTS
// .:F193 AA       TAX             copy the error byte
// .:F194 68       PLA             dump the saved byte
// .:F195 8A       TXA             restore error byte
// .:F196 A6 97    LDX $97         restore X
// .:F198 60       RTS

.label /* $F199 - 61849 */ F199_get_from_tape_serial_rs232 = $F199
// get byte from tape
//
// .:F199 20 0D F8 JSR $F80D       bump tape pointer
// .:F19C D0 0B    BNE $F1A9       if not end get next byte and exit
// .:F19E 20 41 F8 JSR $F841       initiate tape read
// .:F1A1 B0 11    BCS $F1B4       exit if error flagged
// .:F1A3 A9 00    LDA #$00        clear A
// .:F1A5 85 A6    STA $A6         clear tape buffer index
// .:F1A7 F0 F0    BEQ $F199       loop, branch always
// .:F1A9 B1 B2    LDA ($B2),Y     get next byte from buffer
// .:F1AB 18       CLC             flag no error
// .:F1AC 60       RTS
//                                 input device was serial bus
// .:F1AD A5 90    LDA $90         get the serial status byte
// .:F1AF F0 04    BEQ $F1B5       if no errors flagged go input byte and return
// .:F1B1 A9 0D    LDA #$0D        else return [EOL]
// .:F1B3 18       CLC             flag no error
// .:F1B4 60       RTS
// .:F1B5 4C 13 EE JMP $EE13       input byte from serial bus and return
//                                 input device was RS232 device
// .:F1B8 20 4E F1 JSR $F14E       get byte from RS232 device
// .:F1BB B0 F7    BCS $F1B4       branch if error, this doesn't get taken as the last
//                                 instruction in the get byte from RS232 device routine
//                                 is CLC ??
// .:F1BD C9 00    CMP #$00        compare with null
// .:F1BF D0 F2    BNE $F1B3       exit if not null
// .:F1C1 AD 97 02 LDA $0297       get the RS232 status register
// .:F1C4 29 60    AND #$60        mask 0xx0 0000, DSR detected and ??
// .:F1C6 D0 E9    BNE $F1B1       if ?? return null
// .:F1C8 F0 EE    BEQ $F1B8       else loop, branch always

.label /* $F1CA - 61898 */ F1CA_output_one_character = $F1CA
// output character to channel
//
// .:F1CA 48       PHA             save the character to output
// .:F1CB A5 9A    LDA $9A         get the output device number
// .:F1CD C9 03    CMP #$03        compare the output device with the screen
// .:F1CF D0 04    BNE $F1D5       if not the screen go ??
// .:F1D1 68       PLA             else restore the output character
// .:F1D2 4C 16 E7 JMP $E716       go output the character to the screen
// .:F1D5 90 04    BCC $F1DB       if < screen go ??
// .:F1D7 68       PLA             else restore the output character
// .:F1D8 4C DD ED JMP $EDDD       go output the character to the serial bus
// .:F1DB 4A       LSR             shift b0 of the device into Cb
// .:F1DC 68       PLA             restore the output character
//
// output the character to the cassette or RS232 device
//
// .:F1DD 85 9E    STA $9E         save the character to the character buffer
// .:F1DF 8A       TXA             copy X
// .:F1E0 48       PHA             save X
// .:F1E1 98       TYA             copy Y
// .:F1E2 48       PHA             save Y
// .:F1E3 90 23    BCC $F208       if Cb is clear it must be the RS232 device
//                                 output the character to the cassette
// .:F1E5 20 0D F8 JSR $F80D       bump the tape pointer
// .:F1E8 D0 0E    BNE $F1F8       if not end save next byte and exit
// .:F1EA 20 64 F8 JSR $F864       initiate tape write
// .:F1ED B0 0E    BCS $F1FD       exit if error
// .:F1EF A9 02    LDA #$02        set data block type ??
// .:F1F1 A0 00    LDY #$00        clear index
// .:F1F3 91 B2    STA ($B2),Y     save type to buffer ??
// .:F1F5 C8       INY             increment index
// .:F1F6 84 A6    STY $A6         save tape buffer index
// .:F1F8 A5 9E    LDA $9E         restore character from character buffer
// .:F1FA 91 B2    STA ($B2),Y     save to buffer
// .:F1FC 18       CLC             flag no error
// .:F1FD 68       PLA             pull Y
// .:F1FE A8       TAY             restore Y
// .:F1FF 68       PLA             pull X
// .:F200 AA       TAX             restore X
// .:F201 A5 9E    LDA $9E         get the character from the character buffer
// .:F203 90 02    BCC $F207       exit if no error
// .:F205 A9 00    LDA #$00        else clear A
// .:F207 60       RTS
//                                 output the character to the RS232 device
// .:F208 20 17 F0 JSR $F017       send byte to the RS232 buffer, no setup
// .:F20B 4C FC F1 JMP $F1FC       do no error exit

.label /* $F20E - 61966 */ F20E_set_input_device = $F20E
// open channel for input
//
// .:F20E 20 0F F3 JSR $F30F       find a file
// .:F211 F0 03    BEQ $F216       if the file is open continue
// .:F213 4C 01 F7 JMP $F701       else do 'file not open' error and return
// .:F216 20 1F F3 JSR $F31F       set file details from table,X
// .:F219 A5 BA    LDA $BA         get the device number
// .:F21B F0 16    BEQ $F233       if the device was the keyboard save the device #, flag
//                                 ok and exit
// .:F21D C9 03    CMP #$03        compare the device number with the screen
// .:F21F F0 12    BEQ $F233       if the device was the screen save the device #, flag ok
//                                 and exit
// .:F221 B0 14    BCS $F237       if the device was a serial bus device go ??
// .:F223 C9 02    CMP #$02        else compare the device with the RS232 device
// .:F225 D0 03    BNE $F22A       if not the RS232 device continue
// .:F227 4C 4D F0 JMP $F04D       else go get input from the RS232 buffer and return
// .:F22A A6 B9    LDX $B9         get the secondary address
// .:F22C E0 60    CPX #$60
// .:F22E F0 03    BEQ $F233
// .:F230 4C 0A F7 JMP $F70A       go do 'not input file' error and return
// .:F233 85 99    STA $99         save the input device number
// .:F235 18       CLC             flag ok
// .:F236 60       RTS
//                                 the device was a serial bus device
// .:F237 AA       TAX             copy device number to X
// .:F238 20 09 ED JSR $ED09       command serial bus device to TALK
// .:F23B A5 B9    LDA $B9         get the secondary address
// .:F23D 10 06    BPL $F245
// .:F23F 20 CC ED JSR $EDCC       wait for the serial bus end after send
// .:F242 4C 48 F2 JMP $F248
// .:F245 20 C7 ED JSR $EDC7       send secondary address after TALK
// .:F248 8A       TXA             copy device back to A
// .:F249 24 90    BIT $90         test the serial status byte
// .:F24B 10 E6    BPL $F233       if device present save device number and exit
// .:F24D 4C 07 F7 JMP $F707       do 'device not present' error and return

.label /* $F250 - 62032 */ F250_set_output_device = $F250
// open channel for output
//
// .:F250 20 0F F3 JSR $F30F       find a file
// .:F253 F0 03    BEQ $F258       if file found continue
// .:F255 4C 01 F7 JMP $F701       else do 'file not open' error and return
// .:F258 20 1F F3 JSR $F31F       set file details from table,X
// .:F25B A5 BA    LDA $BA         get the device number
// .:F25D D0 03    BNE $F262       if the device is not the keyboard go ??
// .:F25F 4C 0D F7 JMP $F70D       go do 'not output file' error and return
// .:F262 C9 03    CMP #$03        compare the device with the screen
// .:F264 F0 0F    BEQ $F275       if the device is the screen go save output the output
//                                 device number and exit
// .:F266 B0 11    BCS $F279       if > screen then go handle a serial bus device
// .:F268 C9 02    CMP #$02        compare the device with the RS232 device
// .:F26A D0 03    BNE $F26F       if not the RS232 device then it must be the tape device
// .:F26C 4C E1 EF JMP $EFE1       else go open RS232 channel for output
//                                 open a tape channel for output
// .:F26F A6 B9    LDX $B9         get the secondary address
// .:F271 E0 60    CPX #$60
// .:F273 F0 EA    BEQ $F25F       if ?? do not output file error and return
// .:F275 85 9A    STA $9A         save the output device number
// .:F277 18       CLC             flag ok
// .:F278 60       RTS
// .:F279 AA       TAX             copy the device number
// .:F27A 20 0C ED JSR $ED0C       command devices on the serial bus to LISTEN
// .:F27D A5 B9    LDA $B9         get the secondary address
// .:F27F 10 05    BPL $F286       if address to send go ??
// .:F281 20 BE ED JSR $EDBE       else set serial ATN high
// .:F284 D0 03    BNE $F289       go ??, branch always
// .:F286 20 B9 ED JSR $EDB9       send secondary address after LISTEN
// .:F289 8A       TXA             copy device number back to A
// .:F28A 24 90    BIT $90         test the serial status byte
// .:F28C 10 E7    BPL $F275       if the device is present go save the output device number
//                                 and exit
// .:F28E 4C 07 F7 JMP $F707       else do 'device not present error' and return

.label /* $F291 - 62097 */ F291_close_file = $F291
// close a specified logical file
//
// .:F291 20 14 F3 JSR $F314       find file A
// .:F294 F0 02    BEQ $F298       if file found go close it
// .:F296 18       CLC             else the file was closed so just flag ok
// .:F297 60       RTS
//                                 file found so close it
// .:F298 20 1F F3 JSR $F31F       set file details from table,X
// .:F29B 8A       TXA             copy file index to A
// .:F29C 48       PHA             save file index
// .:F29D A5 BA    LDA $BA         get the device number
// .:F29F F0 50    BEQ $F2F1       if it is the keyboard go restore the index and close the
//                                 file
// .:F2A1 C9 03    CMP #$03        compare the device number with the screen
// .:F2A3 F0 4C    BEQ $F2F1       if it is the screen go restore the index and close the
//                                 file
// .:F2A5 B0 47    BCS $F2EE       if > screen go do serial bus device close
// .:F2A7 C9 02    CMP #$02        compare the device with the RS232 device
// .:F2A9 D0 1D    BNE $F2C8       if not the RS232 device go ??
//                                 else close RS232 device
// .:F2AB 68       PLA             restore file index
// .:F2AC 20 F2 F2 JSR $F2F2       close file index X
// .:F2AF 20 83 F4 JSR $F483       initialise RS232 output
// .:F2B2 20 27 FE JSR $FE27       read the top of memory
// .:F2B5 A5 F8    LDA $F8         get the RS232 input buffer pointer high byte
// .:F2B7 F0 01    BEQ $F2BA       if no RS232 input buffer go ??
// .:F2B9 C8       INY             else reclaim RS232 input buffer memory
// .:F2BA A5 FA    LDA $FA         get the RS232 output buffer pointer high byte
// .:F2BC F0 01    BEQ $F2BF       if no RS232 output buffer skip the reclaim
// .:F2BE C8       INY             else reclaim the RS232 output buffer memory
// .:F2BF A9 00    LDA #$00        clear A
// .:F2C1 85 F8    STA $F8         clear the RS232 input buffer pointer high byte
// .:F2C3 85 FA    STA $FA         clear the RS232 output buffer pointer high byte
// .:F2C5 4C 7D F4 JMP $F47D       go set the top of memory to F0xx
//                                 is not the RS232 device
// .:F2C8 A5 B9    LDA $B9         get the secondary address
// .:F2CA 29 0F    AND #$0F        mask the device #
// .:F2CC F0 23    BEQ $F2F1       if ?? restore index and close file
// .:F2CE 20 D0 F7 JSR $F7D0       get tape buffer start pointer in XY
// .:F2D1 A9 00    LDA #$00        character $00
// .:F2D3 38       SEC             flag the tape device
// .:F2D4 20 DD F1 JSR $F1DD       output the character to the cassette or RS232 device
// .:F2D7 20 64 F8 JSR $F864       initiate tape write
// .:F2DA 90 04    BCC $F2E0
// .:F2DC 68       PLA
// .:F2DD A9 00    LDA #$00
// .:F2DF 60       RTS
// .:F2E0 A5 B9    LDA $B9         get the secondary address
// .:F2E2 C9 62    CMP #$62
// .:F2E4 D0 0B    BNE $F2F1       if not ?? restore index and close file
// .:F2E6 A9 05    LDA #$05        set logical end of the tape
// .:F2E8 20 6A F7 JSR $F76A       write tape header
// .:F2EB 4C F1 F2 JMP $F2F1       restore index and close file
//
// serial bus device close
//
// .:F2EE 20 42 F6 JSR $F642       close serial bus device
// .:F2F1 68       PLA             restore file index
//
// close file index X
//
// .:F2F2 AA       TAX             copy index to file to close
// .:F2F3 C6 98    DEC $98         decrement the open file count
// .:F2F5 E4 98    CPX $98         compare the index with the open file count
// .:F2F7 F0 14    BEQ $F30D       exit if equal, last entry was closing file
//                                 else entry was not last in list so copy last table entry
//                                 file details over the details of the closing one
// .:F2F9 A4 98    LDY $98         get the open file count as index
// .:F2FB B9 59 02 LDA $0259,Y     get last+1 logical file number from logical file table
// .:F2FE 9D 59 02 STA $0259,X     save logical file number over closed file
// .:F301 B9 63 02 LDA $0263,Y     get last+1 device number from device number table
// .:F304 9D 63 02 STA $0263,X     save device number over closed file
// .:F307 B9 6D 02 LDA $026D,Y     get last+1 secondary address from secondary address table
// .:F30A 9D 6D 02 STA $026D,X     save secondary address over closed file
// .:F30D 18       CLC             flag ok
// .:F30E 60       RTS

.label /* $F30F - 62223 */ F30F_find_file = $F30F
// find a file
//
// .:F30F A9 00    LDA #$00        clear A
// .:F311 85 90    STA $90         clear the serial status byte
// .:F313 8A       TXA             copy the logical file number to A
//
// find file A
//
// .:F314 A6 98    LDX $98         get the open file count
// .:F316 CA       DEX             decrememnt the count to give the index
// .:F317 30 15    BMI $F32E       if no files just exit
// .:F319 DD 59 02 CMP $0259,X     compare the logical file number with the table logical
//                                 file number
// .:F31C D0 F8    BNE $F316       if no match go try again
// .:F31E 60       RTS

.label /* $F31F - 62239 */ F31F_set_file_values = $F31F
// set file details from table,X
//
// .:F31F BD 59 02 LDA $0259,X     get logical file from logical file table
// .:F322 85 B8    STA $B8         save the logical file
// .:F324 BD 63 02 LDA $0263,X     get device number from device number table
// .:F327 85 BA    STA $BA         save the device number
// .:F329 BD 6D 02 LDA $026D,X     get secondary address from secondary address table
// .:F32C 85 B9    STA $B9         save the secondary address
// .:F32E 60       RTS

.label /* $F32F - 62255 */ F32F_abort_all_files = $F32F
// close all channels and files
//
// .:F32F A9 00    LDA #$00        clear A
// .:F331 85 98    STA $98         clear the open file count

.label /* $F333 - 62259 */ F333_restore_default_io = $F333
// close input and output channels
//
// .:F333 A2 03    LDX #$03        set the screen device
// .:F335 E4 9A    CPX $9A         compare the screen with the output device number
// .:F337 B0 03    BCS $F33C       if <= screen skip the serial bus unlisten
// .:F339 20 FE ED JSR $EDFE       else command the serial bus to UNLISTEN
// .:F33C E4 99    CPX $99         compare the screen with the input device number
// .:F33E B0 03    BCS $F343       if <= screen skip the serial bus untalk
// .:F340 20 EF ED JSR $EDEF       else command the serial bus to UNTALK
// .:F343 86 9A    STX $9A         save the screen as the output device number
// .:F345 A9 00    LDA #$00        set the keyboard as the input device
// .:F347 85 99    STA $99         save the input device number
// .:F349 60       RTS

.label /* $F34A - 62282 */ F34A_open_file = $F34A
// open a logical file
//
// .:F34A A6 B8    LDX $B8         get the logical file
// .:F34C D0 03    BNE $F351       if there is a file continue
// .:F34E 4C 0A F7 JMP $F70A       else do 'not input file error' and return
// .:F351 20 0F F3 JSR $F30F       find a file
// .:F354 D0 03    BNE $F359       if file not found continue
// .:F356 4C FE F6 JMP $F6FE       else do 'file already open' error and return
// .:F359 A6 98    LDX $98         get the open file count
// .:F35B E0 0A    CPX #$0A        compare it with the maximum + 1
// .:F35D 90 03    BCC $F362       if less than maximum + 1 go open the file
// .:F35F 4C FB F6 JMP $F6FB       else do 'too many files error' and return
// .:F362 E6 98    INC $98         increment the open file count
// .:F364 A5 B8    LDA $B8         get the logical file
// .:F366 9D 59 02 STA $0259,X     save it to the logical file table
// .:F369 A5 B9    LDA $B9         get the secondary address
// .:F36B 09 60    ORA #$60        OR with the OPEN CHANNEL command
// .:F36D 85 B9    STA $B9         save the secondary address
// .:F36F 9D 6D 02 STA $026D,X     save it to the secondary address table
// .:F372 A5 BA    LDA $BA         get the device number
// .:F374 9D 63 02 STA $0263,X     save it to the device number table
// .:F377 F0 5A    BEQ $F3D3       if it is the keyboard go do the ok exit
// .:F379 C9 03    CMP #$03        compare the device number with the screen
// .:F37B F0 56    BEQ $F3D3       if it is the screen go do the ok exit
// .:F37D 90 05    BCC $F384       if tape or RS232 device go ??
//                                 else it is a serial bus device
// .:F37F 20 D5 F3 JSR $F3D5       send the secondary address and filename
// .:F382 90 4F    BCC $F3D3       go do ok exit, branch always
// .:F384 C9 02    CMP #$02
// .:F386 D0 03    BNE $F38B
// .:F388 4C 09 F4 JMP $F409       go open RS232 device and return
// .:F38B 20 D0 F7 JSR $F7D0       get tape buffer start pointer in XY
// .:F38E B0 03    BCS $F393       if >= $0200 go ??
// .:F390 4C 13 F7 JMP $F713       else do 'illegal device number' and return
// .:F393 A5 B9    LDA $B9         get the secondary address
// .:F395 29 0F    AND #$0F
// .:F397 D0 1F    BNE $F3B8
// .:F399 20 17 F8 JSR $F817       wait for PLAY
// .:F39C B0 36    BCS $F3D4       exit if STOP was pressed
// .:F39E 20 AF F5 JSR $F5AF       print "Searching..."
// .:F3A1 A5 B7    LDA $B7         get file name length
// .:F3A3 F0 0A    BEQ $F3AF       if null file name just go find header
// .:F3A5 20 EA F7 JSR $F7EA       find specific tape header
// .:F3A8 90 18    BCC $F3C2       branch if no error
// .:F3AA F0 28    BEQ $F3D4       exit if ??
// .:F3AC 4C 04 F7 JMP $F704       do file not found error and return
// .:F3AF 20 2C F7 JSR $F72C       find tape header, exit with header in buffer
// .:F3B2 F0 20    BEQ $F3D4       exit if end of tape found
// .:F3B4 90 0C    BCC $F3C2
// .:F3B6 B0 F4    BCS $F3AC
// .:F3B8 20 38 F8 JSR $F838       wait for PLAY/RECORD
// .:F3BB B0 17    BCS $F3D4       exit if STOP was pressed
// .:F3BD A9 04    LDA #$04        set data file header
// .:F3BF 20 6A F7 JSR $F76A       write tape header
// .:F3C2 A9 BF    LDA #$BF
// .:F3C4 A4 B9    LDY $B9         get the secondary address
// .:F3C6 C0 60    CPY #$60
// .:F3C8 F0 07    BEQ $F3D1
// .:F3CA A0 00    LDY #$00        clear index
// .:F3CC A9 02    LDA #$02
// .:F3CE 91 B2    STA ($B2),Y     save to tape buffer
// .:F3D0 98       TYA             clear A
// .:F3D1 85 A6    STA $A6         save tape buffer index
// .:F3D3 18       CLC             flag ok
// .:F3D4 60       RTS

.label /* $F3D5 - 62421 */ F3D5_send_secondary_address = $F3D5
// send secondary address and filename
//
// .:F3D5 A5 B9    LDA $B9         get the secondary address
// .:F3D7 30 FA    BMI $F3D3       ok exit if -ve
// .:F3D9 A4 B7    LDY $B7         get file name length
// .:F3DB F0 F6    BEQ $F3D3       ok exit if null
// .:F3DD A9 00    LDA #$00        clear A
// .:F3DF 85 90    STA $90         clear the serial status byte
// .:F3E1 A5 BA    LDA $BA         get the device number
// .:F3E3 20 0C ED JSR $ED0C       command devices on the serial bus to LISTEN
// .:F3E6 A5 B9    LDA $B9         get the secondary address
// .:F3E8 09 F0    ORA #$F0        OR with the OPEN command
// .:F3EA 20 B9 ED JSR $EDB9       send secondary address after LISTEN
// .:F3ED A5 90    LDA $90         get the serial status byte
// .:F3EF 10 05    BPL $F3F6       if device present skip the 'device not present' error
// .:F3F1 68       PLA             else dump calling address low byte
// .:F3F2 68       PLA             dump calling address high byte
// .:F3F3 4C 07 F7 JMP $F707       do 'device not present' error and return
// .:F3F6 A5 B7    LDA $B7         get file name length
// .:F3F8 F0 0C    BEQ $F406       branch if null name
// .:F3FA A0 00    LDY #$00        clear index
// .:F3FC B1 BB    LDA ($BB),Y     get file name byte
// .:F3FE 20 DD ED JSR $EDDD       output byte to serial bus
// .:F401 C8       INY             increment index
// .:F402 C4 B7    CPY $B7         compare with file name length
// .:F404 D0 F6    BNE $F3FC       loop if not all done
// .:F406 4C 54 F6 JMP $F654       command serial bus to UNLISTEN and return

.label /* $F409 - 62473 */ F409_open_rs232 = $F409
// open RS232 device
//
// .:F409 20 83 F4 JSR $F483       initialise RS232 output
// .:F40C 8C 97 02 STY $0297       save the RS232 status register
// .:F40F C4 B7    CPY $B7         compare with file name length
// .:F411 F0 0A    BEQ $F41D       exit loop if done
// .:F413 B1 BB    LDA ($BB),Y     get file name byte
// .:F415 99 93 02 STA $0293,Y     copy to 6551 register set
// .:F418 C8       INY             increment index
// .:F419 C0 04    CPY #$04        compare with $04
// .:F41B D0 F2    BNE $F40F       loop if not to 4 yet
// .:F41D 20 4A EF JSR $EF4A       compute bit count
// .:F420 8E 98 02 STX $0298       save bit count
// .:F423 AD 93 02 LDA $0293       get pseudo 6551 control register
// .:F426 29 0F    AND #$0F        mask 0000 xxxx, baud rate
// .:F428 F0 1C    BEQ $F446       if zero skip the baud rate setup
// .:F42A 0A       ASL             * 2 bytes per entry
// .:F42B AA       TAX             copy to the index
// .:F42C AD A6 02 LDA $02A6       get the PAL/NTSC flag
// .:F42F D0 09    BNE $F43A       if PAL go set PAL timing
// .:F431 BC C1 FE LDY $FEC1,X     get the NTSC baud rate value high byte
// .:F434 BD C0 FE LDA $FEC0,X     get the NTSC baud rate value low byte
// .:F437 4C 40 F4 JMP $F440       go save the baud rate values
// .:F43A BC EB E4 LDY $E4EB,X     get the PAL baud rate value high byte
// .:F43D BD EA E4 LDA $E4EA,X     get the PAL baud rate value low byte
// .:F440 8C 96 02 STY $0296       save the nonstandard bit timing high byte
// .:F443 8D 95 02 STA $0295       save the nonstandard bit timing low byte
// .:F446 AD 95 02 LDA $0295       get the nonstandard bit timing low byte
// .:F449 0A       ASL             * 2
// .:F44A 20 2E FF JSR $FF2E
// .:F44D AD 94 02 LDA $0294       read the pseudo 6551 command register
// .:F450 4A       LSR             shift the X line/3 line bit into Cb
// .:F451 90 09    BCC $F45C       if 3 line skip the DRS test
// .:F453 AD 01 DD LDA $DD01       read VIA 2 DRB, RS232 port
// .:F456 0A       ASL             shift DSR in into Cb
// .:F457 B0 03    BCS $F45C       if DSR present skip the error set
// .:F459 20 0D F0 JSR $F00D       set no DSR
// .:F45C AD 9B 02 LDA $029B       get index to Rx buffer end
// .:F45F 8D 9C 02 STA $029C       set index to Rx buffer start, clear Rx buffer
// .:F462 AD 9E 02 LDA $029E       get index to Tx buffer end
// .:F465 8D 9D 02 STA $029D       set index to Tx buffer start, clear Tx buffer
// .:F468 20 27 FE JSR $FE27       read the top of memory
// .:F46B A5 F8    LDA $F8         get the RS232 input buffer pointer high byte
// .:F46D D0 05    BNE $F474       if buffer already set skip the save
// .:F46F 88       DEY             decrement top of memory high byte, 256 byte buffer
// .:F470 84 F8    STY $F8         save the RS232 input buffer pointer high byte
// .:F472 86 F7    STX $F7         save the RS232 input buffer pointer low byte
// .:F474 A5 FA    LDA $FA         get the RS232 output buffer pointer high byte
// .:F476 D0 05    BNE $F47D       if ?? go set the top of memory to F0xx
// .:F478 88       DEY
// .:F479 84 FA    STY $FA         save the RS232 output buffer pointer high byte
// .:F47B 86 F9    STX $F9         save the RS232 output buffer pointer low byte
//
// set the top of memory to F0xx
//
// .:F47D 38       SEC             read the top of memory
// .:F47E A9 F0    LDA #$F0        set $F000
// .:F480 4C 2D FE JMP $FE2D       set the top of memory and return
//
// initialise RS232 output
//
// .:F483 A9 7F    LDA #$7F        disable all interrupts
// .:F485 8D 0D DD STA $DD0D       save VIA 2 ICR
// .:F488 A9 06    LDA #$06        set RS232 DTR output, RS232 RTS output
// .:F48A 8D 03 DD STA $DD03       save VIA 2 DDRB, RS232 port
// .:F48D 8D 01 DD STA $DD01       save VIA 2 DRB, RS232 port
// .:F490 A9 04    LDA #$04        mask xxxx x1xx, set RS232 Tx DATA high
// .:F492 0D 00 DD ORA $DD00       OR it with VIA 2 DRA, serial port and video address
// .:F495 8D 00 DD STA $DD00       save VIA 2 DRA, serial port and video address
// .:F498 A0 00    LDY #$00        clear Y
// .:F49A 8C A1 02 STY $02A1       clear the RS-232 interrupt enable byte
// .:F49D 60       RTS

.label /* $F49E - 62622 */ F49E_load_ram = $F49E
// load RAM from a device
//
// .:F49E 86 C3    STX $C3         set kernal setup pointer low byte
// .:F4A0 84 C4    STY $C4         set kernal setup pointer high byte
// .:F4A2 6C 30 03 JMP ($0330)     do LOAD vector, usually points to $F4A5
//
// load
//
// .:F4A5 85 93    STA $93         save load/verify flag
// .:F4A7 A9 00    LDA #$00        clear A
// .:F4A9 85 90    STA $90         clear the serial status byte
// .:F4AB A5 BA    LDA $BA         get the device number
// .:F4AD D0 03    BNE $F4B2       if not the keyboard continue
//                                 do 'illegal device number'
// .:F4AF 4C 13 F7 JMP $F713       else do 'illegal device number' and return
// .:F4B2 C9 03    CMP #$03
// .:F4B4 F0 F9    BEQ $F4AF
// .:F4B6 90 7B    BCC $F533

.label /* $F4B8 - 62648 */ F4B8_load_file_from_serial_bus = $F4B8
// .:F4B8 A4 B7    LDY $B7         get file name length
// .:F4BA D0 03    BNE $F4BF       if not null name go ??
// .:F4BC 4C 10 F7 JMP $F710       else do 'missing file name' error and return
// .:F4BF A6 B9    LDX $B9         get the secondary address
// .:F4C1 20 AF F5 JSR $F5AF       print "Searching..."
// .:F4C4 A9 60    LDA #$60
// .:F4C6 85 B9    STA $B9         save the secondary address
// .:F4C8 20 D5 F3 JSR $F3D5       send secondary address and filename
// .:F4CB A5 BA    LDA $BA         get the device number
// .:F4CD 20 09 ED JSR $ED09       command serial bus device to TALK
// .:F4D0 A5 B9    LDA $B9         get the secondary address
// .:F4D2 20 C7 ED JSR $EDC7       send secondary address after TALK
// .:F4D5 20 13 EE JSR $EE13       input byte from serial bus
// .:F4D8 85 AE    STA $AE         save program start address low byte
// .:F4DA A5 90    LDA $90         get the serial status byte
// .:F4DC 4A       LSR             shift time out read ..
// .:F4DD 4A       LSR             .. into carry bit
// .:F4DE B0 50    BCS $F530       if timed out go do file not found error and return
// .:F4E0 20 13 EE JSR $EE13       input byte from serial bus
// .:F4E3 85 AF    STA $AF         save program start address high byte
// .:F4E5 8A       TXA             copy secondary address
// .:F4E6 D0 08    BNE $F4F0       load location not set in LOAD call, so continue with the
//                                 load
// .:F4E8 A5 C3    LDA $C3         get the load address low byte
// .:F4EA 85 AE    STA $AE         save the program start address low byte
// .:F4EC A5 C4    LDA $C4         get the load address high byte
// .:F4EE 85 AF    STA $AF         save the program start address high byte
// .:F4F0 20 D2 F5 JSR $F5D2
// .:F4F3 A9 FD    LDA #$FD        mask xxxx xx0x, clear time out read bit
// .:F4F5 25 90    AND $90         mask the serial status byte
// .:F4F7 85 90    STA $90         set the serial status byte
// .:F4F9 20 E1 FF JSR $FFE1       scan stop key, return Zb = 1 = [STOP]
// .:F4FC D0 03    BNE $F501       if not [STOP] go ??
// .:F4FE 4C 33 F6 JMP $F633       else close the serial bus device and flag stop
// .:F501 20 13 EE JSR $EE13       input byte from serial bus
// .:F504 AA       TAX             copy byte
// .:F505 A5 90    LDA $90         get the serial status byte
// .:F507 4A       LSR             shift time out read ..
// .:F508 4A       LSR             .. into carry bit
// .:F509 B0 E8    BCS $F4F3       if timed out go try again
// .:F50B 8A       TXA             copy received byte back
// .:F50C A4 93    LDY $93         get load/verify flag
// .:F50E F0 0C    BEQ $F51C       if load go load
//                                 else is verify
// .:F510 A0 00    LDY #$00        clear index
// .:F512 D1 AE    CMP ($AE),Y     compare byte with previously loaded byte
// .:F514 F0 08    BEQ $F51E       if match go ??
// .:F516 A9 10    LDA #$10        flag read error
// .:F518 20 1C FE JSR $FE1C       OR into the serial status byte
// .:F51B 2C       .BYTE $2C       makes next line BIT $AE91
// .:F51C 91 AE    STA ($AE),Y     save byte to memory
// .:F51E E6 AE    INC $AE         increment save pointer low byte
// .:F520 D0 02    BNE $F524       if no rollover go ??
// .:F522 E6 AF    INC $AF         else increment save pointer high byte
// .:F524 24 90    BIT $90         test the serial status byte
// .:F526 50 CB    BVC $F4F3       loop if not end of file
//                                 close file and exit
// .:F528 20 EF ED JSR $EDEF       command serial bus to UNTALK
// .:F52B 20 42 F6 JSR $F642       close serial bus device
// .:F52E 90 79    BCC $F5A9       if ?? go flag ok and exit
// .:F530 4C 04 F7 JMP $F704       do file not found error and return

.label /* $F533 - 62771 */ F533_load_file_from_tape = $F533
// ??
//
// .:F533 4A       LSR
// .:F534 B0 03    BCS $F539
// .:F536 4C 13 F7 JMP $F713       else do 'illegal device number' and return
// .:F539 20 D0 F7 JSR $F7D0       get tape buffer start pointer in XY
// .:F53C B0 03    BCS $F541       if ??
// .:F53E 4C 13 F7 JMP $F713       else do 'illegal device number' and return
// .:F541 20 17 F8 JSR $F817       wait for PLAY
// .:F544 B0 68    BCS $F5AE       exit if STOP was pressed
// .:F546 20 AF F5 JSR $F5AF       print "Searching..."
// .:F549 A5 B7    LDA $B7         get file name length
// .:F54B F0 09    BEQ $F556
// .:F54D 20 EA F7 JSR $F7EA       find specific tape header
// .:F550 90 0B    BCC $F55D       if no error continue
// .:F552 F0 5A    BEQ $F5AE       exit if ??
// .:F554 B0 DA    BCS $F530       , branch always
// .:F556 20 2C F7 JSR $F72C       find tape header, exit with header in buffer
// .:F559 F0 53    BEQ $F5AE       exit if ??
// .:F55B B0 D3    BCS $F530
// .:F55D A5 90    LDA $90         get the serial status byte
// .:F55F 29 10    AND #$10        mask 000x 0000, read error
// .:F561 38       SEC             flag fail
// .:F562 D0 4A    BNE $F5AE       if read error just exit
// .:F564 E0 01    CPX #$01
// .:F566 F0 11    BEQ $F579
// .:F568 E0 03    CPX #$03
// .:F56A D0 DD    BNE $F549
// .:F56C A0 01    LDY #$01
// .:F56E B1 B2    LDA ($B2),Y
// .:F570 85 C3    STA $C3
// .:F572 C8       INY
// .:F573 B1 B2    LDA ($B2),Y
// .:F575 85 C4    STA $C4
// .:F577 B0 04    BCS $F57D
// .:F579 A5 B9    LDA $B9         get the secondary address
// .:F57B D0 EF    BNE $F56C
// .:F57D A0 03    LDY #$03
// .:F57F B1 B2    LDA ($B2),Y
// .:F581 A0 01    LDY #$01
// .:F583 F1 B2    SBC ($B2),Y
// .:F585 AA       TAX
// .:F586 A0 04    LDY #$04
// .:F588 B1 B2    LDA ($B2),Y
// .:F58A A0 02    LDY #$02
// .:F58C F1 B2    SBC ($B2),Y
// .:F58E A8       TAY
// .:F58F 18       CLC
// .:F590 8A       TXA
// .:F591 65 C3    ADC $C3
// .:F593 85 AE    STA $AE
// .:F595 98       TYA
// .:F596 65 C4    ADC $C4
// .:F598 85 AF    STA $AF
// .:F59A A5 C3    LDA $C3
// .:F59C 85 C1    STA $C1         set I/O start addresses low byte
// .:F59E A5 C4    LDA $C4
// .:F5A0 85 C2    STA $C2         set I/O start addresses high byte
// .:F5A2 20 D2 F5 JSR $F5D2       display "LOADING" or "VERIFYING"
// .:F5A5 20 4A F8 JSR $F84A       do the tape read
// .:F5A8 24       .BYTE $24       makes next line BIT $18, keep the error flag in Cb
// .:F5A9 18       CLC             flag ok
// .:F5AA A6 AE    LDX $AE         get the LOAD end pointer low byte
// .:F5AC A4 AF    LDY $AF         get the LOAD end pointer high byte
// .:F5AE 60       RTS

.label /* $F5AF - 62895 */ F5AF_print_searching = $F5AF
// print "Searching..."
//
// .:F5AF A5 9D    LDA $9D         get message mode flag
// .:F5B1 10 1E    BPL $F5D1       exit if control messages off
// .:F5B3 A0 0C    LDY #$0C
//                                 index to "SEARCHING "
// .:F5B5 20 2F F1 JSR $F12F       display kernel I/O message
// .:F5B8 A5 B7    LDA $B7         get file name length
// .:F5BA F0 15    BEQ $F5D1       exit if null name
// .:F5BC A0 17    LDY #$17
//                                 else index to "FOR "
// .:F5BE 20 2F F1 JSR $F12F       display kernel I/O message

.label /* $F5C1 - 62913 */ F5C1_print_filename = $F5C1
// print file name
//
// .:F5C1 A4 B7    LDY $B7         get file name length
// .:F5C3 F0 0C    BEQ $F5D1       exit if null file name
// .:F5C5 A0 00    LDY #$00        clear index
// .:F5C7 B1 BB    LDA ($BB),Y     get file name byte
// .:F5C9 20 D2 FF JSR $FFD2       output character to channel
// .:F5CC C8       INY             increment index
// .:F5CD C4 B7    CPY $B7         compare with file name length
// .:F5CF D0 F6    BNE $F5C7       loop if more to do
// .:F5D1 60       RTS

.label /* $F5D2 - 62930 */ F5D2_print_loading_verifying = $F5D2
// display "LOADING" or "VERIFYING"
//
// .:F5D2 A0 49    LDY #$49
//                                 point to "LOADING"
// .:F5D4 A5 93    LDA $93         get load/verify flag
// .:F5D6 F0 02    BEQ $F5DA       branch if load
// .:F5D8 A0 59    LDY #$59
//                                 point to "VERIFYING"
// .:F5DA 4C 2B F1 JMP $F12B       display kernel I/O message if in direct mode and return

.label /* $F5DD - 62941 */ F5DD_save_ram = $F5DD
// save RAM to device, A = index to start address, XY = end address low/high
//
// .:F5DD 86 AE    STX $AE         save end address low byte
// .:F5DF 84 AF    STY $AF         save end address high byte
// .:F5E1 AA       TAX             copy index to start pointer
// .:F5E2 B5 00    LDA $00,X       get start address low byte
// .:F5E4 85 C1    STA $C1         set I/O start addresses low byte
// .:F5E6 B5 01    LDA $01,X       get start address high byte
// .:F5E8 85 C2    STA $C2         set I/O start addresses high byte
// .:F5EA 6C 32 03 JMP ($0332)     go save, usually points to $F685
//
// save
//
// .:F5ED A5 BA    LDA $BA         get the device number
// .:F5EF D0 03    BNE $F5F4       if not keyboard go ??
//                                 else ..
// .:F5F1 4C 13 F7 JMP $F713       else do 'illegal device number' and return
// .:F5F4 C9 03    CMP #$03        compare device number with screen
// .:F5F6 F0 F9    BEQ $F5F1       if screen do illegal device number and return
// .:F5F8 90 5F    BCC $F659       branch if < screen

.label /* $F5FA - 62970 */ F5FA_save_to_serial_bus = $F5FA
//                                 is greater than screen so is serial bus
// .:F5FA A9 61    LDA #$61        set secondary address to $01
//                                 when a secondary address is to be sent to a device on
//                                 the serial bus the address must first be ORed with $60
// .:F5FC 85 B9    STA $B9         save the secondary address
// .:F5FE A4 B7    LDY $B7         get the file name length
// .:F600 D0 03    BNE $F605       if filename not null continue
// .:F602 4C 10 F7 JMP $F710       else do 'missing file name' error and return
// .:F605 20 D5 F3 JSR $F3D5       send secondary address and filename
// .:F608 20 8F F6 JSR $F68F       print saving
// .:F60B A5 BA    LDA $BA         get the device number
// .:F60D 20 0C ED JSR $ED0C       command devices on the serial bus to LISTEN
// .:F610 A5 B9    LDA $B9         get the secondary address
// .:F612 20 B9 ED JSR $EDB9       send secondary address after LISTEN
// .:F615 A0 00    LDY #$00        clear index
// .:F617 20 8E FB JSR $FB8E       copy I/O start address to buffer address
// .:F61A A5 AC    LDA $AC         get buffer address low byte
// .:F61C 20 DD ED JSR $EDDD       output byte to serial bus
// .:F61F A5 AD    LDA $AD         get buffer address high byte
// .:F621 20 DD ED JSR $EDDD       output byte to serial bus
// .:F624 20 D1 FC JSR $FCD1       check read/write pointer, return Cb = 1 if pointer >= end
// .:F627 B0 16    BCS $F63F       go do UNLISTEN if at end
// .:F629 B1 AC    LDA ($AC),Y     get byte from buffer
// .:F62B 20 DD ED JSR $EDDD       output byte to serial bus
// .:F62E 20 E1 FF JSR $FFE1       scan stop key
// .:F631 D0 07    BNE $F63A       if stop not pressed go increment pointer and loop for next
//                                 else ..
//                                 close the serial bus device and flag stop
// .:F633 20 42 F6 JSR $F642       close serial bus device
// .:F636 A9 00    LDA #$00
// .:F638 38       SEC             flag stop
// .:F639 60       RTS
// .:F63A 20 DB FC JSR $FCDB       increment read/write pointer
// .:F63D D0 E5    BNE $F624       loop, branch always
// .:F63F 20 FE ED JSR $EDFE       command serial bus to UNLISTEN
//                                 close serial bus device
// .:F642 24 B9    BIT $B9         test the secondary address
// .:F644 30 11    BMI $F657       if already closed just exit
// .:F646 A5 BA    LDA $BA         get the device number
// .:F648 20 0C ED JSR $ED0C       command devices on the serial bus to LISTEN
// .:F64B A5 B9    LDA $B9         get the secondary address
// .:F64D 29 EF    AND #$EF        mask the channel number
// .:F64F 09 E0    ORA #$E0        OR with the CLOSE command
// .:F651 20 B9 ED JSR $EDB9       send secondary address after LISTEN
// .:F654 20 FE ED JSR $EDFE       command serial bus to UNLISTEN
// .:F657 18       CLC             flag ok
// .:F658 60       RTS

.label /* $F659 - 63065 */ F659_save_to_tape = $F659
// .:F659 4A       LSR
// .:F65A B0 03    BCS $F65F       if not RS232 device ??
// .:F65C 4C 13 F7 JMP $F713       else do 'illegal device number' and return
// .:F65F 20 D0 F7 JSR $F7D0       get tape buffer start pointer in XY
// .:F662 90 8D    BCC $F5F1       if < $0200 do illegal device number and return
// .:F664 20 38 F8 JSR $F838       wait for PLAY/RECORD
// .:F667 B0 25    BCS $F68E       exit if STOP was pressed
// .:F669 20 8F F6 JSR $F68F       print saving
// .:F66C A2 03    LDX #$03        set header for a non relocatable program file
// .:F66E A5 B9    LDA $B9         get the secondary address
// .:F670 29 01    AND #$01        mask non relocatable bit
// .:F672 D0 02    BNE $F676       if non relocatable program go ??
// .:F674 A2 01    LDX #$01        else set header for a relocatable program file
// .:F676 8A       TXA             copy header type to A
// .:F677 20 6A F7 JSR $F76A       write tape header
// .:F67A B0 12    BCS $F68E       exit if error
// .:F67C 20 67 F8 JSR $F867       do tape write, 20 cycle count
// .:F67F B0 0D    BCS $F68E       exit if error
// .:F681 A5 B9    LDA $B9         get the secondary address
// .:F683 29 02    AND #$02        mask end of tape flag
// .:F685 F0 06    BEQ $F68D       if not end of tape go ??
// .:F687 A9 05    LDA #$05        else set logical end of the tape
// .:F689 20 6A F7 JSR $F76A       write tape header
// .:F68C 24       .BYTE $24       makes next line BIT $18 so Cb is not changed
// .:F68D 18       CLC             flag ok
// .:F68E 60       RTS

.label /* $F68F - 63119 */ F68F_print_saving = $F68F
//	print saving <file name>
//
// .:F68F A5 9D    LDA $9D         get message mode flag
// .:F691 10 FB    BPL $F68E       exit if control messages off
// .:F693 A0 51    LDY #$51
//                                 index to "SAVING "
// .:F695 20 2F F1 JSR $F12F       display kernel I/O message
// .:F698 4C C1 F5 JMP $F5C1       print file name and return


.label /* $F69B - 63131 */ F69B_bump_clock = $F69B
// increment the real time clock
//
// .:F69B A2 00    LDX #$00        clear X
// .:F69D E6 A2    INC $A2         increment the jiffy clock low byte
// .:F69F D0 06    BNE $F6A7       if no rollover ??
// .:F6A1 E6 A1    INC $A1         increment the jiffy clock mid byte
// .:F6A3 D0 02    BNE $F6A7       branch if no rollover
// .:F6A5 E6 A0    INC $A0         increment the jiffy clock high byte
//                                 now subtract a days worth of jiffies from current count
//                                 and remember only the Cb result
// .:F6A7 38       SEC             set carry for subtract
// .:F6A8 A5 A2    LDA $A2         get the jiffy clock low byte
// .:F6AA E9 01    SBC #$01        subtract $4F1A01 low byte
// .:F6AC A5 A1    LDA $A1         get the jiffy clock mid byte
// .:F6AE E9 1A    SBC #$1A        subtract $4F1A01 mid byte
// .:F6B0 A5 A0    LDA $A0         get the jiffy clock high byte
// .:F6B2 E9 4F    SBC #$4F        subtract $4F1A01 high byte
// .:F6B4 90 06    BCC $F6BC       if less than $4F1A01 jiffies skip the clock reset
//                                 else ..
// .:F6B6 86 A0    STX $A0         clear the jiffy clock high byte
// .:F6B8 86 A1    STX $A1         clear the jiffy clock mid byte
// .:F6BA 86 A2    STX $A2         clear the jiffy clock low byte
//                                 this is wrong, there are $4F1A00 jiffies in a day so
//                                 the reset to zero should occur when the value reaches
//                                 $4F1A00 and not $4F1A01. this would give an extra jiffy
//                                 every day and a possible TI value of 24:00:00
// .:F6BC AD 01 DC LDA $DC01       read VIA 1 DRB, keyboard row port
// .:F6BF CD 01 DC CMP $DC01       compare it with itself
// .:F6C2 D0 F8    BNE $F6BC       loop if changing
// .:F6C4 AA       TAX
// .:F6C5 30 13    BMI $F6DA
// .:F6C7 A2 BD    LDX #$BD        set c6
// .:F6C9 8E 00 DC STX $DC00       save VIA 1 DRA, keyboard column drive
// .:F6CC AE 01 DC LDX $DC01       read VIA 1 DRB, keyboard row port
// .:F6CF EC 01 DC CPX $DC01       compare it with itself
// .:F6D2 D0 F8    BNE $F6CC       loop if changing
// .:F6D4 8D 00 DC STA $DC00       save VIA 1 DRA, keyboard column drive
// .:F6D7 E8       INX
// .:F6D8 D0 02    BNE $F6DC
// .:F6DA 85 91    STA $91         save the stop key column
// .:F6DC 60       RTS

.label /* $F6DD - 63197 */ F6DD_get_time = $F6DD
// read the real time clock
//
// .:F6DD 78       SEI             disable the interrupts
// .:F6DE A5 A2    LDA $A2         get the jiffy clock low byte
// .:F6E0 A6 A1    LDX $A1         get the jiffy clock mid byte
// .:F6E2 A4 A0    LDY $A0         get the jiffy clock high byte

.label /* $F6E4 - 63204 */ F6E4_set_time = $F6E4
//set the real time clock
//
// .:F6E4 78       SEI             disable the interrupts
// .:F6E5 85 A2    STA $A2         save the jiffy clock low byte
// .:F6E7 86 A1    STX $A1         save the jiffy clock mid byte
// .:F6E9 84 A0    STY $A0         save the jiffy clock high byte
// .:F6EB 58       CLI             enable the interrupts
// .:F6EC 60       RTS

.label /* $F6ED - 63213 */ F6ED_check_stop_key = $F6ED
// scan the stop key, return Zb = 1 = [STOP]
//
// .:F6ED A5 91    LDA $91         read the stop key column
// .:F6EF C9 7F    CMP #$7F        compare with [STP] down
// .:F6F1 D0 07    BNE $F6FA       if not [STP] or not just [STP] exit
//                                 just [STP] was pressed
// .:F6F3 08       PHP             save status
// .:F6F4 20 CC FF JSR $FFCC       close input and output channels
// .:F6F7 85 C6    STA $C6         save the keyboard buffer index
// .:F6F9 28       PLP             restore status
// .:F6FA 60       RTS

.label /* $F6FB - 63227 */ F6FB_output_io_error_messages_too_many_files = $F6FB
// file error messages
//
// .:F6FB A9 01    LDA #$01        'too many files' error
// .:F6FD 2C       .BYTE $2C       makes next line BIT $02A9

.label /* $F6FE - 63230 */ F6FE_output_io_error_messages_file_open = $F6FE
// .:F6FE A9 02    LDA #$02        'file already open' error
// .:F700 2C       .BYTE $2C       makes next line BIT $03A9

.label /* $F701 - 63233 */ F701_output_io_error_messages_file_not_open = $F701
// .:F701 A9 03    LDA #$03        'file not open' error
// .:F703 2C       .BYTE $2C       makes next line BIT $04A9

.label /* $F704 - 63236 */ F704_output_io_error_messages_file_not_found = $F704
// .:F704 A9 04    LDA #$04        'file not found' error
// .:F706 2C       .BYTE $2C       makes next line BIT $05A9

.label /* $F707 - 63239 */ F707_output_io_error_messages_device_not_present = $F707
// .:F707 A9 05    LDA #$05        'device not present' error
// .:F709 2C       .BYTE $2C       makes next line BIT $06A9

.label /* $F70A - 63242 */ F70A_output_io_error_messages_not_input_file = $F70A
// .:F70A A9 06    LDA #$06        'not input file' error
// .:F70C 2C       .BYTE $2C       makes next line BIT $07A9

.label /* $F70D - 63245 */ F70D_output_io_error_messages_not_output_file = $F70D
// .:F70D A9 07    LDA #$07        'not output file' error
// .:F70F 2C       .BYTE $2C       makes next line BIT $08A9

.label /* $F710 - 63248 */ F710_output_io_error_messages_missing_filename = $F710
// .:F710 A9 08    LDA #$08        'missing file name' error
// .:F712 2C       .BYTE $2C       makes next line BIT $09A9

.label /* $F713 - 63251 */ F713_output_io_error_messages_illegal_device_number = $F713
// .:F713 A9 09    LDA #$09        do 'illegal device number'
// .:F715 48       PHA             save the error #
// .:F716 20 CC FF JSR $FFCC       close input and output channels
// .:F719 A0 00    LDY #$00
//                                 index to "I/O ERROR #"
// .:F71B 24 9D    BIT $9D         test message mode flag
// .:F71D 50 0A    BVC $F729       exit if kernal messages off
// .:F71F 20 2F F1 JSR $F12F       display kernel I/O message
// .:F722 68       PLA             restore error #
// .:F723 48       PHA             copy error #
// .:F724 09 30    ORA #$30        convert to ASCII
// .:F726 20 D2 FF JSR $FFD2       output character to channel
// .:F729 68       PLA             pull error number
// .:F72A 38       SEC             flag error
// .:F72B 60       RTS

.label /* $F72C - 63276 */ F72C_find_any_tape_header = $F72C
//
// find the tape header, exit with header in buffer
//
// .:F72C A5 93    LDA $93         get load/verify flag
// .:F72E 48       PHA             save load/verify flag
// .:F72F 20 41 F8 JSR $F841       initiate tape read
// .:F732 68       PLA             restore load/verify flag
// .:F733 85 93    STA $93         save load/verify flag
// .:F735 B0 32    BCS $F769       exit if error
// .:F737 A0 00    LDY #$00        clear the index
// .:F739 B1 B2    LDA ($B2),Y     read first byte from tape buffer
// .:F73B C9 05    CMP #$05        compare with logical end of the tape
// .:F73D F0 2A    BEQ $F769       if end of the tape exit
// .:F73F C9 01    CMP #$01        compare with header for a relocatable program file
// .:F741 F0 08    BEQ $F74B       if program file header go ??
// .:F743 C9 03    CMP #$03        compare with header for a non relocatable program file
// .:F745 F0 04    BEQ $F74B       if program file header go  ??
// .:F747 C9 04    CMP #$04        compare with data file header
// .:F749 D0 E1    BNE $F72C       if data file loop to find the tape header
//                                 was a program file header
// .:F74B AA       TAX             copy header type
// .:F74C 24 9D    BIT $9D         get message mode flag
// .:F74E 10 17    BPL $F767       exit if control messages off
// .:F750 A0 63    LDY #$63
//                                 index to "FOUND "
// .:F752 20 2F F1 JSR $F12F       display kernel I/O message
// .:F755 A0 05    LDY #$05        index to the tape filename
// .:F757 B1 B2    LDA ($B2),Y     get byte from tape buffer
// .:F759 20 D2 FF JSR $FFD2       output character to channel
// .:F75C C8       INY             increment the index
// .:F75D C0 15    CPY #$15        compare it with end+1
// .:F75F D0 F6    BNE $F757       loop if more to do
// .:F761 A5 A1    LDA $A1         get the jiffy clock mid byte
// .:F763 20 E0 E4 JSR $E4E0       wait ~8.5 seconds for any key from the STOP key column
// .:F766 EA       NOP             waste cycles
// .:F767 18       CLC             flag no error
// .:F768 88       DEY             decrement the index
// .:F769 60       RTS
//

.label /* $F76A - 63338 */ F76A_write_tape_header = $F76A
// write the tape header
//
// .:F76A 85 9E    STA $9E         save header type
// .:F76C 20 D0 F7 JSR $F7D0       get tape buffer start pointer in XY
// .:F76F 90 5E    BCC $F7CF       if < $0200 just exit ??
// .:F771 A5 C2    LDA $C2         get I/O start address high byte
// .:F773 48       PHA             save it
// .:F774 A5 C1    LDA $C1         get I/O start address low byte
// .:F776 48       PHA             save it
// .:F777 A5 AF    LDA $AF         get tape end address high byte
// .:F779 48       PHA             save it
// .:F77A A5 AE    LDA $AE         get tape end address low byte
// .:F77C 48       PHA             save it
// .:F77D A0 BF    LDY #$BF        index to header end
// .:F77F A9 20    LDA #$20        clear byte, [SPACE]
// .:F781 91 B2    STA ($B2),Y     clear header byte
// .:F783 88       DEY             decrement index
// .:F784 D0 FB    BNE $F781       loop if more to do
// .:F786 A5 9E    LDA $9E         get the header type back
// .:F788 91 B2    STA ($B2),Y     write it to header
// .:F78A C8       INY             increment the index
// .:F78B A5 C1    LDA $C1         get the I/O start address low byte
// .:F78D 91 B2    STA ($B2),Y     write it to header
// .:F78F C8       INY             increment the index
// .:F790 A5 C2    LDA $C2         get the I/O start address high byte
// .:F792 91 B2    STA ($B2),Y     write it to header
// .:F794 C8       INY             increment the index
// .:F795 A5 AE    LDA $AE         get the tape end address low byte
// .:F797 91 B2    STA ($B2),Y     write it to header
// .:F799 C8       INY             increment the index
// .:F79A A5 AF    LDA $AF         get the tape end address high byte
// .:F79C 91 B2    STA ($B2),Y     write it to header
// .:F79E C8       INY             increment the index
// .:F79F 84 9F    STY $9F         save the index
// .:F7A1 A0 00    LDY #$00        clear Y
// .:F7A3 84 9E    STY $9E         clear the name index
// .:F7A5 A4 9E    LDY $9E         get name index
// .:F7A7 C4 B7    CPY $B7         compare with file name length
// .:F7A9 F0 0C    BEQ $F7B7       if all done exit the loop
// .:F7AB B1 BB    LDA ($BB),Y     get file name byte
// .:F7AD A4 9F    LDY $9F         get buffer index
// .:F7AF 91 B2    STA ($B2),Y     save file name byte to buffer
// .:F7B1 E6 9E    INC $9E         increment file name index
// .:F7B3 E6 9F    INC $9F         increment tape buffer index
// .:F7B5 D0 EE    BNE $F7A5       loop, branch always
// .:F7B7 20 D7 F7 JSR $F7D7       set tape buffer start and end pointers
// .:F7BA A9 69    LDA #$69set write lead cycle count
// .:F7BC 85 AB    STA $AB         save write lead cycle count
// .:F7BE 20 6B F8 JSR $F86B       do tape write, no cycle count set
// .:F7C1 A8       TAY
// .:F7C2 68       PLA             pull tape end address low byte
// .:F7C3 85 AE    STA $AE         restore it
// .:F7C5 68       PLA             pull tape end address high byte
// .:F7C6 85 AF    STA $AF         restore it
// .:F7C8 68       PLA             pull I/O start addresses low byte
// .:F7C9 85 C1    STA $C1         restore it
// .:F7CB 68       PLA             pull I/O start addresses high byte
// .:F7CC 85 C2    STA $C2         restore it
// .:F7CE 98       TYA
// .:F7CF 60       RTS

.label /* $F7D0 - 63440 */ F7D0_get_buffer_address = $F7D0
// get the tape buffer start pointer
//
// .:F7D0 A6 B2    LDX $B2         get tape buffer start pointer low byte
// .:F7D2 A4 B3    LDY $B3         get tape buffer start pointer high byte
// .:F7D4 C0 02    CPY #$02        compare high byte with $02xx
// .:F7D6 60       RTS

.label /* $F7D7 - 63447 */ F7D7_set_buffer_stat_end_pointers = $F7D7
// set the tape buffer start and end pointers
//
// .:F7D7 20 D0 F7 JSR $F7D0       get tape buffer start pointer in XY
// .:F7DA 8A       TXA             copy tape buffer start pointer low byte
// .:F7DB 85 C1    STA $C1         save as I/O address pointer low byte
// .:F7DD 18       CLC             clear carry for add
// .:F7DE 69 C0    ADC #$C0        add buffer length low byte
// .:F7E0 85 AE    STA $AE         save tape buffer end pointer low byte
// .:F7E2 98       TYA             copy tape buffer start pointer high byte
// .:F7E3 85 C2    STA $C2         save as I/O address pointer high byte
// .:F7E5 69 00    ADC #$00        add buffer length high byte
// .:F7E7 85 AF    STA $AF         save tape buffer end pointer high byte
// .:F7E9 60       RTS

.label /* $F7EA - 63466 */ F7EA_find_specific_tape_header = $F7EA
// find specific tape header

// .:F7EA 20 2C F7 JSR $F72C       find tape header, exit with header in buffer
// .:F7ED B0 1D    BCS $F80C       just exit if error
// .:F7EF A0 05    LDY #$05        index to name
// .:F7F1 84 9F    STY $9F         save as tape buffer index
// .:F7F3 A0 00    LDY #$00        clear Y
// .:F7F5 84 9E    STY $9E         save as name buffer index
// .:F7F7 C4 B7    CPY $B7         compare with file name length
// .:F7F9 F0 10    BEQ $F80B       ok exit if match
// .:F7FB B1 BB    LDA ($BB),Y     get file name byte
// .:F7FD A4 9F    LDY $9F         get index to tape buffer
// .:F7FF D1 B2    CMP ($B2),Y     compare with tape header name byte
// .:F801 D0 E7    BNE $F7EA       if no match go get next header
// .:F803 E6 9E    INC $9E         else increment name buffer index
// .:F805 E6 9F    INC $9F         increment tape buffer index
// .:F807 A4 9E    LDY $9E         get name buffer index
// .:F809 D0 EC    BNE $F7F7       loop, branch always
// .:F80B 18       CLC             flag ok
// .:F80C 60       RTS

.label /* $F80D - 63501 */ F80D_bump_tape_pointer = $F80D
// bump tape pointer
//
// .:F80D 20 D0 F7 JSR $F7D0       get tape buffer start pointer in XY
// .:F810 E6 A6    INC $A6         increment tape buffer index
// .:F812 A4 A6    LDY $A6         get tape buffer index
// .:F814 C0 C0    CPY #$C0        compare with buffer length
// .:F816 60       RTS

.label /* $F817 - 63511 */ F817_print_press_play_on_tape = $F817
// wait for PLAY
//
// .:F817 20 2E F8 JSR $F82E       return cassette sense in Zb
// .:F81A F0 1A    BEQ $F836       if switch closed just exit
//                                 cassette switch was open
// .:F81C A0 1B    LDY #$1B
//                                 index to "PRESS PLAY ON TAPE"
// .:F81E 20 2F F1 JSR $F12F       display kernel I/O message
// .:F821 20 D0 F8 JSR $F8D0       scan stop key and flag abort if pressed
//                                 note if STOP was pressed the return is to the
//                                 routine that called this one and not here
// .:F824 20 2E F8 JSR $F82E       return cassette sense in Zb
// .:F827 D0 F8    BNE $F821       loop if the cassette switch is open
// .:F829 A0 6A    LDY #$6A
//                                 index to "OK"
// .:F82B 4C 2F F1 JMP $F12F       display kernel I/O message and return

.label /* $F82E - 63534 */ F82E_check_tape_status = $F82E
// return cassette sense in Zb
//
// .:F82E A9 10    LDA #$10        set the mask for the cassette switch
// .:F830 24 01    BIT $01         test the 6510 I/O port
// .:F832 D0 02    BNE $F836       branch if cassette sense high
// .:F834 24 01    BIT $01         test the 6510 I/O port
// .:F836 18       CLC
// .:F837 60       RTS

.label /* $F838 - 63544 */ F838_print_press_record = $F838
// wait for PLAY/RECORD
//
// .:F838 20 2E F8 JSR $F82E       return the cassette sense in Zb
// .:F83B F0 F9    BEQ $F836       exit if switch closed
//                                 cassette switch was open
// .:F83D A0 2E    LDY #$2E
//                                 index to "PRESS RECORD & PLAY ON TAPE"
// .:F83F D0 DD    BNE $F81E       display message and wait for switch, branch always

.label /* $F841 - 63553 */ F841_initiate_tape_read = $F841
// initiate a tape read
//
// .:F841 A9 00    LDA #$00        clear A
// .:F843 85 90    STA $90         clear serial status byte
// .:F845 85 93    STA $93         clear the load/verify flag
// .:F847 20 D7 F7 JSR $F7D7       set the tape buffer start and end pointers
// .:F84A 20 17 F8 JSR $F817       wait for PLAY
// .:F84D B0 1F    BCS $F86E       exit if STOP was pressed, uses a further BCS at the
//                                 target address to reach final target at $F8DC
// .:F84F 78       SEI             disable interrupts
// .:F850 A9 00    LDA #$00        clear A
// .:F852 85 AA    STA $AA
// .:F854 85 B4    STA $B4
// .:F856 85 B0    STA $B0         clear tape timing constant min byte
// .:F858 85 9E    STA $9E         clear tape pass 1 error log/char buffer
// .:F85A 85 9F    STA $9F         clear tape pass 2 error log corrected
// .:F85C 85 9C    STA $9C         clear byte received flag
// .:F85E A9 90    LDA #$90        enable CA1 interrupt ??
// .:F860 A2 0E    LDX #$0E        set index for tape read vector
// .:F862 D0 11    BNE $F875       go do tape read/write, branch always

.label /* $F864 - 63588 */ F864_initiate_tape_write = $F864
// initiate a tape write
//
// .:F864 20 D7 F7 JSR $F7D7       set tape buffer start and end pointers
//                                 do tape write, 20 cycle count
// .:F867 A9 14    LDA #$14        set write lead cycle count
// .:F869 85 AB    STA $AB         save write lead cycle count
//                                 do tape write, no cycle count set
// .:F86B 20 38 F8 JSR $F838       wait for PLAY/RECORD
// .:F86E B0 6C    BCS $F8DC       if STOPped clear save IRQ address and exit
// .:F870 78       SEI             disable interrupts
// .:F871 A9 82    LDA #$82        enable ?? interrupt
// .:F873 A2 08    LDX #$08        set index for tape write tape leader vector

.label /* $F875 - 63605 */ F875_common_tape_code = $F875
// tape read/write
//
// .:F875 A0 7F    LDY #$7F        disable all interrupts
// .:F877 8C 0D DC STY $DC0D       save VIA 1 ICR, disable all interrupts
// .:F87A 8D 0D DC STA $DC0D       save VIA 1 ICR, enable interrupts according to A
//                                 check RS232 bus idle
// .:F87D AD 0E DC LDA $DC0E       read VIA 1 CRA
// .:F880 09 19    ORA #$19        load timer B, timer B single shot, start timer B
// .:F882 8D 0F DC STA $DC0F       save VIA 1 CRB
// .:F885 29 91    AND #$91        mask x00x 000x, TOD clock, load timer A, start timer A
// .:F887 8D A2 02 STA $02A2       save VIA 1 CRB shadow copy
// .:F88A 20 A4 F0 JSR $F0A4
// .:F88D AD 11 D0 LDA $D011       read the vertical fine scroll and control register
// .:F890 29 EF    AND #$EF        mask xxx0 xxxx, blank the screen
// .:F892 8D 11 D0 STA $D011       save the vertical fine scroll and control register
// .:F895 AD 14 03 LDA $0314       get IRQ vector low byte
// .:F898 8D 9F 02 STA $029F       save IRQ vector low byte
// .:F89B AD 15 03 LDA $0315       get IRQ vector high byte
// .:F89E 8D A0 02 STA $02A0       save IRQ vector high byte
// .:F8A1 20 BD FC JSR $FCBD       set the tape vector
// .:F8A4 A9 02    LDA #$02        set copies count. the first copy is the load copy, the
//                                 second copy is the verify copy
// .:F8A6 85 BE    STA $BE         save copies count
// .:F8A8 20 97 FB JSR $FB97       new tape byte setup
// .:F8AB A5 01    LDA $01         read the 6510 I/O port
// .:F8AD 29 1F    AND #$1F        mask 000x xxxx, cassette motor on ??
// .:F8AF 85 01    STA $01         save the 6510 I/O port
// .:F8B1 85 C0    STA $C0         set the tape motor interlock
//                                 326656 cycle delay, allow tape motor speed to stabilise
// .:F8B3 A2 FF    LDX #$FF        outer loop count
// .:F8B5 A0 FF    LDY #$FF        inner loop count
// .:F8B7 88       DEY             decrement inner loop count
// .:F8B8 D0 FD    BNE $F8B7       loop if more to do
// .:F8BA CA       DEX             decrement outer loop count
// .:F8BB D0 F8    BNE $F8B5       loop if more to do
// .:F8BD 58       CLI             enable tape interrupts
// .:F8BE AD A0 02 LDA $02A0       get saved IRQ high byte
// .:F8C1 CD 15 03 CMP $0315       compare with the current IRQ high byte
// .:F8C4 18       CLC             flag ok
// .:F8C5 F0 15    BEQ $F8DC       if tape write done go clear saved IRQ address and exit
// .:F8C7 20 D0 F8 JSR $F8D0       scan stop key and flag abort if pressed
//                                 note if STOP was pressed the return is to the
//                                 routine that called this one and not here
// .:F8CA 20 BC F6 JSR $F6BC       increment real time clock
// .:F8CD 4C BE F8 JMP $F8BE       loop

.label /* $F8D0 - 63696 */ F8D0_check_tape_stop = $F8D0
// scan stop key and flag abort if pressed
//
// .:F8D0 20 E1 FF JSR $FFE1       scan stop key
// .:F8D3 18       CLC             flag no stop
// .:F8D4 D0 0B    BNE $F8E1       exit if no stop
// .:F8D6 20 93 FC JSR $FC93       restore everything for STOP
// .:F8D9 38       SEC             flag stopped
// .:F8DA 68       PLA             dump return address low byte
// .:F8DB 68       PLA             dump return address high byte
//
// clear saved IRQ address
//
// .:F8DC A9 00    LDA #$00        clear A
// .:F8DE 8D A0 02 STA $02A0       clear saved IRQ address high byte
// .:F8E1 60       RTS

.label /* $F8E2 - 63714 */ F8E2_set_read_timing = $F8E2
// # set timing
//
// .:F8E2 86 B1    STX $B1         save tape timing constant max byte
// .:F8E4 A5 B0    LDA $B0         get tape timing constant min byte
// .:F8E6 0A       ASL             *2
// .:F8E7 0A       ASL             *4
// .:F8E8 18       CLC             clear carry for add
// .:F8E9 65 B0    ADC $B0         add tape timing constant min byte *5
// .:F8EB 18       CLC             clear carry for add
// .:F8EC 65 B1    ADC $B1         add tape timing constant max byte
// .:F8EE 85 B1    STA $B1         save tape timing constant max byte
// .:F8F0 A9 00    LDA #$00
// .:F8F2 24 B0    BIT $B0         test tape timing constant min byte
// .:F8F4 30 01    BMI $F8F7       branch if b7 set
// .:F8F6 2A       ROL             else shift carry into ??
// .:F8F7 06 B1    ASL $B1         shift tape timing constant max byte
// .:F8F9 2A       ROL
// .:F8FA 06 B1    ASL $B1         shift tape timing constant max byte
// .:F8FC 2A       ROL
// .:F8FD AA       TAX
// .:F8FE AD 06 DC LDA $DC06       get VIA 1 timer B low byte
// .:F901 C9 16    CMP #$16        compare with ??
// .:F903 90 F9    BCC $F8FE       loop if less
// .:F905 65 B1    ADC $B1         add tape timing constant max byte
// .:F907 8D 04 DC STA $DC04       save VIA 1 timer A low byte
// .:F90A 8A       TXA
// .:F90B 6D 07 DC ADC $DC07       add VIA 1 timer B high byte
// .:F90E 8D 05 DC STA $DC05       save VIA 1 timer A high byte
// .:F911 AD A2 02 LDA $02A2       read VIA 1 CRB shadow copy
// .:F914 8D 0E DC STA $DC0E       save VIA 1 CRA
// .:F917 8D A4 02 STA $02A4       save VIA 1 CRA shadow copy
// .:F91A AD 0D DC LDA $DC0D       read VIA 1 ICR
// .:F91D 29 10    AND #$10        mask 000x 0000, FLAG interrupt
// .:F91F F0 09    BEQ $F92A       if no FLAG interrupt just exit
//                                 else first call the IRQ routine
// .:F921 A9 F9    LDA #$F9        set the return address high byte
// .:F923 48       PHA             push the return address high byte
// .:F924 A9 2A    LDA #$2A        set the return address low byte
// .:F926 48       PHA             push the return address low byte
// .:F927 4C 43 FF JMP $FF43       save the status and do the IRQ routine
// .:F92A 58       CLI             enable interrupts
// .:F92B 60       RTS

.label /* $F92C - 63788 */ F92C_read_tape_bits = $F92C
// On Commodore computers, the streams consist of four kinds of symbols
//
//                                that denote different kinds of low-to-high-to-low transitions on the
//                                read or write signals of the Commodore cassette interface.
//
//                                A A break in the communications, or a pulse with very long cycle
//                                   time.
//
//                                B A short pulse, whose cycle time typically ranges from 296 to 424
//                                   microseconds, depending on the computer model.
//
//                                C A medium-length pulse, whose cycle time typically ranges from
//                                  440 to 576 microseconds, depending on the computer model.
//
//                                D A long pulse, whose cycle time typically ranges from 600 to 744
//                                  microseconds, depending on the computer model.
//
//                                 The actual interpretation of the serial data takes a little more work to explain.
//                                 The typical ROM tape loader (and the turbo loaders) will initialize a timer with a
//                                 specified value and start it counting down. If either the tape data changes or the
//                                 timer runs out, an IRQ will occur. The loader will determine which condition caused
//                                 the IRQ. If the tape data changed before the timer ran out, we have a short pulse,
//                                 or a "0" bit. If the timer ran out first, we have a long pulse, or a "1" bit. Doing
//                                 this continuously and we decode the entire file.
//                                 read tape bits, IRQ routine
//                                 read T2C which has been counting down from $FFFF. subtract this from $FFFF
// .:F92C AE 07 DC LDX $DC07       read VIA 1 timer B high byte
// .:F92F A0 FF    LDY #$FF        set $FF
// .:F931 98       TYA             A = $FF
// .:F932 ED 06 DC SBC $DC06       subtract VIA 1 timer B low byte
// .:F935 EC 07 DC CPX $DC07       compare it with VIA 1 timer B high byte
// .:F938 D0 F2    BNE $F92C       if timer low byte rolled over loop
// .:F93A 86 B1    STX $B1         save tape timing constant max byte
// .:F93C AA       TAX             copy $FF - T2C_l
// .:F93D 8C 06 DC STY $DC06       save VIA 1 timer B low byte
// .:F940 8C 07 DC STY $DC07       save VIA 1 timer B high byte
// .:F943 A9 19    LDA #$19        load timer B, timer B single shot, start timer B
// .:F945 8D 0F DC STA $DC0F       save VIA 1 CRB
// .:F948 AD 0D DC LDA $DC0D       read VIA 1 ICR
// .:F94B 8D A3 02 STA $02A3       save VIA 1 ICR shadow copy
// .:F94E 98       TYA             y = $FF
// .:F94F E5 B1    SBC $B1         subtract tape timing constant max byte
//                                 A = $FF - T2C_h
// .:F951 86 B1    STX $B1         save tape timing constant max byte
//                                 $B1 = $FF - T2C_l
// .:F953 4A       LSR             A = $FF - T2C_h >> 1
// .:F954 66 B1    ROR $B1         shift tape timing constant max byte
//                                 $B1 = $FF - T2C_l >> 1
// .:F956 4A       LSR             A = $FF - T2C_h >> 1
// .:F957 66 B1    ROR $B1         shift tape timing constant max byte
//                                 $B1 = $FF - T2C_l >> 1
// .:F959 A5 B0    LDA $B0         get tape timing constant min byte
// .:F95B 18       CLC             clear carry for add
// .:F95C 69 3C    ADC #$3C
// .:F95E C5 B1    CMP $B1         compare with tape timing constant max byte
//                                 compare with ($FFFF - T2C) >> 2
// .:F960 B0 4A    BCS $F9AC       branch if min + $3C >= ($FFFF - T2C) >> 2
//                                 min + $3C < ($FFFF - T2C) >> 2
// .:F962 A6 9C    LDX $9C         get byte received flag
// .:F964 F0 03    BEQ $F969        if not byte received ??
// .:F966 4C 60 FA JMP $FA60       store the tape character
// .:F969 A6 A3    LDX $A3         get EOI flag byte
// .:F96B 30 1B    BMI $F988
// .:F96D A2 00    LDX #$00
// .:F96F 69 30    ADC #$30
// .:F971 65 B0    ADC $B0         add tape timing constant min byte
// .:F973 C5 B1    CMP $B1         compare with tape timing constant max byte
// .:F975 B0 1C    BCS $F993
// .:F977 E8       INX
// .:F978 69 26    ADC #$26
// .:F97A 65 B0    ADC $B0         add tape timing constant min byte
// .:F97C C5 B1    CMP $B1         compare with tape timing constant max byte
// .:F97E B0 17    BCS $F997
// .:F980 69 2C    ADC #$2C
// .:F982 65 B0    ADC $B0         add tape timing constant min byte
// .:F984 C5 B1    CMP $B1         compare with tape timing constant max byte
// .:F986 90 03    BCC $F98B
// .:F988 4C 10 FA JMP $FA10
// .:F98B A5 B4    LDA $B4         get the bit count
// .:F98D F0 1D    BEQ $F9AC       if all done go ??
// .:F98F 85 A8    STA $A8         save receiver bit count in
// .:F991 D0 19    BNE $F9AC       branch always
// .:F993 E6 A9    INC $A9         increment ?? start bit check flag
// .:F995 B0 02    BCS $F999
// .:F997 C6 A9    DEC $A9         decrement ?? start bit check flag
// .:F999 38       SEC
// .:F99A E9 13    SBC #$13
// .:F99C E5 B1    SBC $B1         subtract tape timing constant max byte
// .:F99E 65 92    ADC $92         add timing constant for tape
// .:F9A0 85 92    STA $92         save timing constant for tape
// .:F9A2 A5 A4    LDA $A4         get tape bit cycle phase
// .:F9A4 49 01    EOR #$01
// .:F9A6 85 A4    STA $A4         save tape bit cycle phase
// .:F9A8 F0 2B    BEQ $F9D5
// .:F9AA 86 D7    STX $D7
// .:F9AC A5 B4    LDA $B4         get the bit count
// .:F9AE F0 22    BEQ $F9D2       if all done go ??
// .:F9B0 AD A3 02 LDA $02A3       read VIA 1 ICR shadow copy
// .:F9B3 29 01    AND #$01        mask 0000 000x, timer A interrupt enabled
// .:F9B5 D0 05    BNE $F9BC       if timer A is enabled go ??
// .:F9B7 AD A4 02 LDA $02A4       read VIA 1 CRA shadow copy
// .:F9BA D0 16    BNE $F9D2       if ?? just exit
// .:F9BC A9 00    LDA #$00        clear A
// .:F9BE 85 A4    STA $A4         clear the tape bit cycle phase
// .:F9C0 8D A4 02 STA $02A4       save VIA 1 CRA shadow copy
// .:F9C3 A5 A3    LDA $A3         get EOI flag byte
// .:F9C5 10 30    BPL $F9F7
// .:F9C7 30 BF    BMI $F988
// .:F9C9 A2 A6    LDX #$A6        set timimg max byte
// .:F9CB 20 E2 F8 JSR $F8E2       set timing
// .:F9CE A5 9B    LDA $9B
// .:F9D0 D0 B9    BNE $F98B
// .:F9D2 4C BC FE JMP $FEBC       restore registers and exit interrupt
// .:F9D5 A5 92    LDA $92         get timing constant for tape
// .:F9D7 F0 07    BEQ $F9E0
// .:F9D9 30 03    BMI $F9DE
// .:F9DB C6 B0    DEC $B0         decrement tape timing constant min byte
// .:F9DD 2C       .BYTE $2C       makes next line BIT $B0E6
// .:F9DE E6 B0    INC $B0         increment tape timing constant min byte
// .:F9E0 A9 00    LDA #$00
// .:F9E2 85 92    STA $92         clear timing constant for tape
// .:F9E4 E4 D7    CPX $D7
// .:F9E6 D0 0F    BNE $F9F7
// .:F9E8 8A       TXA
// .:F9E9 D0 A0    BNE $F98B
// .:F9EB A5 A9    LDA $A9         get start bit check flag
// .:F9ED 30 BD    BMI $F9AC
// .:F9EF C9 10    CMP #$10
// .:F9F1 90 B9    BCC $F9AC
// .:F9F3 85 96    STA $96         save cassette block synchronization number
// .:F9F5 B0 B5    BCS $F9AC
// .:F9F7 8A       TXA
// .:F9F8 45 9B    EOR $9B
// .:F9FA 85 9B    STA $9B
// .:F9FC A5 B4    LDA $B4
// .:F9FE F0 D2    BEQ $F9D2
// .:FA00 C6 A3    DEC $A3         decrement EOI flag byte
// .:FA02 30 C5    BMI $F9C9
// .:FA04 46 D7    LSR $D7
// .:FA06 66 BF    ROR $BF         parity count
// .:FA08 A2 DA    LDX #$DA        set timimg max byte
// .:FA0A 20 E2 F8 JSR $F8E2       set timing
// .:FA0D 4C BC FE JMP $FEBC       restore registers and exit interrupt
// .:FA10 A5 96    LDA $96         get cassette block synchronization number
// .:FA12 F0 04    BEQ $FA18
// .:FA14 A5 B4    LDA $B4
// .:FA16 F0 07    BEQ $FA1F
// .:FA18 A5 A3    LDA $A3         get EOI flag byte
// .:FA1A 30 03    BMI $FA1F
// .:FA1C 4C 97 F9 JMP $F997
// .:FA1F 46 B1    LSR $B1         shift tape timing constant max byte
// .:FA21 A9 93    LDA #$93
// .:FA23 38       SEC
// .:FA24 E5 B1    SBC $B1         subtract tape timing constant max byte
// .:FA26 65 B0    ADC $B0         add tape timing constant min byte
// .:FA28 0A       ASL
// .:FA29 AA       TAX             copy timimg high byte
// .:FA2A 20 E2 F8 JSR $F8E2       set timing
// .:FA2D E6 9C    INC $9C
// .:FA2F A5 B4    LDA $B4
// .:FA31 D0 11    BNE $FA44
// .:FA33 A5 96    LDA $96         get cassette block synchronization number
// .:FA35 F0 26    BEQ $FA5D
// .:FA37 85 A8    STA $A8         save receiver bit count in
// .:FA39 A9 00    LDA #$00        clear A
// .:FA3B 85 96    STA $96         clear cassette block synchronization number
// .:FA3D A9 81    LDA #$81        enable timer A interrupt
// .:FA3F 8D 0D DC STA $DC0D       save VIA 1 ICR
// .:FA42 85 B4    STA $B4
// .:FA44 A5 96    LDA $96         get cassette block synchronization number
// .:FA46 85 B5    STA $B5
// .:FA48 F0 09    BEQ $FA53
// .:FA4A A9 00    LDA #$00
// .:FA4C 85 B4    STA $B4
// .:FA4E A9 01    LDA #$01        disable timer A interrupt
// .:FA50 8D 0D DC STA $DC0D       save VIA 1 ICR
// .:FA53 A5 BF    LDA $BF         parity count
// .:FA55 85 BD    STA $BD         save RS232 parity byte
// .:FA57 A5 A8    LDA $A8         get receiver bit count in
// .:FA59 05 A9    ORA $A9         OR with start bit check flag
// .:FA5B 85 B6    STA $B6
// .:FA5D 4C BC FE JMP $FEBC       restore registers and exit interrupt

.label /* $FA60 - 64096 */ FA60_store_tape_characters = $FA60
// # store character
//
// .:FA60 20 97 FB JSR $FB97       new tape byte setup
// .:FA63 85 9C    STA $9C         clear byte received flag
// .:FA65 A2 DA    LDX #$DA        set timimg max byte
// .:FA67 20 E2 F8 JSR $F8E2       set timing
// .:FA6A A5 BE    LDA $BE         get copies count
// .:FA6C F0 02    BEQ $FA70
// .:FA6E 85 A7    STA $A7         save receiver input bit temporary storage
// .:FA70 A9 0F    LDA #$0F
// .:FA72 24 AA    BIT $AA
// .:FA74 10 17    BPL $FA8D
// .:FA76 A5 B5    LDA $B5
// .:FA78 D0 0C    BNE $FA86
// .:FA7A A6 BE    LDX $BE         get copies count
// .:FA7C CA       DEX
// .:FA7D D0 0B    BNE $FA8A       if ?? restore registers and exit interrupt
// .:FA7F A9 08    LDA #$08        set short block
// .:FA81 20 1C FE JSR $FE1C       OR into serial status byte
// .:FA84 D0 04    BNE $FA8A       restore registers and exit interrupt, branch always
// .:FA86 A9 00    LDA #$00
// .:FA88 85 AA    STA $AA
// .:FA8A 4C BC FE JMP $FEBC       restore registers and exit interrupt
// .:FA8D 70 31    BVS $FAC0
// .:FA8F D0 18    BNE $FAA9
// .:FA91 A5 B5    LDA $B5
// .:FA93 D0 F5    BNE $FA8A
// .:FA95 A5 B6    LDA $B6
// .:FA97 D0 F1    BNE $FA8A
// .:FA99 A5 A7    LDA $A7         get receiver input bit temporary storage
// .:FA9B 4A       LSR
// .:FA9C A5 BD    LDA $BD         get RS232 parity byte
// .:FA9E 30 03    BMI $FAA3
// .:FAA0 90 18    BCC $FABA
// .:FAA2 18       CLC
// .:FAA3 B0 15    BCS $FABA
// .:FAA5 29 0F    AND #$0F
// .:FAA7 85 AA    STA $AA
// .:FAA9 C6 AA    DEC $AA
// .:FAAB D0 DD    BNE $FA8A
// .:FAAD A9 40    LDA #$40
// .:FAAF 85 AA    STA $AA
// .:FAB1 20 8E FB JSR $FB8E       copy I/O start address to buffer address
// .:FAB4 A9 00    LDA #$00
// .:FAB6 85 AB    STA $AB
// .:FAB8 F0 D0    BEQ $FA8A
// .:FABA A9 80    LDA #$80
// .:FABC 85 AA    STA $AA
// .:FABE D0 CA    BNE $FA8A       restore registers and exit interrupt, branch always
// .:FAC0 A5 B5    LDA $B5
// .:FAC2 F0 0A    BEQ $FACE
// .:FAC4 A9 04    LDA #$04
// .:FAC6 20 1C FE JSR $FE1C       OR into serial status byte
// .:FAC9 A9 00    LDA #$00
// .:FACB 4C 4A FB JMP $FB4A
// .:FACE 20 D1 FC JSR $FCD1       check read/write pointer, return Cb = 1 if pointer >= end
// .:FAD1 90 03    BCC $FAD6
// .:FAD3 4C 48 FB JMP $FB48
// .:FAD6 A6 A7    LDX $A7         get receiver input bit temporary storage
// .:FAD8 CA       DEX
// .:FAD9 F0 2D    BEQ $FB08
// .:FADB A5 93    LDA $93         get load/verify flag
// .:FADD F0 0C    BEQ $FAEB       if load go ??
// .:FADF A0 00    LDY #$00        clear index
// .:FAE1 A5 BD    LDA $BD         get RS232 parity byte
// .:FAE3 D1 AC    CMP ($AC),Y
// .:FAE5 F0 04    BEQ $FAEB
// .:FAE7 A9 01    LDA #$01
// .:FAE9 85 B6    STA $B6
// .:FAEB A5 B6    LDA $B6
// .:FAED F0 4B    BEQ $FB3A
// .:FAEF A2 3D    LDX #$3D
// .:FAF1 E4 9E    CPX $9E
// .:FAF3 90 3E    BCC $FB33
// .:FAF5 A6 9E    LDX $9E
// .:FAF7 A5 AD    LDA $AD
// .:FAF9 9D 01 01 STA $0101,X
// .:FAFC A5 AC    LDA $AC
// .:FAFE 9D 00 01 STA $0100,X
// .:FB01 E8       INX
// .:FB02 E8       INX
// .:FB03 86 9E    STX $9E
// .:FB05 4C 3A FB JMP $FB3A
// .:FB08 A6 9F    LDX $9F
// .:FB0A E4 9E    CPX $9E
// .:FB0C F0 35    BEQ $FB43
// .:FB0E A5 AC    LDA $AC
// .:FB10 DD 00 01 CMP $0100,X
// .:FB13 D0 2E    BNE $FB43
// .:FB15 A5 AD    LDA $AD
// .:FB17 DD 01 01 CMP $0101,X
// .:FB1A D0 27    BNE $FB43
// .:FB1C E6 9F    INC $9F
// .:FB1E E6 9F    INC $9F
// .:FB20 A5 93    LDA $93         get load/verify flag
// .:FB22 F0 0B    BEQ $FB2F       if load ??
// .:FB24 A5 BD    LDA $BD         get RS232 parity byte
// .:FB26 A0 00    LDY #$00
// .:FB28 D1 AC    CMP ($AC),Y
// .:FB2A F0 17    BEQ $FB43
// .:FB2C C8       INY
// .:FB2D 84 B6    STY $B6
// .:FB2F A5 B6    LDA $B6
// .:FB31 F0 07    BEQ $FB3A
// .:FB33 A9 10    LDA #$10
// .:FB35 20 1C FE JSR $FE1C       OR into serial status byte
// .:FB38 D0 09    BNE $FB43
// .:FB3A A5 93    LDA $93         get load/verify flag
// .:FB3C D0 05    BNE $FB43       if verify go ??
// .:FB3E A8       TAY
// .:FB3F A5 BD    LDA $BD         get RS232 parity byte
// .:FB41 91 AC    STA ($AC),Y
// .:FB43 20 DB FC JSR $FCDB       increment read/write pointer
// .:FB46 D0 43    BNE $FB8B       restore registers and exit interrupt, branch always
// .:FB48 A9 80    LDA #$80
// .:FB4A 85 AA    STA $AA
// .:FB4C 78       SEI
// .:FB4D A2 01    LDX #$01        disable timer A interrupt
// .:FB4F 8E 0D DC STX $DC0D       save VIA 1 ICR
// .:FB52 AE 0D DC LDX $DC0D       read VIA 1 ICR
// .:FB55 A6 BE    LDX $BE         get copies count
// .:FB57 CA       DEX
// .:FB58 30 02    BMI $FB5C
// .:FB5A 86 BE    STX $BE         save copies count
// .:FB5C C6 A7    DEC $A7         decrement receiver input bit temporary storage
// .:FB5E F0 08    BEQ $FB68
// .:FB60 A5 9E    LDA $9E
// .:FB62 D0 27    BNE $FB8B       if ?? restore registers and exit interrupt
// .:FB64 85 BE    STA $BE         save copies count
// .:FB66 F0 23    BEQ $FB8B       restore registers and exit interrupt, branch always
// .:FB68 20 93 FC JSR $FC93       restore everything for STOP
// .:FB6B 20 8E FB JSR $FB8E       copy I/O start address to buffer address
// .:FB6E A0 00    LDY #$00        clear index
// .:FB70 84 AB    STY $AB         clear checksum
// .:FB72 B1 AC    LDA ($AC),Y     get byte from buffer
// .:FB74 45 AB    EOR $AB         XOR with checksum
// .:FB76 85 AB    STA $AB         save new checksum
// .:FB78 20 DB FC JSR $FCDB       increment read/write pointer
// .:FB7B 20 D1 FC JSR $FCD1       check read/write pointer, return Cb = 1 if pointer >= end
// .:FB7E 90 F2    BCC $FB72       loop if not at end
// .:FB80 A5 AB    LDA $AB         get computed checksum
// .:FB82 45 BD    EOR $BD         compare with stored checksum ??
// .:FB84 F0 05    BEQ $FB8B       if checksum ok restore registers and exit interrupt
// .:FB86 A9 20    LDA #$20        else set checksum error
// .:FB88 20 1C FE JSR $FE1C       OR into the serial status byte
// .:FB8B 4C BC FE JMP $FEBC       restore registers and exit interrupt

.label /* $FB8E - 64398 */ FB8E_reset_tape_pointer = $FB8E
// copy I/O start address to buffer address
//
// .:FB8E A5 C2    LDA $C2         get I/O start address high byte
// .:FB90 85 AD    STA $AD         set buffer address high byte
// .:FB92 A5 C1    LDA $C1         get I/O start address low byte
// .:FB94 85 AC    STA $AC         set buffer address low byte
// .:FB96 60       RTS

.label /* $FB97 - 64407 */ FB97_new_character_setup = $FB97
// new tape byte setup
//
// .:FB97 A9 08    LDA #$08        eight bits to do
// .:FB99 85 A3    STA $A3         set bit count
// .:FB9B A9 00    LDA #$00        clear A
// .:FB9D 85 A4    STA $A4         clear tape bit cycle phase
// .:FB9F 85 A8    STA $A8         clear start bit first cycle done flag
// .:FBA1 85 9B    STA $9B         clear byte parity
// .:FBA3 85 A9    STA $A9         clear start bit check flag, set no start bit yet
// .:FBA5 60       RTS

.label /* $FBA6 - 64422 */ FBA6_send_tone_to_tape = $FBA6
// send lsb from tape write byte to tape
//
//                                this routine tests the least significant bit in the tape write byte and sets VIA 2 T2
//                                depending on the state of the bit. if the bit is a 1 a time of $00B0 cycles is set, if
//                                the bot is a 0 a time of $0060 cycles is set. note that this routine does not shift the
//                                bits of the tape write byte but uses a copy of that byte, the byte itself is shifted
//                                elsewhere
// .:FBA6 A5 BD    LDA $BD         get tape write byte
// .:FBA8 4A       LSR             shift lsb into Cb
// .:FBA9 A9 60    LDA #$60        set time constant low byte for bit = 0
// .:FBAB 90 02    BCC $FBAF       branch if bit was 0
//                                 set time constant for bit = 1 and toggle tape
// .:FBAD A9 B0    LDA #$B0        set time constant low byte for bit = 1
//                                 write time constant and toggle tape
// .:FBAF A2 00    LDX #$00        set time constant high byte
//                                 write time constant and toggle tape
// .:FBB1 8D 06 DC STA $DC06       save VIA 1 timer B low byte
// .:FBB4 8E 07 DC STX $DC07       save VIA 1 timer B high byte
// .:FBB7 AD 0D DC LDA $DC0D       read VIA 1 ICR
// .:FBBA A9 19    LDA #$19        load timer B, timer B single shot, start timer B
// .:FBBC 8D 0F DC STA $DC0F       save VIA 1 CRB
// .:FBBF A5 01    LDA $01         read the 6510 I/O port
// .:FBC1 49 08    EOR #$08        toggle tape out bit
// .:FBC3 85 01    STA $01         save the 6510 I/O port
// .:FBC5 29 08    AND #$08        mask tape out bit
// .:FBC7 60       RTS

.label /* $FBC8 - 64456 */ FBC8_write_data_to_tape = $FBC8
// flag block done and exit interrupt
//
// .:FBC8 38       SEC             set carry flag
// .:FBC9 66 B6    ROR $B6         set buffer address high byte negative, flag all sync,
//                                 data and checksum bytes written
// .:FBCB 30 3C    BMI $FC09       restore registers and exit interrupt, branch always

.label /* $FBCD - 64461 */ FBCD_irq_entry_point = $FBCD
// tape write IRQ routine
//
//                                 this is the routine that writes the bits to the tape. it is called each time VIA 2 T2
//                                times out and checks if the start bit is done, if so checks if the data bits are done,
//                                if so it checks if the byte is done, if so it checks if the synchronisation bytes are
//                                done, if so it checks if the data bytes are done, if so it checks if the checksum byte
//                                is done, if so it checks if both the load and verify copies have been done, if so it
//                                stops the tape
// .:FBCD A5 A8    LDA $A8         get start bit first cycle done flag
// .:FBCF D0 12    BNE $FBE3       if first cycle done go do rest of byte
//                                 each byte sent starts with two half cycles of $0110 ststem clocks and the whole block
//                                 ends with two more such half cycles
// .:FBD1 A9 10    LDA #$10        set first start cycle time constant low byte
// .:FBD3 A2 01    LDX #$01        set first start cycle time constant high byte
// .:FBD5 20 B1 FB JSR $FBB1       write time constant and toggle tape
// .:FBD8 D0 2F    BNE $FC09       if first half cycle go restore registers and exit
//                                 interrupt
// .:FBDA E6 A8    INC $A8         set start bit first start cycle done flag
// .:FBDC A5 B6    LDA $B6         get buffer address high byte
// .:FBDE 10 29    BPL $FC09       if block not complete go restore registers and exit
//                                 interrupt. the end of a block is indicated by the tape
//                                 buffer high byte b7 being set to 1
// .:FBE0 4C 57 FC JMP $FC57       else do tape routine, block complete exit
//                                 continue tape byte write. the first start cycle, both half cycles of it, is complete
//                                 so the routine drops straight through to here
// .:FBE3 A5 A9    LDA $A9         get start bit check flag
// .:FBE5 D0 09    BNE $FBF0       if the start bit is complete go send the byte bits
//                                 after the two half cycles of $0110 ststem clocks the start bit is completed with two
//                                 half cycles of $00B0 system clocks. this is the same as the first part of a 1 bit
// .:FBE7 20 AD FB JSR $FBAD       set time constant for bit = 1 and toggle tape
// .:FBEA D0 1D    BNE $FC09       if first half cycle go restore registers and exit
//                                 interrupt
// .:FBEC E6 A9    INC $A9         set start bit check flag
// .:FBEE D0 19    BNE $FC09       restore registers and exit interrupt, branch always
//                                 continue tape byte write. the start bit, both cycles of it, is complete so the routine
//                                 drops straight through to here. now the cycle pairs for each bit, and the parity bit,
//                                 are sent
// .:FBF0 20 A6 FB JSR $FBA6       send lsb from tape write byte to tape
// .:FBF3 D0 14    BNE $FC09       if first half cycle go restore registers and exit
//                                 interrupt
//                                 else two half cycles have been done
// .:FBF5 A5 A4    LDA $A4         get tape bit cycle phase
// .:FBF7 49 01    EOR #$01        toggle b0
// .:FBF9 85 A4    STA $A4         save tape bit cycle phase
// .:FBFB F0 0F    BEQ $FC0C       if bit cycle phase complete go setup for next bit
//                                 each bit is written as two full cycles. a 1 is sent as a full cycle of $0160 system
//                                 clocks then a full cycle of $00C0 system clocks. a 0 is sent as a full cycle of $00C0
//                                 system clocks then a full cycle of $0160 system clocks. to do this each bit from the
//                                 write byte is inverted during the second bit cycle phase. as the bit is inverted it
//                                 is also added to the, one bit, parity count for this byte
// .:FBFD A5 BD    LDA $BD         get tape write byte
// .:FBFF 49 01    EOR #$01        invert bit being sent
// .:FC01 85 BD    STA $BD         save tape write byte
// .:FC03 29 01    AND #$01        mask b0
// .:FC05 45 9B    EOR $9B         EOR with tape write byte parity bit
// .:FC07 85 9B    STA $9B         save tape write byte parity bit
// .:FC09 4C BC FE JMP $FEBC       restore registers and exit interrupt
//                                 the bit cycle phase is complete so shift out the just written bit and test for byte
//                                 end
// .:FC0C 46 BD    LSR $BD         shift bit out of tape write byte
// .:FC0E C6 A3    DEC $A3         decrement tape write bit count
// .:FC10 A5 A3    LDA $A3         get tape write bit count
// .:FC12 F0 3A    BEQ $FC4E       if all the data bits have been written go setup for
//                                 sending the parity bit next and exit the interrupt
// .:FC14 10 F3    BPL $FC09       if all the data bits are not yet sent just restore the
//                                 registers and exit the interrupt
//                                 do next tape byte
//                                 the byte is complete. the start bit, data bits and parity bit have been written to
//                                 the tape so setup for the next byte
// .:FC16 20 97 FB JSR $FB97       new tape byte setup
// .:FC19 58       CLI             enable the interrupts
// .:FC1A A5 A5    LDA $A5         get cassette synchronization character count
// .:FC1C F0 12    BEQ $FC30       if synchronisation characters done go do block data
//                                 at the start of each block sent to tape there are a number of synchronisation bytes
//                                 that count down to the actual data. the commodore tape system saves two copies of all
//                                 the tape data, the first is loaded and is indicated by the synchronisation bytes
//                                 having b7 set, and the second copy is indicated by the synchronisation bytes having b7
//                                 clear. the sequence goes $09, $08, ..... $02, $01, data bytes
// .:FC1E A2 00    LDX #$00        clear X
// .:FC20 86 D7    STX $D7         clear checksum byte
// .:FC22 C6 A5    DEC $A5         decrement cassette synchronization byte count
// .:FC24 A6 BE    LDX $BE         get cassette copies count
// .:FC26 E0 02    CPX #$02        compare with load block indicator
// .:FC28 D0 02    BNE $FC2C       branch if not the load block
// .:FC2A 09 80    ORA #$80        this is the load block so make the synchronisation count
//                                 go $89, $88, ..... $82, $81
// .:FC2C 85 BD    STA $BD         save the synchronisation byte as the tape write byte
// .:FC2E D0 D9    BNE $FC09       restore registers and exit interrupt, branch always
//                                 the synchronization bytes have been done so now check and do the actual block data
// .:FC30 20 D1 FC JSR $FCD1       check read/write pointer, return Cb = 1 if pointer >= end
// .:FC33 90 0A    BCC $FC3F       if not all done yet go get the byte to send
// .:FC35 D0 91    BNE $FBC8       if pointer > end go flag block done and exit interrupt
//                                 else the block is complete, it only remains to write the
//                                 checksum byte to the tape so setup for that
// .:FC37 E6 AD    INC $AD         increment buffer pointer high byte, this means the block
//                                 done branch will always be taken next time without having
//                                 to worry about the low byte wrapping to zero
// .:FC39 A5 D7    LDA $D7         get checksum byte
// .:FC3B 85 BD    STA $BD         save checksum as tape write byte
// .:FC3D B0 CA    BCS $FC09       restore registers and exit interrupt, branch always
//                                 the block isn't finished so get the next byte to write to tape
// .:FC3F A0 00    LDY #$00        clear index
// .:FC41 B1 AC    LDA ($AC),Y     get byte from buffer
// .:FC43 85 BD    STA $BD         save as tape write byte
// .:FC45 45 D7    EOR $D7         XOR with checksum byte
// .:FC47 85 D7    STA $D7         save new checksum byte
// .:FC49 20 DB FC JSR $FCDB       increment read/write pointer
// .:FC4C D0 BB    BNE $FC09       restore registers and exit interrupt, branch always
//                                 set parity as next bit and exit interrupt
// .:FC4E A5 9B    LDA $9B         get parity bit
// .:FC50 49 01    EOR #$01        toggle it
// .:FC52 85 BD    STA $BD         save as tape write byte
// .:FC54 4C BC FE JMP $FEBC       restore registers and exit interrupt

.label /* $FC57 - 64599 */ FC57_write_tape_leader = $FC57
//                                 tape routine, block complete exit
// .:FC57 C6 BE    DEC $BE         decrement copies remaining to read/write
// .:FC59 D0 03    BNE $FC5E       branch if more to do
// .:FC5B 20 CA FC JSR $FCCA       stop the cassette motor
// .:FC5E A9 50    LDA #$50        set tape write leader count
// .:FC60 85 A7    STA $A7         save tape write leader count
// .:FC62 A2 08    LDX #$08        set index for write tape leader vector
// .:FC64 78       SEI             disable the interrupts
// .:FC65 20 BD FC JSR $FCBD       set the tape vector
// .:FC68 D0 EA    BNE $FC54       restore registers and exit interrupt, branch always
//
// write tape leader IRQ routine
//
// .:FC6A A9 78    LDA #$78        set time constant low byte for bit = leader
// .:FC6C 20 AF FB JSR $FBAF       write time constant and toggle tape
// .:FC6F D0 E3    BNE $FC54       if tape bit high restore registers and exit interrupt
// .:FC71 C6 A7    DEC $A7         decrement cycle count
// .:FC73 D0 DF    BNE $FC54       if not all done restore registers and exit interrupt
// .:FC75 20 97 FB JSR $FB97       new tape byte setup
// .:FC78 C6 AB    DEC $AB         decrement cassette leader count
// .:FC7A 10 D8    BPL $FC54       if not all done restore registers and exit interrupt
// .:FC7C A2 0A    LDX #$0A        set index for tape write vector
// .:FC7E 20 BD FC JSR $FCBD       set the tape vector
// .:FC81 58       CLI             enable the interrupts
// .:FC82 E6 AB    INC $AB         clear cassette leader counter, was $FF
// .:FC84 A5 BE    LDA $BE         get cassette block count
// .:FC86 F0 30    BEQ $FCB8       if all done restore everything for STOP and exit the
//                                 interrupt
// .:FC88 20 8E FB JSR $FB8E       copy I/O start address to buffer address
// .:FC8B A2 09    LDX #$09        set nine synchronisation bytes
// .:FC8D 86 A5    STX $A5         save cassette synchronization byte count
// .:FC8F 86 B6    STX $B6
// .:FC91 D0 83    BNE $FC16       go do the next tape byte, branch always

.label /* $FC93 - 64659 */ FC93_restore_normal_irq = $FC93
// restore everything for STOP
//
// .:FC93 08       PHP             save status
// .:FC94 78       SEI             disable the interrupts
// .:FC95 AD 11 D0 LDA $D011       read the vertical fine scroll and control register
// .:FC98 09 10    ORA #$10        mask xxx1 xxxx, unblank the screen
// .:FC9A 8D 11 D0 STA $D011       save the vertical fine scroll and control register
// .:FC9D 20 CA FC JSR $FCCA       stop the cassette motor
// .:FCA0 A9 7F    LDA #$7F        disable all interrupts
// .:FCA2 8D 0D DC STA $DC0D       save VIA 1 ICR
// .:FCA5 20 DD FD JSR $FDDD
// .:FCA8 AD A0 02 LDA $02A0       get saved IRQ vector high byte
// .:FCAB F0 09    BEQ $FCB6       branch if null
// .:FCAD 8D 15 03 STA $0315       restore IRQ vector high byte
// .:FCB0 AD 9F 02 LDA $029F       get saved IRQ vector low byte
// .:FCB3 8D 14 03 STA $0314       restore IRQ vector low byte
// .:FCB6 28       PLP             restore status
// .:FCB7 60       RTS

.label /* $FCB8 - 64696 */ FCB8_set_irq_vector = $FCB8
// reset vector
//
// .:FCB8 20 93 FC JSR $FC93       restore everything for STOP
// .:FCBB F0 97    BEQ $FC54       restore registers and exit interrupt, branch always

// set tape vector
//
// .:FCBD BD 93 FD LDA $FD93,X     get tape IRQ vector low byte
// .:FCC0 8D 14 03 STA $0314       set IRQ vector low byte
// .:FCC3 BD 94 FD LDA $FD94,X     get tape IRQ vector high byte
// .:FCC6 8D 15 03 STA $0315       set IRQ vector high byte
// .:FCC9 60       RTS

.label /* $FCCA - 64714 */ FCCA_stop_tape_motor = $FCCA
// stop the cassette motor
//
// .:FCCA A5 01    LDA $01         read the 6510 I/O port
// .:FCCC 09 20    ORA #$20        mask xxxx xx1x, turn the cassette motor off
// .:FCCE 85 01    STA $01         save the 6510 I/O port
// .:FCD0 60       RTS

.label /* $FCD1 - 64721 */ FCD1_check_read_write_pointer = $FCD1
// check read/write pointer
//
// 	                                return Cb = 1 if pointer >= end
// .:FCD1 38       SEC             set carry for subtract
// .:FCD2 A5 AC    LDA $AC         get buffer address low byte
// .:FCD4 E5 AE    SBC $AE         subtract buffer end low byte
// .:FCD6 A5 AD    LDA $AD         get buffer address high byte
// .:FCD8 E5 AF    SBC $AF         subtract buffer end high byte
// .:FCDA 60       RTS

.label /* $FCDB - 64731 */ FCDB_bump_read_write_pointer = $FCDB
// increment read/write pointer
//
// .:FCDB E6 AC    INC $AC         increment buffer address low byte
// .:FCDD D0 02    BNE $FCE1       branch if no overflow
// .:FCDF E6 AD    INC $AD         increment buffer address low byte
// .:FCE1 60       RTS

.label /* $FCE2 - 64738 */ FCE2_power_up_reset_entry = $FCE2
// RESET, hardware reset starts here
//
// .:FCE2 A2 FF    LDX #$FF        set X for stack
// .:FCE4 78       SEI             disable the interrupts
// .:FCE5 9A       TXS             clear stack
// .:FCE6 D8       CLD             clear decimal mode
// .:FCE7 20 02 FD JSR $FD02       scan for autostart ROM at $8000
// .:FCEA D0 03    BNE $FCEF       if not there continue startup
// .:FCEC 6C 00 80 JMP ($8000)     else call ROM start code
// .:FCEF 8E 16 D0 STX $D016       read the horizontal fine scroll and control register
// .:FCF2 20 A3 FD JSR $FDA3       initialise SID, CIA and IRQ
// .:FCF5 20 50 FD JSR $FD50       RAM test and find RAM end
// .:FCF8 20 15 FD JSR $FD15       restore default I/O vectors
// .:FCFB 20 5B FF JSR $FF5B       initialise VIC and screen editor
// .:FCFE 58       CLIenable the interrupts
// .:FCFF 6C 00 A0 JMP ($A000)     execute BASIC

.label /* $FD02 - 64770 */ FD02_check_for_8_rom = $FD02
// scan for autostart ROM at $8000, returns Zb=1 if ROM found
//
// .:FD02 A2 05    LDX #$05        five characters to test
// .:FD04 BD 0F FD LDA $FD0F,X     get test character
// .:FD07 DD 03 80 CMP $8003,X     compare wiith byte in ROM space
// .:FD0A D0 03    BNE $FD0F       exit if no match
// .:FD0C CA       DEX             decrement index
// .:FD0D D0 F5    BNE $FD04       loop if not all done
// .:FD0F 60       RTS

.label /* $FD10 - 64784 */ FD10_8_rom_mask_cbm80 = $FD10
// autostart ROM signature
//
// .:FD10 C3 C2 CD 38 30           'CBM80'

.label /* $FD15 - 64789 */ FD15_restore_vectors = $FD15
// restore default I/O vectors
//
// .:FD15 A2 30    LDX #$30        pointer to vector table low byte
// .:FD17 A0 FD    LDY #$FD        pointer to vector table high byte
// .:FD19 18       CLC             flag set vectors

.label /* $FD1A - 64794 */ FD1A_change_vectors_for_user = $FD1A
// set/read vectored I/O from (XY), Cb = 1 to read, Cb = 0 to set
//
// .:FD1A 86 C3    STX $C3         save pointer low byte
// .:FD1C 84 C4    STY $C4         save pointer high byte
// .:FD1E A0 1F    LDY #$1F        set byte count
// .:FD20 B9 14 03 LDA $0314,Y     read vector byte from vectors
// .:FD23 B0 02    BCS $FD27       branch if read vectors
// .:FD25 B1 C3    LDA ($C3),Y     read vector byte from (XY)
// .:FD27 91 C3    STA ($C3),Y     save byte to (XY)
// .:FD29 99 14 03 STA $0314,Y     save byte to vector
// .:FD2C 88       DEY             decrement index
// .:FD2D 10 F1    BPL $FD20       loop if more to do
// .:FD2F 60       RTS
//                                 The above code works but it tries to write to the ROM. while this is usually harmless
//                                 systems that use flash ROM may suffer. Here is a version that makes the extra write
//                                 to RAM instead but is otherwise identical in function. ##

//                                 set/read vectored I/O from (XY), Cb = 1 to read, Cb = 0 to set
//
//                                STX $C3         ; save pointer low byte
//                                STY $C4         ; save pointer high byte
//                                LDY #$1F        ; set byte count
//                                LDA ($C3),Y     ; read vector byte from (XY)
//                                BCC $FD29       ; branch if set vectors
//
//                                LDA $0314,Y     ; else read vector byte from vectors
//                                STA ($C3),Y     ; save byte to (XY)
//                                STA $0314,Y     ; save byte to vector
//                                DEY             ; decrement index
//                                BPL $FD20       ; loop if more to do
//
//                                RTS

.label /* $FD30 - 64816 */ FD30_reset_vectors = $FD30
// kernal vectors
//
// .:FD30 31 EA                    $0314 IRQ vector
// .:FD32 66 FE                    $0316 BRK vector
// .:FD34 47 FE                    $0318 NMI vector
// .:FD36 4A F3                    $031A open a logical file
// .:FD38 91 F2                    $031C close a specified logical file
// .:FD3A 0E F2                    $031E open channel for input
// .:FD3C 50 F2                    $0320 open channel for output
// .:FD3E 33 F3                    $0322 close input and output channels
// .:FD40 57 F1                    $0324 input character from channel
// .:FD42 CA F1                    $0326 output character to channel
// .:FD44 ED F6                    $0328 scan stop key
// .:FD46 3E F1                    $032A get character from the input device
// .:FD48 2F F3                    $032C close all channels and files
// .:FD4A 66 FE                    $032E user function
//                                 Vector to user defined command, currently points to BRK.
//                                 This appears to be a holdover from PET days, when the built-in machine language monitor
//                                 would jump through the $032E vector when it encountered a command that it did not
//                                 understand, allowing the user to add new commands to the monitor.
//                                 Although this vector is initialized to point to the routine called by STOP/RESTORE and
//                                 the BRK interrupt, and is updated by the kernal vector routine at $FD57, it no longer
//                                 has any function.
// .:FD4C A5 F4                    $0330 load
// .:FD4E ED F5                    $0332 save

.label /* $FD50 - 64848 */ FD50_initialise_system_constants = $FD50
// test RAM and find RAM end
//
// .:FD50 A9 00    LDA #$00        clear A
// .:FD52 A8       TAY             clear index
// .:FD53 99 02 00 STA $0002,Y     clear page 0, don't do $0000 or $0001
// .:FD56 99 00 02 STA $0200,Y     clear page 2
// .:FD59 99 00 03 STA $0300,Y     clear page 3
// .:FD5C C8       INY             increment index
// .:FD5D D0 F4    BNE $FD53       loop if more to do
// .:FD5F A2 3C    LDX #$3C        set cassette buffer pointer low byte
// .:FD61 A0 03    LDY #$03        set cassette buffer pointer high byte
// .:FD63 86 B2    STX $B2         save tape buffer start pointer low byte
// .:FD65 84 B3    STY $B3         save tape buffer start pointer high byte
// .:FD67 A8       TAY             clear Y
// .:FD68 A9 03    LDA #$03        set RAM test pointer high byte
// .:FD6A 85 C2    STA $C2         save RAM test pointer high byte
// .:FD6C E6 C2    INC $C2         increment RAM test pointer high byte
// .:FD6E B1 C1    LDA ($C1),Y
// .:FD70 AA       TAX
// .:FD71 A9 55    LDA #$55
// .:FD73 91 C1    STA ($C1),Y
// .:FD75 D1 C1    CMP ($C1),Y
// .:FD77 D0 0F    BNE $FD88
// .:FD79 2A       ROL
// .:FD7A 91 C1    STA ($C1),Y
// .:FD7C D1 C1    CMP ($C1),Y
// .:FD7E D0 08    BNE $FD88
// .:FD80 8A       TXA
// .:FD81 91 C1    STA ($C1),Y
// .:FD83 C8       INY
// .:FD84 D0 E8    BNE $FD6E
// .:FD86 F0 E4    BEQ $FD6C
// .:FD88 98       TYA
// .:FD89 AA       TAX
// .:FD8A A4 C2    LDY $C2
// .:FD8C 18       CLC
// .:FD8D 20 2D FE JSR $FE2D       set the top of memory
// .:FD90 A9 08    LDA #$08
// .:FD92 8D 82 02 STA $0282       save the OS start of memory high byte
// .:FD95 A9 04    LDA #$04
// .:FD97 8D 88 02 STA $0288       save the screen memory page
// .:FD9A 60       RTS

.label /* $FD9B - 64923 */ FD9B_irq_vectors_for_tape_io = $FD9B
// tape IRQ vectors
//
// .:FD9B 6A FC                    $08 write tape leader IRQ routine
// .:FD9D CD FB                    $0A tape write IRQ routine
// .:FD9F 31 EA                    $0C normal IRQ vector
// .:FDA1 2C F9                    $0E read tape bits IRQ routine

.label /* $FDA3 - 64931 */ FDA3_initialise_io = $FDA3
// initialise SID, CIA and IRQ
//
// .:FDA3 A9 7F    LDA #$7F        disable all interrupts
// .:FDA5 8D 0D DC STA $DC0D       save VIA 1 ICR
// .:FDA8 8D 0D DD STA $DD0D       save VIA 2 ICR
// .:FDAB 8D 00 DC STA $DC00       save VIA 1 DRA, keyboard column drive
// .:FDAE A9 08    LDA #$08        set timer single shot
// .:FDB0 8D 0E DC STA $DC0E       save VIA 1 CRA
// .:FDB3 8D 0E DD STA $DD0E       save VIA 2 CRA
// .:FDB6 8D 0F DC STA $DC0F       save VIA 1 CRB
// .:FDB9 8D 0F DD STA $DD0F       save VIA 2 CRB
// .:FDBC A2 00    LDX #$00        set all inputs
// .:FDBE 8E 03 DC STX $DC03       save VIA 1 DDRB, keyboard row
// .:FDC1 8E 03 DD STX $DD03       save VIA 2 DDRB, RS232 port
// .:FDC4 8E 18 D4 STX $D418       clear the volume and filter select register
// .:FDC7 CA       DEX             set X = $FF
// .:FDC8 8E 02 DC STX $DC02       save VIA 1 DDRA, keyboard column
// .:FDCB A9 07    LDA #$07        DATA out high, CLK out high, ATN out high, RE232 Tx DATA
//                                 high, video address 15 = 1, video address 14 = 1
// .:FDCD 8D 00 DD STA $DD00       save VIA 2 DRA, serial port and video address
// .:FDD0 A9 3F    LDA #$3F        set serial DATA input, serial CLK input
// .:FDD2 8D 02 DD STA $DD02       save VIA 2 DDRA, serial port and video address
// .:FDD5 A9 E7    LDA #$E7        set 1110 0111, motor off, enable I/O, enable KERNAL,
//                                 enable BASIC
// .:FDD7 85 01    STA $01         save the 6510 I/O port
// .:FDD9 A9 2F    LDA #$2F        set 0010 1111, 0 = input, 1 = output
// .:FDDB 85 00    STA $00         save the 6510 I/O port direction register

.label /* $FDDD - 64989 */ FDDD_enable_timer = $FDDD
// .:FDDD AD A6 02 LDA $02A6       get the PAL/NTSC flag
// .:FDE0 F0 0A    BEQ $FDEC       if NTSC go set NTSC timing
//                                 else set PAL timing
// .:FDE2 A9 25    LDA #$25
// .:FDE4 8D 04 DC STA $DC04       save VIA 1 timer A low byte
// .:FDE7 A9 40    LDA #$40
// .:FDE9 4C F3 FD JMP $FDF3
// .:FDEC A9 95    LDA #$95
// .:FDEE 8D 04 DC STA $DC04       save VIA 1 timer A low byte
// .:FDF1 A9 42    LDA #$42
// .:FDF3 8D 05 DC STA $DC05       save VIA 1 timer A high byte
// .:FDF6 4C 6E FF JMP $FF6E

.label /* $FDF9 - 65017 */ FDF9_set_filename = $FDF9
// set filename
//
// .:FDF9 85 B7    STA $B7         set file name length
// .:FDFB 86 BB    STX $BB         set file name pointer low byte
// .:FDFD 84 BC    STY $BC         set file name pointer high byte
// .:FDFF 60       RTS

.label /* $FE00 - 65024 */ FE00_set_logical_file_parameters = $FE00
// set logical, first and second addresses
//
// .:FE00 85 B8    STA $B8         save the logical file
// .:FE02 86 BA    STX $BA         save the device number
// .:FE04 84 B9    STY $B9         save the secondary address
// .:FE06 60       RTS

.label /* $FE07 - 65031 */ FE07_get_io_status_word = $FE07
//	read I/O status word
//
// .:FE07 A5 BA    LDA $BA         get the device number
// .:FE09 C9 02    CMP #$02        compare device with RS232 device
// .:FE0B D0 0D    BNE $FE1A       if not RS232 device go ??
//                                 get RS232 device status
// .:FE0D AD 97 02 LDA $0297       get the RS232 status register
// .:FE10 48       PHA             save the RS232 status value
// .:FE11 A9 00    LDA #$00        clear A
// .:FE13 8D 97 02 STA $0297       clear the RS232 status register
// .:FE16 68       PLA             restore the RS232 status value
// .:FE17 60       RTS

.label /* $FE18 - 65048 */ FE18_control_os_messages = $FE18
// control kernal messages
//
// .:FE18 85 9D    STA $9D         set message mode flag
// .:FE1A A5 90    LDA $90         read the serial status byte
//
// OR into the serial status byte
//
// .:FE1C 05 90    ORA $90         OR with the serial status byte
// .:FE1E 85 90    STA $90         save the serial status byte
// .:FE20 60       RTS

.label /* $FE21 - 65057 */ FE21_set_ieee_timeout = $FE21
// set timeout on serial bus
//
// .:FE21 8D 85 02 STA $0285       save serial bus timeout flag
// .:FE24 60       RTS

.label /* $FE25 - 65061 */ FE25_read_set_top_of_memory = $FE25
// read/set the top of memory, Cb = 1 to read, Cb = 0 to set
//
// .:FE25 90 06    BCC $FE2D       if Cb clear go set the top of memory
//
// read the top of memory
//
// .:FE27 AE 83 02 LDX $0283       get memory top low byte
// .:FE2A AC 84 02 LDY $0284       get memory top high byte
//
// set the top of memory
//
// .:FE2D 8E 83 02 STX $0283       set memory top low byte
// .:FE30 8C 84 02 STY $0284       set memory top high byte
// .:FE33 60       RTS

.label /* $FE34 - 65076 */ FE34_read_set_bottom_of_memory = $FE34
// read/set the bottom of memory, Cb = 1 to read, Cb = 0 to set
//
// .:FE34 90 06    BCC $FE3C       if Cb clear go set the bottom of memory
// .:FE36 AE 81 02 LDX $0281       get the OS start of memory low byte
// .:FE39 AC 82 02 LDY $0282       get the OS start of memory high byte
// .:FE3C 8E 81 02 STX $0281       save the OS start of memory low byte
// .:FE3F 8C 82 02 STY $0282       save the OS start of memory high byte
// .:FE42 60       RTS

.label /* $FE43 - 65091 */ FE43_nmi_transfer_entry = $FE43
// NMI vector
//
// .:FE43 78       SEI             disable the interrupts
// .:FE44 6C 18 03 JMP ($0318)     do NMI vector
//
// NMI handler
//
// .:FE47 48       PHA             save A
// .:FE48 8A       TXA             copy X
// .:FE49 48       PHA             save X
// .:FE4A 98       TYA             copy Y
// .:FE4B 48       PHA             save Y
// .:FE4C A9 7F    LDA #$7F        disable all interrupts
// .:FE4E 8D 0D DD STA $DD0D       save VIA 2 ICR
// .:FE51 AC 0D DD LDY $DD0D       save VIA 2 ICR
// .:FE54 30 1C    BMI $FE72
// .:FE56 20 02 FD JSR $FD02       scan for autostart ROM at $8000
// .:FE59 D0 03    BNE $FE5E       branch if no autostart ROM
// .:FE5B 6C 02 80 JMP ($8002)     else do autostart ROM break entry
// .:FE5E 20 BC F6 JSR $F6BC       increment real time clock
// .:FE61 20 E1 FF JSR $FFE1       scan stop key
// .:FE64 D0 0C    BNE $FE72       if not [STOP] restore registers and exit interrupt

.label /* $FE66 - 65126 */ FE66_warm_start_basic = $FE66
// user function default vector
//
//                                 BRK handler
// .:FE66 20 15 FD JSR $FD15       restore default I/O vectors
// .:FE69 20 A3 FD JSR $FDA3       initialise SID, CIA and IRQ
// .:FE6C 20 18 E5 JSR $E518       initialise the screen and keyboard
// .:FE6F 6C 02 A0 JMP ($A002)     do BASIC break entry
//
// RS232 NMI routine
//
// .:FE72 98       TYA
// .:FE73 2D A1 02 AND $02A1       AND with the RS-232 interrupt enable byte
// .:FE76 AA       TAX
// .:FE77 29 01    AND #$01
// .:FE79 F0 28    BEQ $FEA3
// .:FE7B AD 00 DD LDA $DD00       read VIA 2 DRA, serial port and video address
// .:FE7E 29 FB    AND #$FB        mask xxxx x0xx, clear RS232 Tx DATA
// .:FE80 05 B5    ORA $B5         OR in the RS232 transmit data bit
// .:FE82 8D 00 DD STA $DD00       save VIA 2 DRA, serial port and video address
// .:FE85 AD A1 02 LDA $02A1       get the RS-232 interrupt enable byte
// .:FE88 8D 0D DD STA $DD0D       save VIA 2 ICR
// .:FE8B 8A       TXA
// .:FE8C 29 12    AND #$12
// .:FE8E F0 0D    BEQ $FE9D
// .:FE90 29 02    AND #$02
// .:FE92 F0 06    BEQ $FE9A
// .:FE94 20 D6 FE JSR $FED6
// .:FE97 4C 9D FE JMP $FE9D
// .:FE9A 20 07 FF JSR $FF07
// .:FE9D 20 BB EE JSR $EEBB
// .:FEA0 4C B6 FE JMP $FEB6
// .:FEA3 8A       TXA             get active interrupts back
// .:FEA4 29 02    AND #$02        mask ?? interrupt
// .:FEA6 F0 06    BEQ $FEAE       branch if not ?? interrupt
//                                 was ?? interrupt
// .:FEA8 20 D6 FE JSR $FED6
// .:FEAB 4C B6 FE JMP $FEB6
// .:FEAE 8A       TXA             get active interrupts back
// .:FEAF 29 10    AND #$10        mask CB1 interrupt, Rx data bit transition
// .:FEB1 F0 03    BEQ $FEB6       if no bit restore registers and exit interrupt
// .:FEB3 20 07 FF JSR $FF07
// .:FEB6 AD A1 02 LDA $02A1       get the RS-232 interrupt enable byte
// .:FEB9 8D 0D DD STA $DD0D       save VIA 2 ICR

.label /* $FEBC - 65212 */ FEBC_exit_interrupt = $FEBC
// .:FEBC 68       PLA             pull Y
// .:FEBD A8       TAY             restore Y
// .:FEBE 68       PLA             pull X
// .:FEBF AA       TAX             restore X
// .:FEC0 68       PLA             restore A
// .:FEC1 40       RTI
//

.label /* $FEC2 - 65218 */ FEC2_rs232_timing_table_ntsc = $FEC2
// baud rate word is calculated from ..
//
//
//	                                (system clock / baud rate) / 2 - 100
//
//	                                    system clock
//	                                    ------------
//	                                PAL        985248 Hz
//	                                NTSC     1022727 Hz
//	                                baud rate tables for NTSC C64
// .:FEC2 C1 27                      50   baud   1027700
// .:FEC4 3E 1A                      75   baud   1022700
// .:FEC6 C5 11                     110   baud   1022780
// .:FEC8 74 0E                     134.5 baud   1022200
// .:FECA ED 0C                     150   baud   1022700
// .:FECC 45 06                     300   baud   1023000
// .:FECE F0 02                     600   baud   1022400
// .:FED0 46 01                    1200   baud   1022400
// .:FED2 B8 00                    1800   baud   1022400
// .:FED4 71 00                    2400   baud   1022400

.label /* $FED6 - 65238 */ FED6_nmi_rs232_in = $FED6
// ??
//
// .:FED6 AD 01 DD LDA $DD01       read VIA 2 DRB, RS232 port
// .:FED9 29 01    AND #$01        mask 0000 000x, RS232 Rx DATA
// .:FEDB 85 A7    STA $A7         save the RS232 received data bit
// .:FEDD AD 06 DD LDA $DD06       get VIA 2 timer B low byte
// .:FEE0 E9 1C    SBC #$1C
// .:FEE2 6D 99 02 ADC $0299
// .:FEE5 8D 06 DD STA $DD06       save VIA 2 timer B low byte
// .:FEE8 AD 07 DD LDA $DD07       get VIA 2 timer B high byte
// .:FEEB 6D 9A 02 ADC $029A
// .:FEEE 8D 07 DD STA $DD07       save VIA 2 timer B high byte
// .:FEF1 A9 11    LDA #$11        set timer B single shot, start timer B
// .:FEF3 8D 0F DD STA $DD0F       save VIA 2 CRB
// .:FEF6 AD A1 02 LDA $02A1       get the RS-232 interrupt enable byte
// .:FEF9 8D 0D DD STA $DD0D       save VIA 2 ICR
// .:FEFC A9 FF    LDA #$FF
// .:FEFE 8D 06 DD STA $DD06       save VIA 2 timer B low byte
// .:FF01 8D 07 DD STA $DD07       save VIA 2 timer B high byte
// .:FF04 4C 59 EF JMP $EF59

.label /* $FF07 - 65287 */ FF07_nmi_rs232_out = $FF07
// .:FF07 AD 95 02 LDA $0295       nonstandard bit timing low byte
// .:FF0A 8D 06 DD STA $DD06       save VIA 2 timer B low byte
// .:FF0D AD 96 02 LDA $0296       nonstandard bit timing high byte
// .:FF10 8D 07 DD STA $DD07       save VIA 2 timer B high byte
// .:FF13 A9 11    LDA #$11        set timer B single shot, start timer B
// .:FF15 8D 0F DD STA $DD0F       save VIA 2 CRB
// .:FF18 A9 12    LDA #$12
// .:FF1A 4D A1 02 EOR $02A1       EOR with the RS-232 interrupt enable byte
// .:FF1D 8D A1 02 STA $02A1       save the RS-232 interrupt enable byte
// .:FF20 A9 FF    LDA #$FF
// .:FF22 8D 06 DD STA $DD06       save VIA 2 timer B low byte
// .:FF25 8D 07 DD STA $DD07       save VIA 2 timer B high byte
// .:FF28 AE 98 02 LDX $0298
// .:FF2B 86 A8    STX $A8
// .:FF2D 60       RTS
//
// ??
//
// .:FF2E AA       TAX
// .:FF2F AD 96 02 LDA $0296       nonstandard bit timing high byte
// .:FF32 2A       ROL
// .:FF33 A8       TAY
// .:FF34 8A       TXA
// .:FF35 69 C8    ADC #$C8
// .:FF37 8D 99 02 STA $0299
// .:FF3A 98       TYA
// .:FF3B 69 00    ADC #$00        add any carry
// .:FF3D 8D 9A 02 STA $029A
// .:FF40 60       RTS
//
// unused bytes
//
// .:FF41 EA       NOP             waste cycles
// .:FF42 EA       NOP             waste cycles

.label /* $FF43 - 65347 */ FF43_fake_irq_entry = $FF43
// save the status and do the IRQ routine
//
// .:FF43 08       PHP             save the processor status
// .:FF44 68       PLA             pull the processor status
// .:FF45 29 EF    AND #$EF        mask xxx0 xxxx, clear the break bit
// .:FF47 48       PHA             save the modified processor status

.label /* $FF48 - 65352 */ FF48_irq_entry = $FF48
// IRQ vector
//
// .:FF48 48       PHA             save A
// .:FF49 8A       TXA             copy X
// .:FF4A 48       PHA             save X
// .:FF4B 98       TYA             copy Y
// .:FF4C 48       PHA             save Y
// .:FF4D BA       TSX             copy stack pointer
// .:FF4E BD 04 01 LDA $0104,X     get stacked status register
// .:FF51 29 10    AND #$10        mask BRK flag
// .:FF53 F0 03    BEQ $FF58       branch if not BRK
// .:FF55 6C 16 03 JMP ($0316)     else do BRK vector (iBRK)
// .:FF58 6C 14 03 JMP ($0314)     do IRQ vector (iIRQ)

.label /* $FF5B - 65371 */ FF5B_initialize_screen_editor = $FF5B
// initialise VIC and screen editor
//
// .:FF5B 20 18 E5 JSR $E518       initialise the screen and keyboard
// .:FF5E AD 12 D0 LDA $D012       read the raster compare register
// .:FF61 D0 FB    BNE $FF5E       loop if not raster line $00
// .:FF63 AD 19 D0 LDA $D019       read the vic interrupt flag register
// .:FF66 29 01    AND #$01        mask the raster compare flag
// .:FF68 8D A6 02 STA $02A6       save the PAL/NTSC flag
// .:FF6B 4C DD FD JMP $FDDD
//
// ??
//
// .:FF6E A9 81    LDA #$81        enable timer A interrupt
// .:FF70 8D 0D DC STA $DC0D       save VIA 1 ICR
// .:FF73 AD 0E DC LDA $DC0E       read VIA 1 CRA
// .:FF76 29 80    AND #$80        mask x000 0000, TOD clock
// .:FF78 09 11    ORA #$11        mask xxx1 xxx1, load timer A, start timer A
// .:FF7A 8D 0E DC STA $DC0E       save VIA 1 CRA
// .:FF7D 4C 8E EE JMP $EE8E       set the serial clock out low and return

.label /* $FF80 - 65408 */ FF80_version_number = $FF80
// unused
//
// .:FF80 03

.label /* $FF81 - 65409 */ FF81_init_editor_video_chips = $FF81
// initialise VIC and screen editor
//
// .:FF81 4C 5B FF JMP $FF5B       initialise VIC and screen editor

.label /* $FF84 - 65412 */ FF84_init_io_devices = $FF84
// initialise SID, CIA and IRQ, unused
//
// .:FF84 4C A3 FD JMP $FDA3       initialise SID, CIA and IRQ

.label /* $FF87 - 65415 */ FF87_init_ram_buffers = $FF87
// RAM test and find RAM end
//
// .:FF87 4C 50 FD JMP $FD50       RAM test and find RAM end

.label /* $FF8A - 65418 */ FF8A_restore_vectors = $FF8A
// restore default I/O vectors
//
//                                 this routine restores the default values of all system vectors used in KERNAL and
//                                 BASIC routines and interrupts.
// .:FF8A 4C 15 FD JMP $FD15       restore default I/O vectors


.label /* $FF8D - 65421 */ FF8D_change_vectors_for_user = $FF8D
// read/set vectored I/O
//
//                                 this routine manages all system vector jump addresses stored in RAM. Calling this
//                                 routine with the carry bit set will store the current contents of the RAM vectors
//                                 in a list pointed to by the X and Y registers. When this routine is called with
//                                 the carry bit clear, the user list pointed to by the X and Y registers is copied
//                                 to the system RAM vectors.
//                                 NOTE: This routine requires caution in its use. The best way to use it is to first
//                                 read the entire vector contents into the user area, alter the desired vectors and
//                                 then copy the contents back to the system vectors.
// .:FF8D 4C 1A FD JMP $FD1A       read/set vectored I/O


.label /* $FF90 - 65424 */ FF90_control_os_messages = $FF90
//control kernal messages

//                                 this routine controls the printing of error and control messages by the KERNAL.
//                                 Either print error messages or print control messages can be selected by setting
//                                 the accumulator when the routine is called.
//                                 FILE NOT FOUND is an example of an error message. PRESS PLAY ON CASSETTE is an
//                                 example of a control message.
//                                 bits 6 and 7 of this value determine where the message will come from. If bit 7
//                                 is set one of the error messages from the KERNAL will be printed. If bit 6 is set
//                                 a control message will be printed.
// .:FF90 4C 18 FE JMP $FE18       control kernal messages

.label /* $FF93 - 65427 */ FF93_send_sa_after_listen = $FF93
// send secondary address after LISTEN
//
//                                 this routine is used to send a secondary address to an I/O device after a call to
//                                 the LISTEN routine is made and the device commanded to LISTEN. The routine cannot
//                                 be used to send a secondary address after a call to the TALK routine.
//                                 A secondary address is usually used to give set-up information to a device before
//                                 I/O operations begin.
//                                 When a secondary address is to be sent to a device on the serial bus the address
//                                 must first be ORed with $60.
// .:FF93 4C B9 ED JMP $EDB9       send secondary address after LISTEN

.label /* $FF96 - 65430 */ FF96_send_sa_after_talk = $FF96
// send secondary address after TALK
//
//                                 this routine transmits a secondary address on the serial bus for a TALK device.
//                                 This routine must be called with a number between 4 and 31 in the accumulator.
//                                 The routine will send this number as a secondary address command over the serial
//                                 bus. This routine can only be called after a call to the TALK routine. It will
//                                 not work after a LISTEN.
// .:FF96 4C C7 ED JMP $EDC7       send secondary address after TALK

.label /* $FF99 - 65433 */ FF99_set_read_system_ram_top = $FF99
// read/set the top of memory
//
//                                 this routine is used to read and set the top of RAM. When this routine is called
//                                 with the carry bit set the pointer to the top of RAM will be loaded into XY. When
//                                 this routine is called with the carry bit clear XY will be saved as the top of
//                                 memory pointer changing the top of memory.
// .:FF99 4C 25 FE JMP $FE25       read/set the top of memory

.label /* $FF9C - 65436 */ FF9C_set_read_system_ram_bottom = $FF9C
// read/set the bottom of memory
//
//                                 this routine is used to read and set the bottom of RAM. When this routine is
//                                 called with the carry bit set the pointer to the bottom of RAM will be loaded
//                                 into XY. When this routine is called with the carry bit clear XY will be saved as
//                                 the bottom of memory pointer changing the bottom of memory.
// .:FF9C 4C 34 FE JMP $FE34       read/set the bottom of memory

.label /* $FF9F - 65439 */ FF9F_scan_keyboard = $FF9F
// scan the keyboard
//
//                                 this routine will scan the keyboard and check for pressed keys. It is the same
//                                 routine called by the interrupt handler. If a key is down, its ASCII value is
//	                               placed in the keyboard queue.
// .:FF9F 4C 87 EA JMP $EA87       scan keyboard

.label /* $FFA2 - 65442 */ FFA2_set_timeout_in_ieee = $FFA2
// set timeout on serial bus
//
//                                 this routine sets the timeout flag for the serial bus. When the timeout flag is
//                                 set, the computer will wait for a device on the serial port for 64 milliseconds.
//                                 If the device does not respond to the computer's DAV signal within that time the
//                                 computer will recognize an error condition and leave the handshake sequence. When
//                                 this routine is called and the accumulator contains a 0 in bit 7, timeouts are
//                                 enabled. A 1 in bit 7 will disable the timeouts.
//                                 NOTE: The the timeout feature is used to communicate that a disk file is not found
//                                 on an attempt to OPEN a file.
// .:FFA2 4C 21 FE JMP $FE21       set timeout on serial bus

.label /* $FFA5 - 65445 */ FFA5_handshake_serial_byte_in = $FFA5
// input byte from serial bus
//
//                                 this routine reads a byte of data from the serial bus using full handshaking. the
//                                 data is returned in the accumulator. before using this routine the TALK routine,
//                                 $FFB4, must have been called first to command the device on the serial bus to
//                                 send data on the bus. if the input device needs a secondary command it must be sent
//                                 by using the TKSA routine, $FF96, before calling this routine.
//
//                                 errors are returned in the status word which can be read by calling the READST
//                                 routine, $FFB7.
// .:FFA5 4C 13 EE JMP $EE13       input byte from serial bus

.label /* $FFA8 - 65448 */ FFA8_handshake_serial_byte_out = $FFA8
//  output a byte to serial bus
//
//                                  this routine is used to send information to devices on the serial bus. A call to
//                                  this routine will put a data byte onto the serial bus using full handshaking.
//                                  Before this routine is called the LISTEN routine, $FFB1, must be used to
//                                  command a device on the serial bus to get ready to receive data.
//                                  the accumulator is loaded with a byte to output as data on the serial bus. A
//                                  device must be listening or the status word will return a timeout. This routine
//                                  always buffers one character. So when a call to the UNLISTEN routine, $FFAE,
//                                  is made to end the data transmission, the buffered character is sent with EOI
//                                  set. Then the UNLISTEN command is sent to the device.
//  .:FFA8 4C DD ED JMP $EDDD       output byte to serial bus

.label /* $FFAB - 65451 */ FFAB_command_serial_bus_untalk = $FFAB
// command serial bus to UNTALK
//
//                                 this routine will transmit an UNTALK command on the serial bus. All devices
//                                 previously set to TALK will stop sending data when this command is received.
// .:FFAB 4C EF ED JMP $EDEF       command serial bus to UNTALK

.label /* $FFAE - 65454 */ FFAE_command_serial_bus_unlisten = $FFAE
// command serial bus to UNLISTEN
//
//                                 this routine commands all devices on the serial bus to stop receiving data from
//                                 the computer. Calling this routine results in an UNLISTEN command being transmitted
//                                 on the serial bus. Only devices previously commanded to listen will be affected.
//                                 This routine is normally used after the computer is finished sending data to
//                                 external devices. Sending the UNLISTEN will command the listening devices to get
//                                 off the serial bus so it can be used for other purposes.
// .:FFAE 4C FE ED JMP $EDFE       command serial bus to UNLISTEN

.label /* $FFB1 - 65457 */ FFB1_command_serial_bus_listen = $FFB1
// command devices on the serial bus to LISTEN
//
//                                 this routine will command a device on the serial bus to receive data. The
//                                 accumulator must be loaded with a device number between 4 and 31 before calling
//                                 this routine. LISTEN convert this to a listen address then transmit this data as
//                                 a command on the serial bus. The specified device will then go into listen mode
//                                 and be ready to accept information.
// .:FFB1 4C 0C ED JMP $ED0C       command devices on the serial bus to LISTEN

.label /* $FFB4 - 65460 */ FFB4_command_serial_bus_talk = $FFB4
// command serial bus device to TALK
//
//                                 to use this routine the accumulator must first be loaded with a device number
//                                 between 4 and 30. When called this routine converts this device number to a talk
//                                 address. Then this data is transmitted as a command on the Serial bus.
// .:FFB4 4C 09 ED JMP $ED09       command serial bus device to TALK

.label /* $FFB7 - 65463 */ FFB7_read_io_status_word = $FFB7
// read I/O status word
//
//                                 this routine returns the current status of the I/O device in the accumulator. The
//                                 routine is usually called after new communication to an I/O device. The routine
//                                 will give information about device status, or errors that have occurred during the
//                                 I/O operation.
// .:FFB7 4C 07 FE JMP $FE07       read I/O status word

.label /* $FFBA - 65466 */ FFBA_set_logical_file_parameters = $FFBA
// set logical, first and second addresses
//
//                                 this routine will set the logical file number, device address, and secondary
//                                 address, command number, for other KERNAL routines.
//                                 the logical file number is used by the system as a key to the file table created
//                                 by the OPEN file routine. Device addresses can range from 0 to 30. The following
//                                 codes are used by the computer to stand for the following CBM devices:
//                                 ADDRESS DEVICE
//                                 ======= ======
//                                  0      Keyboard
//                                  1      Cassette #1
//                                  2      RS-232C device
//                                  3      CRT display
//                                  4      Serial bus printer
//                                  8      CBM Serial bus disk drive
//                                 device numbers of four or greater automatically refer to devices on the serial
//                                 bus.
//                                 a command to the device is sent as a secondary address on the serial bus after
//                                 the device number is sent during the serial attention handshaking sequence. If
//                                 no secondary address is to be sent Y should be set to $FF.
// .:FFBA 4C 00 FE JMP $FE00       set logical, first and second addresses

.label /* $FFBD - 65469 */ FFBD_set_filename = $FFBD
// set the filename
//
//                                 this routine is used to set up the file name for the OPEN, SAVE, or LOAD routines.
//                                 The accumulator must be loaded with the length of the file and XY with the pointer
//                                 to file name, X being th low byte. The address can be any valid memory address in
//                                 the system where a string of characters for the file name is stored. If no file
//                                 name desired the accumulator must be set to 0, representing a zero file length,
//                                 in that case  XY may be set to any memory address.
// .:FFBD 4C F9 FD JMP $FDF9       set the filename

.label /* $FFC0 - 65472 */ FFC0_open_vector = $FFC0
// open a logical file
//
//                                 this routine is used to open a logical file. Once the logical file is set up it
//                                 can be used for input/output operations. Most of the I/O KERNAL routines call on
//                                 this routine to create the logical files to operate on. No arguments need to be
//                                 set up to use this routine, but both the SETLFS, $FFBA, and SETNAM, $FFBD,
//                                 KERNAL routines must be called before using this routine.
// .:FFC0 6C 1A 03 JMP ($031A)     do open a logical file

.label /* $FFC3 - 65475 */ FFC3_close_vector = $FFC3
// close a specified logical file
//
//                                 this routine is used to close a logical file after all I/O operations have been
//                                 completed on that file. This routine is called after the accumulator is loaded
//                                 with the logical file number to be closed, the same number used when the file was
//                                 opened using the OPEN routine.
// .:FFC3 6C 1C 03 JMP ($031C)     do close a specified logical file

.label /* $FFC6 - 65478 */ FFC6_set_input = $FFC6
// open channel for input
//
//                                 any logical file that has already been opened by the OPEN routine, $FFC0, can be
//                                 defined as an input channel by this routine. the device on the channel must be an
//                                 input device or an error will occur and the routine will abort.
//
//                                 if you are getting data from anywhere other than the keyboard, this routine must be
//                                 called before using either the CHRIN routine, $FFCF, or the GETIN routine,
//                                 $FFE4. if you are getting data from the keyboard and no other input channels are
//                                 open then the calls to this routine and to the OPEN routine, $FFC0, are not needed.
//
//                                 when used with a device on the serial bus this routine will automatically send the
//                                 listen address specified by the OPEN routine, $FFC0, and any secondary address.
//
//                                 possible errors are:
//
//                                 3 : file not open
//                                 5 : device not present
//                                 6 : file is not an input file
// .:FFC6 6C 1E 03 JMP ($031E)     do open channel for input

.label /* $FFC9 - 65481 */ FFC9_set_output = $FFC9
// open channel for output
//
//                                 any logical file that has already been opened by the OPEN routine, $FFC0, can be
//                                 defined as an output channel by this routine the device on the channel must be an
//                                 output device or an error will occur and the routine will abort.
//
//                                 if you are sending data to anywhere other than the screen this routine must be
//                                 called before using the CHROUT routine, $FFD2. if you are sending data to the
//                                 screen and no other output channels are open then the calls to this routine and to
//                                 the OPEN routine, $FFC0, are not needed.
//
//                                 when used with a device on the serial bus this routine will automatically send the
//                                 listen address specified by the OPEN routine, $FFC0, and any secondary address.
//
//                                 possible errors are:
//
//                                 3 : file not open
//                                 5 : device not present
//                                 7 : file is not an output file
// .:FFC9 6C 20 03 JMP ($0320)     do open channel for output

.label /* $FFCC - 65484 */ FFCC_restore_io_vector = $FFCC
// close input and output channels
//
//                                 this routine is called to clear all open channels and restore the I/O channels to
//                                 their original default values. It is usually called after opening other I/O
//                                 channels and using them for input/output operations. The default input device is
//                                 0, the keyboard. The default output device is 3, the screen.
//                                 If one of the channels to be closed is to the serial port, an UNTALK signal is sent
//                                 first to clear the input channel or an UNLISTEN is sent to clear the output channel.
//                                 By not calling this routine and leaving listener(s) active on the serial bus,
//                                 several devices can receive the same data from the VIC at the same time. One way to
//                                 take advantage of this would be to command the printer to TALK and the disk to
//                                 LISTEN. This would allow direct printing of a disk file.
// .:FFCC 6C 22 03 JMP ($0322)     do close input and output channels

.label /* $FFCF - 65487 */ FFCF_input_vector = $FFCF
// input character from channel
//
//                                 this routine will get a byte of data from the channel already set up as the input
//                                 channel by the CHKIN routine, $FFC6.
//
//                                 If CHKIN, $FFC6, has not been used to define another input channel the data is
//                                 expected to be from the keyboard. the data byte is returned in the accumulator. the
//                                 channel remains open after the call.
//
//                                 input from the keyboard is handled in a special way. first, the cursor is turned on
//                                 and it will blink until a carriage return is typed on the keyboard. all characters
//                                 on the logical line, up to 80 characters, will be stored in the BASIC input buffer.
//                                 then the characters can be returned one at a time by calling this routine once for
//                                 each character. when the carriage return is returned the entire line has been
//                                 processed. the next time this routine is called the whole process begins again.
// .:FFCF 6C 24 03 JMP ($0324)     do input character from channel

.label /* $FFD2 - 65490 */ FFD2_output_vector = $FFD2
// output character to channel
//
//                                 this routine will output a character to an already opened channel. Use the OPEN
//                                 routine, $FFC0, and the CHKOUT routine, $FFC9, to set up the output channel
//                                 before calling this routine. If these calls are omitted, data will be sent to the
//                                 default output device, device 3, the screen. The data byte to be output is loaded
//                                 into the accumulator, and this routine is called. The data is then sent to the
//                                 specified output device. The channel is left open after the call.
//                                 NOTE: Care must be taken when using routine to send data to a serial device since
//                                 data will be sent to all open output channels on the bus. Unless this is desired,
//                                 all open output channels on the serial bus other than the actually intended
//                                 destination channel must be closed by a call to the KERNAL close channel routine.
// .:FFD2 6C 26 03 JMP ($0326)     do output character to channel

.label /* $FFD5 - 65493 */ FFD5_load_ram_from_device = $FFD5
// load RAM from a device
//
//                                 this routine will load data bytes from any input device directly into the memory
//                                 of the computer. It can also be used for a verify operation comparing data from a
//                                 device with the data already in memory, leaving the data stored in RAM unchanged.
//                                 The accumulator must be set to 0 for a load operation or 1 for a verify. If the
//                                 input device was OPENed with a secondary address of 0 the header information from
//                                 device will be ignored. In this case XY must contain the starting address for the
//                                 load. If the device was addressed with a secondary address of 1 or 2 the data will
//                                 load into memory starting at the location specified by the header. This routine
//                                 returns the address of the highest RAM location which was loaded.
//                                 Before this routine can be called, the SETLFS, $FFBA, and SETNAM, $FFBD,
//                                 routines must be called.
// .:FFD5 4C 9E F4 JMP $F49E       load RAM from a device

.label /* $FFD8 - 65496 */ FFD8_save_ram_to_device = $FFD8
// save RAM to a device
//
//                                 this routine saves a section of memory. Memory is saved from an indirect address
//                                 on page 0 specified by A, to the address stored in XY, to a logical file. The
//                                 SETLFS, $FFBA, and SETNAM, $FFBD, routines must be used before calling this
//                                 routine. However, a file name is not required to SAVE to device 1, the cassette.
//                                 Any attempt to save to other devices without using a file name results in an error.
//                                 NOTE: device 0, the keyboard, and device 3, the screen, cannot be SAVEd to. If
//                                 the attempt is made, an error will occur, and the SAVE stopped.
// .:FFD8 4C DD F5 JMP $F5DD       save RAM to device

.label /* $FFDB - 65499 */ FFDB_set_real_time_clock = $FFDB
// set the real time clock
//
//                                 the system clock is maintained by an interrupt routine that updates the clock
//                                 every 1/60th of a second. The clock is three bytes long which gives the capability
//                                 to count from zero up to 5,184,000 jiffies - 24 hours plus one jiffy. At that point
//                                 the clock resets to zero. Before calling this routine to set the clock the new time,
//                                 in jiffies, should be in YXA, the accumulator containing the most significant byte.
// .:FFDB 4C E4 F6 JMP $F6E4       set real time clock

.label /* $FFDE - 65502 */ FFDE_read_real_time_clock = $FFDE
// read the real time clock
//
//                                 this routine returns the time, in jiffies, in AXY. The accumulator contains the
//                                 most significant byte.
// .:FFDE 4C DD F6 JMP $F6DD       read real time clock

.label /* $FFE1 - 65505 */ FFE1_test_stop_vector = $FFE1
// scan the stop key
//
//                                 if the STOP key on the keyboard is pressed when this routine is called the Z flag
//                                 will be set. All other flags remain unchanged. If the STOP key is not pressed then
//                                 the accumulator will contain a byte representing the last row of the keyboard scan.
//                                 The user can also check for certain other keys this way.
// .:FFE1 6C 28 03 JMP ($0328)     do scan stop key

.label /* $FFE4 - 65508 */ FFE4_get_from_keyboad = $FFE4
// get character from input device
//
//                                 in practice this routine operates identically to the CHRIN routine, $FFCF,
//                                 for all devices except for the keyboard. If the keyboard is the current input
//                                 device this routine will get one character from the keyboard buffer. It depends
//                                 on the IRQ routine to read the keyboard and put characters into the buffer.
//                                 If the keyboard buffer is empty the value returned in the accumulator will be zero.
// .:FFE4 6C 2A 03 JMP ($032A)     do get character from input device

.label /* $FFE7 - 65511 */ FFE7_close_all_channels_and_files = $FFE7
// close all channels and files
//
//                                 this routine closes all open files. When this routine is called, the pointers into
//                                 the open file table are reset, closing all files. Also the routine automatically
//                                 resets the I/O channels.
// .:FFE7 6C 2C 03 JMP ($032C)     do close all channels and files

.label /* $FFEA - 65514 */ FFEA_increment_real_time_clock = $FFEA
// increment real time clock
//
//                                 this routine updates the system clock. Normally this routine is called by the
//                                 normal KERNAL interrupt routine every 1/60th of a second. If the user program
//                                 processes its own interrupts this routine must be called to update the time. Also,
//                                 the STOP key routine must be called if the stop key is to remain functional.
// .:FFEA 4C 9B F6 JMP $F69B       increment real time clock

.label /* $FFED - 65517 */ FFED_return_screen_organization = $FFED
// return X,Y organization of screen
//
//                                 this routine returns the x,y organisation of the screen in X,Y
// .:FFED 4C 05 E5 JMP $E505       return X,Y organization of screen

.label /* $FFF0 - 65520 */ FFF0_read_set_cursor_x_y_position = $FFF0
// read/set X,Y cursor position
//
//                                 this routine, when called with the carry flag set, loads the current position of
//                                 the cursor on the screen into the X and Y registers. X is the column number of
//                                 the cursor location and Y is the row number of the cursor. A call with the carry
//                                 bit clear moves the cursor to the position determined by the X and Y registers.
// .:FFF0 4C 0A E5 JMP $E50A       read/set X,Y cursor position

.label /* $FFF3 - 65523 */ FFF3_return_io_base_address = $FFF3
// return the base address of the I/O devices
//
//                                 this routine will set XY to the address of the memory section where the memory
//                                 mapped I/O devices are located. This address can then be used with an offset to
//                                 access the memory mapped I/O devices in the computer.
// .:FFF3 4C 00 E5 JMP $E500       return the base address of the I/O devices

.label /* $FFF6 - 65526 */ FFF6_ = $FFF6
// .:FFF6 52 52 42 59              RRBY

.label /* $FFF8 - 65528 */ FFF8_system = $FFF8

.label /* $FFFA - 65530 */ FFFA_vector_nmi = $FFFA
// .:FFFA 43 FE                    NMI Vektor

.label /* $FFFC - 65532 */ FFFC_vector_reset = $FFFC
// .:FFFC E2 FC                    RESET Vektor

.label /* $FFFE - 65534 */ FFFE_vector_irq = $FFFE
// .:FFFE 48 FF                    IRQ Vektor

}
