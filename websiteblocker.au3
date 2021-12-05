#include <GuiConstants.au3>
#include <EditConstants.au3>
#include <guilistbox.au3>
#include <File.au3>
#RequireAdmin

$gui=GUICreate("WebsiteBlocker",200,150)
GUISetBkColor(0x000000)
$label=GUICtrlCreateLabel("Inserisci la password",33,10,200)
GUICtrlSetColor($label,0xff0000)
GUICtrlSetFont($label,11)
$input=GUICtrlCreateInput("",25,40,150,20,$ES_PASSWORD)
GUICtrlSetBkColor($input,0x000000)
GUICtrlSetColor($input,0xff00000)
$accedi=GUICtrlCreateButton("Accedi",50,80,100,25)
GUICtrlSetBkColor($accedi,0x000000)
GUICtrlSetColor($accedi,0xff0000)


$DIR=@AppDataDir&"\WebsiteBlocker"
$FILE=$DIR&"\pwd.txt"
$FILE_HOST=@WindowsDir&"\system32\drivers\etc\hosts"

If Not FileExists($DIR) then
  DirCreate($DIR)
  GUICtrlSetData($accedi,"Registra")
EndIf

GUISetState()

While 1
  Switch GUIGetMsg()
Case $GUI_EVENT_CLOSE
  Exit
Case $accedi
  $pwd=GUICtrlRead($input)
  If GUICtrlRead($accedi)="Registra" Then
         If $pwd="" Then
                MsgBox(16,"Errore","Devi inserire una password")
         Else
                $tmp=FileOpen($FILE,1)
                FileWrite($tmp,$pwd)
                MsgBox(0,"Ok","Password salvata con successo")
                ExitLoop
                FileClose($tmp)
         EndIf
  Else
         $tmp=FileOpen($FILE)
         $pwdtmp=FileRead($tmp)
         If $pwd=$pwdtmp Then
                MsgBox(0,"Ok","Accesso permesso")
                FileClose($tmp)
                ExitLoop
         Else
                MsgBox(16,"Errore","Accesso negato")
                FileClose($tmp)
         EndIf
  EndIf
  EndSwitch
WEnd
 
GUIDelete($gui)


$gui=GUICreate("WebsiteBlocker",300,400)
GUISetBkColor(0x000000)
$list=GUICtrlCreateList("",0,0,300,250)
GUICtrlSetBkColor($list,0x000000)
GUICtrlSetColor($list,0xff0000)
$label=GUICtrlCreateLabel("Inserisci i siti da bloccare",50,260,300)
GUICtrlSetColor($label,0xff0000)
GUICtrlSetFont($label,12)
$input=GUICtrlCreateInput("",0,300,300,30,$ES_CENTER)
GUICtrlSetBkColor($input,0x000000)
GUICtrlSetColor($input,0xff0000)
GUICtrlSetFont($input,13)
$blocca=GUICtrlCreateButton("Blocca",30,350,100)
GUICtrlSetBkColor($blocca,0x000000)
GUICtrlSetColor($blocca,0xff0000)
$sblocca=GUICtrlCreateButton("Sblocca",160,350,100)
GUICtrlSetBkColor($sblocca,0x000000)
GUICtrlSetColor($sblocca,0xff0000)



GUISetState()

$line=_filecountlines($FILE_HOST)
$hosts=FileOpen($FILE_HOST)
For $i=1 to $line
  $site=FileReadLine($hosts,$i)
  If Not StringInStr($site,"www")=0 Then
         $arr=StringSplit($site," ")
         _guictrllistbox_addstring($list,$arr[2])
  EndIf
Next
FileClose($hosts)

While 1
  Switch GUIGetMsg()
Case $GUI_EVENT_CLOSE
  Exit
Case $blocca
  $site=GUICtrlRead($input)
  If StringInStr($site,"www")=0 Then
         MsgBox(16,"Errore","Il sito deve avere questa struttura (www.nomesito....)")
     GUICtrlSetData($input,"")
  Else
  _guictrllistbox_addstring($list,$site)
  $hosts=FileOpen($FILE_HOST,1)
  FileWrite($hosts,@CRLF&@CRLF&"127.0.0.1 "&$site)
  FileClose($hosts)
  GUICtrlSetData($input,"")
  EndIf
Case $sblocca
  $item=_guictrllistbox_getcursel($list)
  $tmp=_guictrllistbox_gettext($list,$item)
  $line=_filecountlines($FILE_HOST)
  $hosts=FileOpen($FILE_HOST)
  For $i=1 to $line
         $site=FileReadLine($hosts,$i)
         If Not StringInStr($site,$tmp)=0 Then
                _filewritetoline($FILE_HOST,$i,"",1)
                _GUICtrlListBox_DeleteString($list, $item)                
         EndIf
  Next
  FileClose($hosts)
  EndSwitch
WEnd
