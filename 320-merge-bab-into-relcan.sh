#!/usr/bin/bash


#
source 990-sysincludes/010-ini.sh
grub_label=$(grep "search --no-floppy --set=root -l" "${current_relcan_workfolder}/EFI/BOOT/grub.cfg" | sed "s/.*-l '\(.*\)'/\1/")


#
echo
echo ".........."
echo ":"
echo ":  Will use label $grub_label for the hd:.../.ks in grub.cfg/isolinux.cfg (and maybe for inst.repo-info in install.ks)"
echo ":  Will merge build and bundle objects from $current_bab_workfolder into $current_relcan_workfolder"
echo ":"


# --- Copy objects from abstract 120-builds-and-bundles to the workfolder:
echo ":  Copy install.ks ..."
if ! cp "${current_bab_workfolder}/install.ks" "${current_relcan_workfolder}"; then
	die ":( Error copying install.ks to the root of the image" 101
fi
echo ":  Copy all of /install/ ..."
if ! rsync -avh --progress "${current_bab_workfolder}/install" "${current_relcan_workfolder}"; then
	die ":( Error rsyncing install to the root of the image" 103
fi
echo ":  Copy vdab splash screen ..."
if ! cp "540-custom-objects/vdab-isolinux-splash.png" "${current_relcan_workfolder}/isolinux/splash.png"; then
	die ":( Error copying vdab splash screen to the isolinux directory of the image" 104
fi
if ! cp "540-custom-objects/vdab-isolinux-splash.png" "${current_relcan_workfolder}/EFI/BOOT/splash.png"; then
	die ":( Error copying vdab splash screen to the EFI/BOOT directory of the image" 105
fi


# --- Substitute variable tags %x% with variable names ${x}
#     For:
#		%grub_label%			${grub_label}
#		%current_build%			${current_build}
#       %current_rhel_version%	${current_rhel_version}

# /install.ks
echo ":  Replace variables like %grub_label% ..."
if ! sed -i "s/%grub_label%/${grub_label}/g" "${current_relcan_workfolder}/install.ks"; then
	die ":( Error setting the current grub_label into ${current_relcan_workfolder}/install.ks" 106
fi
if ! sed -i "s/%current_build%/${current_build}/g" "${current_relcan_workfolder}/install.ks"; then
	die ":( Error setting the current_build version into ${current_relcan_workfolder}/install.ks" 106
fi
if ! sed -i "s/%current_rhel_version%/${current_rhel_version}/g" "${current_relcan_workfolder}/install.ks"; then
	die ":( Error setting the current_rhel_version into ${current_relcan_workfolder}/install.ks" 106
fi
# /install/install.sh
echo ":  Replace variables like %build_version% ..."
if ! sed -i "s/%grub_label%/${grub_label}/g" "${current_relcan_workfolder}/install/install.sh"; then
	die ":( Error setting the current grub_label into ${current_relcan_workfolder}/install/install.sh" 106
fi
if ! sed -i "s/%current_build%/${current_build}/g" "${current_relcan_workfolder}/install/install.sh"; then
	die ":( Error setting the current_build version into ${current_relcan_workfolder}/install/install.sh" 106
fi
if ! sed -i "s/%current_rhel_version%/${current_rhel_version}/g" "${current_relcan_workfolder}/install/install.sh"; then
	die ":( Error setting the current_rhel_version into ${current_relcan_workfolder}/install/install.sh" 106
fi


# --- Changes in /EFI/BOOT/grub.cfg
efi_config_file="${current_relcan_workfolder}/EFI/BOOT/grub.cfg"
# set default="0"
echo ":  replace set default="1" with set default="0" in EFI/BOOT/grub.cfg"
if ! sed -i "s/set default=\"1\"/set default=\"0\"/g" "${efi_config_file}"; then
	die ":( Error setting the default grub menu option from 1 to 0 in ${efi_config_file}" 107
fi
# set timeout=
new_timeout="set timeout=5"
echo ":  set timeout=5 in EFI/BOOT/grub.cfg"
if ! sed -i "s/set timeout=.*/${new_timeout}/" "${efi_config_file}"; then
	die ":( Error setting timeout in ${efi_config_file}" 108
fi
# Add splash after $new_timeout
echo ":  set splash in EFI/BOOT/grub.cfg"
a_temporary_file="$(mktemp)"
cp "${efi_config_file}" "${a_temporary_file}" # Yes, this is counter-intuïtive, isn't it? It is.
if ! awk \
		"/${new_timeout}/ { print; print \"insmod png\"; print \"set GRUB_BACKGROUND=\\\"splash.png\\\"\"; next }1" \
		"${a_temporary_file}" > \
		"${efi_config_file}"; then
	die ":( Error adding splash to ${efi_config_file}" 109
fi
rm "${a_temporary_file}"
# Add /install.ks
#todo: still appending to too many lines...
echo ":  Add inst.ks=hd:LABEL=${grub_label}:/install.ks into EFI/BOOT/grub.cfg"
if ! sed -i "/linuxefi/s/$/ inst.ks=hd:LABEL=${grub_label}:\/install.ks/" "${efi_config_file}"; then
	die ":( Error adding 'inst.ks...install.ks' to ${efi_config_file}" 110
fi
# Add inst.repo
#echo ":  Add inst.repo=hd:LABEL=${grub_label} into EFI/BOOT/grub.cfg"
#if ! sed -i "/linuxefi/s/$/ inst.repo=hd:LABEL=${grub_label}:\//" "${efi_config_file}"; then
#	die ":( Error adding 'inst.repo' to ${efi_config_file}" 110
#fi
# Add build-number to menu entries:
echo ":  Add '${current_build}' to menu entries of EFI/BOOT/grub.cfg"
a_temporary_file="$(mktemp)"
awk -v build="Using ${current_build}: " '/^menuentry/ {sub(/'\''/, "&" build, $2)} 1' "${efi_config_file}" > "${a_temporary_file}"
mv "$a_temporary_file" "$efi_config_file"


# --- Changes in /isolinux/isolinux.cfg
isolinux_config_file="${current_relcan_workfolder}/isolinux/isolinux.cfg"
# Add /install.ks
#todo: still appending to too many lines...
echo ":  Add inst.ks=hd:LABEL=${grub_label}:/install.ks into isolinux/isolinux.cfg"
if ! sed -i "/append initrd=initrd.img/s/$/ inst.ks=hd:LABEL=${grub_label}:\/install.ks/" "${isolinux_config_file}"; then
	die ":( Error adding 'inst.ks...install.ks' to isolinux.cfg.cfg in isolinux of $current_relcan_workfolder/isolinux" 111
fi
# Add /install.ks
#echo ":  Add inst.repo=hd:LABEL=${grub_label} into isolinux/isolinux.cfg"
#if ! sed -i "/append initrd=initrd.img/s/$/ inst.repo=hd:LABEL=${grub_label}:\//" "${isolinux_config_file}"; then
#	die ":( Error adding 'inst.repo' to isolinux.cfg.cfg in isolinux of $current_relcan_workfolder/isolinux" 111
#fi
# Add build-number to menu title:
echo ":  Add '${current_build}' to menu title of isolinux.cfg"
sed -i "/^[[:space:]]*menu title/ s/$/ ${current_build}/" "${isolinux_config_file}"


echo ":) Done: merged ${current_bab_workfolder} ==> $current_relcan_workfolder"
echo ":  *OK* All looks ok so far" 0
if [ "$1" != "--noenter" ]; then
	echo ":  Press ENTER to continue,"
	read -p ":"
else
	echo ":"
	echo ":"
fi
