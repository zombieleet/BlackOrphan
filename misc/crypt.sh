# Crypt the script
crypt() {
    local type=$1 shc="${2}"/misc/shc/shc
    # check if shc is executable ( shc is the script that will crypt the malware )
    if [[ ! -x "${shc}" ]];then

        (

            cd "${shc%%/shc*}" && \
                tar -xvf "${shc%%shc*}shc-3.8.7.tgz"
            mv "shc-3.8.7" "${shc##*/}"
            cd "${shc##*/}" && \
                {
                    make || gcc shc.c shc || {
			    printf "\n${open}${bold}${red}%s${close}\n" "Error while compiling shc " && exit 6
                        }
                } ||  {
                    printf "\n${open}${bold}${red}%s${close}\n" "Error while compiling shc " && exit 6
                }
        )
    fi
    
    printf "\n${open}${bold}${green}%s${type}\n" "Crypting the "
    "${shc}" -r -f "${fileName}" && \
	{
	    rm "${fileName}"
	    mv "${fileName}.x" "${fileName}"
	    rm "${fileName}.x.c"
	    printf "${open}${bold}${green}%s${close}\n" "Done"
	} || \
	    { printf "${open}${bold}${red}%s${type}\n" "Fatal Error while crypting " && exit 2 ;}
    
}
