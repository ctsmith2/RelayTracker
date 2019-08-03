//////////////////////////////////////////////////////////////////////////
// Relay Tracker
//
// Version: 1.1b
// Author: Deadline
//
// 2019 CityXen
//
// As seen on our youtube channel:
// https://www.youtube.com/CityXen
//
// Assembly files are for use with KickAssembler
// http://theweb.dk/KickAssembler
//
// Notes: If you're going to attempt to compile this, you'll
// need the Macros and Constants from this repo:
// https://github.com/cityxen/Commodore64_Programming
//
// How To setup KickAssembler in Windows 10:
// https://www.youtube.com/watch?v=R9VE2U_p060
//
//////////////////////////////////////////////////////////////////////////

*=$2ff0 "constants"
#import "../../Commodore64_Programming/include/Constants.asm"
#import "../../Commodore64_Programming/include/Macros.asm"
#import "relay_tracker-vars.asm"

*=$3000 "customfont"
#import "relay_tracker-charset.asm"
*=$3800 "screendata"
#import "relay_tracker-screen.asm"

*=$0801 "BASIC"
    BasicUpstart($080d)
*=$080d "Program"

    ClearScreen(BLACK) // from Macros.asm
    lda VIC_MEM_POINTERS // point to the new characters
    ora #$0c
    sta VIC_MEM_POINTERS
    jsr initialize
    jsr draw_screen

mainloop:
//////////////////////////////////////////////////
// CHECK KEYBOARD FOR KEY HITS
    jsr KERNAL_GETIN
//////////////////////////////////////////////////
// SPACE (PLAY/PAUSE)
check_space_hit:
    cmp #$20
    bne check_dollar_hit
    // TODO: play/pause stuff
    jmp mainloop
//////////////////////////////////////////////////////////
// $ (Show Directory)
check_dollar_hit:
    cmp #$24
    bne check_c_hit
    jsr show_directory
    jsr draw_screen
    jmp mainloop
//////////////////////////////////////////////////////////
// C (Change Speed)
check_c_hit:
    cmp #$43
    bne check_d_hit
    // TODO: Change speed
    jmp mainloop
//////////////////////////////////////////////////
// D (Change Drive)
check_d_hit:
    cmp #$44
    bne check_e_hit
    jsr change_drive
    jmp mainloop
//////////////////////////////////////////////////
// E (Erase File)
check_e_hit:
    cmp #$45
    bne check_f_hit
    // TODO: Erase File
    jmp mainloop
//////////////////////////////////////////////////
// F (Change Filename)
check_f_hit:
    cmp #$46
    bne check_l_hit
    jsr change_filename
    jmp mainloop
//////////////////////////////////////////////////
// L (Load File)
check_l_hit:
    cmp #$4c
    bne check_n_hit
    jsr load_file
    jmp mainloop    
//////////////////////////////////////////////////
// N (New Data)
check_n_hit:
    cmp #$4e
    bne check_s_hit
    // TODO: New Data
    jmp mainloop
//////////////////////////////////////////////////
// S (Save File)
check_s_hit:
    cmp #$53
    bne check_colon_hit
    jsr save_file
    jmp mainloop
//////////////////////////////////////////////////
// COLON (Change Pattern DOWN)
check_colon_hit:
    cmp #58
    bne check_semicolon_hit
    ldx track_block_cursor
    lda track_block,x
    cmp #pattern_min
    beq check_colon_nope
    dec track_block,x
check_colon_nope:
    jsr refresh_track_blocks
    jsr calculate_pattern_block
    jsr refresh_pattern
    jmp mainloop
//////////////////////////////////////////////////
// SEMICOLON (Change Pattern UP)
check_semicolon_hit:
    cmp #59
    bne check_1_hit
    ldx track_block_cursor
    lda track_block,x
    cmp #pattern_max
    beq check_semicolon_nope
    inc track_block,x
check_semicolon_nope:
    jsr refresh_track_blocks
    jsr calculate_pattern_block
    jsr refresh_pattern
    jmp mainloop
//////////////////////////////////////////////////
// 1 (Set Relay 1)
check_1_hit:
    cmp #$31
    bne check_2_hit
    jsr toggle_relay_1
    jsr calculate_pattern_block
    jmp mainloop
//////////////////////////////////////////////////
// 2 (Set Relay 2)
check_2_hit:
    cmp #$32
    bne check_3_hit
    jsr toggle_relay_2
    jsr calculate_pattern_block
    jmp mainloop
//////////////////////////////////////////////////
// 3 (Set Relay 3)
check_3_hit:
    cmp #$33
    bne check_4_hit
    jsr toggle_relay_3
    jsr calculate_pattern_block
    jmp mainloop
//////////////////////////////////////////////////
// 4 (Set Relay 4)
check_4_hit:
    cmp #$34
    bne check_5_hit
    jsr toggle_relay_4
    jsr calculate_pattern_block
    jmp mainloop
//////////////////////////////////////////////////
// 5 (Set Relay 5)
check_5_hit:
    cmp #$35
    bne check_6_hit
    jsr toggle_relay_5
    jsr calculate_pattern_block
    jmp mainloop
//////////////////////////////////////////////////
// 6 (Set Relay 6)
check_6_hit:
    cmp #$36
    bne check_7_hit
    jsr toggle_relay_6
    jsr calculate_pattern_block
    jmp mainloop
//////////////////////////////////////////////////
// 7 (Set Relay 7)
check_7_hit:
    cmp #$37
    bne check_8_hit
    jsr toggle_relay_7
    jsr calculate_pattern_block
    jmp mainloop
//////////////////////////////////////////////////
// 8 (Set Relay 8)
check_8_hit:
    cmp #$38
    bne check_minus_hit
    jsr toggle_relay_8
    jsr calculate_pattern_block
    jmp mainloop
//////////////////////////////////////////////////
// MINUS (Turn OFF all relays)
check_minus_hit:
    cmp #$2d
    bne check_plus_hit
    jsr all_relay_off
    jsr calculate_pattern_block
    jmp mainloop
//////////////////////////////////////////////////
// PLUS (Turn ON all relays)
check_plus_hit:
    cmp #$2b
    bne check_star_hit
    jsr all_relay_on
    jsr calculate_pattern_block
    jmp mainloop
//////////////////////////////////////////////////
// STAR (Change Command)
check_star_hit:
    cmp #$38
    bne check_equal_hit
    // TODO: Change Command
    jmp mainloop
//////////////////////////////////////////////////
// EQUAL (Change Command Value)
check_equal_hit:
    cmp #$38
    bne check_f1_hit
    // TODO: Change Command Value
    jmp mainloop
//////////////////////////////////////////////////
// F1 (Move Track Position UP)
check_f1_hit:
    cmp #$85
    bne check_f2_hit
    lda track_block_cursor
    cmp #$00
    beq check_f1_hit_too_high
    dec track_block_cursor
    jsr refresh_track_blocks
    jsr calculate_pattern_block
    jsr refresh_pattern
check_f1_hit_too_high:
    jmp mainloop
//////////////////////////////////////////////////
// F2 (Pattern UP)
check_f2_hit:
    cmp #$89
    bne check_f3_hit
    // TODO: Pattern UP
    jmp mainloop
//////////////////////////////////////////////////
// F3 (Move Track Position DOWN)
check_f3_hit:
    cmp #$86
    bne check_f4_hit
    lda track_block_cursor
    cmp #$ff
    beq check_f3_hit_too_low
    inc track_block_cursor
    jsr refresh_track_blocks
    jsr calculate_pattern_block
    jsr refresh_pattern
check_f3_hit_too_low:
    jmp mainloop
//////////////////////////////////////////////////
// F4 (Pattern DOWN)
check_f4_hit:
    cmp #$8a
    bne check_f5_hit
    // TODO: Pattern UP
    jmp mainloop
//////////////////////////////////////////////////
// F5 (Page UP in current Pattern)
check_f5_hit:
    cmp #$87
    bne check_f6_hit
    // TODO: Page UP in current Pattern
    jmp mainloop
//////////////////////////////////////////////////
// F6
check_f6_hit:
    cmp #$8b
    bne check_f7_hit
    jmp mainloop
//////////////////////////////////////////////////
// F7 (Page DOWN in current Pattern)
check_f7_hit:
    cmp #$88
    bne check_f8_hit
    // TODO: Page DOWN in current Pattern
    jmp mainloop
//////////////////////////////////////////////////
// F8
check_f8_hit:
    cmp #$89
    bne check_cursor_up_hit
    jmp mainloop
//////////////////////////////////////////////////
// Cursor UP (Move down one position in current pattern)
check_cursor_up_hit:
    cmp #$11
    bne check_cursor_down_hit
    lda pattern_cursor
    cmp #$ff
    beq check_pattern_too_low
    inc pattern_cursor
    jsr calculate_pattern_block
    jsr refresh_pattern
    
check_pattern_too_low:
    jmp mainloop
//////////////////////////////////////////////////
// Cursor DOWN (Move up one position in current pattern)
check_cursor_down_hit:
    cmp #$91
    bne check_home_hit
    lda pattern_cursor
    cmp #$00
    beq check_pattern_too_high
    dec pattern_cursor
    jsr calculate_pattern_block
    jsr refresh_pattern
check_pattern_too_high:
    jmp mainloop
//////////////////////////////////////////////////
// HOME (Move to top position in current pattern)
check_home_hit:
    cmp #$13
    bne check_clr_hit
    // TODO: Move to top position in current pattern)
    jmp mainloop
//////////////////////////////////////////////////
// CLR (Move to end position in current pattern)
check_clr_hit:
    cmp #$93
    bne check_keys_done
    // TODO: Move to end position in current pattern
    jmp mainloop

check_keys_done:
    jmp mainloop

////////////////////////////////////////////////////
// initialize
initialize:

    lda #08     // Set drive to 8
    sta drive   // Set drive to 8

    lda #$ff    // Set all DATA Direction
    sta $dd03   // on user port

    ldx #00     // Store initial_filename in filename_buffer
init_fn_loop:
    lda initial_filename,x
    sta filename_buffer,x
    inx
    cpx #$10
    bne init_fn_loop
    ldx #00
    stx filename_cursor

    lda #track_block_cursor_init // Set Track block cursor to 0
    sta track_block_cursor

    lda #pattern_cursor_init    // Set Pattern cursor to 0
    sta pattern_cursor

    lda pattern_cursor
    sta pattern_block

    jsr calculate_pattern_block

    rts
initial_filename:
.text "filename.rtd"
.byte 0,0,0,0

////////////////////////////////////////////////////
// draw screen
draw_screen:

    ldx #$00    // Draw the screen from memory location
ds_loop:
    lda screen_001+2,x
    sta 1024,x
    lda screen_001+2+256,x
    sta 1024+256,x
    lda screen_001+2+512,x
    sta 1024+512,x
    lda screen_001+2+512+256,x
    sta 1024+512+256,x
    lda screen_001+1000+2,x
    sta COLOR_RAM,x // And the colors
    lda screen_001+1000+2+256,x
    sta COLOR_RAM+256,x
    lda screen_001+1000+2+512,x
    sta COLOR_RAM+512,x
    lda screen_001+1000+2+512+256,x
    sta COLOR_RAM+512+256,x
    inx
    bne ds_loop

    ldx #$00    // Draw the filename onto the screen
ds_fn_loop:
    lda filename_buffer,x
    cmp #$00
    bne ds_fn_2
    lda #$20
ds_fn_2:
    sta filename,x
    lda #$01
    sta filename_color,x
    inx
    cpx #$10
    bne ds_fn_loop

    jsr show_drive  // Draw the drive onto the screen
    jsr refresh_track_blocks // Update track blocks
    jsr calculate_pattern_block
    jsr refresh_pattern // Update pattern

    rts

.macro DrawRelays(xpos,ypos) { // Macro for drawing relay settings
    clc
    lsr
    tax
    bcc dr_1_1
    lda #90
    sta $0400+xpos+ypos*40
    lda #02
    sta $d800+xpos+ypos*40
    jmp dr_1_2
dr_1_1:
    lda #94
    sta $0400+xpos+ypos*40
    lda #11
    sta $d800+xpos+ypos*40
dr_1_2:
    clc
    txa
    lsr
    tax
    bcc dr_2_1
    lda #90
    sta $0401+xpos+ypos*40
    lda #02
    sta $d801+xpos+ypos*40
    jmp dr_2_2
dr_2_1:
    lda #94
    sta $0401+xpos+ypos*40
    lda #11
    sta $d801+xpos+ypos*40
dr_2_2:
    clc
    txa
    lsr
    tax
    bcc dr_3_1
    lda #90
    sta $0402+xpos+ypos*40
    lda #02
    sta $d802+xpos+ypos*40
    jmp dr_3_2
dr_3_1:
    lda #94
    sta $0402+xpos+ypos*40
    lda #11
    sta $d802+xpos+ypos*40
dr_3_2:
    clc
    txa
    lsr
    tax
    bcc dr_4_1
    lda #90
    sta $0403+xpos+ypos*40
    lda #02
    sta $d803+xpos+ypos*40
    jmp dr_4_2
dr_4_1:
    lda #94
    sta $0403+xpos+ypos*40
    lda #11
    sta $d803+xpos+ypos*40
dr_4_2:
    clc
    txa
    lsr
    tax
    bcc dr_5_1
    lda #90
    sta $0404+xpos+ypos*40
    lda #02
    sta $d804+xpos+ypos*40
    jmp dr_5_2
dr_5_1:
    lda #94
    sta $0404+xpos+ypos*40
    lda #11
    sta $d804+xpos+ypos*40
dr_5_2:
    clc
    txa
    lsr
    tax
    bcc dr_6_1
    lda #90
    sta $0405+xpos+ypos*40
    lda #02
    sta $d805+xpos+ypos*40
    jmp dr_6_2
dr_6_1:
    lda #94
    sta $0405+xpos+ypos*40
    lda #11
    sta $d805+xpos+ypos*40
dr_6_2:
    clc
    txa
    lsr
    tax
    bcc dr_7_1
    lda #90
    sta $0406+xpos+ypos*40
    lda #02
    sta $d806+xpos+ypos*40
    jmp dr_7_2
dr_7_1:
    lda #94
    sta $0406+xpos+ypos*40
    lda #11
    sta $d806+xpos+ypos*40
dr_7_2:
    clc
    txa
    lsr
    tax
    bcc dr_8_1
    lda #90
    sta $0407+xpos+ypos*40
    lda #02
    sta $d807+xpos+ypos*40
    jmp dr_8_2
dr_8_1:
    lda #94
    sta $0407+xpos+ypos*40
    lda #11
    sta $d807+xpos+ypos*40
dr_8_2:
}

////////////////////////////////////////////////////
// refresh pattern
refresh_pattern:

    lda #$20 // Clear pattern area
    ldx #$00
rp_loop1:
    sta $400+11*40+1,x // POS Column
    sta $400+12*40+1,x
    sta $400+13*40+1,x
    sta $400+14*40+1,x
    sta $400+15*40+1,x
    sta $400+16*40+1,x
    sta $400+17*40+1,x
    sta $400+18*40+1,x
    sta $400+19*40+1,x
    sta $400+20*40+1,x
    sta $400+21*40+1,x
    sta $400+22*40+1,x
    sta $400+23*40+1,x

    sta $400+11*40+17,x // VA Column
    sta $400+12*40+17,x
    sta $400+13*40+17,x
    sta $400+14*40+17,x
    sta $400+15*40+17,x
    sta $400+16*40+17,x
    sta $400+17*40+17,x
    sta $400+18*40+17,x
    sta $400+19*40+17,x
    sta $400+20*40+17,x
    sta $400+21*40+17,x
    sta $400+22*40+17,x
    sta $400+23*40+17,x    
    inx
    cpx #$04
    bne rp_loop1
    ldx#$00
rp_loop2:
    sta $400+11*40+6,x // RELAY Column
    sta $400+12*40+6,x
    sta $400+13*40+6,x
    sta $400+14*40+6,x
    sta $400+15*40+6,x
    sta $400+16*40+6,x
    sta $400+17*40+6,x
    sta $400+18*40+6,x
    sta $400+19*40+6,x
    sta $400+20*40+6,x
    sta $400+21*40+6,x
    sta $400+22*40+6,x
    sta $400+23*40+6,x
    inx
    cpx#$0a
    bne rp_loop2
    ldx #$00
rp_loop3:
    sta $400+11*40+22,x // Command Column
    sta $400+12*40+22,x
    sta $400+13*40+22,x
    sta $400+14*40+22,x
    sta $400+15*40+22,x
    sta $400+16*40+22,x
    sta $400+17*40+22,x
    sta $400+18*40+22,x
    sta $400+19*40+22,x
    sta $400+20*40+22,x
    sta $400+21*40+22,x
    sta $400+22*40+22,x
    sta $400+23*40+22,x
    inx
    cpx #$09
    bne rp_loop3
    ldx #$00
rp_loop4:
    sta $400+11*40+32,x // Command DATA Column
    sta $400+12*40+32,x
    sta $400+13*40+32,x
    sta $400+14*40+32,x
    sta $400+15*40+32,x
    sta $400+16*40+32,x
    sta $400+17*40+32,x
    sta $400+18*40+32,x
    sta $400+19*40+32,x
    sta $400+20*40+32,x
    sta $400+21*40+32,x
    sta $400+22*40+32,x
    sta $400+23*40+32,x
    inx
    cpx #$07
    bne rp_loop4

    // Done clearing, now draw pattern

    // current_pattern
    // pattern_cursor
    
    // pattern_block_start
    // pattern_block_end
    // pattern is 256 bytes (relay data)
    //            256 bytes (command data)
    //            256 bytes (command data data)
    //            256 bytes (future data)

    // 13 shown pattern values on screen
    // 7 is the cursor position

rp_v1:
    clc
    lda pattern_cursor
    sbc #$05
    bcs rp_v1_2
    jmp rp_v2
rp_v1_2:
    sta pattern_block_lo
    ldx #$00
    lda (pattern_block,x)
    PrintHex(2,11)
    ldx #$00
    lda (pattern_block,x)
    DrawRelays(7,11)
    ldx #$00
    lda (pattern_block,x)
    PrintHex(18,11)
rp_v2:
    clc
    lda pattern_cursor
    sbc #$04
    bcs rp_v2_2
    jmp rp_v3
rp_v2_2:
    sta pattern_block_lo
    ldx #$00
    lda (pattern_block,x)
    PrintHex(2,12)
    ldx #$00
    lda (pattern_block,x)
    DrawRelays(7,12)
    ldx #$00
    lda (pattern_block,x)
    PrintHex(18,12)
rp_v3:
    clc
    lda pattern_cursor
    sbc #$03
    bcs rp_v3_2
    jmp rp_v4
rp_v3_2:
    sta pattern_block_lo
    ldx #$00
    lda (pattern_block,x)
    PrintHex(2,13)
    ldx #$00
    lda (pattern_block,x)
    DrawRelays(7,13)
    ldx #$00
    lda (pattern_block,x)
    PrintHex(18,13)
rp_v4:
    clc
    lda pattern_cursor
    sbc #$02
    bcs rp_v4_2
    jmp rp_v5
rp_v4_2:
    sta pattern_block_lo
    ldx #$00
    lda (pattern_block,x)
    PrintHex(2,14)
    ldx #$00
    lda (pattern_block,x)
    DrawRelays(7,14)
    ldx #$00
    lda (pattern_block,x)
    PrintHex(18,14)
rp_v5:
    clc
    lda pattern_cursor
    sbc #$01
    bcs rp_v5_2
    jmp rp_v6
rp_v5_2:
    sta pattern_block_lo
    ldx #$00
    lda (pattern_block,x)
    PrintHex(2,15)
    ldx #$00
    lda (pattern_block,x)
    DrawRelays(7,15)
    ldx #$00
    lda (pattern_block,x)
    PrintHex(18,15)
rp_v6:
    clc
    lda pattern_cursor
    sbc #$00
    bcs rp_v6_2
    jmp rp_v7
rp_v6_2:
    sta pattern_block_lo
    ldx #$00
    lda (pattern_block,x)
    PrintHex(2,16)
    ldx #$00
    lda (pattern_block,x)
    DrawRelays(7,16)
    ldx #$00
    lda (pattern_block,x)
    PrintHex(18,16)
rp_v7:
    lda pattern_cursor
    sta pattern_block_lo
    ldx #$00
    lda (pattern_block,x)
    PrintHex(2,17)
    ldx #$00
    lda (pattern_block,x)
    DrawRelays(7,17)
    ldx #$00
    lda (pattern_block,x)
    PrintHex(18,17)
rp_v8:
    clc
    lda pattern_cursor
    adc #$01
    bcc rp_v8_2
    jmp rp_v9
rp_v8_2:
    sta pattern_block_lo
    ldx #$00
    lda (pattern_block,x)
    PrintHex(2,18)
    ldx #$00
    lda (pattern_block,x)
    DrawRelays(7,18)
    ldx #$00
    lda (pattern_block,x)
    PrintHex(18,18)
rp_v9:
    clc
    lda pattern_cursor
    adc #$02
    bcc rp_v9_2
    jmp rp_v10
rp_v9_2:
    sta pattern_block_lo
    ldx #$00
    lda (pattern_block,x)
    PrintHex(2,19)
    ldx #$00
    lda (pattern_block,x)
    DrawRelays(7,19)
    ldx #$00
    lda (pattern_block,x)
    PrintHex(18,19)
rp_v10:
    clc
    lda pattern_cursor
    adc #$03
    bcc rp_v10_2
    jmp rp_v11
rp_v10_2:
    sta pattern_block_lo
    ldx #$00
    lda (pattern_block,x)
    PrintHex(2,20)
    ldx #$00
    lda (pattern_block,x)
    DrawRelays(7,20)
    ldx #$00
    lda (pattern_block,x)
    PrintHex(18,20)
rp_v11:
    clc
    lda pattern_cursor
    adc #$04
    bcc rp_v11_2
    jmp rp_v12
rp_v11_2:
    sta pattern_block_lo
    ldx #$00
    lda (pattern_block,x)
    PrintHex(2,21)
    ldx #$00
    lda (pattern_block,x)
    DrawRelays(7,21)
    ldx #$00
    lda (pattern_block,x)
    PrintHex(18,21)
rp_v12:
    clc
    lda pattern_cursor
    adc #$05
    bcc rp_v12_2
    jmp rp_v13
rp_v12_2:
    sta pattern_block_lo
    ldx #$00
    lda (pattern_block,x)
    PrintHex(2,22)
    ldx #$00
    lda (pattern_block,x)
    DrawRelays(7,22)
    ldx #$00
    lda (pattern_block,x)
    PrintHex(18,22)
rp_v13:
    clc
    lda pattern_cursor
    adc #$06
    bcc rp_v13_2
    jmp rp_v14
rp_v13_2:
    sta pattern_block_lo
    ldx #$00
    lda (pattern_block,x)
    PrintHex(2,23)
    ldx #$00
    lda (pattern_block,x)
    DrawRelays(7,23)
    ldx #$00
    lda (pattern_block,x)
    PrintHex(18,23)
rp_v14:
    rts

////////////////////////////////////////////////////
// refresh track blocks
refresh_track_blocks:

    lda #$20 // Clear Track Blocks Area
    ldx #$00
rtb_loop1:
    sta $400+3*40,x
    sta $400+4*40,x
    sta $400+5*40,x
    inx
    cpx #$07
    bne rtb_loop1

    // Done clearing track blocks area

    ldx track_block_cursor
    dex
    cpx #$ff
    beq rtb_skip_top
    
    lda #58
    sta $400+3+3*40

    txa
    PrintHex(1,3)
    ldx track_block_cursor
    dex
    lda track_block,x
    PrintHex(4,3)

rtb_skip_top:

    lda #58
    sta $400+3+4*40
    
    ldx track_block_cursor
    txa
    PrintHex(1,4)
    ldx track_block_cursor
    lda track_block,x
    PrintHex(4,4)
    ldx track_block_cursor
    lda track_block,x
    PrintHex(16,3)

    lda #58
    sta $400+3+5*40

    ldx track_block_cursor
    inx
    txa
    PrintHex(1,5)
    ldx track_block_cursor
    inx
    lda track_block,x
    PrintHex(4,5)

    ldx #$00
rtb_rev:
    lda $400+4*40,x
    adc #$80
    sta $400+4*40,x
    lda #$01
    sta $d800+4*40,x
    inx
    cpx #$07
    bne rtb_rev
    rts

////////////////////////////////////////////////////
// change filename
change_filename:

    ldx #$00 // Reverse the editing area
fn_reverse:
    lda filename,x
    ora #$80
    sta filename,x
    lda #$01
    sta filename_color,x
    inx
    cpx #$10
    bne fn_reverse

fn_kb_chk: // Check Keyboard loop

    lda #$55    // Check raster and flash the cursor
    cmp VIC_RASTER_COUNTER
    bne fn_kb_chk_no_crs

    ldx filename_cursor
    lda filename,x
    cmp #$80
    bcs fn_kb_chk_crs_not_revd
    ora #$80
    sta filename,x
    jmp fn_kb_chk_no_crs
fn_kb_chk_crs_not_revd:
    and #$7f
    sta filename,x

fn_kb_chk_no_crs: // End of flash cursor stuff

    ldx filename_cursor
    cpx #$10
    bne fn_kb_not_too_long
    ldx #$0f
    stx filename_cursor
fn_kb_not_too_long:

    jsr KERNAL_GETIN
    cmp #$00
    beq fn_kb_chk

    cmp #13
    beq fn_kb_chk_end

    cmp #20
    bne fn_kb_chk_not_del
    ldx filename_cursor
    cpx #$00
    beq fn_kb_chk_del_first_pos
    lda #$a0
    ldx filename_cursor
    sta filename,x
    dec filename_cursor
    jmp fn_kb_chk
fn_kb_chk_del_first_pos:
    lda #$a0
    sta filename
    jmp fn_kb_chk

fn_kb_chk_not_del:
    cmp #64
    bcc fn_kb_num
    sbc #64
fn_kb_num:
    ora #$80
    ldx filename_cursor
    sta filename,x
    inc filename_cursor
    jmp fn_kb_chk
     
fn_kb_chk_end:
    ldx #00

fn_rereverse:   // Done editing, re-reverse all the characters
    lda filename,x
    and #$7f
    sta filename,x
    sta filename_buffer,x
    inx
    cpx #$10
    bne fn_rereverse
    ldx #$00

    ldx #$0f // fill in spaces on end with 0 (start at end and work backward)
fn_trim:
    lda filename_buffer,x
    cmp #$20
    bne fn_out
    lda #00
    sta filename_buffer,x
    dex
    jmp fn_trim

fn_out:
    rts

////////////////////////////////////////////////////
// change drive
change_drive:
    inc drive
show_drive:
    lda drive
    cmp #08
    bne cd_2
    lda #48
    sta $491
    lda #56
    sta $492
    rts
cd_2:
    cmp #09
    bne cd_3
    lda #48
    sta $491
    lda #57
    sta $492
    rts
cd_3:
    cmp #10
    bne cd_4
    lda #49
    sta $491
    lda #48
    sta $492
    rts
cd_4:
    cmp #11
    bne cd_5
    lda #49
    sta $491
    lda #49
    sta $492
    rts
cd_5:
    lda #07
    sta drive
    jmp change_drive

////////////////////////////////////////////////////
// show directory
show_directory:
    lda #$01
    sta $0286
    jsr $e544      // clear screen
    lda #$01
    ldx #<dirname
    ldy #>dirname
    jsr KERNAL_SETNAM // set filename "$"
    lda drive
    sta $ba
    lda #$60
    sta $b9        // secondary chn
    jsr $f3d5      // open for serial bus devices
    jsr $f219      // set input device
    ldy #$04
labl1:
    jsr $ee13      // input byte on serial bus
    dey
    bne labl1      // get rid of y bytes
    lda $c6        // key pressed?
    ora $90        // or eof?
    bne labl2      // if yes exit
    jsr $ee13      // now get in ax the dimension
    tax            // of the file
    jsr $ee13
    jsr $bdcd      // print number from ax
labl3:
    jsr $ee13      // now the filename
    jsr $e716      // put a character to screen
    bne labl3      // while not 0 encountered
    jsr $aad7      // put a cr , end line
    ldy #$02       // set 2 bytes to skip
    bne labl1      // repeat
labl2:
    jsr $f642      // close serial bus device
    jsr $f6f3      // restore i/o devices to default

    lda #13
    jsr KERNAL_CHROUT
    jsr show_drive_status

    ldx #$00
labl22:
    lda dir_presskey,x
    beq labl4
    jsr KERNAL_CHROUT
    inx
    jmp labl22        

labl4:
    jsr $f142      // w8 a key
    beq labl4
    rts
dirname:
.text "$"
dir_presskey:
.encoding "screencode_mixed"
.byte 13
.text "PRESS ANY KEY"
.byte 0

////////////////////////////////////////////////////
// save file
save_file:

    lda #$01
    sta $0286
    jsr $e544      // clear screen

    ldx #$00
sv_labl1:
    lda save_saving,x
    beq sv_labl2
    sta SCREEN_RAM,x
    inx
    jmp sv_labl1
    
    ldx #$00
sv_labl0:
    lda #$00
    sta filename_save,x
    inx
    cpx #$10
    bne sv_labl0
sv_labl2:
    ldx #$00
sv_labl3:
    lda filename_buffer,x
    beq sv_labl33
    sta SCREEN_RAM+7,x
    inx
    cpx #$10
    bne sv_labl3
sv_labl33:
    ldx #$00
sv_labl4:
    lda filename_buffer,x
    cmp #$00
    beq sv_labl5
    cmp #27
    bcs sv_dont_add
    adc #$40
sv_dont_add:
    sta filename_save,x
    inx
    jmp sv_labl4
sv_labl5:
    stx filename_length

.var tmpalow = $fb 
.var tmpahigh = $fc 
.var savefrom = $4000 
.var saveto   = $9fff 

   lda #$0f
   ldx drive
   ldy #$ff
   jsr KERNAL_SETLFS
    
   lda filename_length //#$10
   ldx #<filename_save
   ldy #>filename_save
   jsr KERNAL_SETNAM
    
   lda #<savefrom // Set Start Address
   sta tmpalow
   lda #>savefrom
   sta tmpahigh
   ldx #<saveto // Set End Address 
   ldy #>saveto 
   lda #<tmpalow
   jsr KERNAL_SAVE 

    lda #13
    jsr KERNAL_CHROUT
    jsr KERNAL_CHROUT
    jsr show_drive_status

    ldx #$00
sv_labl22:
    lda dir_presskey,x
    beq sv_out
    jsr KERNAL_CHROUT
    inx
    jmp sv_labl22
sv_out:
    jsr $f142      // w8 a key
    beq sv_out
    jsr draw_screen
    rts

save_saving:
.encoding "screencode_mixed"
.text "saving "
.byte 0

////////////////////////////////////////////////////
// load file
load_file:

    lda #$01
    sta $0286
    jsr $e544      // clear screen

    ldx #$00
ld_labl1:
    lda load_loading,x
    beq ld_labl2
    sta SCREEN_RAM,x
    inx
    jmp ld_labl1
    
    ldx #$00
ld_labl0:
    lda #$00
    sta filename_save,x
    inx
    cpx #$10
    bne ld_labl0
ld_labl2:
    ldx #$00
ld_labl3:
    lda filename_buffer,x
    beq ld_labl33
    sta SCREEN_RAM+8,x
    inx
    cpx #$10
    bne ld_labl3
ld_labl33:
    ldx #$00
ld_labl4:
    lda filename_buffer,x
    cmp #$00
    beq ld_labl5
    cmp #27
    bcs ld_dont_add
    adc #$40
ld_dont_add:
    sta filename_save,x
    inx
    jmp ld_labl4
ld_labl5:
    stx filename_length

.var loadto   = $4000 

   lda #$0f
   ldx drive
   ldy #$ff
   jsr KERNAL_SETLFS
    
   lda filename_length //#$10
   ldx #<filename_save
   ldy #>filename_save
   jsr KERNAL_SETNAM
    
   ldx #<loadto // Set End Address
   ldy #>loadto 
   lda #00
   jsr KERNAL_LOAD

    lda #13
    jsr KERNAL_CHROUT
    jsr KERNAL_CHROUT
    jsr show_drive_status

    ldx #$00
ld_labl22:
    lda dir_presskey,x
    beq ld_out
    jsr KERNAL_CHROUT
    inx
    jmp ld_labl22
ld_out:
    jsr $f142      // w8 a key
    beq ld_out
    jsr draw_screen
    rts

load_loading:
.encoding "screencode_mixed"
.text "loading "
.byte 0


////////////////////////////////////////////////////
// show drive status
show_drive_status:
    lda #$00
    sta $90       // clear status flags

    lda drive       // device number
    jsr $ffb1     // call listen
    lda #$6f      // secondary address 15 (command channel)
    jsr $ff93     // call seclsn (second)
    jsr $ffae     // call unlsn
    lda $90       // get status flags
    bne sds_devnp    // device not present

    lda drive       // device number
    jsr $ffb4     // call talk
    lda #$6f      // secondary address 15 (error channel)
    jsr $ff96     // call sectlk (tksa)

sds_loop:
    lda $90       // get status flags
    bne sds_eof      // either eof or error
    jsr $ffa5     // call iecin (get byte from iec bus)
    jsr $ffd2     // call chrout (print byte to screen)
    jmp sds_loop     // next byte
sds_eof:
    jsr $ffab     // call untlk
    rts
sds_devnp:
    //  ... device not present handling ...
    rts

////////////////////////////////////////////////////
// Draw Current Relay
draw_current_relays:
    jsr calculate_pattern_block
    ldx #$00
    lda (pattern_block,x)
    eor #$ff    // relay block is actually inverse of what is shown on screen
    sta $dd01   // Set Actual USER Port relays
    ldx #$00
    lda (pattern_block,x)
    DrawRelays(7,17)
    ldx #$00
    lda (pattern_block,x)
    DrawRelays(31,0)
    ldx #$00
    lda (pattern_block,x)
    PrintHex(18,17)
/*
    ldx #$00
dcr_rev:
    lda $400+17*40+6,x
    adc #$80
    sta $400+17*40+6,x
    inx
    cpx#$0a
    bne dcr_rev
   */
    rts

////////////////////////////////////////////////////
// toggle relay 1
toggle_relay_1:
    jsr calculate_pattern_block
    clc
    ldx #$00
    lda (pattern_block,x)
    and #$01
    beq check_1_hit_offz
    jmp check_1_hit_off
check_1_hit_offz:
    ldx #$00
    lda (pattern_block,x)
    ora #$01
    sta (pattern_block,x)
    jsr draw_current_relays
    rts
check_1_hit_off:
    ldx #$00
    lda (pattern_block,x)
    and #$fe
    sta (pattern_block,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// toggle relay 2
toggle_relay_2:
    jsr calculate_pattern_block
    clc
    ldx #$00
    lda (pattern_block,x)
    and #$02
    beq check_2_hit_offz
    jmp check_2_hit_off
check_2_hit_offz:
    ldx #$00
    lda (pattern_block,x)
    ora #$02
    sta (pattern_block,x)
    jsr draw_current_relays
    rts
check_2_hit_off:
    ldx #$00
    lda (pattern_block,x)
    and #$fd
    sta (pattern_block,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// toggle relay 3
toggle_relay_3:
    jsr calculate_pattern_block
    clc
    ldx #$00
    lda (pattern_block,x)
    and #$04
    beq check_3_hit_offz
    jmp check_3_hit_off
check_3_hit_offz:
    ldx #$00
    lda (pattern_block,x)
    ora #$04
    sta (pattern_block,x)
    jsr draw_current_relays
    rts
check_3_hit_off:
    ldx #$00
    lda (pattern_block,x)
    and #$fb
    sta (pattern_block,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// toggle relay 4
toggle_relay_4:
    jsr calculate_pattern_block
    clc
    ldx #$00
    lda (pattern_block,x)
    and #$08
    beq check_4_hit_offz
    jmp check_4_hit_off
check_4_hit_offz:
    ldx #$00
    lda (pattern_block,x)
    ora #$08
    sta (pattern_block,x)
    jsr draw_current_relays
    rts
check_4_hit_off:
    ldx #$00
    lda (pattern_block,x)
    and #$f7
    sta (pattern_block,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// toggle relay 5
toggle_relay_5:
    jsr calculate_pattern_block
    clc
    ldx #$00
    lda (pattern_block,x)
    and #16
    beq check_5_hit_offz
    jmp check_5_hit_off
check_5_hit_offz:
    ldx #$00
    lda (pattern_block,x)
    ora #16
    sta (pattern_block,x)
    jsr draw_current_relays
    rts
check_5_hit_off:
    ldx #$00
    lda (pattern_block,x)
    and #$ef
    sta (pattern_block,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// toggle relay 6
toggle_relay_6:
    jsr calculate_pattern_block
    clc
    ldx #$00
    lda (pattern_block,x)
    and #32
    beq check_6_hit_offz
    jmp check_6_hit_off
check_6_hit_offz:
    ldx #$00
    lda (pattern_block,x)
    ora #32
    sta (pattern_block,x)
    jsr draw_current_relays
    rts
check_6_hit_off:
    ldx #$00
    lda (pattern_block,x)
    and #$df
    sta (pattern_block,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// toggle relay 7
toggle_relay_7:
    jsr calculate_pattern_block
    clc
    ldx #$00
    lda (pattern_block,x)
    and #64
    beq check_7_hit_offz
    jmp check_7_hit_off
check_7_hit_offz:
    ldx #$00
    lda (pattern_block,x)
    ora #64
    sta (pattern_block,x)
    jsr draw_current_relays
    rts
check_7_hit_off:
    ldx #$00
    lda (pattern_block,x)
    and #$bf
    sta (pattern_block,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// toggle relay 8
toggle_relay_8:
    jsr calculate_pattern_block
    clc
    ldx #$00
    lda (pattern_block,x)
    and #128
    beq check_8_hit_offz
    jmp check_8_hit_off
check_8_hit_offz:
    ldx #$00
    lda (pattern_block,x)
    ora #128
    sta (pattern_block,x)
    jsr draw_current_relays
    rts
check_8_hit_off:
    ldx #$00
    lda (pattern_block,x)
    and #$7f
    sta (pattern_block,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// all relays off
all_relay_off:
    jsr calculate_pattern_block
    lda #$00
    ldx #$00
    sta (pattern_block,x)
    jsr draw_current_relays
    rts

////////////////////////////////////////////////////
// all relays on
all_relay_on:
    jsr calculate_pattern_block
    lda #$ff
    ldx #$00
    sta (pattern_block,x)
    jsr draw_current_relays
    rts

///////////////////////////////////////////////////
// Calculate pattern block
calculate_pattern_block:

    lda pattern_cursor
    sta pattern_block_lo
    lda #$41
    sta pattern_block_hi

    ldx track_block_cursor
    lda track_block,x
    tax
    cpx #$00
    beq cpb_2
cpb_1:
    lda pattern_block_hi
    adc #$02
    sta pattern_block_hi
    dex
    cpx #$00
    beq cpb_2    
    jmp cpb_1
cpb_2:

    lda pattern_block_lo
    PrintHex(4,24)
    lda pattern_block_hi
    PrintHex(2,24)

    ldx #$00
    lda (pattern_block,x)
    PrintHex(8,24)

    rts