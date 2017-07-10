#!/bin/sh
# 块大小
obj_size=4194304
# 块设备名称
rbd_name="${1}" 
# rbd_name="f0c0df58-43bf-4cd6-9023-82f6a36197e7"
# 块设备前缀
rbd_prefix="${2}"
# rbd_prefix="593f17fdcc233"
# 块设备对象数
rebuild_block_size=${3}
# rebuild_block_size=512
# 块设备大小
rbd_size=$[obj_size*rebuild_block_size]
# rbd_size="2147483648" 
base_files=$(ls -1 ${rbd_name}/*data.${rbd_prefix}.* 2>/dev/null | wc -l | awk '{print $1}')
if [ ${base_files} -lt 1 ]; then
  echo "COULD NOT FIND FILES FOR ${rbd_prefix} IN $(pwd)"
  exit
fi

# 创建一个完整大小的空文件
dd if=/dev/zero of=${rbd_name}/${rbd_name} bs=1 count=0 seek=${rbd_size} 2>/dev/null
for file_name in $(ls -1 ${rbd_name}/*data.${rbd_prefix}.* 2>/dev/null); do
  ver=$(echo $file_name | rev | cut -d "/" -f 1 | rev | cut -d "." -f 3 | cut -d "_" -f 1)
  num=$((16#$ver))
  count=$(ls -l ${file_name} | awk '{ print $5 }')
  echo "dd conv=notrunc if=${file_name} of=${rbd_name}/${rbd_name} seek=$(($obj_size * $num)) bs=1 count=${count} 2>/dev/null"
  dd conv=notrunc if=${file_name} of=${rbd_name}/${rbd_name} seek=$(($obj_size * $num)) count=${count} bs=1 2>/dev/null
done
echo "全量块设备重组完成,文件保存路径${rbd_name}/${rbd_name}"
file ${rbd_name}/${rbd_name}