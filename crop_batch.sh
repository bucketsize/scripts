#!/bin/bash 

calc(){ echo "scale=2;$@" | bc;}

#############################
base=/media/cedric/__dont_del
tmp=crop_batch

height=2848
width=4288
c_c=10
c_tw=1200
#############################
c_h=$(calc $height*${c_c}/100)
c_w=$(calc $width*${c_c}/100)
c_height=$(calc $height-$c_h)
c_width=$(calc $width-$c_w)
c_s=$(calc $c_width/$c_tw);
c_scaleh=$(calc $c_height/$c_s)
c_scalew=$(calc $c_width/$c_s)
c_hx=$(calc $c_h/2)
c_wx=$(calc $c_w/2)

echo "${height}x${width} -> ${c_height}x${c_width} / $c_s -> ${c_scaleh}xNN"

home=$pwd

cd $base
files=`find media-wedding-selected/ -name *.JPG`
for i in $files; do
  dirn=`dirname $tmp/$i`
  if [ ! -d $dirn ]; then
    echo "creating fdir: $dirn"
    mkdir -p $dirn
  fi

  i_x=$(identify $i  | cut -d " " -f 3 | cut -d "x" -f 1)
  if [ $i_x -eq $width ]; then
    cmd="convert \
      -crop ${c_width}x${c_height}+${c_wx}+${c_hx} \
      -resize x${c_scaleh} \
      $i \
      ${tmp}/${i}"
  else
    cmd="convert \
      -crop ${c_height}x${c_width}+${c_hx}+${c_wx} \
      -resize x${c_scalew} \
      $i \
      ${tmp}/${i}"
  fi

  #echo "$cmd"
  $cmd
  if [ "$?" -ne "0" ]; then
    echo $i >> ~/crop_batch.log
  fi
done

