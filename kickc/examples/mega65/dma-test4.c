// MEGA65 DMA test using 256MB version
// Appendix J in https://mega.scryptos.com/sharefolder-link/MEGA/MEGA65+filehost/Docs/MEGA65-Book_draft.pdf
#pragma target(mega65)
#include <mega65-dma.h>

void main() {
    // Map memory to BANK 0 : 0x00XXXX - giving access to I/O
    memoryRemap(0,0,0);
    // Move screen up using DMA
    memcpy_dma256(0,0, DEFAULT_SCREEN, 0,0, DEFAULT_SCREEN+80, 24*80);    
}
