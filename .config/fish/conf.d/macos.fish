# macOS-specific fish configuration

if test (uname -s) = "Darwin"
    # Lock screen (afk)
    function afk
        /System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend
    end
end
