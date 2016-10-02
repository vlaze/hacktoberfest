#! /bin/bash

# ------------------------------------------------------------------------------
# Name:         Joseph Myers
# Date:         December 9, 2015
# File Name:    ebook.sh.sh
# Descriptoin:  This bash script will help clean up ebook files aka epub and 
#               and mobi files.  It will create two list for each type with 
#               the series name in each so it will not include - Volume and 
#               numbers.  It will then make sure the files are tagged with a 
#               purple tag so that the script newbooks.sh can find them easier.
#               The files will then be moved to their destination if directory 
#               exists if not they won't be moved.  If the series directory
#               exists, but not the format folder then it will create it the
#               move the files.  Then the lists will be deleted.
# ------------------------------------------------------------------------------

source=/Users/josdmyer/Downloads/Documents/
dest=/Users/josdmyer/Documents/Books/Books/
list=/Users/josdmyer/.Scripts/
option=false

usage()
{
	clear
	echo "ebook.sh"
	echo "Description:  Is a program to help clean up ebook files and put them in their proper location"
echo
echo "Options:"
echo "-d  move directories to the destination directory"
echo "-o  force move individual files and overwrite in destination"
}


# Check to see if ther are any epub or mobi or pdf files
count=`ls -1 "$source"*.epub 2>/dev/null | wc -l`
count2=`ls -1 "$source"*.mobi 2>/dev/null | wc -l`
count3=`ls -1 "$source"*.pdf 2>/dev/null | wc -l`

# A function to check to see if the user wants to remove the previous log file
log()
{
while true; do
    read -p "Do you wish to remove the previous log file?  " yn
    case $yn in
        [Yy]* ) 
            if [ -f log/ebook.log ];then 
                rm log/ebook.log 
            fi 
        return
        ;;
        [Nn]* ) 
            return
        ;;
        * ) echo "Please answer yes or no.";;
    esac
done
}

createList()
{
# If there are epub files then get a series list, tag the files, and move them
# if not then show message "No Epub files found"
	if [ $count != 0 ]
	then
    	cd "$source" || exit
    	ls *.epub | sed 's/-.*//' | sed 's/\(.*\)\..*/\1/' | sed 's/[0-9].*//' | uniq >> "$list"list.txt
		cd "$list" || exit
		epubtag "$@"
		moveEpub "$@"
	else
    	echo "No Epub files found"
	fi

# If there are mobi files then get a series list, tag the files, and move them
# if not then show message "No Mobi files found"
	if [ $count2 != 0 ]
	then
    	cd "$source" || exit
    	ls *.mobi | sed 's/-.*//' | sed 's/\(.*\)\..*/\1/' | sed 's/[0-9].*//' | uniq >> "$list"list2.txt
		cd "$list" || exit
		mobitag "$@"
		moveMobi "$@"
	else
    	echo "No Mobi files found"
	fi

# If there are pdf files then get a series list, tag the files, and move them
# if not then show message "No PDF files found"
	if [ $count2 != 0 ]
	then
    	cd "$source" || exit
    	ls *.pdf | sed 's/-.*//' | sed 's/\(.*\)\..*/\1/' | sed 's/[0-9].*//' | uniq >> "$list"list3.txt
		cd "$list" || exit
		pdftag "$@"
		movePDF "$@"
	else
    	echo "No PDF files found"
	fi
}

# Tag epub files
epubtag()
{
    find "$source" -maxdepth 1 -iname "*.epub" -type f -print0 | xargs -0 -I '{}' tag -a Purple {}
}

# Tag mobi files
mobitag()
{
	find "$source" -maxdepth 1 -iname "*.mobi" -type f -print0 | xargs -0 -I '{}' tag -a Purple {}
}

# Tag pdf files
pdftag()
{
	find "$source" -maxdepth 1 -iname "*.pdf" -type f -print0 | xargs -0 -I '{}' tag -a Purple {}
}

# Move epub files
moveEpub()
{
    while read -r line
    do
    if [ -d "$dest$line" ]; then
    	if [ -d "$dest$line/EPUB" ]; then
    		if [ "$1" = "-o" ]; then
    			find "$source" -maxdepth 1 -iname "*$line*" -and ! -iname ".*$line*" -type f -print0 | xargs -0 -I '{}' mv -f -v {} "$dest$line"/EPUB/ >> log/ebook.log
    		else
    			find "$source" -maxdepth 1 -iname "*$line*" -and ! -iname ".*$line*" -type f -print0 | xargs -0 -I '{}' mv -n -v {} "$dest$line"/EPUB/ >> log/ebook.log
    		fi
    else
        mkdir "$dest$line/EPUB"
    	find "$source" -maxdepth 1 -iname "*$line*" -and ! -iname ".*$line*" -type f -print0 | xargs -0 -I '{}' mv -v {} "$dest$line"/EPUB/ >> log/ebook.log
    	fi
    fi
	done < "list.txt"
}

# Move Mobi files
moveMobi()
{
    while read -r line
    do
    if [ -d "$dest$line" ]; then
		if [ -d "$dest$line/MOBI" ]; then
    	if [ "$1" = "-o" ]; then
    		find "$source" -maxdepth 1 -iname "*$line*" -and ! -iname ".*$line*" -type f -print0 | xargs -0 -I '{}' mv -f -v {} "$dest$line"/MOBI/ >> log/ebook.log
    	else
    		find "$source" -maxdepth 1 -iname "*$line*" -and ! -iname ".*$line*" -type f -print0 | xargs -0 -I '{}' mv -n -v {} "$dest$line"/MOBI/ >> log/ebook.log
    	fi
	else
		mkdir "$dest$line/MOBI"
    	find "$source" -maxdepth 1 -iname "*$line*" -and ! -iname ".*$line*" -type f -print0 | xargs -0 -I '{}' mv -v {} "$dest$line"/MOBI/ >> log/ebook.log
		fi
    fi
    done < "list2.txt"
}

# Move PDF files
movePDF()
{
    while read -r line
    do
    if [ -d "$dest$line" ]; then
		if [ -d "$dest$line/PDF" ]; then
    	if [ "$1" = "-o" ]; then
    	    find "$source" -maxdepth 1 -iname "*$line*" -and ! -iname ".*$line*" -type f -print0 | xargs -0 -I '{}' mv -f -v {} "$dest$line"/PDF/ >> log/ebook.log
    	else
    		find "$source" -maxdepth 1 -iname "*$line*" -and ! -iname ".*$line*" -type f -print0 | xargs -0 -I '{}' mv -n -v {} "$dest$line"/PDF/ >> log/ebook.log
    	fi
	else
		mkdir "$dest$line/PDF"
    	find "$source" -maxdepth 1 -iname "*$line*" -and ! -iname ".*$line*" -type f -print0 | xargs -0 -I '{}' mv -v {} "$dest$line"/PDF/ >> log/ebook.log
		fi
    fi
    done < "list3.txt"
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Main ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if [ "$#" -eq 0 ] || [ "$1" == "-o" ]
then
clear
log
clear
createList "$@"

# if epub list exists delete it
if [ -f list.txt ]; then
	rm list.txt
fi

# if mobi list exist delete it
if [ -f list2.txt ]; then
	rm list2.txt
fi

# if pdf list exist delete it
if [ -f list3.txt ]; then
	rm list3.txt
fi
elif [ "$1" == "-d" ]
then
	dir
else
	usage
fi
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ End of File ~~~~~~~~~~~~~~~~~~~~~~~~~
