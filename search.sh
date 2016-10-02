#! /bin/bash

# ------------------------------------------------------------------------------
# Name:         Joseph Myers
# Date:         June 1, 2016
# Update:       July 7, 2016
# File Name:    search.sh
# Descriptoin:  This bash script will search the Books directory for a keyword
#               and by default display the files of the EPUB directory of that
#               keyword find, but will also be able to show the results for
#               PDF and MOBI 
# ------------------------------------------------------------------------------

################################################################################
#                       Usage                                                  #
################################################################################
# Description:  A function to display the help menu                            #
################################################################################
usage()
{
  printf "${red}%*s\n" $(((${#line}+COLUMNS)/2)) "HELP"
  echo -n "${PROGNAME} [KEYWORD]... [OPTION]... [OPTION2]... {OPTION3]...

This script searches for book(s) and if book(s) is found it will look for specific format and if found display the files.

${PROGNAME} [KEYWORD]...  will use EPUB by default

 Options:
  -a, --all         All format types
  -e, --epub        Show resuls for EPUB directory
  -m, --mobi        Show results for MOBI directory
  -p, --pdf         Show results for PDF directory
  -h, --help        Display this help and exit
  -?, --help        Display this help and exit
  -o, --on          Strict search on - volumes have to match keyword
  -d, --dup         Don't show duplicate files

 Options2:
  -o, --on          Strict search on - volumes have to match keyword
  -d, --dup         Don't show duplicate files

 Option3:
  -d, --dup         Don't show duplicate files
${end}"
}

################################################################################
#                            Check                                             #
################################################################################
# Description:  A function to check on the existence of the temp file and it content  #
# ---------------------------------------------------------------------------- #
# * Check to see if the file exists first                                      #
# * If it does then check to see if it size is greater than 0                  #
# * If it is greater than 0 then check to see if the first                     #
#   line is a space orblank                                                    #
# * If it passes all of those checks then processed on                         #
# * else inform the user of the empty line                                     #
# * else inform the user that the file doesn't exist                           #
# * else inform the user that there was no book matching the keyword           #
################################################################################
check()
{
	line2=$(head -n 1 "$list")
	if [  -f "$list" ]
	then
		if [[ -s $list ]]  
		then
			if [[ ! "$line2" =~ [^[:space:]] ]]  
			then  
				echo "${yel}Error Empty line${end}"
			else
				logic "$@"
			fi
			else
			echo "${yel}No Book found matching the $1${end}"
		fi
	else
		echo "${red}Temp file doesn't exist${end}"
	fi
}

################################################################################
#                            Createlist                                        #
################################################################################
# Description:  A function to search for books and if found create a           #
# list of titles                                                               #
# ---------------------------------------------------------------------------- #
# * First check to make sure user enter 3 or more characters for the keyword   #
# * If they didn't tell them and exit                                          #
# * If they did then check to make sure the first 3 characters                 #
#   don't contain an *                                                         #
# * If it does then inform user they can't use it and exit                     #
# * else find books and create list then processed                             #
################################################################################
createlist()
{
	if [ "$size" -lt 3 ]
	then
		echo "${yel}keyword is too short${end}"
		exit
	fi
	find "$source." -iname "*$1*" -maxdepth 1 -type d | awk -F/ '{print $NF}' >> "$list"
	check "$@"
}

################################################################################
#                               Search                                         #
################################################################################
# Description:  A function to search and display volumes for specific formats  #
# ---------------------------------------------------------------------------- #
# * Print Book Title                                                           #
# * Find book from list then search for specific volumes of specific format    #
# * If it doesn't find volumes for format let the user know                    #
################################################################################
search()
{
	while read -r line
	do
		printf "${gre}%*s\n${end}" $(((${#line}+COLUMNS)/2)) "$line"
		for i in "${array[@]}"
		do
			if [ -d "$source$line/$i" ]
			then
				echo "${yel}${underline}$i${endunder}${end}"   
			if [ $dup = false ]
			then
				find "$source$line" -iname "*$option*.$i" -and ! -iname ".*"  -type f | awk -F/ '{print $NF}'
			else	
				find "$source$line" -iname "*$option*.$i" -and ! -iname ".*"  -type f | awk -F/ '{print $NF}' | sort | uniq
			fi
			else
				echo "${yel}No Volumes in the $i format${end}"
			fi
			echo
		done
	done < "$list"
}

2ndlogic()
{
		# help
		if [ "$2" = "-h" ] || [ "$2" = "--help" ] || [ "$2" = "-?" ]
		then
			usage
		# -e or --epub
		elif [ "$2" = "-e" ] || [ "$2" = "--epub" ]
		then 
			search "$@"
		# -p or --pfd
		elif [ "$2" = "-p" ] || [ "$2" = "--pdf" ]
		then
			array=( "PDF" )
			search "$@"
		# -m or ---mobi
		elif [ "$2" = "-m" ] || [ "$2" = "--mobi" ]
		then
			array=( "MOBI" )
			search "$@"
		# -a or --all
		elif [ "$2" = "-a" ] || [ "$2" = "--all" ]
		then
			array=( "EPUB" "PDF" "MOBI" )
			search "$@"
		elif [ "$2" = "-o" ] || [ "$2" = "--on" ]
		then
			option="$1"
			search "$@"
		elif [ "$2" = "-d" ] || [ "$2" = "--dup" ]
		then
			dup=false
			search "$@"
		else
			usage
		fi
}

################################################################################
#                            Logic                                             #
################################################################################
# Description:  A function to determien what action to perform during search   #
# ---------------------------------------------------------------------------- #
# * If user only enter 1 para perform default search                           #
# * If user input 2 para check                                                 #
# * If second para deals with help display usage                               #
# * If second para is epub run default search                                  #
# * If second para is pdf run seach with format defined as pdf                 #
# * If second para is mobi run search with format defined as mobi              #
# * If second para is all run search for all formats                           #
# * If second para is using some other -option that is not defined             #
#   show help menu                                                             #
# * If third para exist check                                                  #
# * If third para is enable run search as default                              #
# * If third para is off then don't search as strictly                         #
# * If third para is not defined show usage                                    #
# * If more than three para show usage                                         #
################################################################################
logic()
{
	# 1 para logic
	if [ $# -eq 1 ]
	then
		search "$@"

	# 2 para logic	
	elif [ $# -eq 2 ]
	then
		2ndlogic "$@"

	# 3 para logic
	elif [ $# -eq 3 ]
	then
		if [ "$3" = "-o" ] || [ "$3" = "--on" ]
		then
			option="$1"
			2ndlogic "$@"
		elif [ "$3" = "-d" ] || [ "$3" = "--dup" ]
		then
			dup=false
			2ndlogic "$@"
		else
			usage
		fi

	# 4 para logic
	elif [ $# -eq 4 ]
	then
		if [ "$4" = "-d" ] || [ "$4" = "--dup" ]
		then
			if [ "$3" = "-o" ] || [ "$3" = "--on" ]
			then
				option="$1"
			else
				:
			fi
			dup=false
			2ndlogic "$@"
		else
				usage
		fi

	# 5 or more para logic		
	elif [ $# -gt 4 ]
	then
		usage
	fi
}

################################################################################
#                            rmfile                                            #
################################################################################
# Description:  A function to remove temp file                                 #
# ---------------------------------------------------------------------------- #
# * Check if file exist and if it does remove it                               #
################################################################################
rmfile()
{
if [ -f "$list" ]
then
	rm "$list"
fi
}

######################################################################
#                                Main                                #
######################################################################
# Main does the following                                            #
# * Clear the screen                                                 #
# * remove old temp file if it exists                                #
# * check to see if user enter para if not display help              #
# * checks to see if file structure exits for this script to run     #
# * if it does processed with finding books and creating list and on #
# * if not tell user and exit program                                #
######################################################################
clear
rmfile
if [ $# -eq 0 ]
then
	usage
elif [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "-?" ]
then
	usage
else
	if [ -d "$dir" ]
	then
		createlist "$@"
	else
		echo "${red}ERROR FILE STRUCTURE DOESN'T EXIT${end}"
		exit 1
	fi
fi
rmfile
