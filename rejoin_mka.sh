#!/bin/bash
while getopts ":f:" optname
  do
    case "$optname" in
        "f")
        folder="$OPTARG"
        ;;
      "?")
        echo "Unknown option $OPTARG"
	exit 1
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit 1
        ;;
      *)
        echo "Unknown error while processing options"
        exit 1
        ;;
    esac
  done
unset IFS
folder=$(readlink -f "$folder")
if [ ! -d "$folder" ]; then
    echo "Folder not found!"
    exit 0
fi

command=$(which mkvmerge)
workdir=$(eval echo ~$USER/tmp/)

if [ ! -d "$workdir" ]; then
  mkdir -p "$workdir"
fi

function ctrl_c() {
        echo "** Trapped CTRL-C"
}

trap ctrl_c INT
IFS=$'\n'
declare -a directories
directories=( $(find "$folder" -type f -iname '*.m4a' -exec dirname {} \; |uniq) )
for i in "${directories[@]}"; do
   declare -a playlist
   declare -a restlist
   fp=$(readlink -f $i)
   curdir=${fp##*/}
   dstfile="${curdir}.mka"
   playlist=( $(find "$fp" -iname '*.m4a' -exec readlink -f {} \; | sort) )
   first="${playlist[0]}"
   unset playlist[0]
   counter=0
	for j in "${!playlist[@]}"; do
		restlist[counter]="${playlist[j]}"
		let counter=counter+1
	done
   echo "Creating ${dstfile}"
   $command -q -o ${workdir}/${dstfile} -a 0 -D -S -T --no-global-tags --no-chapters "$first" --no-chapters "${restlist[@]/#/+}" --clusters-in-meta-seek
   mv "${workdir}/${dstfile}" "$fp"
   unset playlist
   unset restlist
done
