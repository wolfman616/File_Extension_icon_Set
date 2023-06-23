#notrayicon	;MW 2023;  ;MW 2023; Past experience of the lack of simple shell extension handler icon association ability is what led me to create this tool. Use at own risk.
#NoEnv                 ;MW 2023;
#persistent            ;MW 2023;
#Singleinstance        ;MW 2023;

DetectHiddenWindows,On
DetectHiddenText,	On
SetTitleMatchMode,	2
SetTitleMatchMode,	Slow
coordMode,	ToolTip,Screen
coordmode,	Mouse,	Screen
Setworkingdir,% (splitpath(A_AhkPath)).dir
SetBatchLines,	-1
SetWinDelay,	-1

gosub,Varz
gosub,Menuz
gosub,OnMsgs

menu,tray,icon,
menu,tray,icon,% "HBITMAP:*" hbitmap

; #IfTimeout,200 ;* DANGER * : Performance impact if set too low. *think about using this*.
; ListLines,Off

if(!Args1:= a_Args[1]) {
	msgbox,0x40004,% "Question",% "Add to shell context menu? this can be done manually with the following:`n	add:`nComputer\HKEY_CLASSES_ROOT\AllFilesystemObjects\shell\*your_desired_ref_orSubcommand*\command\`n""C:\Program Files\Autohotkey13602\AutoHotkeyU64.exe"" ""C:\*Scriptloc*\FileExtension_iconSet.ahk"" ""%l"""
	ifmsgbox,yes
		runas,% "fa.reg"
	exitapp,
} OnExit,AtExit

regRead,default,% Regki:="HKEY_CLASSES_ROOT\." . xt:= (p:= splitpath(args1)).ext
if(!default) {
	regRead,defaulticon,% Regki:="HKEY_CLASSES_ROOT\." . xt . "\DefaultIcon"
	if(!defaulticon)
		msgbox,no default set
	else {
		(instr(defaulticon,"%SystemRoot%")? defaulticon:= strreplace(defaulticon,"%SystemRoot%","C:\Windows"))
		(instr(defaulticon,"%1")||instr(defaulticon,"%l")?  defaulticon:= "C:\Icon\FileTypes\davinci.ico")
		MsgbTtl:= xt . " default icon", MsgbTxt:= quote("currently default icon for " . xt . " is " . chr(0x27) . defaulticon . chr(0x27) . " ")
	}
} else {
	regRead,ext_desc,% Regki:= "HKEY_CLASSES_ROOT\" . default
	regRead,defaulticon,% Regki . "\DefaultIcon"
	if !defaulticon
		msgbox,no default set
	else {
		xtt:= chr(0x27) . "." . xt . chr(0x27)
		(instr(defaulticon,"%SystemRoot%")? defaulticon:= strreplace(defaulticon,"%SystemRoot%","C:\Windows"))
		(instr(defaulticon,"%1")||instr(defaulticon,"%l")?  defaulticon:= "C:\Icon\FileTypes\davinci.ico")
		defi:= chr(0x27) . defaulticon . chr(0x27)
		MsgbTtl:=  "Replace default icon for ." . chr(0x27) . xt . chr(0x27) . " Files?", MsgbTxt:= "Redefine Icon for " . xtt . " files, systemwide? R0nr0nCurrent defined default root icon derived from:R0n" . defi
	}
} w:= regexmatch(defaulticon,"(\,\-?\d+)")? Msgbicon:= regexreplace(defaulticon,"(\,\-?\d+)","") :  Msgbicon:= defaulticon
((!Msgbhicon:= ico2hicon(Msgbicon))? Msgbhicon:= ico2hicon("C:\Icon\FileTypes\davinci.ico"))
PipeMsgBox(MsgbTtl,MsgbTxt . " r0nRoot Registry key:r0n" . chr(0x27) . "\HKEY_CLASSES_ROOT\." . xt . "\" . chr(0x27) . "r0nSubclass-assigned Registry key: r0n" . chr(0x27) . "\" . Regki . "\" . chr(0x27),Msgbhicon,"","0x40124")
return,

setYES:
tooltip,% mgtt:="Select A new icon"
	sleep,300
loop,3 {
	sleep,300
	tooltip,% mgtt .= "."
}	sleep,300
tooltip,
FileSelectFile,iconpath_New,S8,% MsgbIcon,% "Select icon file",*.ico
if(!iconpath_New) {
	msgbox,0x0,Aborting,No file selected.,3
	exitapp,
} regwki:="HKEY_CURRENT_USER\Software\Classes\" . default
RegWrite,REG_SZ,% r:= regwki . "\DefaultIcon",,% iconpath_New
sleep,120
loop,10 {
	regRead,test,% regwki . "\DefaultIcon"
	if(test=iconpath_New) {
		success:= true
		sleep,40
	} else,break,
} if !success
	msgbox,0x0,% "error writing registry",% "Exiting...",3
else {
	MsgbTtl:= "Changed Icon for" . chr(0x27) . "." . xt . chr(0x27) . " Files"
	MsgbTxt:= "Success.r0n New default icon for " . xt . " is " . iconpath_New
	Msgbhicon:= ico2hicon(iconpath_New)
	PipeMsgBox(MsgbTtl,MsgbTxt,Msgbhicon,3,"0x40120")
	run,ie4uinit.exe -show
	sleep.1000
	sendinput,{f5}
} return,

setNO:
exitapp,

AtExit:
gosub,unhook
exitapp,

UnHook:
hOOkz:= "HookMb,ProcMb_"
loop,Parse,% hOOkz,`,
{
	dllcall("UnhookWinEvent","Ptr",a_loopfield)
	sleep,20
	dllcall("GlobalFree",    "Ptr",a_loopfield,"Ptr")
	(%a_loopfield%) := ""
} return,

PipeMsgBox(MsgbTtl="",MsgbTxt="",MsgbIcon="",MsgBTimeOut="",MsgbFlags="") {
	global ;MsgbIcon2,hhh
	settimer,unhook,-1
	MBoxCode:="
	(
		#notrayicon
		#noenv
		DetectHiddenWindows,On
		DetectHiddenText,	On
		SetTitleMatchMode,	2
		SetTitleMatchMode,	Slow
		MsgbTxt2:= strreplace(" quote(MsgbTxt) ",""R0n"",chr(10))
		sendmsg:= ""no""
		msgbox," MsgbFlags "," MsgbTtl ",%MsgbTxt2%," MsgBTimeOut "
		ifmsgbox,yes
			sendmsg:= ""yes""
		ifmsgbox,no
			sendmsg:= ""no""
		result:= Send_WM_COPYDATA(SendMsg,SN:=""FileExtension_iconSet.ahk ahk_class AutoHotkey"")
		exitapp,

		Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetScriptTitle) {
			static TimeOutMS:= 2700
			VarSetCapacity(CopyDataStruct,3* A_PtrSize,0)
			NumPut(SizeInBytes:= (StrLen(StringToSend) +1) *(A_IsUnicode? 2:1),CopyDataStruct,A_PtrSize)
			NumPut(&StringToSend,CopyDataStruct,2*A_PtrSize)
			SendMessage,0x4a,0,&CopyDataStruct,,% TargetScriptTitle,,,,% TimeOutMS
			return,errOrlevel
		}
	)"
	if(MsgbIcon!="") {
		SnipeMboxIcon()
		return,pipe(MBoxCode)
	}
}

SnipeMboxIcon() {
	global HookMb:= dllcall("SetWinEventHook","Uint",0x0010,"Uint",0x0010,"Ptr",0,"Ptr"
	, ProcMb_:= RegisterCallback("onMsgbox",""),"Uint",0,"Uint",0,"Uint",skipownprocess:= 0x0002)
}

onMsgbox(UProc,Event,hWnd) {
	critical 500
	settimer,unhook,-10
	coordmode,Mouse,Window
	coordmode,Pixel,Window
	controlget,cw,hwnd,,static1,ahk_id %hwnd%
	((hwpos:= wingetpos(hwnd)).h>299? hh:= hwpos.h-48 : hh:= 300)
	byy:= hwpos.h-155, win_move(hwnd,(a_screenwidth/2)-(hwpos.w/2)-75,(a_screenheight/2)-(hwpos.h/2)+32,hwpos.w+158,hh,"")
	winset,redraw,,ahk_id %hwnd%
	controlget,textwnd,hwnd,,static2,ahk_id %hwnd%
	txtpos:= wingetpos(textwnd)
	controlget,butt1wnd,hwnd,,Button1,ahk_id %hwnd%
	butt1pos:= wingetpos(butt1wnd)
	, win_move(textwnd,272,8,"","","" )
	controlget,butt2wnd,hwnd,,Button2,ahk_id %hwnd%
	butt2pos:= wingetpos(butt2wnd)
	sleep,10
	win_move(butt2wnd,hwpos.w-20,byy,butt2pos.w,butt2pos.h,"")
	, win_move(butt1wnd,hwpos.w-170,byy,butt1pos.w,butt1pos.h,"")
	, cwpos:= wingetpos(cw), win_move(cw,270,200,"","",""), SetImg(cw,msgbhicon)
	gui,t12:new,+hwndh12wnd +E0x2080000 -dpiscale +toolwindow
	gui,t12:add,picture,h256 w256 +hwndh12picwnd,% Msgbicon
	gui,t12:show,na hide x90 y90 w300 h300
	winset,redraw,,ahk_id %butt1wnd%
	winset,redraw,,ahk_id %butt2wnd%
	sleep,10
	winset,redraw,,ahk_id %cw%	
	sleep,10
	RE1:= DllCall("SetParent","uint",h12picwnd,"uint",hwnd)
	sleep,20
	win_move(h12picwnd,10,10,"","","")
	sleep,20
	SetImg(cw,msgbhicon)
	sleep,10
	winset,redraw,,ahk_id %hwnd%
}

CreateNamedPipe(Name,OpenMode=3,PipeMode=0,MaxInstances=255) {
	static skipownprocess=0x0002
	return,dllcall("CreateNamedPipe","str","\\.\pipe\" Name,"uint",OpenMode
	,"uint",PipeMode,"uint",MaxInstances,"uint",0,"uint",0,"uint",0,"uint",0)
}

getPipePiD(byref pipe_n) {
	Sleep(3000), hw:= winexist(ad:= ("\\.\pipe\" . pipe_n))
	winget,pid,PID,Ahk_id %hw%
	return,pid
}

Pipe(filename="",ahkexe="") {
	global
	pipe_ga:= "", (filename="")? filename:= a_scriptfullpath : ()
	(ahkexe="")? ahkexe:= quote(ProcPath()) : ()
	static pipe:= A_Tickcount, pip2:= pipe . 1
	local pipe_name:= a_now ;splitpath(filename).fn  ;a_now ;pipe_name:= "'" MyTab . "'" . " - " .AHK_Portable;
	if(aca:= winexist(_:= "\\.\pipe\" . pipe_name))
	loop,
		if(aca:= winexist(_:= "\\.\pipe\" .  pipe_name .  A_index))
			msgbox,% result "`n" pipe_name "`n" aca " taken"
		else,break,
	pipe_name.= A_index, GI:= (ahkexe . " " . CHR(34) . "\\.\pipe\" . pipe_name .  CHR(34))
	(%pip2%):= CreateNamedPipe(pipe_name,2) ; "PIPE-Name" ; AHK calls GetFileAttributes()
	(%pipe%):= CreateNamedPipe(pipe_name,2) ; <=>=> Close & Create new pipe.
	if(!((%pipe%)=-1||(%pip2%)=-1)) {
		run,% GI,"C:\Program Files\Autohotkey",,ppidd
		dllcall("ConnectNamedPipe",	ptr,pipe_ga,ptr,0)
		dllcall("CloseHandle",ptr,	pipe_ga)
		dllcall("ConnectNamedPipe",	ptr,(%pipe%),ptr,0)
		TxtNew:= fileexist(filename)? file2var(filename) : filename
		Script:= (A_IsUnicode? chr(0xfeff) : chr(239) chr(187) chr(191)) . "#persistent`n" . TxtNew
		char_size:= (A_IsUnicode? 2:1)
		sleep,400 ; v-important ;
		(!Dllcall("WriteFile",ptr, %pipe%,"str",Script,"uint",(StrLen(Script)+1)*char_size,"uint*",0,ptr,0)
		? MsgB0x("WriteFile failed: " ErrorLevel "/" A_LastError) : Pipes.push({ "name" : a:=pipe_name, "hWnd" : b:=(ppidd)}))
		dllcall("CloseHandle",ptr,(%pipe%))
		return,ppid:= getPipePiD(pipe_name)
	} else,msgBox,"Fail","CreateNamedPipe failed.",4)
}

ProcPath(PiDhWnd="") {
	(PiDhWnd="")?PiDhWnd:= DllCall("GetCurrentProcessId") : ()
	Process,Exist,% PiDhWnd
	if(errorlevel)
		winget,ProcPath,processpath,AhK_PiD %PiDhWnd%
	else,winget,ProcPath,processpath,AhK_iD %PiDhWnd%
	return,ProcPath
}

SetImg(hwnd,hBitmap) { ; Example:Gui,Add,Text,0xE w500 h300 hwndhPic 	 ;STM_SETIMAGE=0x172 ;SS_Bitmap=0xE
	Static Ptr:= "UPtr", Uint:= "UInt"
	((!hBitmap||!hwnd)? return())
	E:= DllCall("SendMessage",Ptr,hwnd,Uint,0x172,Uint,0x1,Ptr,hBitmap)
	DllCall("DeleteObject",UPtr,(E))
	return,E
}

RedRaw:
winset,redraw,,ahk_id %h12picwnd%
return,

guiescape:
~escape::
exitapp,

onmsgs:
OnMessage(0x404,"AHK_NOTIFYICON")
OnMessage(0x04a,"Receive_WM_COPYDATA") ;0x4a-WM_COPYDATA
OnMessage(0x015,"WM_DPICHANGED") ;WM_SYSCOLORCHANGE seems to be  cause of relog gfx issue banner2
wm_allow()
return,

menutray() {
	Menu,Tray,Show
}

menuz:
menu,Tray,NoStandard
menu,Tray,Add,%	 splitpath(A_scriptFullPath).fn,% "do_nothing"
menu,Tray,disable,% splitpath(A_scriptFullPath).fn
menu,Tray,Add ,% "Open",%		"MenHandlr"
menu,Tray,Icon,% "Open",%		"C:\Icon\24\Gterminal_24_32.ico"
menu,Tray,Add ,% "script dir",%	"MenHandlr"
menu,Tray,Icon,% "script dir",%	"C:\Icon\24\explorer24.ico"
menu,Tray,Add ,% "Edit",%		"MenHandlr"
menu,Tray,Icon,% "Edit",%		"C:\Icon\24\explorer24.ico"
menu,Tray,Add ,% "Reload",%		"MenHandlr"
menu,Tray,Icon,% "Reload",%		"C:\Icon\24\eaa.bmp"
menu,Tray,Add,%	 "Suspend",%	"MenHandlr"
menu,Tray,Icon,% "Suspend",%	"C:\Icon\24\head_fk_a_24_c1.ico"
menu,Tray,Add,%	 "Pause",%		"MenHandlr"
menu,Tray,Icon,% "Pause",%		"C:\Icon\24\head_fk_a_24_c2b.ico"
menu,Tray,Add ,% "Exit",%		"MenHandlr"
menu,Tray,Icon,% "Exit",%		"C:\Icon\24\head_fk_a_24_c2b.ico"
a_scriptStartTime:= time4mat(a_now,"H:m - d\M"), _:=""
menu,Tray,Tip,% splitpath(A_scriptFullPath).fn "`nRunning, Started @`n" a_scriptStartTime
do_nothing:
return,

MenHandlr(isTarget="") {
	listlines,off
	switch,(isTarget=""? a_thismenuitem : isTarget) {
		case,"script-dir": TT("Opening "   a_scriptdir "..." Open_Containing(A_scriptFullPath),1)
		case,"edit","Open","SUSPEND","pAUSE":
			PostMessage,0x0111,(%a_thismenuitem%),,,% A_ScriptName " - AutoHotkey"
		case,"RELOAD": reload,
		case,"EXIT": exitapp,
		default: islabel(a_thismenuitem)? timer(a_thismenuitem,-10) : ()
	} return,1
}

AHK_NOTIFYICON(byref wParam="",byref lParam="",b1="",br="",bb="") {	
	switch,lParam {
		case,0x0204: settimer,menutray,-20
			return, ;WM_RBUTTONdn;
		case,0x0203: tt("Loading...","Tray",1.5)
			PostMessage,0x0111,%Open%,,,% a_scriptname " - AutoHotkey"
			return, ; WM_doubleclick
		case,0x101: msgbox 101	;case,512: mp:= mPosGet() ;tt("e88t`n2w42",mp.x-56,mp.y-64)	;	case 0x0206: ; WM_RBUTTONDBLCLK	;	case 0x020B: ; WM_XBUTTONDOWN;	case 0x0201: ; WM_LBUTTONDOWN	;	case 0x0202: ; WM_LBUTTONUP
	}
}

WM_DPICHANGED() {
	global
	settimer,RedRaw,-3000
}

mPosGet() {
	static init:=0, o
	(init=0? o:={},init:=1)
	mousegetpos,x,y,hwnd,cwnd,2
	return,o.push({"x" 	: x , "y" : y
		, "hwnd" : hwnd, "cwnd"	: cwnd})
}

wmKeyUp(byref wParam="",byref lParam="",b1="",br="",bb="") {
	switch,lParam {
		case,0x0204: settimer,menutray,-20
		case,0x0203: tt("Loading...","Tray",1.5)
			PostMessage,0x0111,%Open%,,,% a_scriptname " - AutoHotkey"
	}
}

Receive_WM_COPYDATA(byref wParam,byref lParam) {
	global Time_ExCat,CopyOfData
	switch,	CopyOfData:= (StrGet(NumGet(lParam + 2*A_PtrSize))) {
		case,"YES" : settimer,setYES,-20
		case,"NO" : exitapp,
	} return,1
}

File2Var(Path,ByRef Var="",Type="#10") {
	VarSetCapacity(Var,128),VarSetCapacity(Var,0)
	if(!A_IsCompiled) {
		FileGetSize,nSize,%Path%
		FileRead,Var,%Path%
		Return,Var
	} If(hMod:= DllCall("GetModuleHandle",UInt,0))
		If(hRes:= DllCall("FindResource",UInt,hMod,Str,Path,Str,Type)) ;RCDATA = #10
			If(hData:= DllCall("LoadResource",UInt,hMod,UInt,hRes))
				If(pData:= DllCall( "LockResource",UInt,hData)) {
					VarSetCapacity(Var,nSize:= DllCall( "SizeofResource",UInt,hMod,UInt,hRes))
					, DllCall("RtlMoveMemory",Str,Var,UInt,pData,UInt,nSize)
					 return,byref Var
				}
	Return,0
}

b64_2_hBitmap(B64in,NewHandle:= False) {
	Static hBitmap:= 0
	(NewHandle? hBitmap:= 0)
	If(hBitmap)
		Return,hBitmap
	VarSetCapacity(B64,3864 <<!!A_IsUnicode)
	If(!DllCall("Crypt32.dll\CryptStringToBinary","Ptr",&B64in,"UInt",0,"UInt", 0x01,"Ptr",0,"UIntP",DecLen,"Ptr",0,"Ptr",0))
		Return,False
	VarSetCapacity(Dec,DecLen,0)
	If(!DllCall("Crypt32.dll\CryptStringToBinary","Ptr",&B64in,"UInt",0,"UInt",0x01,"Ptr",&Dec,"UIntP",DecLen,"Ptr",0,"Ptr",0))
		Return,False
	hData:= DllCall("Kernel32.dll\GlobalAlloc","UInt",2,"UPtr",DecLen,"UPtr"), pData:= DllCall("Kernel32.dll\GlobalLock","Ptr",hData,"UPtr")
	DllCall("Kernel32.dll\RtlMoveMemory","Ptr",pData,"Ptr",&Dec,"UPtr",DecLen), DllCall("Kernel32.dll\GlobalUnlock","Ptr",hData)
	DllCall("Ole32.dll\CreateStreamOnHGlobal","Ptr",hData,"Int",True,"PtrP",pStream)
	hGdip:= DllCall("Kernel32.dll\LoadLibrary","Str","Gdiplus.dll","UPtr"), VarSetCapacity(SI,16,0), NumPut(1,SI,0,"UChar")
	DllCall("Gdiplus.dll\GdiplusStartup","PtrP",pToken,"Ptr",&SI,"Ptr",0)
	, DllCall("Gdiplus.dll\GdipCreateBitmapFromStream","Ptr",pStream,"PtrP",pBitmap)
	, DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap","Ptr",pBitmap,"PtrP",hBitmap,"UInt",0)
	, DllCall("Gdiplus.dll\GdipDisposeImage","Ptr",pBitmap), DllCall("Gdiplus.dll\GdiplusShutdown","Ptr",pToken)
	DllCall("Kernel32.dll\FreeLibrary","Ptr",hGdip), DllCall(NumGet(NumGet(pStream +0,0,"UPtr") +(A_PtrSize *2),0,"UPtr"),"Ptr",pStream)
	Return,hBitmap
}

Varz:
B64icon:="AAABAAEAHh4AAAEAIACwDgAAFgAAACgAAAAeAAAAPAAAAAEAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACVEUwAlRFMAJURTACVEUwAlBFMAJURTQCVEUwAIAANAAkAAgETAAMDGwAGAw0AAwEQAAUACQACAQgAAwIIAAIBBwADAC4AFQCVEUwAlRFNAJURTACVEU0AlRFMAJURTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACVEUwAlRFMAJURTACFDUQALwAWABkACwAYAAoADAACARsBCAk8AhsbVgMqIiMBDgsHAAMCGAEICDICFhUwAhMSHQAFBhEAAgEyABYAVQUpAJQRTACVEUwAlBFMAJURTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACVEU0AlRFMAGIHMQASAAYADwAEARoABgMWAAMDFAACBDwDGyGYEk6GoBNTlkADHSYNAAQIOwMbI5UQTXqHD0RfNQIWFxAAAQMLAAIBCAACARsACgB9DT4AlRFMAJURTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACVEU0AlRFMABQABwAQAAUCLAESC08DJiBDAx8kJQENFE8FJj26GGHXvhli3VIFJ0QtARIgaQg0ZrkXYdSsFlm2PwMdJBoBBwosARIPIgENCA4ABQIZAAoAlRFNAJURTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACVEUwATAQlAAgAAgElAQ8KZgQyMpoST4isFlmxSAQiNlAFJkLCGmXoyxpq9F0HLWBWBilRxxpo8MwbavdrCTRsJgEOGTgCGB+QEEljXAQtKyQBDgoHAAMBTQQkAJURTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACVEUwALQAVAAsAAwEwAhQSlRFLc7wZYdDEGWbmcAo3d0EEHUF1DTuS0SBv/XoOPqRsCzeO2iBy/9gecP9iBzBpMQIVKGgJM162F17CmRFOgDwDGxsLAAQCKQASAJURTQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAqABMAEQACARIAAgMeAQkNVAUoOK4WWbnOG2z3zx5r+3wTQK6FLE3W4E2F/9szfP+ULFn/406H/+A0e/9uEDiVcgw5hcocae/LGmrlsBVbr0MDHiMTAAIDHgANAJURTQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANAAEBIQEHBjkDGRlFBSArRQcfQ3MOOZeXFU394jF5/+VKhv/qV5L//////+RSnf/pUJ///////+lZkf+VRGP/2TB2/+IgeP+uElrWaQk0WSkCDxcWAAIEDQACASAADQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAgECNwMYFZATSm2wJlvGejk4z9dEbf/lRXX/712F///////wYcL/7V7J//95/P/mR7j/7Vq6/+d2wv//////71yG//FGfP/hQ3P/cTkzuFYeKFNFByAjHwELCQQCAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALBgcCPAYcHqAxWqHDZHr/z7Fn/9S2Zv/Xtmj/17ht/9i2gP/pY9D/4zLT/+tM1f/tSs7/yTGX//99+v/Xt4H/17dt/9i1aP/UtWb/zbFm/79jd/2kMVuZSwYkIBcGCwMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKBAUHOg0cNn9SWcX////////////////////////////////paNL/6kfT/+xFzv/IJZf/60nO/8NcqP////////////////////////////////+6U3Lwbw86TSYDEgoAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAYvBhUtbyI3p9NYb//Rtl7/zr5g/829X//Pu2D/1Lhl/9Oyb//oXML/7EbJ/8komP/JI6H/60nQ/9dRpv/Qs2j/zLxd/8y9Xf/NvV7/zr1f/9O2YP/cWHT/eiI9sDUGGC4AAAAGAAAAAAAAAAAAAAAAAAAAAwAAACdwL0Sj2GaE/9i0bf/QvWP/zr5g/829X//UuWX/5n+H/9mycf/qWLb//HLu//ti+f/PIpT/7j7D/9VNmf/Rs2f/zLxd/8y9Xf/NvV7/zb1f/9C9Yv/YtGz/2maE/3IuRKMAAAAnAAAAAwAAAAAAAAAAAAAACQAAAGHXV4D////////////////////////////////////////////vY7b/8Tq1/+MqtP/2JZz/8jq7/9xdqv///////////////////////////////////////////9hWgP8AAABhAAAACQAAAAAAAAAAAAAACQAAAGHSRnD/17Fo/9e3a//Xt2r/17Zp/9e2af/Ytmn/2Lht/9u5gf//tf//8T2m//5i+f/zKqn/0ymX//l48f/ZtoH/17dt/9e1aP/XtWj/17Zp/9e3av/Xt2r/2LFo/9RGcf8AAABhAAAACQAAAAAAAAAAAAAAAwAAACdrHDOg0j1q/9xEb//eRHD/4ERx/+RFc//uRnr/7l2F///////tXZX/1VSW//+A///zPKL/81Cs//Jfuf//////71yG/+ZFdv/iRHP/4EVy/+BFcf/hRHL/1T1s/20dNKAAAAAnAAAAAwAAAAAAAAAAAAAAAAAAAAYtAhInVQkpY2ALLoBoDTKQehA9tZQTSvXbIHL/2DB2/5dEYP/sVoz//////9lPjv/wT5n//////+tWkf/mSYX/4zF6/5UUTPdvDjagZgwxhmwMNoWBDESKYQkwZi4CEycAAAAGAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAEDDwADCRkABxBJBCM0rxZbv8QYZerIGWfxcgw5iG4QOJfgNHr/4k6F/5UsVv/bM3v/302E/4UsTdeBEkK11R1v/soaaPNqCTVtPQMcLCcBERUwABcPHQAKCg0AAQMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAhAA4ACAACAB8ABwVgAy8poBNSk7cXXsppCDNjNwIYKmgHNGzZHXH/2R9z/2sLNpB6DT6m0R5u/nUNO5ZVBSlQqBNXsMkaauq0GF/IkxBMbS8CFRELAAQCCQACAB4ADQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACVEUwAHQALABEABAIxARQPcQg4PZQRTXY7AxsjOAEbG38JQ3TPG2z7xxpp81UFKVNdBi1iyxpq98IYZ+pVBSpKWwYsRrAWW7qeElGNagY1NSUBDwoIAAIBRQIhAJQRTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACVEUwAXAYtAAwAAwAUAAMDJwEPDDACFRMbAQkMQwMgJ7AWXb26GGHaaQg0aiwBEyFSBSdHvhlj4rsYYttQBSZAKAEPFkcDICdaAyslLwEUDQ4ABQISAAYAlRFNAJURTQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACVEUwAlRFMAEkCIwAPAAQABwACAQoAAwIPAAIDNwIXGo0QSG+aEVCKPgMdJw0ABAlCBB4qpBVUopwSUJE/AxwjFgACBRoAAwQdAAYEDgAEAQ8ABQBXBioAlRFMAJURTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACVEUwAlRFMAJURTACOEEgARAMgACoAEwAPAAIBHgAGBzYCFxZKAiQcIAEMCgYAAwImAQ8OaQg1L1ADJyMiAQ0KCwACARUACAATAAcAIwAPAG0KNQCVEU0AlRFNAJURTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACVEUwAlRFMAJURTACVEUwAlRFMAJURTQAoABEADwACAQ8ABAIWAAUDCwADAQoABAAOAAQCIgAJBh4ABwQOAAMBGQAKAJURTQCVEUwAlRFMAJURTACUEUwAlRFMAJURTQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD////8/////P////z/4R/8/8AH/P4AAfz8AAD8+AAAfPgAAHzwAAB84AAAPOAAABzgAAAc4AAADMAAAAyAAAAEgAAABIAAAASAAAAEwAAADOAAABz4AAB8+AAAfPwAAPz+AAH8/4AP/P/CH/z////8/////P////w"

global Edit:= 65304, Open:= 65407, Suspend:= 65305, Pause:= 65306, Exit:= 6530
, hbitmap:= b64_2_hBitmap(b64icon), This_PiD:= DllCall("GetCurrentProcessId")
, iconpath_New, Msgbicon, h12picwnd
, _:= " ", Pipes:= {}
, MsgbIcon, ProcMb_, HookMb, hhh, Msgbhicon
(!PtrP? global PtrP:= A_IsUnicode?	"UPtr*" : "UInt*")
  ,(!Ptr? Ptr:= A_IsUnicode? "Ptr"	: "UInt")
   ,char_size:= A_IsUnicode? 2 : 1
return,