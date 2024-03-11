#!/usr/bin/bash
# Make sure syslinux is installed (yum, apt, ...)


#
source 990-sysincludes/010-ini.sh
target_block_device="/dev/sdb"
if ! grub_label=$(grep "search --no-floppy --set=root -l" "${current_relcan_workfolder}/EFI/BOOT/grub.cfg" | sed "s/.*-l '\(.*\)'/\1/"); then
	die ":( Could not fetch defined label in /EFI/BOOT/grub.cfg" 997
fi


#
echo
echo ".........."
echo ":"
echo ":  Will build image110-images-relcans/${current_relcan_basename}.iso"
echo ":       write USB ${target_block_device}"
echo ":"


#
echo ":  About to fetch Volume id from the original ISO ($current_redhat_iso)"
if ! original_volume_id=$(isoinfo -d -i 100-images-redhats/current | grep 'Volume id' | awk '{print $3}'); then
	die ":( Could not fetch Volume id" 998
fi
echo ":  GRUB-label is ${grub_label}"
echo ":  .ISO-label is ${original_volume_id}"
if [ "$grub_label" != "$original_volume_id" ]; then
  die ":( *ANALYSE* There is an inconsistency; probably the 'current'-symlinks are changed somewhere between running 310* and 390* ..." 999
fi
echo ":  Ready to export to .iso and USB ..."

#
echo ":  About to build 110-images-relcans/$current_relcan_basename.iso with Volume id '$original_volume_id'"
rm -f "110-images-relcans/${current_relcan_basename}.iso"
if ! sudo xorriso -as mkisofs \
			-iso-level 3 \
			-full-iso9660-filenames \
			-volid "$original_volume_id" \
			-eltorito-boot isolinux/isolinux.bin \
			-eltorito-catalog isolinux/boot.cat \
			-no-emul-boot -boot-load-size 4 -boot-info-table \
			-isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
			-eltorito-alt-boot \
			-e images/efiboot.img \
			-no-emul-boot \
			-isohybrid-gpt-basdat \
			-output "110-images-relcans/${current_relcan_basename}.iso" \
			"$current_relcan_workfolder"; then
	die ":( Could not create .iso using $iso_tool" 201
fi
sudo chown stephan:stephan "110-images-relcans/${current_relcan_basename}.iso"

#
read -p ":  About to write 110-images-relcans/$current_relcan_basename.iso to ${target_block_device}. Press ^C to abort, or press ENTER to continue ..."
if ! sudo dd if=110-images-relcans/$current_relcan_basename.iso of=${target_block_device} bs=4M status=progress oflag=sync; then
	die ":( Could not write .iso to USB" 202
fi
sudo sync


#
echo ":) Done: 1) created 110-images-relcans/${current_relcan_basename}.iso"
echo ":        2) created bootable USB ${target_block_device}"
echo ":  *OK* Press ENTER to continue ..."
echo ":"
echo ":  H.B.D! Good luck,"
echo ":"
read -p ":............."
