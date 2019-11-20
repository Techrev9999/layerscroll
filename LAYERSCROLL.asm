; 64TASS ASM FILE

;
; Simple horizontal scroll demo of layer0 with layer1 being static
;

.section section_ZP
hScrollDelay		.byte		?
hScrollOff			.byte		?
hScrollPos			.byte		?
.send section_ZP

.section section_BSS
oldISR:		.word		?
mapChar		.byte		?
.send section_BSS

.section section_CODE
	.byte $0e, $08, $0a, $00, $9e, $20, $28, $32, $30, $36, $34, $29, $00, $00, $00		; Start at $0810


ISR_ADDR	= $0314
L0_MAP_BASE	= $00000
L1_MAP_BASE	= $04000
HUD_OUT_CLR	= $8B
HUD_TXT_CLR = $61
HSCROLL_DELAY_RESET	= 2		; 1 second for every 60 delay

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		jsr titleScreen
		jsr initGame

		jsr isrInit

		jmp *
		;rts

isrInit:
		sei			; disable interrupts

		;save previous interrupt location
		lda ISR_ADDR
		sta oldISR
		lda ISR_ADDR+1
		sta oldISR+1

		lda #<myIsr				; hook to myisr
		sta ISR_ADDR
		lda #>myIsr
		sta ISR_ADDR+1

		lda #$00				; init hscroll value
		sta hScrollOff
		sta mapChar
		lda #30
		sta hScrollPos
		lda #HSCROLL_DELAY_RESET		; scroll delay
		sta hScrollDelay

		cli			; enable interrupts
		rts


titleScreen:
		rts

initGame:
		; most everything is done on data port 0
		#Vera.setDataPort 0

		; set screen to 320x240
		#Vera.setScreenRes 320,240

		; setup layer 0: mode=0/e=1, map=32x32, map=$0000, tile=font0, h/v-scroll=0
		#Vera.layerSetup 0, %01100001, $00, L0_MAP_BASE, Vera.FONT_LPETSCII, $0000, $0000
		; setup layer 1: mode=0/e=1, map=64x32, map=$4000, tile=font0, h/v-scroll=0
		#Vera.layerSetup 1, %01100001, $01, L1_MAP_BASE, Vera.FONT_LPETSCII, $0000, $0000

		; copy the palette data over to VERA
		#Vera.copyDataToVera palette, Vera.PALETTE, 512
		; copy the 'font' data into low PETSCII location only copying 64 characters
		#Vera.copyDataToVera font, Vera.FONT_LPETSCII, 64*4*8

		; fill window: mapBase, numMapCols, c, r, w, h, chr, clr
		#Vera.fillWindow L0_MAP_BASE, 32, 1, 1, 32, 32, 24, 0			; clear layer0
		#Vera.fillWindow L1_MAP_BASE, 64, 1, 1, 28, 28, 0, 0			; HUD clear viewport to see layer0
		#Vera.fillWindow L1_MAP_BASE, 64, 0, 0, 40, 1, 3, 0				; HUD top H line
		#Vera.fillWindow L1_MAP_BASE, 64, 0, 29, 40, 1, 3, 0			; HUD bottom H line
		#Vera.fillWindow L1_MAP_BASE, 64, 0, 0, 1, 30, 4, 0				; HUD left V line
		#Vera.fillWindow L1_MAP_BASE, 64, 29, 0, 1, 30, 4, 0			; HUD mid V line
		#Vera.fillWindow L1_MAP_BASE, 64, 39, 0, 1, 30, 4, 0			; HUD right V line
		#Vera.fillWindow L1_MAP_BASE, 64, 30, 1, 9, 9, 1, 0				; HUD smallmap text area fill
		#Vera.fillWindow L1_MAP_BASE, 64, 29, 9, 11, 1, 3, 0			; HUD smallmap separator
		#Vera.fillChar L1_MAP_BASE, 64, 0, 0, 5, 0						; HUD top left corner
		#Vera.fillChar L1_MAP_BASE, 64, 29, 0, 9, 0						; HUD top mid T
		#Vera.fillChar L1_MAP_BASE, 64, 39, 0, 6, 0						; HUD top right corner
		#Vera.fillChar L1_MAP_BASE, 64, 0, 29, 7, 0						; HUD bot left corner
		#Vera.fillChar L1_MAP_BASE, 64, 29, 29, 10, 0					; HUD bot mid T
		#Vera.fillChar L1_MAP_BASE, 64, 39, 29, 8, 0					; HUD bot right corner
		#Vera.fillChar L1_MAP_BASE, 64, 29, 9, 11, 0					; HUD smallmap left T
		#Vera.fillChar L1_MAP_BASE, 64, 39, 9, 12, 0					; HUD smallmap right T
		#Vera.fillWindow L1_MAP_BASE, 64, 30, 10, 9, 19, 2, 0			; HUD right text area fill

		rts

myIsr:
		lda #$01				; clear VERA interrupt status
		sta Vera.IO_VERA.isr

		dec hScrollDelay		; decrease scroll delay
		bne isr_done
		lda #HSCROLL_DELAY_RESET	; reset if at zero
		sta hScrollDelay

		#vaddr 0, Vera.L0_HSCROLL
		inc Vera.IO_VERA.data0

		lda hScrollOff
		ina
		cmp #8
		bne +
		lda #0
+		sta hScrollOff
		bne isr_done

		; setup for FillWindow routine
		#vaddr 1, L0_MAP_BASE
		#bpoke 1, Vera.cw_row
		#bpoke 1, Vera.cw_width
		#bpoke 28, Vera.cw_height
		#bpoke 0, Vera.cw_color
		#bpoke (32 - 1)<<1, Vera.cw_winc

		; column pos
		lda hScrollPos
		sta Vera.cw_col
		ina
		and #$1f
		sta hScrollPos

		; fill with mapChar
		lda #24
		sta Vera.cw_char
		;inc mapChar

		; do fill
		jsr Vera.AddCwRowColToVAddr32
		jsr Vera.FillWindow

isr_done:
		ply
		plx
		pla
		rti
		;jmp oldISR				; jump to old ISR

;#include "debug.asm"
.send section_CODE


.section section_DATA
palette:
.binary "res/palette.bin"
font:
.binary "res/font-hud.bin"
.send section_DATA

;
; included libraries
;
.include "vera.asm"

;
; Memory map
;
*	= $00
.dsection section_ZP
.cerror * >= $90, "To many ZP variables"

*	= $0400
.dsection section_BSS
.cerror * >= $0800, "To many BSS variables"

*	= $0801
.dsection section_CODE
.cerror * >= $9f00, "CODE size is to big"
.dsection section_DATA
.cerror * >= $9f00, "DATA size is to big"
*	= $9f00
.dsection section_IO_AUDIO
*	= $9f20
.dsection section_IO_VERA
*	= $9f60
.dsection section_IO_VIA1
*	= $9f70
.dsection section_IO_VIA2
*	= $9f80
.dsection section_IO_RTC

*	= $A000
.dsection section_HIMEM
.cerror * > $bfff, "HIMEM data size to big"
