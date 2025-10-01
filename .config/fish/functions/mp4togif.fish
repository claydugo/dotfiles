# Convert mp4 to gif using ffmpeg and gifski
function mp4togif
    if not type -q ffmpeg; or not type -q gifski
        echo "Error: ffmpeg and gifski are required"
        return 1
    end

    if test (count $argv) -eq 0
        echo "Usage: mp4togif <input.mp4>"
        return 1
    end

    set input_file $argv[1]
    set base_name (basename $input_file .mp4)
    ffmpeg -i $input_file -f yuv4mpegpipe - | gifski -Q 100 --extra -o "$base_name.gif" -
end
