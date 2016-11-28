
stripHashBang() {
    
    
    local regex="$1"
    
    [[ -z "$regex" ]] && {
	printf "%s\n" "Null arguments are not allowed"
	exit 1
    }
    
    while read fileContent;do
	printf "%s\n" "${fileContent}" >> "${dirfile}"
    done < "${fileName}"
    
    
    sed -i "s/^#\!.*$(echo "${regex}")//g" "${dirfile}" #Striping off intereperter
    echo "!" >> "${dirfile}"
    
    
    
    while read fileContent;do
	printf "%s\n" "${fileContent}" >> "${fileName}"
    done < "${dirfile}"
    
    
    echo "${dirfile}" "${fileName}"
    mv "${dirfile}" "${fileName}"
    
    
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
	echo "${dirfile}" "${fileName}"
	mv "${dirfile}" "${fileName}"
	chown root:root ./*
	chmod 775 ./*
	crypt "shell script" "${CRYPT}"
	;;
    py)
	_py
	stripHashBang "python"
	crypt "python script" "${CRYPT}"
	;;
    pl)
	_pl
	stripHashBang "perl"
	crypt "perl script" "${CRYPT}"
	;;
    esac
}
