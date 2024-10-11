#!/bin/bash

author="Mangaliso Linda Dlamini"
student_number="S2110978"

backup_dir=~/.versionBackup
monitor_pid=-1


function list(){
	
	if [[ -d $backup_dir ]] 
	then
		displayFormat="%s%20s%20s%20s\n"

		echo "List of files in $backup_dir:"
		printf "$displayFormat" "Filename" "Size" "Type"

	
		for file in "$backup_dir"/*; do
			if [ -f "$file" ]; then
			    	filename=$(basename "$file")
			    	size=$(stat -c %s "$file")
			    	file_type=$(file -b --mime-type "$file")
				printf "$displayFormat" "$filename" "$size  bytes" "$file_type"
			fi
	    	done
	else
		
		echo "Version backup directory does not exist"
	fi
}

function recover(){
	file_to_recover="$1"
	
	if [[ -d $backup_dir ]]
	then
		
		if [[ -f $backup_dir/$file_to_recover ]] 
		then
			
			cp $backup_dir/$file_to_recover .
			echo "$file_to_recover has been recovered"
		else
			echo "No such file in versionBackup directory"
		fi
	else
		echo "Version backup directory does not exist"
	fi
}

function delete(){
	
	if [[ -d $backup_dir ]] 
	then 
		
		if [[ -z $(find $backup_dir -mindepth 1) ]]
		then
			echo "Directory is  empty"
		else
		
			for file in $backup_dir/*
			do
				read -p "Do you want to delete $file [y/n]: " choice
				if [[ $choice == "y" ]]
				then
					rm $file
					echo "$file has been deleted"
				else
					echo "$file kept"
				fi
			done
			echo "You have gone through all files "
		fi
	else
		echo "Directory does not exist"
	fi
}

function total(){

	if [[ -d $backup_dir ]]
	then
		
		total_size=$(du -sb $backup_dir | cut -f1)
		echo "Total usage of $backup_dir: $total_size bytes"
		if [[ $total_size -gt 1024 ]]
		then
			amber_color="\e[33m"
			reset_color="\e[0m"
			echo -e "${amber_color}  Warning: Backup directory exceeds 1Kbytes.${reset_color}" 
		fi
	else
		echo "Version backup directory does not exist"
	fi
}

function monitor(){
	
	xterm -e ./monitor.sh &
	echo "monitor.sh has started"	
}

function kill_monitor(){
	
	if ps aux | grep -q monitor.sh
	then
		
		pkill -f monitor.sh
		echo "monitor.sh has been terminated"
	else
		echo "monitor.sh is not running"
	fi
}

ctrl_c(){
	
	regular_files=$(find "$backup_dir" -type f -not -name ".*" | wc -l)

	echo ""
    	echo "Total number of regular files in $backup_dir: $regular_files"
	echo "Terminating the script."
    	exit
}


trap ctrl_c SIGINT

echo "===================================="
echo "Author: $author" 
echo "Student number: $student_number"
echo "===================================="


while getopts :lr:dtmk args 
do
  case $args in
 	l) list;;
 	r) recover "$OPTARG";;
 	d) delete;;
 	t) total;;
 	m) monitor;;
 	k) kill_monitor;;	 
 	:) echo "data missing, option -$OPTARG";;
	\?) echo "$USAGE";;
  esac
done

((pos = OPTIND - 1))
shift $pos

PS3='option> '


if (( $# == 0 ))
then
	if (( $OPTIND == 1 ))
 	then 
		select menu_list in list recover delete total monitor kill exit
		do case $menu_list in
		     	"list") list;;
		     	"recover") read -p "Enter the file to recover: " file_to_recover
				recover "$file_to_recover" ;;
		     	"delete") delete;;
		     	"total") total;;
		     	"monitor") monitor;;
		     	"kill") kill_monitor;;
		     	"exit") exit 0;;
		     	*) echo "unknown option";;
     			esac
  		done
 	fi
else 
	
	versionBackupDir="$HOME/.versionBackup"
	versionRegFile="$versionBackupDir/.versionReg.txt"

	if [[ ! -d "$versionBackupDir" ]]; then
	    	mkdir -p "$versionBackupDir"
	fi

	if [[ ! -f "$versionRegFile" ]]; then
	    	touch "$versionRegFile"
	fi

	if [ $# -lt 1 ]; then
		echo "Usage: $0 <filename>"
		exit 1
	fi

	filename="$1"

	
	if [ ! -f "$filename" ]; then
		echo "File '$filename' not found."
		exit 1
	fi

	
	if grep -q "^$filename" "$versionRegFile"; then
		
		version_num=$(awk -v name="$filename" '$1 == name { print $2 + 1 }' "$versionRegFile")
		awk -v name="$filename" -v ver_num="$version_num" '$1 == name { $2 = ver_num } 1' 			"$versionRegFile" > temp.txt && mv temp.txt "$versionRegFile"
	else
		
		version_num=1
		echo "$filename $version_num" >> "$versionRegFile"
	fi

		
		cp "$filename" "$versionBackupDir/$filename.$version_num"
		echo "$filename has been stored in backup directory as $filename.$version_num"

fi


	


