#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Icon=ping-pong-green-multi-size.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Fileversion=0.0.0.29
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_ProductName=Ping by Adrian Perez
#AutoIt3Wrapper_Res_ProductVersion=0.0.0.3
#AutoIt3Wrapper_Res_CompanyName=ALP
#AutoIt3Wrapper_Res_LegalCopyright=Adrián Pérez
#AutoIt3Wrapper_Res_Language=11274
#AutoIt3Wrapper_Res_Icon_Add=ping-pong-red-multi-size.ico
#AutoIt3Wrapper_Res_File_Add=alerta.wav
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Constants.au3>
#include <MsgBoxConstants.au3>
#include <AutoItConstants.au3>
#include <FileConstants.au3>
#include <StringConstants.au3>
#include <TrayConstants.au3>


;MsgBox(0, "Version", "Version " & $ver)


Opt("TrayIconDebug", 1) ;0=no info, 1=debug line info
Opt("TrayOnEventMode", 1) ; Enable TrayOnEventMode.
Opt("GUIOnEventMode", 1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Opt("TrayOnEventMode", 1)
Opt("TrayMenuMode", 1)
Opt("TrayAutoPause", 0)
Global Const $sTitle = "Ping"
;TraySetIcon("shell32.dll", -15) ; ico de red
;TraySetIcon("ping.exe", -1) ; ico ping en verde rojo
;TraySetIcon("ping.exe", -5) ; ico ping en rojo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Opt("TCPTimeout", 30000) ;30 segundos de timeout
Opt("CaretCoordMode", 2) ;
Opt("PixelCoordMode", 2) ; 0 = relative coords to the defined window, 1 = (default) absolute screen coordinates, 2 = relative coords to the client area of the defined window

Local $hWnd = WinGetHandle("[CLASS:TscShellContainerClass]", "")
Local $aList = WinList("[TITLE:Conexión a Escritorio remoto; CLASS:#32770; INSTANCE:1]", "")

$ver = FileGetVersion(@ScriptFullPath)
$sock = ""
$ip = ""
$port = ""
$stimeout = ""
$stimeoutm = ""
$srep = ""

#Region ### START Koda GUI section ### Form=
$Frm_Main = GUICreate($sTitle, 370, 325, -1, -1) ;, 193, 125)
$IPin = GUICtrlCreateInput("", 45, 5, 70, 21)
GUICtrlCreateLabel("IP/Host:", 1, 9, 40, 17)
$Portin = GUICtrlCreateInput("3389", 145, 5, 35, 21)

GUICtrlCreateLabel("Port", 120, 9, 23, 17)
GUICtrlCreateLabel("Cada", 185, 7, 25, 17)
$timeout = GUICtrlCreateInput("60", 215, 5, 25, 21)
GUICtrlCreateLabel("seg", 245, 7, 30, 17)
GUICtrlCreateLabel("Ciclo:", 235, 33, 33, 21)
$numciclo = GUICtrlCreateLabel("0", 275, 33, 24, 24)
GUICtrlCreateLabel("/", 285, 33, 12, 21)
$rep = GUICtrlCreateInput("5", 295, 30, 24, 21)
GUICtrlCreateLabel("Ping", 320, 33, 30, 21)
$History = GUICtrlCreateEdit("", 10, 142, 336, 150)

$go = GUICtrlCreateCheckbox("Ping", 290, 5, 60, 21, 0)
GUICtrlSetBkColor($go, 0x009933)
GUICtrlSetState($go, $GUI_CHECKED)

$detectrdp = GUICtrlCreateCheckbox("Detectar Cliente", 235, 60, 95, 20)
$rojo = GUICtrlCreateCheckbox("Detectar Rojo", 235, 90, 95, 20)
$max = GUICtrlCreateCheckbox("Min/Maximizar", 235, 120, 111, 20, 0)


$inicio = GUICtrlCreateCheckbox("Iniciar con Windows", 15, 295, 125, 25, 0)
GUICtrlSetState($inicio, $GUI_CHECKED)


$version = GUICtrlCreateLabel("Version: " & $ver & " ", 245, 300, 125, 25, 0)


GUICtrlCreateLabel("Historial de fallas:", 5, 120, 87, 17, 0)

;$VerLog = GUICtrlCreateButton("VerLog", 135, 295, 95, 25, 0)


$Gstatus = GUICtrlCreateLabel("", 20, 30, 190, 40)
$GstatusRdp = GUICtrlCreateLabel("", 20, 75, 190, 40)


GUISetOnEvent($GUI_EVENT_CLOSE, "_Quit")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "_GUI_ToTray")


GUICtrlSetFont(-1, 24, 400, 0, "MS Sans Serif")
GUISetState(@SW_SHOW)


#EndRegion ### START Koda GUI section ### Form=


_GUI_ToTray()

$stimeout = GUICtrlRead($timeout)
$timeoutm = Number($stimeout * 1000)
$srep = GUICtrlRead(Number($rep))

While 1

	$msgb = GUIGetMsg()
	Switch $msgb

		Case $GUI_EVENT_CLOSE ;; -3
			_Quit()

		Case $GUI_EVENT_MINIMIZE ;; -4
			_GUI_ToTray()


		Case BitAND((GUICtrlRead($go)), $GUI_UNCHECKED, "")
			If BitAND(GUICtrlRead($go), $GUI_UNCHECKED) Then
				GUICtrlSetBkColor($go, 0xFF0000)
				Sleep(100)
				;MsgBox(0, "Error", "Ping deshabilitado", 5)
				TraySetIcon("ping.exe", -5) ; ico ping en rojo
				ContinueCase
			Else
				ContinueCase
			EndIf

		Case BitAND((GUICtrlRead($go)), $GUI_CHECKED, "")
			If BitAND(GUICtrlRead($go), $GUI_CHECKED) Then
				GUICtrlSetBkColor($go, 0x00FF00)
				TraySetIcon("ping.exe", -1) ; ico verde
				Sleep(1000)
				;Repeticion()
				For $i = 1 To $srep Step 1 ; Repetir veces y siguiente
					Sleep(100)
					GUICtrlSetData($numciclo, $i)
					Pinger()
					If BitAND(GUICtrlRead($go), $GUI_CHECKED) Then
						Sleep($timeoutm) ; $srep minutos en ms
					Else
						ContinueCase
					EndIf
				Next
				GUICtrlSetData($History, "[" & @HOUR & ":" & @MIN & ":" & @SEC & "]" & " Ciclo de: " & $srep & " Pings completados correctamente." & @CRLF, GUICtrlRead($History))
				ContinueCase
			Else
				ContinueCase
			EndIf


		Case BitAND((GUICtrlRead($detectrdp)), $GUI_UNCHECKED, "")
			If BitAND(GUICtrlRead($detectrdp), $GUI_UNCHECKED) Then
				GUICtrlSetBkColor($detectrdp, 0xFF0000)
				;MsgBox(0, "Error", "Detectar emergencias rojas deshabilitado", 3)
				ContinueCase
			Else
				ContinueCase
			EndIf

		Case BitAND((GUICtrlRead($detectrdp)), $GUI_CHECKED, "")
			If BitAND(GUICtrlRead($detectrdp), $GUI_CHECKED) Then
				GUICtrlSetBkColor($detectrdp, 0x00FF00)
				;MsgBox(0, "Error", "Buscando cliente RDP", 3)
				detectrdp()
				ContinueCase
			Else
				ContinueCase
			EndIf


		Case BitAND((GUICtrlRead($rojo)), $GUI_UNCHECKED, "")
			If BitAND(GUICtrlRead($rojo), $GUI_UNCHECKED) Then
				GUICtrlSetBkColor($rojo, 0xFF0000)
				;MsgBox(0, "Error", "Detectar emergencias rojas deshabilitado", 3)
				ContinueCase
			Else
				ContinueCase
			EndIf


		Case BitAND((GUICtrlRead($rojo)), $GUI_CHECKED, "")
			If BitAND(GUICtrlRead($rojo), $GUI_CHECKED) Then
				GUICtrlSetBkColor($rojo, 0x00FF00)
				;MsgBox(0, "Error", "Buscando Emergencias Rojas", 3)
				rojo()
				ContinueCase
			Else
				ContinueCase
			EndIf

		Case BitAND((GUICtrlRead($max)), $GUI_UNCHECKED, "")
			If BitAND(GUICtrlRead($max), $GUI_UNCHECKED) Then
				GUICtrlSetBkColor($max, 0xFF0000)
				;MsgBox(0, "Error", "Restaurar y Maximizar deshabilitado.", 3)
				ContinueCase
			Else
				ContinueCase
			EndIf

		Case BitAND((GUICtrlRead($max)), $GUI_CHECKED, "")
			If BitAND(GUICtrlRead($max), $GUI_CHECKED) Then
				GUICtrlSetBkColor($max, 0x00FF00)
				;MsgBox(0, "Error", "Restaurando y Maximizando cliente RDP.", 3)
				Max()
				ContinueCase
			Else
				ContinueCase
			EndIf


		Case BitAND((GUICtrlRead($inicio)), $GUI_UNCHECKED, "")
			If BitAND(GUICtrlRead($inicio), $GUI_UNCHECKED) Then
				noinicio()
				ContinueCase
			Else
				inicio()
				ContinueCase
			EndIf


		Case BitAND((GUICtrlRead($inicio)), $GUI_CHECKED, "")
			If BitAND(GUICtrlRead($inicio), $GUI_CHECKED) Then
				inicio()
				ContinueCase
			Else
				noinicio()
				ContinueCase
			EndIf


	EndSwitch

WEnd


Func Pinger()

	TCPStartup()

	$ip = TCPNameToIP($ip)
	Sleep(500)

	$start = TimerInit()

	$ip = GUICtrlRead($IPin, 1)
	$port = GUICtrlRead($Portin, 1)
	If $ip = "" Or $port = "" Then
	Else
		$ip = TCPNameToIP($ip)
		Sleep(1000)
		$start = TimerInit()
		$sock = TCPConnect($ip, $port)
		If @error = 1 Then
			SoundPlay(@ScriptDir & "\" & "alerta.wav")
			MsgBox(0, "Error 1", "Host no responde!", 5)
			SoundPlay(@ScriptDir & "\" & "alerta.wav")
			TraySetIcon("ping.exe", -5) ; ico ping en rojo
			FileWrite(@ScriptDir & "\" & "ping.log", @CRLF & @CRLF & "[" & @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & "] OFFLINE. Error Host no responde. " & $ip & ":$port" & " " & "ms: TimeOut.")
			FileClose(@ScriptDir & "\" & "ping.log")
			GUICtrlSetData($Gstatus, "OFFLINE")
			GUICtrlSetFont($Gstatus, 24)
			GUICtrlSetColor($Gstatus, 0xFF0093)
			GUICtrlSetData($History, "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] OFFLINE, " & $ip & ":" & $port & @CRLF, GUICtrlRead($History))

		ElseIf @error = 2 Then
			SoundPlay(@ScriptDir & "\" & "alerta.wav")
			MsgBox(0, "Error 2", "Puerto no responde!", 5)
			FileWrite(@ScriptDir & "\" & "ping.log", @CRLF & @CRLF & "[" & @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & "] OFFLINE. Error Puerto no responde. " & $ip & ":$port" & " " & "ms: TimeOut.")
			FileClose(@ScriptDir & "\" & "ping.log")
			TraySetIcon("ping.exe", -5) ; ico ping en rojo
			GUICtrlSetData($Gstatus, "OFFLINE")
			GUICtrlSetFont($Gstatus, 24)
			GUICtrlSetColor($Gstatus, 0xFF0093)
			SoundPlay(@ScriptDir & "\" & "alerta.wav")
			GUICtrlSetData($History, "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] OFFLINE, " & $ip & ":" & $port & @CRLF, GUICtrlRead($History))

		ElseIf $sock = -1 Then
			SoundPlay(@ScriptDir & "\" & "alerta.wav")
			MsgBox(0, "Error -1", "Sock no responde!", 5)
			FileWrite(@ScriptDir & "\" & "ping.log", @CRLF & @CRLF & "[" & @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & "] OFFLINE. Socket no responde. " & $ip & ":$port" & " " & "ms: TimeOut.")
			FileClose(@ScriptDir & "\" & "ping.log")
			TraySetIcon("ping.exe", -5) ; ico ping en rojo
			GUICtrlSetData($Gstatus, "OFFLINE")
			GUICtrlSetFont($Gstatus, 24)
			GUICtrlSetColor($Gstatus, 0xFF0093)
			SoundPlay(@ScriptDir & "\" & "alerta.wav")
			GUICtrlSetData($History, "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] OFFLINE, " & $ip & ":" & $port & @CRLF, GUICtrlRead($History))


		Else
			$Stop = Round(TimerDiff($start), 5)
			TCPCloseSocket($sock)
			FileWrite(@ScriptDir & "\" & "ping.log", @CRLF & "[" & @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & "] ONLINE, " & $ip & ":" & $port & " ms:" & $Stop)
			FileClose(@ScriptDir & "\" & "ping.log")
			TraySetIcon("ping.exe", -1) ; ico ping en rojo
			GUICtrlSetData($Gstatus, "ONLINE")
			GUICtrlSetFont($Gstatus, 24)
			GUICtrlSetColor($Gstatus, 0x009933)

			;MsgBox($MB_SYSTEMMODAL, "File Content", FileRead(@ScriptDir & "\" & "ping.log"))

			;MsgBox(0, "PING", "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] ONLINE, "&$ip&":"&$port&" ms:" & $Stop, 5 )
		EndIf
	EndIf

	TCPCloseSocket($sock)
	TCPShutdown()
EndFunc   ;==>Pinger


Func CerrarTcp() ; cierra TCP
	TCPCloseSocket($sock)
	TCPShutdown()
EndFunc   ;==>CerrarTcp


Func Max()
	;If WinExists("[TITLE:Conexión a Escritorio remoto; CLASS:DirectUIHWND; INSTANCE:1]", "") Then
	;  MsgBox ($MB_SYSTEMMODAL, "RDP CERRADO!", "ABRIR CLIENTE RDP", 5)
	;EndIf
	Opt("WinTitleMatchMode", 1) ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
	If WinExists("Conexión a Escritorio remoto") Then

		;FileWrite(@ScriptDir & "\" & "ping.log", @CRLF & @CRLF & "[" & @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & "] Comprobacion de Cliente RDP PC local: OK.")
		;FileClose(@ScriptDir & "\" & "ping.log")
		;GUICtrlSetData($GstatusRDP, "ABIERTO")
		;GUICtrlSetFont($GstatusRDP, 24)
		;GUICtrlSetColor($GstatusRDP, 0x009933)

		Sleep(500)
		WinActivate("Conexión a Escritorio remoto", "")
		Sleep(500)
		WinSetState("Conexión a Escritorio remoto", "", @SW_ENABLE)
		Sleep(500)
		WinSetState("Conexión a Escritorio remoto", "", @SW_RESTORE)
		Sleep(1000)
		WinSetState("Conexión a Escritorio remoto", "", @SW_MAXIMIZE)
		Sleep(1000)
		WinSetState("Conexión a Escritorio remoto", "", @SW_MINIMIZE)
		Sleep(1000)
		WinSetState("Conexión a Escritorio remoto", "", @SW_MAXIMIZE)
		Sleep(500)

	EndIf

	If Not WinExists("[CLASS:TscShellContainerClass]", "Host") Then
		SoundPlay(@ScriptDir & "\" & "alerta.wav")
		MsgBox(0, "RDP CERRADO!", "ABRIR CLIENTE RDP", 5)
		TraySetIcon("ping.exe", -5) ; ico ping en rojo
		FileWrite(@ScriptDir & "\" & "ping.log", @CRLF & @CRLF & "[" & @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & "] OFFLINE. RDP CERRADO. No se detecto cliente RDP en esta PC.")
		FileClose(@ScriptDir & "\" & "ping.log")
		GUICtrlSetData($GstatusRdp, "CERRADO")
		GUICtrlSetFont($GstatusRdp, 24)
		GUICtrlSetColor($GstatusRdp, 0xFF0093)
		SoundPlay(@ScriptDir & "\" & "alerta.wav")
		GUICtrlSetData($History, "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Cliente RDP no detectado." & @CRLF, GUICtrlRead($History))
	EndIf
EndFunc   ;==>Max


Func detectrdp()
	Opt("WinTitleMatchMode", 3) ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
	Local $hWnd = WinGetHandle("[TITLE: - Conexión a Escritorio remoto; CLASS:TscShellContainerClass]", "")
	Local $aList = WinList("[TITLE:Conexión a Escritorio remoto; CLASS:#32770; INSTANCE:1]", "")

	;FileWrite(@ScriptDir & "\" & "ping.log", @CRLF & @CRLF & "[" & @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & "] Comprobando RDP.")
	;FileClose(@ScriptDir & "\" & "ping.log")
	Sleep(500)
	Opt("WinTitleMatchMode", 3) ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
	;If WinExists("Conexión a Escritorio remoto") Then
	; MsgBox (0, "Verificando", "VENTANA DE DESCONEXION")
	;EndIf
	If WinExists($hWnd) Then
		;MsgBox (0, "Verificando", "Host OK, cerrando en 3, 2, 1..", 3)
		FileWrite(@ScriptDir & "\" & "ping.log", @CRLF & @CRLF & "[" & @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & "] Comprobacion de Cliente RDP PC local: ABIERTO.")
		FileClose(@ScriptDir & "\" & "ping.log")
		GUICtrlSetData($GstatusRdp, "ABIERTO")
		GUICtrlSetFont($GstatusRdp, 24)
		GUICtrlSetColor($GstatusRdp, 0x009933)
		GUICtrlSetData($History, "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Cliente RDP ABIERTO" & @CRLF, GUICtrlRead($History))
		Sleep(500)
	Else
		SoundPlay(@ScriptDir & "\" & "alerta.wav")
		MsgBox(0, "RDP CERRADO!", "Conectarse a Host", 5)
		FileWrite(@ScriptDir & "\" & "ping.log", @CRLF & @CRLF & "[" & @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & "] Comprobacion de Cliente RDP PC local: CERRADO.")
		FileClose(@ScriptDir & "\" & "ping.log")
		GUICtrlSetData($GstatusRdp, "CERRADO")
		GUICtrlSetFont($GstatusRdp, 24)
		GUICtrlSetColor($GstatusRdp, 0xFF0093)
		GUICtrlSetData($History, "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Cliente RDP no detectado" & @CRLF, GUICtrlRead($History))
		Sleep(500)
	EndIf

	For $i = 1 To $aList[0][0]
		If $aList[$i][0] <> "" And BitAND(WinGetState($aList[$i][1]), 2) Then
			SoundPlay(@ScriptDir & "\" & "alerta.wav")
			MsgBox(0, "", "Title: " & $aList[$i][0] & @CRLF & "Handle: " & $aList[$i][1], 5)
			FileWrite(@ScriptDir & "\" & "ping.log", @CRLF & @CRLF & "[" & @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & "] Comprobacion de Cliente RDP: Desconectado por otro cliente.")
			FileClose(@ScriptDir & "\" & "ping.log")
			GUICtrlSetData($GstatusRdp, "DESCONECTADO")
			GUICtrlSetFont($GstatusRdp, 24)
			GUICtrlSetColor($GstatusRdp, 0xFF0093)
			GUICtrlSetData($History, "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Cliente RDP desconectado por otro usuario." & @CRLF, GUICtrlRead($History))
			Sleep(500)
		EndIf
	Next

	Opt("WinTitleMatchMode", 1) ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
	Sleep(1000)
EndFunc   ;==>detectrdp


Func rojo()
	Sleep(500)
	WinActivate("[CLASS:TscShellContainerClass]", "Host")
	Opt("CaretCoordMode", 0)
	Sleep(100)
	Global $aCoord = PixelSearch(220, 450, 900, 670, 0xFF0000)

	If Not @error Then
		SoundPlay(@ScriptDir & "\" & "alerta.wav")
		MsgBox(0, "Hay emergencias", "Posicion X: " & $aCoord[0] & ", Y: " & $aCoord[1], 3)
		SoundPlay(@ScriptDir & "\" & "alerta.wav")
		TraySetIcon("ping.exe", -5) ; ico ping en rojo
		GUICtrlSetData($History, "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Emergencia roja detectada. Posicion" & $aCoord[0] & "," & $aCoord[1] & @CRLF, GUICtrlRead($History))
		FileWrite(@ScriptDir & "\" & "ping.log", @CRLF & @CRLF & "[" & @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & "] Comprobacion de Emergencias en rojo detectadas." & $aCoord[0] & "," & $aCoord[1])
		FileClose(@ScriptDir & "\" & "ping.log")
	Else
		;MsgBox(0, "OK", "No hay ROJO", 3)
		TraySetIcon("ping.exe", -1) ; ico ping en verde
		GUICtrlSetData($History, "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Comprobacion de Emergencias en rojo. OK." & @CRLF, GUICtrlRead($History))
		FileWrite(@ScriptDir & "\" & "ping.log", @CRLF & @CRLF & "[" & @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & "] No se encontraron Emergencias en rojo.")
		FileClose(@ScriptDir & "\" & "ping.log")
		Sleep(1000)
	EndIf

EndFunc   ;==>rojo


Func inicio()
	;RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "Ping")
	;@error is set to non-zero when reading a registry key that doesn't exist.
	If Not @error Then
		;MsgBox($MB_SYSTEMMODAL, "Error", "Ya inicia con windows.")
		Return False
	EndIf
	;RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "Ping", "REG_SZ", '"' & @ScriptFullPath & '"')
	MsgBox(0, "ALERTA", "Programa agregado de inicio de Windows.", 5)
EndFunc   ;==>inicio

Func noinicio()
	;RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "Ping")
	;@error is set to non-zero when reading a registry key that doesn't exist.
	If Not @error Then
		;MsgBox($MB_SYSTEMMODAL, "Error", @error)
		;Return $Frm_Main
		;RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "Ping")
		MsgBox(0, "ALERTA", "Programa eliminado de inicio de Windows.", 5)
	EndIf
EndFunc   ;==>noinicio


Func _GUI_ToTray()
	GUISetState(@SW_HIDE, $Frm_Main)
	TraySetOnEvent($TRAY_EVENT_PRIMARYUP, "_GUI_Restore")
	TraySetOnEvent($TRAY_EVENT_SECONDARYUP, "_GUI_Restore")
	TrayTip($sTitle, "Ejecutandose en segundo plano" & @CRLF & "Click para restaurar", 5, 1)
	;TraySetToolTip($sTitle & @CRLF & @CRLF & "Left click to restore" & @CRLF & "Right click to Exit")
	TraySetToolTip("")
	Opt("TrayIconHide", 0)
	Return $Frm_Main
EndFunc   ;==>_GUI_ToTray


Func _GUI_Restore()
	GUISetState(@SW_SHOW, $Frm_Main)
	WinActivate($Frm_Main)
	;TraySetState(2)
	;Opt("TrayIconHide", 1)
EndFunc   ;==>_GUI_Restore


Func _Quit()
	$MyBox = MsgBox(1, "", "Cerrar programa?")
	If $MyBox == 1 Then
		MsgBox(0, "", "Cerrando...", 5)
		Sleep(100)
		TCPCloseSocket($sock)
		Sleep(100)
		TCPShutdown()
		Sleep(100)
		GUIDelete()
		Exit
	ElseIf $MyBox == 2 Then
		MsgBox(0, "", "Cierre cancelado!")
		Return
	EndIf

EndFunc   ;==>_Quit
