work_dir='/tmp/temporary_workdir'

if [ -f "$work_dir" ] 
then
    echo "$work_dir existed"
    exit -1
fi

mkdir $work_dir

input_video=$1
output_video=$2

echo "input=$1, output=$2"

if [ -f "$2" ]
then
    echo "Output video $2 existed"
        exit -1
fi

cd $work_dir
mkdir "input_video_frames"
echo "Extracting frames from video.."
ffmpeg -i "$1" -r 15 "input_video_frames/output_%04d.png"

echo "Predict frames.."
cd -
flow --imgdir "$work_dir/input_video_frames/" --model cfg/tiny-yolo-voc.cfg --load bin/tiny-yolo-voc.weights

cd $work_dir
echo "Generating output video.."
ls .
ffmpeg -framerate 15 -pattern_type glob -i 'input_video_frames/out/*.png' -c:v libx264 -pix_fmt yuv420p $2
