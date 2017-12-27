/*
 * Installation Program for Beat/2
 *
 * [HISTORY]
 * Revision 1 (04.Aug.2000)
 * > Renewal
 * Revision 2 (18.Jan.2001)
 * > Fix problem.
 * Revision 3 (13.Nov.2017)
 * > Root directory support, folder icons.
 *
 *
 */
rc = RxFuncAdd( "SysLoadFuncs", "RexxUtil", "SysLoadFuncs")

DIR = directory()
IF Right(DIR,1)<>'\' THEN DIR=DIR'\'

APL_FOLDER_NAME  = "Beat/2"
APL_FOLDER_ID    = "<BEAT2_FOLDER>"
APL_FOLDER_ICONS = "ICONFILE="DIR"Beat_C.ICO;ICONNFILE=1,"DIR"Beat_O.ICO"

APL_EXE_NAME = "Beat/2"
APL_EXE_FILE = DIR"BEAT.EXE"
APL_EXE_ID   = "<BEAT2>"

README_E_FILE = DIR"readme_e.htm"
README_E_NAME = "Readme English"


say ""
say " Install Beat/2..."
say ""

/* Create Folders */
/* 1. Pretty Pop Software Main Folder */
if SysCreateObject( 'WPFolder', 'Pretty Pop Software', '<WP_DESKTOP>', "OBJECTID=<PRETTY_POP_SOFTWARE>", "u" ) then do
    say ' Create Folder : Pretty Pop Software'
end

/* 2. Application Folder */
if SysCreateObject( 'WPFolder', APL_FOLDER_NAME, '<PRETTY_POP_SOFTWARE>', "OBJECTID="APL_FOLDER_ID";"APL_FOLDER_ICONS,"u" ) then do
    say " Create Folder : "APL_FOLDER_NAME
end

/* Create Objects */
parameter = "EXENAME="APL_EXE_FILE";STARTUPDIR="directory()";OBJECTID="APL_EXE_ID
if SysCreateObject('WPProgram', APL_EXE_NAME,'<WP_START>', parameter, 'u') then do
    say " Create Object : "APL_EXE_NAME
end

if SysCreateShadow("<WP_START>", APL_FOLDER_ID) then do
    say " Create Shadow : Startup Folder"
end

if SysCreateObject( 'WPUrl', README_E_NAME, APL_FOLDER_ID, 'URL=file:///'README_E_FILE, "u" ) then do
    say " Create Object : "README_E_NAME
end

say ""
say " Beat/2 installation was successfully completed."
say " Please restart OS/2 or start Beat/2 in the startup folder."
say ""
say " Beat/2 のインストールは無事に終了しました。"
say " OS/2をリスタートするか始動フォルダのBeat/2を起動してください。"