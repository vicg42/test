@ Как собрать образ linux.
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
  7. cd ~/work/uclinux/xilinx/too/linux-xil
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

  11. скопировать VirtuabBox -> PC(work):
     ~/work/uclinux/tool/linux-xlnx/arch/microblaze/boot/simpleImage.xilinx -> d:\Work\Linkos\test\uclinux\ml505\system_big\image

  12. Xilinx SDK: Xilinx Tools/Program FPGA (bootloader)

  13. Xilinx SDK: Xilinx Tools/XDM console

  14. Запустить программу терминал (нпр. Tera Term (Serial Port: 115200))

  15. XDM% connect mb
  16. XDM% dow d:/Work/Linkos/test/uclinux/ml505/system_big/image/simpleImage.xilinx.unstrip
  17. XDM% run (для запуска загрузки linux)
  18. XDM% stop (для остановки microblaze)



@ -  XILINX.dts
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

@ - linux команды:
  @) - Если в терминале выдается абра-кодабра, то можно набрать на клавиатуре reset и тогда шрифт должен востановиться

  @) делаем файл(ы) исполняемым:
    chmod +x имя_файла( или * - все файлы в каталоге)

  @) делаем файл(ы) не исполняемым:
    chmod -x имя_файла( или * - все файлы в каталоге)

  @) sudo /sbin/lspci   -- использование команды если работаю под логином пользователя

  @) df -h  --вывод информации о свободном/занятом месте на дисках



@ - linux dev

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


