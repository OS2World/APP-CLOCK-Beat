/*
 * Packing Program - Beat/2
 *
 */

rc = rxfuncadd( "sysloadfuncs", "rexxutil", "sysloadfuncs")
if rc <> 1 then rc = sysloadfuncs()

say ""
address cmd "@echo off"
say "PACKING... Beat/2"

VRX_file = "window1.vrx"

vmaj = 0
vmin = 0
beta = 0
do until lines(VRX_file) = 0
    line_text=strip(linein(VRX_file),,)
    if left(line_text, length("Beat2_Version")) = "Beat2_Version" then do
        parse var line_text . '= "' ver '"'
        say "Version "ver
        parse var ver vmaj "." vmin " beta " beta
        leave
    end
end
call lineout VRX_file


if beta > 0 then do
    fn  = "b"vmaj""vmin"b"beta".zip"
    fnr = "b"vmaj""vmin"b"beta"r.zip"
    wpi = "b"vmaj""vmin"b"beta"r"
    ver = vmaj"."vmin"."beta
end
else do
    fn  = "beat"vmaj""vmin".zip"
    fnr = "beat"vmaj""vmin"r.zip"
    wpi = "beat"vmaj""vmin"r"
end

say "File Name : "fn "/" fnr
say ""
rc = SysFileDelete(wpi".in")
rc = SysFileDelete(wpi".wis")

say "1.ZIP Files"
address cmd "zip -D" fn  "*.*"
address cmd "zip -D" fnr "beat.exe install.cmd readme_?.htm styles.css upload.hobbes"
say ""

say "2.Copy runtime file to bin"
address cmd "copy" fnr "bin"
say ""

say "3.Unzip new archive in BIN directory"
address cmd "cd bin"
address cmd "unzip -o "left(fnr, length(fnr) - 4)".zip"
address cmd "cd .."

say "4.Create WPI file"
call lineout wpi".in", "install=\PrettyPop\Beat", 1
call lineout wpi".in", "vendor=Pretty Pop Software"
call lineout wpi".in", "application=Beat/2"
call lineout wpi".in", "description=Beat/2, Swatch Beat, Internet Time Indicator"
call lineout wpi".in", "version="ver
call lineout wpi".in", "execute=install.cmd"
call lineout wpi".in"

/*
address cmd "zip2wpi.exe "wpi".zip "wpi".in "wpi".wpi "wpi".wis"
*/
address cmd "zip2wpi.exe "wpi".in"
say ""

say "5.Homepage library directory"
address cmd "copy" fnr         "e:\wwwhome\index\prettypopnet\software\library"
address cmd "copy" wpi".wpi"   "e:\wwwhome\index\prettypopnet\software\library"
address cmd "copy readme_?.htm  e:\wwwhome\index\prettypopnet\software\beat"
address cmd "copy styles.css    e:\wwwhome\index\prettypopnet\software\beat"
address cmd "copy" fn          "e:\wwwhome\index\prettypopnet\library"
say ""

say "6.Copy to Upload directory"
address cmd "copy" fnr "e:\upload"
address cmd "copy" wpi".wpi" "e:\upload"
address cmd "copy upload.hobbes e:\upload\"left(fnr, length(fnr) - 4)".txt"
say ""

say "7.Delete temporary files"
rc = SysFileDelete(wpi".in")
rc = SysFileDelete(wpi".wis")
rc = SysFileDelete(wpi".wpi")
say ""
