#!/bin/bash

author="Mangaliso Linda Dlamini"
student_number="S2110978"

Backup=~/.versionBackup

main() {
	cycle=0
    displayFormat="%s%20s%20s%20s\n"
    echo "===================================="
    echo "Author: $author" 
    echo "Student number: $student_number"
    echo "===================================="
    echo ""
    echo -n "Monitor starting in "
    sleep 1
    echo -n "3"
    sleep 1
    echo -n " 2"
    sleep 1
    echo " 1"
    sleep 1
    echo ""
    while [ true ]; do
	
        if [ -e "$Backup" ]; then
            if [ "$(ls -A $Backup)" ]; then
		if [ $cycle -eq 0 ]
		then
			clear
			echo "===================================="
			echo "Author: $author" 
			echo "Student number: $student_number"
			echo "===================================="

			regular_files=$(find "$Backup" -type f -not -name ".*" | wc -l)

			echo ""
    			echo "Started with: $regular_files file(s)"
			echo "Time: $(date +"%Y-%m-%d %H:%M:%S")"
			echo ""
			printf "$displayFormat" "Created" "Updated" "Deleted" "Timestamp"
			printf "$displayFormat" "-------" "-------" "-------" "--------------" 
		fi
		cycle=1
               
                cd $Backup
                items=$(ls)
                md5sum $items > ".md5sum1"
                echo -n "Monitoring changes in backup directory"
		
                sleep 5
                echo -n "."
                sleep 5
                echo -n " ."
                sleep 4
                echo -n -e ".\r"
                sleep 1
                created=0
                updated=0
                deleted=0
                items=$(ls)
                md5sum $items > ".md5sum2"
                updated=$(md5sum --quiet --check .md5sum1 2>/dev/null | wc -l)
                lines1=$(wc -l ".md5sum1" | awk '{ print $1 }')
                lines2=$(wc -l ".md5sum2" | awk '{ print $1 }')
		
		
                if [ $lines1 -lt $lines2 ]; then
                    created=$(($lines2 - $lines1))
                fi
		
                if [ $lines1 -gt $lines2 ]; then
                    deleted=$(($lines1 - $lines2))
                    updated=$(($updated - $deleted))
                fi
                
       		if [ $created != 0 ] || [ $updated != 0 ] || [ $deleted != 0 ]
		then
			
                	printf "$displayFormat" "($created) file(s)" "($updated) file(s)" "($deleted) file(s)" "$(date +"%Y-%m-%d %H:%M:%S")"
		fi
               
            else
                clear
		echo "===================================="
		echo "Author: $author" 
		echo "Student number: $student_number"
		echo "===================================="
                echo ""
		
                echo -n "backup directory is empty"
                sleep 5
                echo -n "."
                sleep 5
                echo -n " ."
                sleep 4
                echo -n -e ".\r"
                sleep 1
                cycle=0
               
            fi
        else
            clear
		echo "===================================="
   		echo "Author: $author" 
		echo "Student number: $student_number"
		echo "===================================="
            echo ""
            echo -n "backup directory does not exist"
            sleep 5
            echo -n "."
            sleep 5
            echo -n " ."
            sleep 4
            echo -n -e ".\r"
            sleep 1
            cycle=0
        fi
   done
}

main

	

