#!/bin/bash
osd_dir=$1
rbd_name=$2

echo "创建块设备对象保存目录"
mkdir -p ${rbd_name}
echo "Running command:mkdir -p ${rbd_name}"
result=$(eval $cmd)
echo "#####Success#####"

echo "查找块设备id文件"
cmd="find ${osd_dir} -name '*id.${rbd_name}__head*'"
echo "Running command:"$cmd
result=$(eval $cmd)
echo "#####Success#####"

echo "获取块设备前缀"
cmd="cat '$result'"
echo "Running command:"$cmd
result=$(eval $cmd)
echo "#####Success#####"

echo "根据块设备前缀查找对象"
rbd_prefix=${result:1}
cmd="find ${osd_dir} -name '*data.${rbd_prefix}*'"
echo "Running command:"$cmd
result=$(eval $cmd)
echo "#####Success#####"

count=0
# 遍历对象并复制到保存目录中
for file_path in $(ls -1 ${result} 2>/dev/null); do
	file_name=${file_path#*_head/}
	echo "获取文件:"$file_path
	count=$[count+1]
	cp -f $file_path ${rbd_name}"/"${file_name}
done
echo "总共获取${count}个对象"
echo "块设备前缀:${rbd_prefix}"
echo "#####Success#####"

echo "如果是全量块设备,请使用命令:sh ./build_rbd.sh ${rbd_name} ${rbd_prefix} [block_count]进行重组"
