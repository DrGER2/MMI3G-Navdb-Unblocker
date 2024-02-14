#!/bin/ksh

# 20230404 drger; Update 1: Remove FSC(s) from /HBpersistence.
# 20221225 drger; New MMI3G NavUnblocker installer script.

# Script startup:
xversion=v240214
showScreen ${SDLIB}/navdbpatch-0.png
touch ${SDPATH}/.started
xlogfile=${SDPATH}/run-$(getTime).log
exec > ${xlogfile} 2>&1
umask 022
echo "[INFO] Start: $(date); Timestamp: $(getTime); MU: $MUVER"

echo; echo "[INFO] MMI3G Nav Database Unblocker: navunblocker-$xversion"

# Exit the script if patch installed previously
if [ -n "$(grep 'acios_db.ini' /usr/bin/manage_cd.sh)" ]
then
  echo; echo "[INFO] MMI3G NavUnblocker patch installed already."
else
  mes=/mnt/efs-system
  mount -uw $mes
  # NavUnblocker patch not installed; look for old mme-becker patch to remove
  if [ -e ${mes}/sbin/mme-becker.sh ]
  then
    if [ -n "$(grep 'acios_db.ini' ${mes}/sbin/mme-becker.sh)" ]
    then
      if [ -e ${mes}/etc/mmelauncher.cfg.pre-navdb.bak ]
      then
        echo; echo "[ACTI] Removing old mme-becker 'activator' patch."
        mv -v ${mes}/etc/mmelauncher.cfg ${mes}/etc/mmelauncher.cfg-TMP
        mv -v ${mes}/etc/mmelauncher.cfg.pre-navdb.bak \
              ${mes}/etc/mmelauncher.cfg
        rm -v ${mes}/etc/mmelauncher.cfg-TMP
        rm -v ${mes}/sbin/mme-becker.sh
      fi
      if [ -e ${mes}/etc/mmelauncher.cfg-ORIG ]
      then
        echo; echo "[ACTI] Removing old mme-becker 'activator' patch."
        mv -v ${mes}/etc/mmelauncher.cfg ${mes}/etc/mmelauncher.cfg-TMP
        mv -v ${mes}/etc/mmelauncher.cfg-ORIG \
              ${mes}/etc/mmelauncher.cfg
        rm -v ${mes}/etc/mmelauncher.cfg-TMP
        rm -v ${mes}/sbin/mme-becker.sh
      fi
    fi
  fi

  # Patch /usr/bin/manage_cd.sh
  echo; echo "[ACTI] Appending patch to /usr/bin/manage_cd.sh ..."
  mv -v ${mes}/usr/bin/manage_cd.sh ${mes}/usr/bin/manage_cd.sh-ORIG
  cp -v ${mes}/usr/bin/manage_cd.sh-ORIG ${mes}/usr/bin/manage_cd.sh
  echo '/usr/apps/bench/TimeLogger "Starting MMI3G NavUnblocker patch"' >> \
    ${mes}/usr/bin/manage_cd.sh
  echo '(waitfor /mnt/lvm/acios_db.ini 180 && sleep 10 && slay vdev-logvolmgr)&' >> \
    ${mes}/usr/bin/manage_cd.sh
  chmod 0777 ${mes}/usr/bin/manage_cd.sh
  touch -r ${mes}/usr/bin/manage_cd.sh-ORIG ${mes}/usr/bin/manage_cd.sh

  mep=/mnt/efs-persist
  mount -uw $mep
  # Copy interesting files to SD card /var dir:
  echo; echo "[ACTI] Copy FSC and acios_db.ini files to $SDVAR"
  cp -v ${mep}/FSC/*.fsc ${SDVAR}/
  cp -v ${mep}/navi/db/acios_db.ini ${SDVAR}/
  mkdir ${SDVAR}/FSCBackup
  cp -v /mnt/efs-extended/FSCBackup/*.fsc ${SDVAR}/FSCBackup/

  # Remove FSC files in /mnt/efs-persist, only, for DTC 03623:
  echo; echo "[ACTI] Remove FSC files from /HBpersistence:"
  rm -v ${mep}/FSC/*.fsc
  [ "$MUVER" = MMI3GP ] && rm -v ${mep}/FSC/cache/*.fsc
fi

# Script cleanup:
echo; echo "[INFO] End: $(date); Timestamp: $(getTime)"
showScreen ${SDLIB}/navdbpatch-1.png
rm -f ${SDPATH}/.started
exit 0
