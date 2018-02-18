#!/bin/bash

kernel_path=/lib/modules/$(uname -r)/build/
cp -a "${kernel_path}/drivers/amlogic/video_dev" "linux/drivers/media/"
sed -i 's,common/,,g; s,"trace/,",g' $(find linux/drivers/media/video_dev/ -type f)
sed -i 's,\$(CONFIG_V4L_AMLOGIC_VIDEO),m,g' "linux/drivers/media/video_dev/Makefile"
cat linux/drivers/media/Makefile | grep "obj-y += video_dev/" || echo "obj-y += video_dev/" >> "linux/drivers/media/Makefile"

cp -a "${kernel_path}/drivers/media/v4l2-core/videobuf-res.c" "linux/drivers/media/v4l2-core/"
cp -a "${kernel_path}/include/media/videobuf-res.h" "linux/include/media/"
cat linux/drivers/media/v4l2-core/Makefile | grep "obj-m += videobuf-res.o" || echo "obj-m += videobuf-res.o" >> "linux/drivers/media/v4l2-core/Makefile"
