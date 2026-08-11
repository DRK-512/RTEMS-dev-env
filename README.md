# RTEMS Environment
This Dockerfile simply is used for my RTEMs development environment<br>
It pulls the latest version of RTEMs and sets up the environment for you to cross-compile for the device<br>
<br>
The content in the include directory are utilized to build RTEMS along with the docker container<br>
Whereas the share directory is a mounted volume for the container, so you can share files between the host and the container through there<br>
A good place to start with example projects can be found [here](https://gitlab.rtems.org/rtems/rtos/rtems-examples.git)

# Building
./waf configure --prefix=$RTEMS_PREFIX
./waf 

touch uEnv.txt
vim uEnv.txt 

## Generate rtems-app.img
arm-rtems6-objcopy   ./build/arm-rtems6-beagleboneblack/hello.exe   -O binary app.bin
gzip -9 -f app.bin
mkimage   -A arm   -O linux   -T kernel   -a 0x80000000   -e 0x80000000   -n RTEMS   -d app.bin.gz   rtems-app.img

#### am335 is provided by dockerfile in /opt/

SD card 
First 512M: 
rtems-app.img
am335x-boneblack.dtb
uEnv.txt

Rest empty, or ext4, it does not matter we will never use it
