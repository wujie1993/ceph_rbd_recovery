# ceph_rbd_recovery

#### 介绍

> 该项目的设计目的于在Ceph集群出现灾难性的故障,无法通过现有的手段将集群恢复到正常工作状态时，尽可能完整地恢复重组存储池中的rbd(块设备),rbd分全量和增量两种类型，两者的重组方式稍有不同

#### 环境需求

一台用于恢复块设备文件的linux机器，存储空间尽可能大，因为恢复后的块设备会全量存放在本地

#### 准备

创建一个数据恢复目录,拷贝项目到本地

```
git clone https://github.com/361007018/ceph_rbd_recovery.git
```

首先将所有的osd盘挂载到恢复节点上，如本地目录`/mnt/ceph/osd/ceph-0`,`/mnt/ceph/osd/ceph-1`...

#### 全量块设备

1.执行对象获取脚本
```
sh get_rbd_objects.sh [osd路径] [块设备名称]
```
如
```
sh get_rbd_objects.sh /mnt/ceph/osd/ my_rbd_name
```

> 脚本执行完成后会在当前目录下生成一个以块设备名称命名的目录，目录中会保存所有查找到的块设备对象,并且会输出块设备前缀，需要记录该项用于后续的重组

2.执行重组脚本
```
sh ./build_rbd.sh [块设备名称] [块设备前缀] [对象总数]
```
如
```
sh ./build_rbd.sh my_rbd_name 39222ae8944a 51200
```

重组后的块设备文件存放在`./my_rbd_name/my_rbd_name`,可用`rbd import`命令导入到ceph集群中

> 提示:重组脚本中默认每个对象的大小为4M,如果需要修改请修改脚本中obj_size项。

> 这里的对象总数参数并不是通过对象获取脚本得到的对象总数,而是根据块设备大小(如:200GB),根据该大小除以对象大小得到的对象总数(如:200GB/4M=51200).重组脚本中指定对象总数参数时必须大于或等于计算出的对象总数值,否则很有可能会出现重组时写入对象块偏移地址越界的问题。

> 重组的过程比较耗费时间，需要耐心等待。

#### 增量块设备

> 这里的增量块设备(增量盘)是指在一个全量的块设备(母盘)的基础上做一层只读快照，在通过该只读快照克隆出的块设备。不适用于做了多层快照的场景。

1.获取母盘对象
```
sh get_rbd_objects.sh [osd路径] [母盘块设备名称]
```
如
```
sh get_rbd_objects.sh /mnt/ceph/osd/ parent_rbd_name
```

2.获取增量盘对象
```
sh get_rbd_objects.sh [osd路径] [增量盘块设备名称]
```
如
```
sh get_rbd_objects.sh /mnt/ceph/osd/ my_rbd_name
```

3.重组增量块设备
```
sh ./build_inc_rbd.sh [母盘块设备名称] [母盘块设备前缀] [增量盘块设备名称] [增量盘块设备前缀] [对象总数]
```
如
```
sh ./build_rbd.sh parent_rbd_name 39sdfae8944a my_rbd_name 39222ae8944a 51200
```

重组后的块设备文件存放在`./my_rbd_name/my_rbd_name`,可用`rbd import`命令导入到ceph集群中

#### 参考文档

http://www.sysnote.org/2016/02/28/ceph-rbd-snap/