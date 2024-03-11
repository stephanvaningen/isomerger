#!/usr/bin/bash


#
echo
echo ".........."
echo ":"
echo ":  Will mount $current_redhat_iso to 100-images-redhats/mnt ... "
echo ":"


#
source 990-sysincludes/010-ini.sh

#
if sudo mount 100-images-redhats/current 100-images-redhats/mnt; then
	echo 

	echo ":  Will now extract the mounted disk to work-folder $current_relcan_workfolder ... "
	if sudo rm -Rf $current_relcan_workfolder; then
		if mkdir -p $current_relcan_workfolder; then
			if sudo rsync -avh --progress 100-images-redhats/mnt/ $current_relcan_workfolder; then
				echo ":  Done copying all the stuff; now doing some chown/chmod to $current_relcan_workfolder ..."
				echo
				sudo chown -R __loggedonuser__:__loggedonuser__ $current_relcan_workfolder
				sudo chmod -R 755 $current_relcan_workfolder
				success=1
			fi
		fi
	fi
fi

if [ "$success" -eq 1 ]; then
	echo ":) *OK* Finished extracting: $current_redhat_iso ==> $current_relcan_workfolder"
else
	echo ":( Bummer, check errors and try again ..."
fi
if [ "$1" != "--noenter" ]; then
	echo ":  Press ENTER to continue ..."
	read -p ":"
else
	echo ":"
	echo ":"
fi

sudo umount 100-images-redhats/mnt
