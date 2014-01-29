##########################
# Как собрать образ linux.
##########################
  1. создать проект в среде Xilinx XPS
  2. экспортировать прокет Xilinx XPS ->  Xilinx SDK. в каталог ../test/uclinux/ml505/system_big/sdk/
  3. device-tree
     1) git clone https://github.com/Xilinx/device-tree.git
     2) copy to ../test/uclinux/ml505/system_big/sdk/xilinx_bsp
  4. U-BOOT
     1) download  http://www.wiki.xilinx.com/file/view/uboot_bsp.tar.gz/421818190/uboot_bsp.tar.gz
     2) copy to ../test/uclinux/ml505/system_big/sdk/xilinx_bsp
  5. В среде Xilinx SDK /File/New/Board Support Package
     для linux (device-tree) + для u-boot

  6. Запустить виртуальную машину.
  7. cd ~/work/uclinux/xilinx/too/linux-xlnx
  8. установить переменную CROSS_COMPILE:
     > export CROSS_COMPILE=~/work/..path../microblaze-gnu/binsries/lin64-microblaze-unknow-linux-gnu_xxx/bin/microbalze-unknow-linux-gnu-

    (plb bus) microblaze littel endian: lin64-microblazeel-unknow-linux-...
    (axi bus) microblaze big endian: lin64-microblaze-unknow-linux-...

  9. скопировать PC(work) -> VirtuabBox:
     d:\Work\Linkos\test\uclinux\ml505\system_big\image\.config  -> ~/work/uclinux/tool/linux-xlnx
     d:\Work\Linkos\test\uclinux\ml505\system_big\image\xilinx.dts  -> ~/work/uclinux/tool/linux-xlnx/arch/microblaze/boot/dts

  10. Linux Kernel compile
     1. cd ~/work/uclinux/xilinx/tool/linux-xlnx
     2. make ARCH=microblaze simpleImage.xilinx или make ARCH=microblaze menuconfig (для настройки ядра linux)
       (make ARCH=<architecture> (menu|x|n)config)

  11. скопировать VirtuabBox -> PC(work):
     ~/work/uclinux/tool/linux-xlnx/arch/microblaze/boot/simpleImage.xilinx -> d:\Work\Linkos\test\uclinux\ml505\system_big\image

  12. Xilinx SDK: Xilinx Tools/Program FPGA (bootloader)

  13. Xilinx SDK: Xilinx Tools/XDM console

  14. Запустить программу терминал (нпр. Tera Term (Serial Port: 115200))

  15. XDM% connect mb mdm
  16. XDM% dow d:/Work/Linkos/test/uclinux/ml505/system_big/image/simpleImage.xilinx
  17. XDM% run (для запуска загрузки linux)
  18. XDM% stop (для остановки microblaze)

##########################
# Linux users:
##########################
  root (password: linkos)
  user (password: linkos)

##########################
# MTD - работа с flash
##########################
  >войти в систему под root
  > cat /proc/mtd  (просмотр на какие разделы разбита flash)
  MTD commands:
  > flash_eraseall /dev/mtd0 (стирание соотв. раздела)

##########################
# Подключение сетевых шар:
##########################
  samba:
  > mkdir -p /mnt/smb
  > mount -t cifs //10.1.7.125/Change -o username=guest /mnt/smb

##########################
# U-BOOT
##########################
http://www.denx.de/wiki/U-Boot/WebHome
http://www.monstr.eu/wiki/doku.php?id=uboot:uboot

Rules:
FLASH base address must be higher than main memory - BSP takes care about

                       ----------------       ----------------
                      | FLASH:         |     | RAM:           |
                       ----------------       ----------------
                      |(FPGA firmware) |     |(Linux)         |
                      |                |     |                |
                       ----------------      |                |
                      |(Linux)         |---->|                |
                      |                |     |                |
----------------       ----------------       ----------------
FPGA(BRAM):     |     |(U-BOOT)        |     |(U-BOOT)        |
SREC_bootloader |---->|                |---->|                |
----------------       ----------------       ----------------

1. BRAM(SREC_bootloader) загружает из FLASH U-BOOT
2. U-BOOT загружает из FLASH Linux

Как создать/использовать SREC_bootloader:
http://macgyverque.net/2013/10/09/xilinx-sp606-fpga-microblaze-bootloader-generation/
http://www.xilinx.com/support/answers/43615.htm

1. Xilinx SDK/File/New/Application Project   и после выбираем из списка примеров SREC Bootloader
2. Into  blconfig.h  корректируем  #define FLASH_IMAGE_BASEADDR 0x....

   FLASH_IMAGE_BASEADDR - адреса FLASH где размещена выполняемая программ (в нашем случае U-BOOT (elf))

  (Into  bootloader.c !!!!
    /* Comment the following line, if you want a smaller and faster bootloader which will be silent */
    #define VERBOSE  )

3. Прошиваем в FPGA(BRAM) программу SREC_bootloader.elf:  Xilinx SDK/Xilinx Tool/Programm FPGA
4. Прошиваем в FLASH программу U-BOOT:   Xilinx SDK/Xilinx Tool/Program Flash Memory
   (Convert elf to bootloadable SREC format and program  - set enable)
   и
   выбирам скомпилированую программу U-BOOT.
   Как получить скомпилированую программу U-BOOT для microblaze описано здесь:
   http://www.wiki.xilinx.com/Build+U-Boot#MicroBlaze
   1.Building U-Boot
      First, download the U-Boot BSP source  http://www.wiki.xilinx.com/file/view/uboot_bsp.tar.gz/421818190/uboot_bsp.tar.gz
      Once it has been installed and the project has been exported to SDK,
      the U-Boot BSP can be created for the system.

      Once the U-Boot BSP has been compiled in SDK,
      the generated files, config.mk and xparameters.h,
      can be found at <sdk_workspace>/uboot_bsp_0/microblaze_0/libsrc/uboot_v*/ .

    2. Downloading the source tree git clone git://github.com/Xilinx/u-boot-xlnx.git
    3. Compiling U-Boot
       The U-Boot compilation will use the definitions
       and flags defined in config.mk and xparameters.h .
       Import these two files generated by the U-Boot BSP in SDK into
       the U-Boot directory for MicroBlaze located at <u-boot-xlnx>/board/xilinx/microblaze-generic/ .

       Xilinx's MicroBlaze GNU toolchain will be used to cross-compile U-Boot for MicroBlaze.
       (т.е. дожен быть определн компилятор для microbalze: export CROSS_COMPILE=~/....)

       Now that U-Boot and the toolchain are configured correctly, we can cross-compile U-Boot:
       linux-host> cd <u-boot-xlnx>
       linux-host> export BUILD_DIR=$PWD/build
       linux-host> make microblaze-generic_config
       linux-host> make

     4. Loading and running U-Boot
        Once the bitstream containing at least a minimally
        configured hardware system has been downloaded to the FPGA,
        XMD is used to download the cross-compiled U-Boot to the MicroBlaze soft processor:

        XMD> connect mb mdm
        XMD> dow <u-boot-xlnlx>/build/u-boot
        XMD> run




##########################
# XILINX.dts
##########################
  @) аргуманы строки bootargs (http://www.monstr.eu/wiki/doku.php?id=fdt:fdt)
 ------------------------------------------------------------------------------------------------------------------
|Rootfs on SystemACE                  | root=/dev/xsa2                                                             |
|-------------------------------------|----------------------------------------------------------------------------|
|NFS rootfs                           | root=/dev/nfs rw nfsroot=192.168.0.102:/tftpboot/rootnfs                   |
|-------------------------------------|----------------------------------------------------------------------------|
|Console on uart16550 or old uartlite | console=ttyS0,115200                                                       |
|-------------------------------------|----------------------------------------------------------------------------|
|Console on uarlite                   | console=ttyUL0,115200                                                      |
|-------------------------------------|----------------------------------------------------------------------------|
|Turn off console                     | silent=off                                                                 |
|-------------------------------------|----------------------------------------------------------------------------|
|Single user mode                     | single                                                                     |
|-------------------------------------|----------------------------------------------------------------------------|
|tmpfs as root                        | devfs=mount rw rootfstype=tmpfs root=/dev/ram                              |
|-------------------------------------|----------------------------------------------------------------------------|
|setup ipaddr by dhcp                 | ip=dhcp                                                                    |
|-------------------------------------|----------------------------------------------------------------------------|
|setup static ipaddr                  |ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf> |
|                                     |----------------------------------------------------------------------------|
|                                     |ip=192.168.10.2:192.168.10.1:192.168.10.1:255.255.255.0:test:eth0:on        |
 -----------------------------------------------------------------------------------------------------------------

 example :
 bootargs = "console=ttyUL0,115200 highres=on ip=dhcp root=/dev/nfs rw nfsroot=192.168.0.102:/tftpboot/rootnommu";

 others info:
 http://www.tldp.org/HOWTO/BootPrompt-HOWTO-3.html

##########################
# linux команды:
##########################
  @) - Если в терминале выдается абра-кодабра, то можно набрать на клавиатуре reset и тогда шрифт должен востановиться

  @) делаем файл(ы) исполняемым:
    chmod +x имя_файла( или * - все файлы в каталоге)

  @) делаем файл(ы) не исполняемым:
    chmod -x имя_файла( или * - все файлы в каталоге)

  @) sudo /sbin/lspci   -- использование команды если работаю под логином пользователя

  @) df -h  --вывод информации о свободном/занятом месте на дисках



##########################
# linux dev
##########################

  @) i2c - EEPROM
    *) I2C EEPROM Driver Kernel Configuration:
    There are higher layer drivers that allow the I2C driver
    to be used to access other devices such as the I2C serial EEPROM on the ML507 board.
    The following steps may be used to enable the driver in the kernel configuration.
    From the device drivers menu, select Misc devices

    -- Select EEPROM Support
    -- Select I2C EEPROMs from most vendors

    *) Adding An I2C EEPROM To The Device Tree

    The following example shows adding the I2C EEPROM for the ML507 to it's device tree.
    The value of 0x050 is the I2C address of the EEPROM.

    The device-tree generator for the EDK does not create this device on the I2C bus.

    IIC: i2c@81600000 {
        compatible = "xlnx,xps-iic-2.00.a";
        interrupt-parent = <&xps_intc_0>;
        interrupts = < 6 2 >;
        reg = < 0x81600000 0x10000 >;
        xlnx,clk-freq = <0x5f5e100>;
        xlnx,family = "virtex5";
        xlnx,gpo-width = <0x1>;
        xlnx,iic-freq = <0x186a0>;
        xlnx,scl-inertial-delay = <0x0>;
        xlnx,sda-inertial-delay = <0x0>;
        xlnx,ten-bit-adr = <0x0>;

        #address-cells = <1>;
        #size-cells = <0>;

        m24c08@50 {
            compatible = "at,24c08";
            reg = <0x50>;
        };
    } ;

    *) testing
      The EEPROM driver allows the contents of the EEPROM
      to be seen in the sys file system at /sys/bus/i2c/devices/0-0050/eeprom.
      The file, eeprom, is a file that can be read and written from user space.

      If the sys file system is not mounted (no /sys dir),
      then the following commands will create and mount it.

      bash>mkdir /sys
      bash>mount - t sysfs sysfs sys

      The following shell commands can view the contents
      of the eeprom by 1st capturing it and then displaying the file as binary data.

      bash>more /sys/bus/i2c/devices/0-0050/eeprom > eeprom.txt | od -x

      The following command will write "01234567890DEADBEEFCAFE" to the EEPROM.
      Be careful as the ethernet MAC address is in the EEPROM and can be overwritten.

      bash>echo 0123456789DEADBEEFCAFE > /sys/bus/i2c/devices/0-0050/eeprom


