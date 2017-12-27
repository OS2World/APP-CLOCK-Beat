/*:VRX         Main
*/
/*
 * Beat/2 - Swatch Beat, Internet Time Indicator
 *
 * [History]
 * Version 0.01 (12.Jul.1999)
 * > ...in the begining
 * Version 0.02 (13.Jul.1999)
 * > Implement parameters
 * Version 0.90 (15.Jul.1999) since 14.Jul.1999
 * > ほぼ完成に近いβ版。
 * Version 0.91 (15.Jul.1999)
 * > 30分単位のTimeZoneに対応。
 * Version 0.92 (18.Jul.1999) since 16.Jul.1999
 * > `Hide/Show Title Bar' Functionの追加。(16.Jul.1999)
 * > Beat Fontが正しく反映されない不具合を修正。(16.Jul.1999)
 * > Color設定パラメータの追加。ただし、隠しコマンド的(INIファイルのParameterをEditor等で設定)。 (16.Jul.1999)
 * > Sub WindowのDefault表示位置をDesktopのCenterに変更(従来はParent WindowのCenter)。 (18.Jul.1999)
 * Version 1.00 (21.Jul.1999)
 * > Version 1.00公開。
 * Version 1.01 (24.Jul.1999) since 22.Jul.1999
 * > Config.sysにTimeZone設定がない時に生じる不具合の修正(JavaかVAJが入っていないと起きる問題？)。
 * Version 2.00 (13.Aug.1999) since 30.Jul.1999
 * > `Color Customize' Functionの追加 (30.Jul.1999 - 31.Jul.1999, 1.09 beta 1)
 * > `Sizeable Window' Functionの追加 (30.Jul.1999 - 31.Jul.1999, 1.09 beta 1)
 * > `Auto Font Size' Functionの追加 (30.Jul.1999 - 31.Jul.1999, 1.09 beta 1)
 * > Window Size Ratioを3:4に設定。Default Sizeは750x1000 (03.Aug.1999, 1.09 beta 2)
 * > `Keep Window Size Ratio' Functionを追加。Window Sizeを自由に設定することも可能 (03.Aug.1999, 1.09 beta 2)
 * > Window Size Ratioを554:964に変更 (04.Aug.1999, 1.09 beta 3)
 * > Beat TimeのCopy to Clipboard機能の追加 (06.Aug.1999, 1.09 beta 4)
 * > Default Sizeを 554*1.3 x 964*1.3 に変更してVersion 2.00として公開。
 * Version 2.01 (21.Aug.1999) since 16.Aug.1999
 * > PopCD!でSystem Shutdown時に生じる問題に対処するためにCommnet Outした項目をComment Out (2.01 beta 1, 16.Aug.1999)
 *        _VREHalt:
 *          _VREReturnValue = Fini()
 *          call VRDestroy _VREPrimaryWindow  <- Comment Out
 *        _VRELeaveMain:
 *           call VRFini                      <- Comment Out
 *        exit _VREReturnValue
 * > Startup FolderにあるBeat/2 Object NameをSimpleな名前に変更する機能の追加 (2.01 beta 2, 19.Aug.1999)
 * > Version 2.01公開 (21.Aug.1999)
 * Version 2.02 (28.Aug.1999) since 25.Aug.1999
 * > SET TZ=CST等、TZの設定値に数値がない場合に生じる立ち上げ時の不具合を修正 (2.02 beta 1, 25-26.Aug.1999)
 * > AutoFontSizeの初期値をDisabledからEnabledに変更 (2.02 beta 1, 25.Aug.1999)
 * > さらに調整 (2.02 beta 2, 26.Aug.1999)
 * > 2.02公開 (28.Aug.1999)
 *
 */
/*  Main
*/
Main:
/*  Process the arguments.
    Get the parent window.
*/
    parse source . calledAs .
    parent = ""
    argCount = arg()
    argOff = 0
    if( calledAs \= "COMMAND" )then do
        if argCount >= 1 then do
            parent = arg(1)
            argCount = argCount - 1
            argOff = 1
        end
    end; else do
        call VROptions 'ImplicitNames'
    end
    InitArgs.0 = argCount
    if( argCount > 0 )then do i = 1 to argCount
        InitArgs.i = arg( i + argOff )
    end
    drop calledAs argCount argOff

/*  Load the windows
*/
    call VRInit
    parse source . . spec
    _VREPrimaryWindowPath = ,
        VRParseFileName( spec, "dpn" ) || ".VRW"
    _VREPrimaryWindow = ,
        VRLoad( parent, _VREPrimaryWindowPath )
    drop parent spec
    if( _VREPrimaryWindow == "" )then do
        call VRMessage "", "Cannot load window:" VRError(), ,
            "Error!"
        _VREReturnValue = 32000
        signal _VRELeaveMain
    end

/*  Process events
*/
    call Init
    signal on halt
    do while( \ VRGet( _VREPrimaryWindow, "Shutdown" ) )
        _VREEvent = VREvent()
        interpret _VREEvent
    end
_VREHalt:
    _VREReturnValue = Fini()
/*
    call VRDestroy _VREPrimaryWindow /* Comment Out, 16.Aug.1999 */
*/
_VRELeaveMain:
/*
    call VRFini /* Comment Out, 16.Aug.1999 */
*/
exit _VREReturnValue

VRLoadSecondary:
    __vrlsWait = abbrev( 'WAIT', translate(arg(2)), 1 )
    if __vrlsWait then do
        call VRFlush
    end
    __vrlsHWnd = VRLoad( VRWindow(), VRWindowPath(), arg(1) )
    if __vrlsHWnd = '' then signal __vrlsDone
    if __vrlsWait \= 1 then signal __vrlsDone
    call VRSet __vrlsHWnd, 'WindowMode', 'Modal'
    __vrlsTmp = __vrlsWindows.0
    if( DataType(__vrlsTmp) \= 'NUM' ) then do
        __vrlsTmp = 1
    end
    else do
        __vrlsTmp = __vrlsTmp + 1
    end
    __vrlsWindows.__vrlsTmp = VRWindow( __vrlsHWnd )
    __vrlsWindows.0 = __vrlsTmp
    do while( VRIsValidObject( VRWindow() ) = 1 )
        __vrlsEvent = VREvent()
        interpret __vrlsEvent
    end
    __vrlsTmp = __vrlsWindows.0
    __vrlsWindows.0 = __vrlsTmp - 1
    call VRWindow __vrlsWindows.__vrlsTmp
    __vrlsHWnd = ''
__vrlsDone:
return __vrlsHWnd

/*:VRX         CalculateFontSize
*/
CalculateFontSize:

    if TitleBar = "Enabled" then do
        wSize = b2_height - 260
    end
    else if TitleBar = "Disabled" then do
        wSize = b2_height
    end

    fSize = wSize % 38

    parse var BeatFont bfSize "." bfName

    BeatFont = fSize"."bfName
    ok = VRSet( "DT_BeatTime", "Font", BeatFont )

return

/*:VRX         CB_AlwaysOnTop_Click
*/
CB_AlwaysOnTop_Click:

    set = VRGet( "CB_AlwaysOnTop", "Set" )
    if set = 0 then do
        AlwaysOnTop = "Disabled"
    end
    else if set = 1 then do
        AlwaysOnTop = "Enabled"
    end

return

/*:VRX         CB_AutoFontSize_Click
*/
CB_AutoFontSize_Click:

    set = VRGet( "CB_AutoFontSize", "Set" )
    if set = 1 then AutoFontSize = "Enabled"
    else if set = 0 then AutoFontSize = "Disabled"

    if AutoFontSize = "Enabled" then do
        call CalculateFontSize
    end

return

/*:VRX         CB_KeepWindowSizeRatio_Click
*/
CB_KeepWindowSizeRatio_Click:

    set = VRGet( "CB_KeepWindowSizeRatio", "Set" )
    if set = 1 then do
        KeepWindowSizeRatio = "Enabled"
    end
    else if set = 0 then do
        KeepWindowSizeRatio = "Disabled"
    end

return

/*:VRX         CB_OnlyBeat_Click
*/
CB_OnlyBeat_Click:

    set = VRGet( "CB_OnlyBeat", "Set" )
    if set = 0 then OnlyBeat = "No"
    else if set = 1 then OnlyBeat = "Yes"

return

/*:VRX         DT_BeatTime_ContextMenu
*/
DT_BeatTime_ContextMenu:

    if TitleBar = "Enabled" then do
        ok = VRSet( "Menu_HideShowTitleBar", "Checked", 0 )
    end
    else if TitleBar = "Disabled" then do
        ok = VRSet( "Menu_HideShowTitleBar", "Checked", 1 )
    end

    ok = VRMethod( "Menu_Menu", "Popup")

return

/*:VRX         Fini
*/
Fini:
/*
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
*/
return 0

/*:VRX         Halt
*/
Halt:
    signal _VREHalt
return

/*:VRX         Init
*/
Init:

    /* Run Optionのargumentにdebugmodeを指定した場合の処置 */
    if translate(initArgs.1) =  "DEBUGMODE" then debug_mode = 1
    else debug_mode = 0

    call rxfuncadd sysloadfuncs, rexxutil, sysloadfuncs
    call sysloadfuncs

    call VRSet "console", "WindowListTitle", ""
    if debug_mode = 0 then do
        call VRRedirectStdio "off" 
    end

    /* Beat/2 Version */
    Beat2_Version = "2.03"
    ok = VRSet( "Window1", "Caption", "Beat/2 "beat2_version )
    ok = VRSet( "Window1", "WindowListTitle", "Beat/2 "Beat2_Version)

    BeatDirectory = VRCurrDrive()""VRCurrDir()

    TimeZone = "NULL"
    indicate_type = "BEAT" /* BEAT or CLOCK */

    ok = VRSet( "DT_BeatTime", "Caption", "Beat" )

    Interval = 0.02

    /* Always on Top */
    AlwaysOnTop = "Disabled"

    /* Only Beat */
    OnlyBeat = "No"

    /* Show Hide Title Bar */
    TitleBar = "Enabled"

    /* Color */
    BackColor = "(0,0,0)"
    ForeColor = "(255,255,255)"

    /* Size */
    b2_height = 554*1.3%1
    b2_width  = 964*1.3%1
    b2_height_default = b2_height
    b2_width_default  = b2_width

    KeepWindowSizeRatio = "Enabled"

    /* Auto Font Size */
    AutoFontSize = "Enabled" /* Enabledに変更 (2.02 beta 1) */

    /* Font */
    BeatFont = "<NONE>"
    Font = "<NONE>"

    PosX_old = 0
    PosY_old = 0

    /* Read Initial File */
    call ReadInitialFile

    /* If TimeZone is not set, then check Config.sys and set TimeZone */
    if TimeZone = "NULL" then do
        TimeZone = 0 /* とりあえず、数値のデフォルト値(NULLではなく)に設定 */

        boot_drive = left(VRIniDir(), 2)
        config_sys = boot_drive"\config.sys"

        do until lines(config_sys) = 0
            line_text = linein(config_sys)

            if translate(left(line_text, 6)) = "SET TZ" then do
                parse var line_text . "=" tzd "," .

                tzd=tzd||'A'
                do until right(tzd, 1)='NUM'
                    tzd = left(tzd, length(tzd) - 1)
                end

                /* 更にData TypeをCheckする。 例えば、SET TZ=CST等数値が入っていない場合のチェック (2.02, 25-26.Aug.1999) */
                if tzd <> "" then do
                    tzd = right(tzd, length(tzd) - 3)

                    /* 30分単位の設定 */
                    parse var tzd tzd ":" tzd2
                    if tzd2 = "30" then tzd = tzd".5"
                    else                tzd = tzd".0"
                end
                else do
                    tzd = 0
                end
                TimeZone = tzd
            end
        end
        call lineout config_sys
    end

    /* Set Default Font */
    if BeatFont = "<NONE>" then do
        BeatFont_old = "18.Arial"
        BeatFont = VRFontDialog( VRWindow(), "18.Arial", "Beat/2 - Set clock font, anyway" )
        if BeatFont = "" then BeatFont = BeatFont_old
    end

    if Font = "<NONE>" then do
        Font_old = "9.WarpSans"
        Font = VRFontDialog( VRWindow(), "9.WarpSans", "Beat/2 - Set other font, anyway" )
        if Font = "" then Font = Font_old
    end

    /* Set Font */
    ok = VRSet( "DT_BeatTime", "Font", BeatFont )

    /* Set Color */
    ok = VRSet( "DT_BeatTime", "BackColor", BackColor )
/*  ok = VRSet( "DT_BeatTime", "ForeColor", ForeColor ) */
    ok = VRSet( "DT_BeatTime", "ForeColor", BackColor )

    ok = VRSet( "Window1", "BackColor", BackColor )

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

    ok = VRSet( "Window1", "Height",  b2_height )
    ok = VRSet( "Window1", "Width",   b2_width  ) /* 1241:1217 */

    window = VRWindow()
    call VRMethod window, "CenterWindow"

    /* Set Position */
    ok = VRSet( "Window1", "Left", PosX )
    ok = VRSet( "Window1", "Top",  PosY )

    if PreferencePosX = 0 then PreferencePosX = PosX
    if PreferencePosY = 0 then PreferencePosY = PosY

    /* Set Title Bar */
    if TitleBar = "Enabled" then do
        ok = VRSet( "Window1", "TitleBar", 1 )
    end
    else if TitleBar = "Disabled" then do
        ok = VRSet( "Window1", "TitleBar", 0 )
    end
    ok = VRSet( "Window1", "Height", b2_height )

    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
    drop window

    /* 色の後処理 */
    ok = VRSet( "DT_BeatTime", "ForeColor", ForeColor )
    ok = VRSet( "Window1", "BackColor", "<Default>" )

return

/*:VRX         Menu_Exit_Click
*/
Menu_Exit_Click:

    PosX = VRGet( "Window1", left )
    PosY = VRGet( "Window1", top )

    call WriteInitialFile

    call quit

return

/*:VRX         Menu_HideShowTitleBar_Click
*/
Menu_HideShowTitleBar_Click:

    if TitleBar = "Enabled" then do
        ok = VRSet( "Window1", "TitleBar", 0 )
        ok = VRSet( "Window1", "Height", b2_height - 260 )

        t = VRGet( "Window1", Top )
        ok = VRSet( "Window1", "Top", t + 260 )

        TitleBar = "Disabled"
    end
    else if TitleBar = "Disabled" then do
        ok = VRSet( "Window1", "TitleBar", 1 )
        ok = VRSet( "Window1", "Height", b2_height + 260 )

        t = VRGet( "Window1", Top )
        ok = VRSet( "Window1", "Top", t - 260 )

        TitleBar = "Enabled"
    end

return

/*:VRX         Menu_Preference_Click
*/
Menu_Preference_Click:

    ok = VRLoadSecondary( "SW_Preference", "w" )

return

/*:VRX         MItem_About_Click
*/
MItem_About_Click:

    ok = VRLoadSecondary( "SW_About", "w" )

return

/*:VRX         MItem_Copy_Click
*/
MItem_Copy_Click:

    ok = VRMethod( "Application", "PutClipboard", "@"beat )

return

/*:VRX         PB_AboutBeat2_Click
*/
PB_AboutBeat2_Click:

    ok = VRLoadSecondary( "SW_About", "w" )

return

/*:VRX         PB_ExitAbout_Click
*/
PB_ExitAbout_Click:

    ok = VRDestroy( "SW_About" )

return

/*:VRX         PB_Preference_Return_Click
*/
PB_Preference_Return_Click:

    PreferencePosX = VRGet( "SW_Preference", "Left" )
    PreferencePosY = VRGet( "SW_Preference", "Top" )

    call WriteInitialFile

    ok = VRDestroy( "SW_Preference" )

return

/*:VRX         PB_SetBackColor_Click
*/
PB_SetBackColor_Click:

    SetColorPlace = "BackColor"
    ok = VRLoadSecondary( "SW_SetColor", "w" )

return

/*:VRX         PB_SetClockFont_Click
*/
PB_SetClockFont_Click:

    BeatFont_old = BeatFont
    BeatFont = VRFontDialog( VRWindow(), BeatFont, "Select a font!")
    if BeatFont = "" then BeatFont = BeatFont_old

/*  ok = VRSet( "EF_ClockFont", "Font", BeatFont ) */
    ok = VRSet( "EF_ClockFont", "Font", Font )
    ok = VRSet( "EF_ClockFont", "Value", BeatFont )

    ok = VRSet( "DT_BeatTime", "Font", BeatFont )

    if AutoFontSize = "Enabled" then do
        call CalculateFontSize
    end

return

/*:VRX         PB_SetColorWindow_Cancel_Click
*/
PB_SetColorWindow_Cancel_Click:

    if SetColorPlace = "ForeColor" then do
        ok = VRSet( "DT_BeatTime", "ForeColor", OldColor )
    end
    else if SetColorPlace = "BackColor" then do
        ok = VRSet( "DT_BeatTime", "BackColor", OldColor )
    end

    ok = VRDestroy( "SW_SetColor" )

return

/*:VRX         PB_SetColorWindow_OK_Click
*/
PB_SetColorWindow_OK_Click:

    if SetColorPlace = "ForeColor" then do
        ForeColor = "("cRed","cGreen","cBlue")"
        ok = VRSet( "Pict_ForeColor", "BackColor", ForeColor )
        ok = VRSet( "DT_BeatTime", "ForeColor", ForeColor )
    end
    else if SetColorPlace = "BackColor" then do
        BackColor = "("cRed","cGreen","cBlue")"
        ok = VRSet( "Pict_BackColor", "BackColor", BackColor )
        ok = VRSet( "DT_BeatTime", "BackColor", BackColor )
    end

    call WriteInitialFile

    ok = VRDestroy( "SW_SetColor" )

return

/*:VRX         PB_SetDefaultSize_Click
*/
PB_SetDefaultSize_Click:

    b2_width  = b2_width_default

    if TitleBar = "Enabled" then do
        b2_height = b2_height_default
    end
    else if TitleBar = "Disabled" then do
        b2_height = b2_height_default - 260
    end

    ok = VRSet( "Window1", "Height", b2_height )
    ok = VRSet( "Window1", "Width",  b2_width  )

    call SetWindowSize

return

/*:VRX         PB_SetFont_Click
*/
PB_SetFont_Click:

    Font_old = Font
    Font = VRFontDialog( VRWindow(), font, "Select a font!")
    if Font = "" then Font = Font_old

    ok = VRSet( "EF_Font", "Font", Font )
    ok = VRSet( "EF_Font", "Value", Font )

    call SetPreferenceFont

return

/*:VRX         PB_SetForeColor_Click
*/
PB_SetForeColor_Click:

    SetColorPlace = "ForeColor"
    ok = VRLoadSecondary( "SW_SetColor", "w" )

return

/*:VRX         Quit
*/
Quit:
    window = VRWindow()
    call VRSet window, "Shutdown", 1
    drop window
return

/*:VRX         ReadInitialFile
*/
ReadInitialFile:

    initial_file = BeatDirectory"\Beat.ini"

    i = 0
    do until lines(initial_file) = 0
        line_text=linein(initial_file)

        parse var line_text keyword '=' detail

        if left(keyword, 30) = "; Beat.ini - Beat Initial File" then do
            parse var keyword "(" old_version ")"
        end
        last_version = "Last Official Version"

        select
            when keyword = "PosX" then PosX = detail
            when keyword = "PosY" then PosY = detail

            when keyword = "PreferencePosX" then PreferencePosX = detail
            when keyword = "PreferencePosY" then PreferencePosY = detail

            when keyword = "BackColor" then BackColor = detail
            when keyword = "ForeColor" then ForeColor = detail

            when keyword = "Height" then b2_height = detail
            when keyword = "Width"  then b2_width  = detail

            when keyword = "TimeZone" then TimeZone = detail

            when keyword = "Interval"            then Interval = detail
            when keyword = "AlwaysOnTop"         then AlwaysOnTop = detail
            when keyword = "OnlyBeat"            then OnlyBeat = detail
            when keyword = "TitleBar"            then TitleBar = detail
            when keyword = "AutoFontSize"        then AutoFontSize = detail
            when keyword = "KeepWindowSizeRatio" then KeepWindowSizeRatio = detail
            when keyword = "BeatFont"            then BeatFont = detail
            when keyword = "Font"                then Font = detail
            otherwise
                nop
        end
    end

    /* Startup FolderにあるBeat/2 ObjectのRename (18-19.Aug.1999) */
    if (left(old_version, 9) = "2.01 beta") | (Beat2_Version > old_version) then do
        params = "TITLE=Beat/2;"
        rc = SysSetObjectData( "<BEAT2>", params )
    end

return

/*:VRX         SetPreferenceFont
*/
SetPreferenceFont:

    ok = VRSet( "DT_TimeZone",          "Font", Font )
    ok = VRSet( "SPIN_TimeZone",        "Font", Font )
    ok = VRSet( "PB_Preference_Return", "Font", Font )
    ok = VRSet( "CB_AlwaysOnTop",       "Font", Font )
    ok = VRSet( "DT_Interval",          "Font", Font )
    ok = VRSet( "SPIN_Interval",        "Font", Font )
    ok = VRSet( "DT_IntervalScale",     "Font", Font )
    ok = VRSet( "CB_OnlyBeat",          "Font", Font )
    ok = VRSet( "GB_Font",              "Font", Font )
    ok = VRSet( "DT_ClockFont",         "Font", Font )
    ok = VRSet( "DT_Font",              "Font", Font )
/*  ok = VRSet( "EF_ClockFont",         "Font", BeatFont ) */
    ok = VRSet( "EF_ClockFont",         "Font", Font )
    ok = VRSet( "EF_Font",              "Font", Font )
    ok = VRSet( "PB_SetDefaultSize",    "Font", Font )
    ok = VRSet( "DT_ForeColor",         "Font", Font )
    ok = VRSet( "DT_BackColor",         "Font", Font )
    ok = VRSet( "PB_SetForeColor",      "Font", Font )
    ok = VRSet( "PB_SetBackColor",      "Font", Font )
    ok = VRSet( "PB_AboutBeat2",        "Font", Font )

    ok = VRSet( "CB_AutoFontSize",   "Font", Font )
    ok = VRSet( "PB_SetDefaultSize", "Font", Font )
    ok = VRSet( "CB_KeepWindowSizeRatio", "Font", Font )

    ok = VRSet( "PB_SetClockFont",      "Font", Font )
    ok = VRSet( "PB_SetFont",           "Font", Font )

return

/*:VRX         SetWindowSize
*/
SetWindowSize:

    ok = VRSet( "DT_BeatTime", "width",  b2_width  )

    if TitleBar = "Enabled" then do
        ok = VRSet( "DT_BeatTime", "Height", b2_height - 260 )
    end
    else if TitleBar = "Disabled" then do
        ok = VRSet( "DT_BeatTime", "Height", b2_height )
    end

return

/*:VRX         SL_Blue_Change
*/
SL_Blue_Change:

    percentile = VRGet( "SL_Blue", "Percentile" )
    cBlue = (255 * percentile) % 100

    call TentativelyChangeColor

return

/*:VRX         SL_Green_Change
*/
SL_Green_Change:

    percentile = VRGet( "SL_Green", "Percentile" )
    cGreen = (255 * percentile) % 100

    call TentativelyChangeColor

return

/*:VRX         SL_Red_Change
*/
SL_Red_Change:

    percentile = VRGet( "SL_Red", "Percentile" )
    cRed = (255 * percentile) % 100

    call TentativelyChangeColor

return

/*:VRX         SPIN_Interval_Change
*/
SPIN_Interval_Change:

    value = VRGet( "SPIN_Interval", "Value" )
    Interval = value

    ok = VRSet( "TM_BeatTimer", "Delay", (86400 * Interval) % 1 )

return

/*:VRX         SPIN_TimeZone_Change
*/
SPIN_TimeZone_Change:

    value = VRGet( "SPIN_TimeZone", "Value" )
    TimeZone = value

return

/*:VRX         SW_About_Close
*/
SW_About_Close:
    call SW_About_Fini
return

/*:VRX         SW_About_Create
*/
SW_About_Create:
    call SW_About_Init
return

/*:VRX         SW_About_Fini
*/
SW_About_Fini:
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_About_Init
*/
SW_About_Init:

    ok = VRSet( "SW_About", "Caption", "Beat/2 "Beat2_Version )

    ok = VRSet( "DT_Homepage",  "Font", Font )
    ok = VRSet( "EF_Homepage",  "Font", Font )
    ok = VRSet( "PB_ExitAbout", "Font", Font )
    ok = VRSet( "DT_EMail",     "Font", Font )
    ok = VRSet( "EF_EMail",     "Font", Font )
    ok = VRSet( "GB_PrettyPopMusicAndSoftware", "Font", Font )
    ok = VRSet( "DT_ApplicationDetail", "Font", Font )
    ok = VRSet( "DT_AppliocationType",  "Font", Font )

    AboutClock = 1

    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
/*      call VRMethod window, "CenterWindow" */
        ok = VRMethod( window, "CenterWindow", Desktop )

        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         SW_Preference_Close
*/
SW_Preference_Close:
    call SW_Preference_Fini
return

/*:VRX         SW_Preference_Create
*/
SW_Preference_Create:
    call SW_Preference_Init
return

/*:VRX         SW_Preference_Fini
*/
SW_Preference_Fini:
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_Preference_Init
*/
SW_Preference_Init:

    /* Set Time Zone */
    tz0 = -24
    do i = 1 to 95
        tz0 = tz0 + 0.5
        tz.i = tz0
    end
    tz.0 = 95
    ok = VRMethod( "SPIN_TimeZone", "SetStringList", "tz." )
    ok = VRSet( "SPIN_TimeZone", "Value", TimeZone )

    /* Set Interval */
    do i = 1 to 5
        intbeat.i = i * 0.01
    end
    intbeat.0 = 5
    ok = VRMethod( "SPIN_Interval", "SetStringList", "intbeat." )
    ok = VRSet( "SPIN_Interval", "Value", Interval )

    /* Always on Top */
    if AlwaysOnTop = "Enabled" then do
        ok = VRSet( "CB_AlwaysOnTop", "Set", 1 )
    end
    else if AlwaysOnTop = "Disabled" then do
        ok = VRSet( "CB_AlwaysOnTop", "Set", 0 )
    end

    /* Only Beat */
    if OnlyBeat = "Yes" then do
        ok = VRSet( "CB_OnlyBeat", "Set", 1 )
    end
    else if OnlyBeat = "No" then do
        ok = VRSet( "CB_OnlyBeat", "Set", 0 )
    end

    /* Set Color */
    ok = VRSet( "Pict_ForeColor", "BackColor", ForeColor )
    ok = VRSet( "Pict_BackColor", "BackColor", BackColor )

    /* Auto Font Size */
    if AutoFontSize = "Enabled" then do
        ok = VRSet( "CB_AutoFontSize", "Set", 1 )
    end
    else if AutoFontSize = "Disabled" then do
        ok = VRSet( "CB_AutoFontSize", "Set", 0 )
    end

    /* Keep Window Size Ratio */
    if KeepWindowSizeRatio = "Enabled" then do
        ok = VRSet( "CB_KeepWindowSizeRatio", "Set", 1 )
    end
    else if KeepWindowSizeRatio = "Disabled" then do
        ok = VRSet( "CB_KeepWindowSizeRatio", "Set", 0 )
    end

    /* Set Font */
    call SetPreferenceFont

/*  ok = VRSet( "EF_ClockFont", "Font", BeatFont ) */

    ok = VRSet( "EF_ClockFont", "Value", BeatFont )
    ok = VRSet( "EF_Font",      "Value", Font )




/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
/*      call VRMethod window, "CenterWindow" */
        ok = VRMethod( window, "CenterWindow", Desktop )

        ok = VRSet( "SW_Preference", "left", PreferencePosX )
        ok = VRSet( "SW_Preference", "top",  PreferencePosY )

        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         SW_SetColor_Close
*/
SW_SetColor_Close:
    call SW_SetColor_Fini
return

/*:VRX         SW_SetColor_Create
*/
SW_SetColor_Create:
    call SW_SetColor_Init
return

/*:VRX         SW_SetColor_Fini
*/
SW_SetColor_Fini:
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_SetColor_Init
*/
SW_SetColor_Init:

    if SetColorPlace = "ForeColor" then do
        parse var ForeColor "(" cRed "," cGreen "," cBlue ")"
        OldColor = ForeColor

        ok = VRSet( "SW_SetColor", "Caption", "Beat/2 - Set Fore Color" )
    end
    else if SetColorPlace = "BackColor" then do
        parse var BackColor "(" cRed "," cGreen "," cBlue ")"
        OldColor = BackColor

        ok = VRSet( "SW_SetColor", "Caption", "Beat/2 - Set Back Color" )
    end

    RedParcentile   = (cRed   * 100) % 255
    GreenParcentile = (cGreen * 100) % 255
    BlueParcentile  = (cBlue  * 100) % 255

    ok = VRSet( "SL_Red"  , "Percentile", RedParcentile   )
    ok = VRSet( "SL_Green", "Percentile", GreenParcentile )
    ok = VRSet( "SL_Blue" , "Percentile", BlueParcentile  )


    /* Set Font */
    ok = VRSet( "PB_SetColorWindow_OK",     "Font", Font )
    ok = VRSet( "PB_SetColorWindow_Cancel", "Font", Font )



    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         TentativelyChangeColor
*/
TentativelyChangeColor:

    if SetColorPlace = "ForeColor" then do
        ok = VRSet( "DT_BeatTime", "ForeColor", "("cRed","cGreen","cBlue")" )
    end
    else if SetColorPlace = "BackColor" then do
        ok = VRSet( "DT_BeatTime", "BackColor", "("cRed","cGreen","cBlue")" )
    end

return

/*:VRX         TM_AboutClock_Trigger
*/
TM_AboutClock_Trigger:

    AboutClock = AboutClock + 1

    select
        when AboutClock = 1 then do
            ok = VRSet( "Pict_Icon", "PicturePath", "#301" )
        end
        when AboutClock = 2 then do
            ok = VRSet( "Pict_Icon", "PicturePath", "#302" )
        end
        when AboutClock = 3 then do
            ok = VRSet( "Pict_Icon", "PicturePath", "#303" )
        end
        when AboutClock = 4 then do
            ok = VRSet( "Pict_Icon", "PicturePath", "#304" )
        end
        when AboutClock = 5 then do
            ok = VRSet( "Pict_Icon", "PicturePath", "#301" )
        end
        when AboutClock = 6 then do
            ok = VRSet( "Pict_Icon", "PicturePath", "#302" )
        end
        when AboutClock = 7 then do
            ok = VRSet( "Pict_Icon", "PicturePath", "#303" )
        end
        when AboutClock = 8 then do
            ok = VRSet( "Pict_Icon", "PicturePath", "#304" )
        end
        when AboutClock = 9 then do
            ok = VRSet( "Pict_Icon", "PicturePath", "#350" )
            AboutClock = 0
        end
        otherwise
    end

return

/*:VRX         TM_BeatTimer_Trigger
*/
TM_BeatTimer_Trigger:

    if AlwaysOnTop = "Enabled" then do
        ok = VRSet( "Window1", "SiblingOrder", 1)
    end

    PosX = VRGet( "Window1", "Left" )
    PosY = VRGet( "Window1", "Top" )
    if (PosX <> PosX_old) | (PosY <> PosY_old) then do
        call WriteInitialFile
        PosX_old = PosX
        PosY_old = PosY
    end

    if indicate_type = "BEAT" then do
        BeatTZ = TimeZone + 1
        if BeatTZ = 24   then BeatTZ = 0
        if BeatTZ = 24.5 then BeatTZ = 0.5

        beat = time(S) + BeatTZ * 60 * 60
        if beat < 0 then beat = beat + 24 * 60 * 60
        beat = right((beat/86.4 + 0.5) % 1, 3, "0")

        ok = VRSet( "DT_BeatTime", "Caption", "@"beat )

        if OnlyBeat = "No" then do
            indicate_type = "CLOCK"
        end
    end
    else if indicate_type = "CLOCK" then do
        clock = time("N")
        l = length(clock)
        clock = left(clock, l - 3)

        ok = VRSet( "DT_BeatTime", "Caption", clock )

        indicate_type = "BEAT"
    end

return

/*:VRX         Window1_Close
*/
Window1_Close:
    call Quit
return

/*:VRX         Window1_Resize
*/
Window1_Resize:

    ok = VRSet( "Window1", "BackColor", BackColor )

    b2_height = VRGet( "Window1", height )

    if TitleBar = "Enabled" then do
        b2h = b2_height - 260
    end
    else if TitleBar = "Disabled" then do
        b2h = b2_height
    end

    if KeepWindowSizeRatio = "Enabled" then do
        b2_width = (b2h * b2_width_default) % b2_height_default
    end
    else do
        b2_width = VRGet( "Window1", width )
    end

    ok = VRSet( "Window1", "Width", b2_width )

    call SetWindowSize

    ok = VRSet( "Window1", "BackColor", "<Default>" )

    if AutoFontSize = "Enabled" then do
        call CalculateFontSize
    end

return

/*:VRX         WriteInitialFile
*/
WriteInitialFile:

    PosX = VRGet( "Window1", "Left" )
    PosY = VRGet( "Window1", "Top" )

    out_file = BeatDirectory"\Beat.ini"

    rc = SysFileDelete(out_file)

    call lineout out_file, ";", 1
    call lineout out_file, "; Beat.ini - Beat Initial File ("Beat2_Version")"
    call lineout out_file, ";"
    call lineout out_file, "PosX="PosX
    call lineout out_file, "PosY="PosY

    call lineout out_file, "PreferencePosX="PreferencePosX
    call lineout out_file, "PreferencePosY="PreferencePosY

    call lineout out_file, "BackColor="BackColor
    call lineout out_file, "ForeColor="ForeColor

    call lineout out_file, "Height="b2_height
    call lineout out_file, "Width="b2_width

    call lineout out_file, "TimeZone="TimeZone

    call lineout out_file, "Interval="Interval
    call lineout out_file, "AlwaysOnTop="AlwaysOnTop
    call lineout out_file, "OnlyBeat="OnlyBeat
    call lineout out_file, "TitleBar="TitleBar
    call lineout out_file, "AutoFontSize="AutoFontSize
    call lineout out_file, "KeepWindowSizeRatio="KeepWindowSizeRatio
    call lineout out_file, "BeatFont="BeatFont
    call lineout out_file, "Font="Font

    call lineout out_file
return

