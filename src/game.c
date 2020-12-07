#include <c64.h>
#include <6502.h>
#include <keyboard.h>
#include <multiply.h>
#include <stdio.h>

// Encoding needed for filename
#pragma encoding(petscii_mixed)

// Sprite file
// #pragma data_seg(Sprite)
// The sprite data
// export __address(0x2040) char SPRITE[0x40] = kickasm(resource "balloon.png") {{
//     .var pic = LoadPicture("src/balloon.png", List().add($000000, $ffffff))
//     .for (var y=0; y<21; y++)
//         .for (var x=0;x<3; x++)
//             .byte pic.getSinglecolorByte(x,y)
// }};

// Program file
#pragma data_seg(Data)

char* const SCREEN = 0x0400;
char* const SPRITES_PTR = SCREEN+SPRITE_PTRS;

void main() {
    word player_x = 24;
    word player_y = 50;

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
    byte offset = 0;
    for (byte i: 0..7) {
        sprite_enable(i, true);
        // SPRITES_PTR[i] = toSpritePtr(SPRITE);
        sprite_position(i, x + offset, y);
        offset += 25;
    }
    sprite_enable(1, false);
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
