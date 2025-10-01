# Linux-specific fish configuration

if test (uname -s) = "Linux"
    # OCR screenshot
    alias ocr='flameshot gui -s -r | convert - -colorspace Gray -scale 1191x2000 -unsharp 6.8x2.69+0 -resize 500% png:- | tesseract - - | gxmessage -title "Decoded Data" -fn "Consolas 12" -wrap -geometry 640x480 -file -'
end
