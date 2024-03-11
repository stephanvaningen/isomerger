# 
# 'sourced' by scripts in .. to set some variables that re-occur in different scripts


#
success=0 #pessimist
current_redhat_iso=$(basename "$(readlink 100-images-redhats/current)")
current_redhat="${current_redhat_iso%.*}"
current_rhel_version=$(echo $current_redhat | sed -n 's/.*rhel-\([0-9]\)\.[0-9].*/RHEL\1/p')
current_build=$(basename "$(readlink 120-builds-and-bundles/current)")
current_relcan_basename=$current_redhat-$current_build
current_relcan_workfolder=110-images-relcans/$current_relcan_basename/
current_bab_workfolder=120-builds-and-bundles/$current_build/

function die() {
	local message="${1:-   Script ended in error. Check above or logs for details ...}"
	local exit_code="${2:-1}"

	echo "$message"
	read -p "   Press ENTER to continue ..."
	exit $exit_code
}
