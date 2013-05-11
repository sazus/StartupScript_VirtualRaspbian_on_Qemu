StartupScript_VirtualRaspbian_on_Qemu
=====================================

* The easy way!! Startup Script Virtual Raspbian on Qemu


** 本スクリプトについて
  QemuでRaspberryPiを実行させるスクリプトです。

** 使い方
	- コマンド
		$ ./raspi-qemu-load.bash
		と実行させるだけです。
	
	- 初回起動時のみ
		QMU起動時の表示にて
		fsck died with exit status 4
		failed (code 4).
		[FAIL] An automatic file system check (fsck) of the root filesystem failed. A manual fsck must be performed, then the system restarted. The fsck should be performed in maintenance mode with the root filesystem mounted in read-only mode. .. failed!
		[warn] The root filesystem is currently mounted in read-only mode. A maintenence shell will now be started. After performing system maintenance, pleass CONTROL-D to terminate the maintenance shell and restart the system. ... (warning).
		sulogin: root account is locked, starting shell
		root@raspberrypi:~#
		
		と出てきますので、QEMU上にて
		root@raspberrypi:~# fsck /dev/sda2
		y		<- input key(ｙを入力する。)
		root@raspberrypi:~# shutdown -r now
		
		と入力してください。
		再起動させるようにしてるけど、再起動してくれないので、
		本スクリプトにて初回時のみQEMU自体を再実行させています。
		
		再起動後にRaspi-configが表示できればOKです。
		
	- コンソールでのlogin
		Raspbianのrfsを使用していますので、defaultの
		user : pi
		password : raspberry
		でlogin可能です。
		
	- SSHでremote login
		Qemu起動時に、HOST(QEMUを起動させているPC)の外部からのSSHポート(10022)を
		Qemuにて起動しているRaspbianの内部のSSHポート(22)へリダイレクトする設定をおこなっていますので、
		
		入力コマンド
		$ ssh -p 10022 pi@localhost
		にて接続可能です。

** 動作確認環境
	Ubuntu 12.04 64bit

** 参考URL
	- [1] QEMU – Emulating Raspberry Pi the easy way (Linux or Windows!
		http://xecdesign.com/qemu-emulating-raspberry-pi-the-easy-way/
		-- 上記URLの手順では、正常に動作しない。
	- [2] Raspberry Piのフォーラム HOWTO: Virtual Raspbian on Qemu in Ubuntu Linux 12.10
		http://www.raspberrypi.org/phpBB3/viewtopic.php?f=29&t=37386
		-- 上記の手順にて動作を確認しています。
