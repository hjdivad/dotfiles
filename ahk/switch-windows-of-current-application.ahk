/* !`::    ; Next window */
/* WinGetClass, ActiveClass, A */
/* WinSet, Bottom,, A */
/* WinActivate, ahk_class %ActiveClass% */
/* return */


/* ;
*****************************
***** UTILITY FUNCTIONS *****
*****************************
*/


ExtractAppTitle(FullTitle)
{	
	AppTitle := SubStr(FullTitle, InStr(FullTitle, " ", false, -1) + 1)
	Return AppTitle
}



/* ;
***********************************
***** SHORTCUTS CONFIGURATION *****
***********************************
*/


; Alt + ` -  Activate NEXT Window of same type (title checking) of the current APP
!`::
WinGet, ActiveProcess, ProcessName, A
WinGet, OpenWindowsAmount, Count, ahk_exe %ActiveProcess%

If OpenWindowsAmount = 1  ; If only one Window exist, do nothing
    Return
	
Else
	{
		WinGetTitle, FullTitle, A
		AppTitle := ExtractAppTitle(FullTitle)

		SetTitleMatchMode, 2		
		WinGet, WindowsWithSameTitleList, List, %AppTitle%
		
		If WindowsWithSameTitleList > 1 ; If several Window of same type (title checking) exist
		{
			WinActivate, % "ahk_id " WindowsWithSameTitleList%WindowsWithSameTitleList%	; Activate next Window	
		}
	}
Return
