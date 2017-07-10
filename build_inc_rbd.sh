#!/bin/sh
# 块大小
obj_size=4194304
# 母盘块设备名称
parent_rbd_name="${1}" 
# 母盘块设备前缀
parent_rbd_prefix="${2}"
# 块设备名称
rbd_name="${3}"
# 母盘块设备前缀
rbd_prefix="${4}"
# 块设备对象总数
rebuild_block_size=${5}
# 块设备大小
rbd_size=$[obj_size*rebuild_block_size]

base_files=$(ls -1 ${parent_rbd_name}/*data.${parent_rbd_prefix}.* 2>/dev/null | wc -l | awk '{print $1}')
if [ ${base_files} -lt 1 ]; then
  echo "找不到母盘块设备对象文件"
  exit
fi
dd if=/dev/zero of=${rbd_name}/${rbd_name} bs=1 count=0 seek=${rbd_size} 2>/dev/null
for file_name in $(ls -1 ${parent_rbd_name}/*data.${parent_rbd_prefix}.* 2>/dev/null); do
  ver=$(echo $file_name | rev | cut -d "/" -f 1 | rev | cut -d "." -f 3 | cut -d "_" -f 1)
  num=$((16#$ver))
  count=$(ls -l ${file_name} | awk '{ print $5 }')
  echo "dd conv=notrunc if=${file_name} of=${rbd_name}/${rbd_name} seek=$(($obj_size * $num)) bs=1 count=${count} 2>/dev/null"
  dd conv=notrunc if=${file_name} of=${rbd_name}/${rbd_name} seek=$(($obj_size * $num)) bs=1 count=${count} 2>/dev/null
done

base_files=$(ls -1 ${rbd_name}/*data.${rbd_prefix}.* 2>/dev/null | wc -l | awk '{print $1}')
if [ ${base_files} -lt 1 ]; then
  echo "找不到块设备对象文件"
  exit
fi
for file_name in $(ls -1 ${rbd_name}/*data.${rbd_prefix}.* 2>/dev/null); do
  ver=$(echo $file_name | rev | cut -d "/" -f 1 | rev | cut -d "." -f 3 | cut -d "_" -f 1)
  num=$((16#$ver))
  count=$(ls -l ${file_name} | awk '{ print $5 }')
  echo "dd conv=notrunc if=${file_name} of=${rbd_name}/${rbd_name} seek=$(($obj_size * $num)) bs=1 count=${count} 2>/dev/null"
  dd conv=notrunc if=${file_name} of=${rbd_name}/${rbd_name} seek=$(($obj_size * $num)) bs=1 count=${count} 2>/dev/null
done
echo "增量块设备重组完成,文件保存路径${rbd_name}/${rbd_name}"
file ${rbd_name}/${rbd_name}