; File: W65C02S_Demo.asm
; 08/08/2013

     PW 128         ;Page Width (# of char/line)
     PL 60          ;Page Length for HP Laser
     INCLIST ON     ;Add Include files in Listing

				;*********************************************
				;Test for Valid Processor defined in -D option
				;*********************************************
	IF	USING_02
	ELSE
		EXIT         "Not Valid Processor: Use -DUSING_02, etc. ! ! ! ! ! ! ! ! ! ! ! !"
	ENDIF




;****************************************************************************
;****************************************************************************
; End of testing for proper Command line Options for Assembly of this program
;****************************************************************************
;****************************************************************************


			title  "W65C02S Simulator Program V 1.00 for W65C02 - W65C02S_Demo.asm"
			sttl


; bgnpkhdr
;***************************************************************************
;  FILE_NAME: W65C02S_Demo.asm
;
;  DATA_RIGHTS: Western Design Center
;               Copyright(C) 1980-2013
;               All rights reserved. Reproduction in any manner,
;               in whole or in part, is strictly prohibited without
;               the prior written approval of The Western Design Center, Inc (WDC).
;
;               Information contained in this publication regarding
;               device applications and the like is intended through
;               suggestion only and may be superseded by updates.
;               It is your responsibility to ensure that your application
;               meets with your specifications.  No representation or
;               warranty is given and no liability is assumed by
;               Western Design Center, Inc. with respect to the accuracy
;               or use of such information, or infringement of patents
;               or other intellectual property rights arising from such
;               use or otherwise.  Use of WDC's products
;               as critical components in life support systems is not
;               authorized except with express written approval by
;               WDC.  No licenses are conveyed,implicitly or otherwise,
;								under any intellectual property rights.
;
;
;
;  TITLE: W65C02S_Demo
;
;  DESCRIPTION: This File describes the WDC Simulator Example Program.
;
;
;
;  DEFINED FUNCTIONS:
;          badVec
;                   - Process a Bad Interrupt Vector - Hang!
;
;  SPECIAL_CONSIDERATIONS:
;
;
;  SHARED_DATA:
;          None
;
;  GLOBAL_MODULES:
;          None
;
;  LOCAL_MODULES:
;          See above in "DEFINED FUNCTIONS"
;
;  AUTHOR: David Gray
;
;  CREATION DATE: August 8, 2013
;
;  REVISION HISTORY
;     Name           Date         Description
;     ------------   ----------   ------------------------------------------------
;     David Gray		 08/08/2013   1.00 Initial
;
;
; NOTE:
;    Change the lines for each version - current version is 1.00b
;    See -
;         title  "W65C02S_Demo Program V 1.0x for W65C02S - W65C02S_Demo.asm"
;
;
;***************************************************************************
;endpkhdr


;***************************************************************************
;                             Include Files
;***************************************************************************
;None


;***************************************************************************
;                              Global Modules
;***************************************************************************
;None

;***************************************************************************
;                              External Modules
;***************************************************************************
;None

;***************************************************************************
;                              External Variables
;***************************************************************************
;None


;***************************************************************************
;                               Local Constants
;***************************************************************************
;
	.sttl "W65C02S Demo Code"
	.page
;***************************************************************************
;***************************************************************************
;                    W65C02S_Demo Code Section
;***************************************************************************
;***************************************************************************


		org	$2000
This_project_end:
WDCMON_RAM_START	EQU	$7C00
ROMSPACE EQU WDCMON_RAM_START-This_project_end  ;gives space left in the ROM BEFORE WDCMON TABLES

	IF ROMSPACE<0
		EXIT         "Not Enough Memory for This Application - bumping into WDCMON! ! ! ! ! ! ! ! ! ! ! !"
	ENDIF


	bits:	db	1
	cnt:	db	0
	wraps:	dw	0
	delay:	db	10
