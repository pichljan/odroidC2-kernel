# Odroid C2 kernel with DVB-T and HW acceleration

This repository contains instructions to compile Linux 3.14 kernel for Odroid C2 with DVB-T drivers and HW acceleration available in Kodi.

## Prerequisites

These instructions are taken from the [official wiki](https://wiki.odroid.com/odroid-c2/software/building_kernel)
You need to install GCC v4.9 because the Odroid C2 Linux kernel compilation cannot be done using 5.x

```
sudo apt-get install gcc-4.9
sudo rm /usr/bin/gcc
sudo ln -s /usr/bin/gcc-4.9 /usr/bin/gcc
```

## Linux

Clone Hardkernel Linux repository
```
git clone --depth 1 https://github.com/hardkernel/linux.git -b odroidc2-3.14.y
cd linux
```
Apply patch which allows you to compile aml video driver as a module (I took this step from [LibreELEC media_build edition](https://github.com/wrxtasy/LibreELEC.tv))
```
patch -p1 < ../odroidC2-kernel/allow_amlvideodri_as_module.patch
```
Apply default Odroid C2 config
```
make odroidc2_defconfig
```
Now modify the config
```
make menuconfig
```
And set the following values (press Y to select, N to remove and M to select it as a module)
```
Device Drivers
   Amlogic Device Drivers
      ION Support
         ION memory management support = Yes
      Amlogic ion video support
         videobuf2-ion video device support = M
         Amlogic ion video devic support = no
      V4L2 Video Support
         Amlogic v4l video device support = M
         Amlogic v4l video2 device support = no
      Amlogic Camera Support
         Amlogic Platform Capture Driver = no
   Multimedia support = M
```
Compile the kernel
```
make -j5 LOCALVERSION=""
```
After the successful compilation, install the modules, kernel and reboot the system
```
sudo make modules_install
sudo cp -f arch/arm64/boot/Image arch/arm64/boot/dts/meson64_odroidc2.dtb /media/boot/
sudo sync
sudo reboot
```

## Media build

Clone media_build repository and try to build it.
```
git clone https://git.linuxtv.org/media_build.git
cd media_build
./build
```
The build command probably fails. Ignore this error and continue with following steps.
Following script is also inspired by [LibreELEC media_build edition](https://github.com/wrxtasy/LibreELEC.tv) and it just includes the video driver into media module.
```
../odroidC2-kernel/add_video_driver_module.sh
```
To avoid potential issues with compilation, try to disable Remote controller support and all the USB adapter you don't need to.
Try to run:
```
make menuconfig
```
It will probably result in an error similar to the following one:
```
./Kconfig:694: syntax error
./Kconfig:693: unknown option "Enable"
./Kconfig:694: unknown option "which"
```
You need to edit the file `v4l/Kconfig` and align with spaces the lines printed in the error. The lines need to be aligned with the previous ones. Then, run the `make menuconfig` again. Probably, you need to do this step multiple times.

If you see a menu instead of the error, you can modify the config in the following way:
```
Remote Controller support = no
Multimedia support
    Media USB Adapters
        ## Disable all driver you don't need ##
```
Apply the folling patch
```
patch -p1 < ../odroidC2-kernel/warning.patch
```
Make the following change to avoid error and compile kernel
```
sed -i 's/#define NEED_PM_RUNTIME_GET 1/\/\/#define NEED_PM_RUNTIME_GET 1/g' v4l/config-compat.h
make -j5 LOCALVERSION=""
```
The LOCALVERSION parameter is only to avoid "+" sign in the name of kernel.
Possibly, you need to run previous step (both sed and make) multiple times before it succeeds.

After the compilation, install the modules and reboot the system
```
sudo make install
sudo reboot
```
The final step is to add `amlvideodri` module into `/etc/modules` to make it load on boot.
```
sudo echo "amlvideodri" >> /etc/modules
```

That's all. You can now enjoy your DVB-T TV and HW accelerated videos in Kodi.

