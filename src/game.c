#include <c64.h>
#include <6502.h>
#include <keyboard.h>
#include <multiply.h>
#include <print.h>

// Encoding needed for filename
#pragma encoding(petscii_mixed)

// Sprite file
#pragma data_seg(Sprite)
// The sprite data
export __address(0x2040) char SPRITE[0x40] = kickasm(resource "sprites-spritepad.bin") {{
    .import binary "src/sprites-spritepad.bin"
    // .var pic = LoadPicture("src/balloon.png", List().add($000000, $ffffff))
    // .for (var y=0; y<21; y++)
    //     .for (var x=0;x<3; x++)
    //         .byte pic.getSinglecolorByte(x,y)
}};

// Program file
#pragma data_seg(Data)

char* const SCREEN = 0x0400;
char* const SPRITES_PTR = SCREEN + SPRITE_PTRS;


void main() {
    word player_x = 24;
    word player_y = 100;

    while(true) {
        wait_for_vblank();
        if (keyboard_key_pressed(KEY_A)) {
            player_x--;
        }

        if (keyboard_key_pressed(KEY_D)) {
            player_x++;
        }

        if (keyboard_key_pressed(KEY_W)) {
            player_y--;
        }

        if (keyboard_key_pressed(KEY_S)) {
            player_y++;
        }
        draw_all_sprites(player_x, player_y);
    }
}

void draw_all_sprites(word x, word y) {
    byte x_offset = 0;

    SPRITES_MC1[0] = ORANGE;
    SPRITES_MC2[0] = GREEN;

    for (byte i: 0..3) {
        sprite_enable(i, true);
        SPRITES_PTR[i] = toSpritePtr(SPRITE) + i;
        sprite_position(i, x + x_offset, y);
        x_offset += 25;

        byte flag = sprite_flag(i, SPRITE);
        if (is_bit_set(7, flag)) {
            set_bit(i, &SPRITES_MC[0]);
        } else {
            clear_bit(i, &SPRITES_MC[0]);
        }
        SPRITES_COLOR[i] = %00001111 & flag;
    }
}

byte sprite_flag(byte no, byte* sprite_data) {
    byte offset = 64;
    for (byte i=0; i < no; i++) {
        offset += 64;
    }
    return sprite_data[offset - 1];
}

bool inline is_bit_set(byte n, byte value) {
    return (value & (1 << n)) != 0;
}

void set_bit(byte n, byte* value) {
    *value |= 1 << n;
}

void clear_bit(byte n, byte* value) {
    *value &= ~(1 << n);
}

void toggle_bit(byte n, byte* value) {
    *value ^= 1 << n;
}


void wait_for_vblank() {
    while(true) {
        if (*RASTER == $32) {
            return;
        }
    }
}

void sprite_enable(byte sprite_no, bool enable) {
    byte mask = %00000001;
    mask = mask << sprite_no;
    if (enable) {
        VICII->SPRITES_ENABLE = VICII->SPRITES_ENABLE | mask;
    } else {
        mask = ~mask;
        VICII->SPRITES_ENABLE = VICII->SPRITES_ENABLE & mask;
    }
}

void sprite_position(byte sprite_no, word x, word y) {
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

