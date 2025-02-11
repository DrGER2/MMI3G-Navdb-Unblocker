# MMI3G-Navdb-Unblocker
Patch MMI3G/3GP systems to unblock access to an updated navigation database.

As delivered from the factory, MMI 3G (High) and Plus systems navigation databases are activated with an encoded FSC file stored in /mnt/efs-persist/FSC. This FSC file is specific to the database release as defined in the PKG file of the database.

When an end-user updates the navigation database without first completing the SVM - Activation process with ODIS and generating a new FSC file for
the database release, further access to the navigation database will be blocked by the system. A work-around to unblock access to the navigation
database following an update is to disable the normal activation process by terminating system process vdev-logvolmgr shortly after it starts and
creates regular file /mnt/lvm/acios_db.ini in the QNX filesystem, as described by Keldo in early 2016.

A common approach used by so-called "activator" SD card scripts is to start a background sub-shell at system startup that waits for the
appearance of regular file /mnt/lvm/acios_db.ini and terminates process vdev-logvolmgr after a brief wait. The shell commands for the background
sub-shell are included commonly in a (new) wrapper shell script that starts process mme-becker, as defined in mmelauncher.cfg.

Objections I have to this approach are that (1) it adds a new, unnecessary shell script (mme-becker.sh) to launch the background sub-shell and
then start the actual mme-becker process; and (2) possible variations in mmelauncher.cfg files across generations (High / Plus), platforms, and
regions implies that "sed" must be used to edit the file so that the new wrapper script is called (rather than calling mme-becker, directly). I
believe this approach was used for the work-around because an early method of accessing internet data through the internal WLAN device used
wrapper script mme-becker.sh to force the DHCP client to start on interface uap0 (due to required access to certain HDD mounts not available
earlier in the QNX boot process).

A simpler approach to the nav database unblocking work-around is to add the background sub-shell commands to an existing shell script that is
called by system process srv-starter-QNX as defined by /etc/mmi3g-srv-starter.cfg, since the commands used by the sub-shell are stored in flash
memory and available immediately. Inspection of /etc/mmi3g-srv-starter.cfg shows that shell script /usr/bin/manage_cd.sh is called relatively
early in the boot process on both 3G High and Plus systems. The purpose of the script is to provide interface /dev/shmem/CD0_STARTED.

To install the navigation database unblocker patch, download and extract the ZIP archive file navunblocker-YYMMDD.zip to a full-size FAT32 SD card.  After the MMI system is running fully,
insert the SD card into an available (i.e., empty) SD slot and follow the prompts on the MMI screen.  Inspection of the log file created on the
SD card is recommended (though not required).  *Restart the MMI system for the patch to take effect*.  Since the patch disables the normal navigation database activation process
permanently (or until the ifs-root flash filesystem is re-imaged due to a software update), the patch is not needed following subsequent navigation
database updates.
