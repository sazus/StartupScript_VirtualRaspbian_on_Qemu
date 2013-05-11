#!/bin/bash

#
# Raspberry pi のQEMU load Scropt
#

# QEMUで使用するkernel Image
KERNEL_IMAGE="kernel-qemu"
QEMU_SYSTEM_ARM="/usr/bin/qemu-system-arm"
#QEMU_SYSTEM_ARM="/opt/DeveloperTool/Qt/raspberry-pi/qemu-linaro/arm-softmmu/qemu-system-arm"

# QEMUで使用するroot file system
RASPBIAN="2013-02-09-wheezy-raspbian"
RASPBIAN_GET_HTTP="http://ftp.snt.utwente.nl/pub/software/rpi/images/raspbian/${RASPBIAN}/${RASPBIAN}.zip"
RASPBIAN_IMAGE="${RASPBIAN}.img"

#	QEMU – Emulating Raspberry Pi the easy way (Linux or Windows!
#		http://xecdesign.com/qemu-emulating-raspberry-pi-the-easy-way/
#	の手順では、正常に動作しなかったので
#	Raspberry Piのフォーラム HOWTO: Virtual Raspbian on Qemu in Ubuntu Linux 12.10
#		http://www.raspberrypi.org/phpBB3/viewtopic.php?f=29&t=37386
#	の手順で一部コメントアウトするfile
FILE_LD_SO_PRELOAD="ld.so.preload"
SED_CHECK_STRING_LD_SO_PRELOAD="\/usr\/lib\/arm-linux-gnueabihf\/libcofi_rpi.so"
CHECK_FIRST_BOOT=""

# error number define
ERROR_KERNEL_IMAGE=1
ERROR_RASPBIAN_IMAGE=2


# Error 処理
#	読み出し先にて error ${error number define} ${LINENO}
error(){
	ERROR_NUM="ERROR($1 : $2)"
	case "$1" in
		${ERROR_KERNEL_IMAGE}) echo "${ERROR_NUM} Not Found kernel-qemu image"
		;;
		${ERROR_RASPBIAN_IMAGE}) echo "${ERROR_NUM} get Raspbian wheezy image"
		;;
		*) echo "${ERROR_NUM} Unknown error"
	    ;;
	esac
	exit -1
}


# QEMU用のkernelのimageの取得
chk_kernel_image() {
	# wgetコマンドのinstall確認
	if [ ! -e /usr/bin/wget ]; then
		sudo apt-get install wget
	fi
	
	# kernel imageの取得
	if [ ! -e ./${KERNEL_IMAGE} ]; then
		echo "get qemu kernel image"
		wget http://xecdesign.com/downloads/linux-qemu/kernel-qemu || error ${ERROR_KERNEL_IMAGE} #${LINENO}
	fi
	
	# ARM 用のQEMU install 状況確認
	if [ ! -e ${QEMU_SYSTEM_ARM} ]; then
		echo "install qemu(arm)"
		sudo apt-get install qemu-kvm qemu-kvm-extras
	fi
	
	# RASPBIAN imageのチェック
	if [ ! -e ${RASPBIAN_IMAGE} ]; then
		echo "get raspbian image"
		wget ${RASPBIAN_GET_HTTP} || error ${ERROR_RASPBIAN_IMAGE} ${LINENO}
		unzip $RASPBIAN.zip || error ${ERROR_RASPBIAN_IMAGE} ${LINENO}
	fi
}


# QEMU にてRaspbian imageを起動させる為の前処理
before_raspbian_image_Setting(){
	# 下記urlを参考にして、起動させる為に前処理を入れておく。
	#	http://www.raspberrypi.org/phpBB3/viewtopic.php?t=37386&p=313716
	#	ここでは、ld.so.preloadの中身をコメント化するだけ。
	#	起動後、
	# # fsck /dev/sda2
	# # shutdown -r now
	# は、自前で行なって、再度このスクリプトを実行させれば問題なく起動できるはず。
	if [ ! -e .stamp_before_raspbian_image_setting ]; then
		touch .stamp_before_raspbian_image_setting
		echo "raspbianをQEMUで起動させるした処理をします。一時的にsudoにて処理するのでpasswordをいれてください。"
		sudo mount ${RASPBIAN_IMAGE} -o offset=62914560 /mnt
		sleep 1s
		
		# コメントアウトを追加する。
		sudo sed -i "1s/^/\#/" /mnt/etc/${FILE_LD_SO_PRELOAD}
		sudo umount /mnt
		sleep 1s
		
		CHECK_FIRST_BOOT=1
	fi
}


# QEMUでのRaspbian imageの起動
boot_raspbian_image() {
	# PCの外部からのSSHポート(10022)をraspberrypiの内部のSSHポートへリダイレクトするようにしておく。
	#	format : -redir tcp:10022::22
	# キーボードは、日本語109
	#	-k jp
	echo "Booting ...Raspbian on Qemu"
	echo "kernel: ${KERNEL_IMAGE}\nrfs(Rsspbian):${RASPBIAN_IMAGE}"
	$QEMU_SYSTEM_ARM -kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append "root=/dev/sda2 panic=1" -hda ${RASPBIAN_IMAGE} -k ja -redir tcp:10022::22
	# 初回時のみQEMUの再起動
	if [ ${CHECK_FIRST_BOOT} ]; then
		echo "Reboot Qemu ...."
		$QEMU_SYSTEM_ARM -kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append "root=/dev/sda2 panic=1" -hda ${RASPBIAN_IMAGE} -k ja -redir tcp:10022::22
	fi

	echo "shutdown Qemu"
}

# Shell Script Start
chk_kernel_image
before_raspbian_image_Setting
boot_raspbian_image

exit
