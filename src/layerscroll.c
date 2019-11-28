#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "vera.h"
#include "font-hud.h"
#include "font-hud-palette.h"

int main() {
	//These functions are defined in vera.h.  This will not work without it, or without being linked to vera.lib
	setDataPort(1, 0);  //set stride here and dataport
	setScreenScale(64, 64, 1);  //set the scale and set video mode to 1 (VGA)
	mlayer0Setup(0x61, 0x00, L0_MAP_BASE, FONT_UPETSCII, 0x0000, 0x0000);  //layer 0 configuration options
	mlayer1Setup(0x61, 0x01, L1_MAP_BASE, FONT_UPETSCII, 0x0000, 0x0000);  //layer 1 configuration options
	copyData(32, (uint16_t)(&palette), PALETTE);   //Need to fix this function so data is on the C side and addresses are passed to veralib
	copyData(4096, (uint16_t)(&fonthud), FONT_UPETSCII) ;
	// number of columns, starting column, starting row, width, height, chacterr, color, layer map address
	fillWindow(32, 1, 1, 28, 28, 64, 0, L0_MAP_BASE);  // Creates and fills an area with the selected char, using the selected font.
	fillWindow(64, 1, 1, 28, 28, 0, 0, L1_MAP_BASE);   // Currently that font is defined and copied over in vera.lib, but I will move
	fillWindow(64, 0, 0, 40, 1, 3, 0, L1_MAP_BASE);    // some of that to the C side soon.
	fillWindow(64, 0, 29, 40, 1, 3, 0, L1_MAP_BASE);
	fillWindow(64, 0, 0, 1, 30, 4, 0, L1_MAP_BASE);
	fillWindow(64, 29, 0, 1, 30, 4, 0, L1_MAP_BASE);
	fillWindow(64, 39, 0, 1, 30, 4, 0, L1_MAP_BASE);
	fillWindow(64, 30, 1, 9, 9, 1, 0, L1_MAP_BASE);
	fillWindow(64, 29, 9, 11, 1, 3, 0, L1_MAP_BASE);
	fillChar(64, 0, 0, 5, 0, L1_MAP_BASE);
	fillChar(64, 29, 0, 9, 0, L1_MAP_BASE);
	fillChar(64, 39, 0, 6, 0, L1_MAP_BASE);
	fillChar(64, 0, 29, 7, 0, L1_MAP_BASE);
	fillChar(64, 29, 29, 10, 0, L1_MAP_BASE);
	fillChar(64, 39, 29, 8, 0, L1_MAP_BASE);
	fillChar(64, 29, 9, 11, 0, L1_MAP_BASE);
	fillChar(64, 39, 9, 12, 0, L1_MAP_BASE);
	fillWindow(64, 30, 10, 9, 19, 2, 0, L1_MAP_BASE);

	while(1){}   // An unending loop so you can bask in the glory of this demo forever.  And ever.  And ever.
    return 0;
 }