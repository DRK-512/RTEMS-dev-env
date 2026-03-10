# RTEMS Environment
This Dockerfile simply is used for my RTEMs development environment<br>
It pulls the latest version of RTEMs and sets up the environment for you to cross-compile for the device<br>
<br>
The content in the include directory are utilized to build RTEMS along with the docker container<br>
Whereas the share directory is a mounted volume for the container, so you can share files between the host and the container through there<br>
A good place to start with example projects can be found [here](https://gitlab.rtems.org/rtems/rtos/rtems-examples.git)

