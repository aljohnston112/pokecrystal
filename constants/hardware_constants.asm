; Graciously aped from:
; http://nocash.emubase.de/pandocs.htm
; http://gameboy.mongenel.com/dmg/asmmemmap.html

; memory map
VRAM_Begin  EQU $8000
VRAM_End    EQU $a000
SRAM_Begin  EQU $a000
SRAM_End    EQU $c000
WRAM0_Begin EQU $c000
WRAM0_End   EQU $d000
WRAM1_Begin EQU $d000
WRAM1_End   EQU $e000
; hardware registers $ff00-$ff80 (see below)
HRAM_Begin  EQU $ff80
HRAM_End    EQU $ffff

; MBC3
MBC3SRamEnable EQU $0000
MBC3RomBank    EQU $2000
MBC3SRamBank   EQU $4000
MBC3LatchClock EQU $6000
MBC3RTC        EQU $a000

SRAM_DISABLE EQU $00
SRAM_ENABLE  EQU $0a

NUM_SRAM_BANKS EQU 4

RTC_S  EQU $08 ; Seconds   0-59 (0-3Bh)
RTC_M  EQU $09 ; Minutes   0-59 (0-3Bh)
RTC_H  EQU $0a ; Hours     0-23 (0-17h)
RTC_DL EQU $0b ; Lower 8 bits of Day Counter (0-FFh)
RTC_DH EQU $0c ; Upper 1 bit of Day Counter, Carry Bit, Halt Flag
			   ;   bit 0: Most significant bit of Day Counter (Bit 8)
			   ;   bit 6: Halt (0=Active, 1=Stop Timer)
			   ;   bit 7: Day Counter Carry Bit (1=Counter Overflow)

; interrupt flags
VBLANK   EQU 0
LCD_STAT EQU 1
TIMER    EQU 2
SERIAL   EQU 3
JOYPAD   EQU 4
IE_DEFAULT EQU (1 << SERIAL) | (1 << TIMER) | (1 << LCD_STAT) | (1 << VBLANK)

; OAM attribute flags
OAM_TILE_BANK EQU 3
OAM_OBP_NUM   EQU 4 ; non CGB Mode Only
OAM_X_FLIP    EQU 5
OAM_Y_FLIP    EQU 6
OAM_PRIORITY  EQU 7 ; 0: OBJ above BG, 1: OBJ behind BG (colors 1-3)

; BG Map attribute flags
PALETTE_MASK EQU %111
VRAM_BANK_1  EQU 1 << OAM_TILE_BANK ; $08
OBP_NUM      EQU 1 << OAM_OBP_NUM   ; $10
X_FLIP       EQU 1 << OAM_X_FLIP    ; $20
Y_FLIP       EQU 1 << OAM_Y_FLIP    ; $40
PRIORITY     EQU 1 << OAM_PRIORITY  ; $80

; Hardware registers
rJOYP       EQU $ff00 ; Joypad (R/W)
rSB         EQU $ff01 ; Serial transfer data (R/W)
rSC         EQU $ff02 ; Serial Transfer Control (R/W)
rSC_ON      EQU 7
rSC_CGB     EQU 1
rSC_CLOCK   EQU 0
rDIV        EQU $ff04 ; Divider Register (R/W)
rTIMA       EQU $ff05 ; Timer counter (R/W)
rTMA        EQU $ff06 ; Timer Modulo (R/W)
rTAC        EQU $ff07 ; Timer Control (R/W)
rTAC_ON        EQU 2
rTAC_4096_HZ   EQU %00
rTAC_262144_HZ EQU %01
rTAC_65536_HZ  EQU %10
rTAC_16384_HZ  EQU %11
rIF         EQU $ff0f ; Interrupt Flag (R/W)
rNR10       EQU $ff10 ; Channel 1 Sweep register (R/W)
					  ;   bit 7:   unused
					  ;   bit 6-4: sweep time (R/W)
					  ;   bit 3:   sweep direction (R/W)
					  ;   but 2-0: sweep shift (R/W)
rNR11       EQU $ff11 ; Channel 1 Sound length/Wave pattern duty (R/W)
					  ;   bit 7-6: Wave Pattern Duty (R/W)
					  ;   bit 5-0: Sound length data (Write Only) (t1: 0-63)
					  ;     Wave Duty:
					  ;       00: 12.5% ( _-------_-------_------- )
					  ;       01: 25%   ( __------__------__------ )
					  ;       10: 50%   ( ____----____----____---- )
					  ;       11: 75%   ( ______--______--______-- )
					  ;     Sound Length = (64-t1)*(1/256) seconds
					  ;     The Length value is used only if Bit 6 in NR14 is set.
rNR12       EQU $ff12 ; Channel 1 Volume Envelope (R/W)
					  ;	  bit 7-4: Initial Volume of envelope (0-0Fh) (0=No Sound)
					  ;	  bit 3:   Envelope Direction (0=Decrease, 1=Increase)
					  ;	  bit 2-0: Number of envelope sweep (n: 0-7)
					  ;			  (If zero, stop envelope operation.)
					  ;	Length of 1 step = n*(1/64) seconds
rNR13       EQU $ff13 ; Channel 1 Frequency lo (Write Only)
					  ; Lower 8 bits of 11 bit frequency (x).
					  ; Next 3 bit are in NR14 ($FF14)
rNR14       EQU $ff14 ; Channel 1 Frequency hi (R/W)
					  ;   bit 7:   Initial (1=Restart Sound) (Write Only)
					  ;   bit 6:   Counter/consecutive selection (R/W)
					  ;			   (1=Stop output when length in NR11 expires)
					  ;   bit 2-0: Frequency's higher 3 bits (x) (Write Only)
					  ; Frequency = 131072/(2048-x) Hz
rNR20       EQU $ff15 ; Channel 2 Sweep register (R/W)
					  ; unused by system
rNR21       EQU $ff16 ; Channel 2 Sound Length/Wave Pattern Duty (R/W)
					  ; Same as rNR11
rNR22       EQU $ff17 ; Channel 2 Volume Envelope (R/W)
					  ; Same as rNR12
rNR23       EQU $ff18 ; Channel 2 Frequency lo data (W)
					  ; Same as rNR13
rNR24       EQU $ff19 ; Channel 2 Frequency hi data (R/W)
					  ; Same as rNR14
rNR30       EQU $ff1a ; Channel 3 Sound on/off (R/W)
					  ;   bit 7:   Sound Channel 3 Off  (0=Stop, 1=Playback)
					  ;   bit 6-0: unused
rNR31       EQU $ff1b ; Channel 3 Sound Length
					  ;   bit 7-0: Sound length (t1: 0 - 255)
					  ; Sound Length = (256-t1)*(1/256) seconds
					  ; The Length value is used only if Bit 6 in NR34 is set.
rNR32       EQU $ff1c ; Channel 3 Select output level (R/W)
					  ;   bit 7:   unused
					  ;   bit 6-5: Select output level
					  ;   bit 4-0: unused
					  ; Possible Output levels are:
					  ;   0: Mute (No sound)
					  ;   1: 100% Volume (Produce Wave Pattern RAM Data as it is)
					  ;   2:  50% Volume (Produce Wave Pattern RAM data shifted once to the right)
					  ;   3:  25% Volume (Produce Wave Pattern RAM data shifted twice to the right)
rNR33       EQU $ff1d ; Channel 3 Frequency's lower data (W)
					  ; Lower 8 bits of an 11 bit frequency (x).
rNR34       EQU $ff1e ; Channel 3 Frequency's higher data (R/W)
					  ;   bit 7:   Initial (1=Restart Sound)     (Write Only)
					  ;   bit 6:   Counter/consecutive selection (R/W)
					  ;			  (1=Stop output when length in NR31 expires)
					  ;   bit 2-0: Frequency's higher 3 bits (x) (Write Only)
					  ; Frequency = 65536/(2048-x) Hz
rNR40       EQU $ff1f ; Channel 4 Sweep register (R/W)
					  ; unused by system
rNR41       EQU $ff20 ; Channel 4 Sound Length (R/W)
					  ;   bit 7-6: unused
					  ;   bit 5-0: Sound length data (Write Only) (t1: 0-63)
					  ; Sound Length = (64-t1)*(1/256) seconds
					  ; The Length value is used only if Bit 6 in NR44 is set.
rNR42       EQU $ff21 ; Channel 4 Volume Envelope (R/W)
					  ; Same as rNR12
rNR43       EQU $ff22 ; Channel 4 Polynomial Counter (R/W)
					  ;   bit 7-4: Shift Clock Frequency (s)
					  ;   bit 3:   Counter Step/Width (0=15 bits, 1=7 bits)
					  ;   bit 2-0: Dividing Ratio of Frequencies (r)
					  ; Frequency = 524288 Hz / r / 2^(s+1) 
					  ; For r=0 assume r=0.5 instead
rNR44       EQU $ff23 ; Channel 4 Counter/consecutive; Inital    (R/W)
					  ;   bit 7:   Initial (1=Restart Sound)     (Write Only)
					  ;   bit 6:   Counter/consecutive selection (R/W)
rNR50       EQU $ff24 ; Channel control / ON-OFF / Volume (R/W)
					  ;   bit 7:   Vin->SO2 ON/OFF
					  ;   bit 6-4: SO2 output level (volume) (# 0-7)
					  ;   bit 3:   Vin->SO1 ON/OFF
					  ;   bit 2-0: SO1 output level (volume) (# 0-7)
rNR51       EQU $ff25 ; Selection of Sound output terminal (R/W)
					  ;   bit 7-4: ch1-4 so2 on/off
					  ;   bit 3-0: ch1-4 so1 on/off
rNR52       EQU $ff26 ; Sound on/off
					  ;   bit 7:   All sound on/off (0: stop all sound circuits) (R/W)
					  ;   bit 6-4: unused    
					  ;   bit 3:   Sound 4 ON flag (Read Only)
					  ;   bit 2:   Sound 3 ON flag (Read Only)
					  ;   bit 1:   Sound 2 ON flag (Read Only)
					  ;   bit 0:   Sound 1 ON flag (Read Only)
rWave_0     EQU $ff30
rWave_1     EQU $ff31
rWave_2     EQU $ff32
rWave_3     EQU $ff33
rWave_4     EQU $ff34
rWave_5     EQU $ff35
rWave_6     EQU $ff36
rWave_7     EQU $ff37
rWave_8     EQU $ff38
rWave_9     EQU $ff39
rWave_a     EQU $ff3a
rWave_b     EQU $ff3b
rWave_c     EQU $ff3c
rWave_d     EQU $ff3d
rWave_e     EQU $ff3e
rWave_f     EQU $ff3f
rLCDC       EQU $ff40 ; LCD Control (R/W)
rLCDC_BG_PRIORITY    EQU 0 ; 0=Off, 1=On
rLCDC_SPRITES_ENABLE EQU 1 ; 0=Off, 1=On
rLCDC_SPRITE_SIZE    EQU 2 ; 0=8x8, 1=8x16
rLCDC_BG_TILEMAP     EQU 3 ; 0=9800-9BFF, 1=9C00-9FFF
rLCDC_TILE_DATA      EQU 4 ; 0=8800-97FF, 1=8000-8FFF
rLCDC_WINDOW_ENABLE  EQU 5 ; 0=Off, 1=On
rLCDC_WINDOW_TILEMAP EQU 6 ; 0=9800-9BFF, 1=9C00-9FFF
rLCDC_ENABLE         EQU 7 ; 0=Off, 1=On
LCDC_DEFAULT EQU (1 << rLCDC_ENABLE) | (1 << rLCDC_WINDOW_TILEMAP) | (1 << rLCDC_WINDOW_ENABLE) | (1 << rLCDC_SPRITES_ENABLE) | (1 << rLCDC_BG_PRIORITY)
rSTAT       EQU $ff41 ; LCDC Status (R/W)
rSCY        EQU $ff42 ; Scroll Y (R/W)
rSCX        EQU $ff43 ; Scroll X (R/W)
rLY         EQU $ff44 ; LCDC Y-Coordinate (R)
LY_VBLANK EQU 144
rLYC        EQU $ff45 ; LY Compare (R/W)
rDMA        EQU $ff46 ; DMA Transfer and Start Address (W)
rBGP        EQU $ff47 ; BG Palette Data (R/W) - Non CGB Mode Only
rOBP0       EQU $ff48 ; Object Palette 0 Data (R/W) - Non CGB Mode Only
rOBP1       EQU $ff49 ; Object Palette 1 Data (R/W) - Non CGB Mode Only
rWY         EQU $ff4a ; Window Y Position (R/W)
rWX         EQU $ff4b ; Window X Position minus 7 (R/W)
rLCDMODE    EQU $ff4c
rKEY1       EQU $ff4d ; CGB Mode Only - Prepare Speed Switch
rVBK        EQU $ff4f ; CGB Mode Only - VRAM Bank
rBLCK       EQU $ff50
rHDMA1      EQU $ff51 ; CGB Mode Only - New DMA Source, High
rHDMA2      EQU $ff52 ; CGB Mode Only - New DMA Source, Low
rHDMA3      EQU $ff53 ; CGB Mode Only - New DMA Destination, High
rHDMA4      EQU $ff54 ; CGB Mode Only - New DMA Destination, Low
rHDMA5      EQU $ff55 ; CGB Mode Only - New DMA Length/Mode/Start
rRP         EQU $ff56 ; CGB Mode Only - Infrared Communications Port
rRP_LED_ON EQU 0
rRP_RECEIVING EQU 1
rRP_ENABLE_READ_MASK EQU %11000000
rBGPI       EQU $ff68 ; CGB Mode Only - Background Palette Index
rBGPI_AUTO_INCREMENT EQU 7 ; increment rBGPI after write to rBGPD
rBGPD       EQU $ff69 ; CGB Mode Only - Background Palette Data
rOBPI       EQU $ff6a ; CGB Mode Only - Sprite Palette Index
rOBPI_AUTO_INCREMENT EQU 7 ; increment rOBPI after write to rOBPD
rOBPD       EQU $ff6b ; CGB Mode Only - Sprite Palette Data
rUNKNOWN1   EQU $ff6c ; (FEh) Bit 0 (R/W) - CGB Mode Only
rSVBK       EQU $ff70 ; CGB Mode Only - WRAM Bank
rUNKNOWN2   EQU $ff72 ; (00h) - Bit 0-7 (R/W)
rUNKNOWN3   EQU $ff73 ; (00h) - Bit 0-7 (R/W)
rUNKNOWN4   EQU $ff74 ; (00h) - Bit 0-7 (R/W) - CGB Mode Only
rUNKNOWN5   EQU $ff75 ; (8Fh) - Bit 4-6 (R/W)
rUNKNOWN6   EQU $ff76 ; (00h) - Always 00h (Read Only)
rUNKNOWN7   EQU $ff77 ; (00h) - Always 00h (Read Only)
rIE         EQU $ffff ; Interrupt Enable (R/W)
