#include <c64.h>
#include <6502.h>
#include <keyboard.h>
#include <multiply.h>
#include <print.h>

byte const FRAME_COUNT = 45;
byte const FIRST_FRAME_INDEX = 256 - FRAME_COUNT;

byte const CENTER_X = 184;
byte const CENTER_Y = 150;

byte const SPRITE_WIDTH = 24;
byte const SPRITE_HEIGHT = 21;

byte* const SCREEN = 0x0400;
byte* const SPRITES_PTR = SCREEN + SPRITE_PTRS;


export __address(FIRST_FRAME_INDEX * 64) char SPRITE[0x40] = kickasm(resource "hourglass-spritepad.bin") {{
    .import binary "src/hourglass-spritepad.bin"
}};

void main() {
    print_cls();

    set_sprite_enable(0, true);
    set_sprite_enable(1, true);
    set_sprite_expand(0, true, true);

    set_sprite_position(
        0,
        CENTER_X - 2*SPRITE_WIDTH,
        CENTER_Y - 2*SPRITE_HEIGHT);

    set_sprite_position(
        1, CENTER_X, CENTER_Y);

    SPRITES_COLOR[0] = BLACK;
    SPRITES_COLOR[1] = BLACK;

    set_sprite_pointer(0, SPRITE, FIRST_FRAME_INDEX);
    set_sprite_pointer(1, SPRITE, FIRST_FRAME_INDEX);


    byte frame = FIRST_FRAME_INDEX;
    while(true) {
        sleep(1800);
        set_sprite_pointer(0, SPRITE, frame);
        set_sprite_pointer(1, SPRITE, frame);

        if (frame == 255) {
            frame = FIRST_FRAME_INDEX;
        }

        frame++;
    }
}

void sleep(word delay) {
    for (word wait: 0..delay) {}
}

void wait_for_vblank() {
    while(true) {
        if (*RASTER == $32) {
            return;
        }
    }
}

void set_sprite_enable(byte sprite_no, bool enable) {
    byte mask = %00000001;
    mask = mask << sprite_no;
    if (enable) {
        VICII->SPRITES_ENABLE = VICII->SPRITES_ENABLE | mask;
    } else {
        mask = ~mask;
        VICII->SPRITES_ENABLE = VICII->SPRITES_ENABLE & mask;
    }
}

void set_sprite_expand(byte sprite_no, bool x, bool y) {
    byte mask = %00000001;
    mask = mask << sprite_no;
    if (x) {
        VICII->SPRITES_EXPAND_X = VICII->SPRITES_EXPAND_X | mask;
    } else {
        mask = ~mask;
        VICII->SPRITES_EXPAND_X = VICII->SPRITES_EXPAND_X & mask;
    }

    if (y) {
        VICII->SPRITES_EXPAND_Y = VICII->SPRITES_EXPAND_Y | mask;
    } else {
        mask = ~mask;
        VICII->SPRITES_EXPAND_Y = VICII->SPRITES_EXPAND_Y & mask;
    }
}

void set_sprite_position(byte sprite_no, word x, word y) {
    byte index = <mul8u(sprite_no, 2);
    SPRITES_XPOS[index]  = <x;
    SPRITES_YPOS[index]  = <y;

    byte mask = %00000001;
    mask = mask << sprite_no;

    if (>x > 0) {
        SPRITES_XMSB[0] = SPRITES_XMSB[0] | mask;
    } else {
        SPRITES_XMSB[0] = SPRITES_XMSB[0] & ~mask;
    }
}

void set_sprite_pointer(byte sprite_no, char * sprite, byte index) {
    SPRITES_PTR[sprite_no] = toSpritePtr(sprite_no) + index;
}
