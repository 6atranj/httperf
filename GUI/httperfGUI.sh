#!/bin/bash
#
#"Httperf -- a tool for measuring web server performance. It provides a flexible facility for generating various HTTP workloads and for measuring #server performance. The focus of httperf is not on implementing one particular benchmark but on providing a robust, high-performance tool that #facilitates the construction of both micro- and macro-level benchmarks. The three distinguishing characteristics of httperf are its robustness, #which includes the ability to generate and sustain server overload, support for the HTTP/1.1 and SSL protocols, and its extensibility to new #workload generators and performance measurements."
#
# Author: Mehrdad Dadkhah
# Email: dadkhah.ir at gmail.com
# Licence: GPL
# based now on yad.
#
Encoding=UTF-8
#
#
# define some variables
#
TITLE='Httperf ... measuring web server performance'
VERSION=0.9.0
ICON=/usr/share/icons/6atranj-icons/httperfGUI.jpg

#
#questions
#
function menu {
data=($(yad --form --title="$TITLE"" $VERSION" --window-icon=$ICON \
			--on-top \
			--center \
			--margins=10 \
			--image=$ICON \
			--image-on-top \
			--borders=15 \
			--item-separator=, \
			--separator="," \
			--field="hostname:TEXT" \
			--field="port number:NUM" \
			--field="uri (if wan't to check several uri or ajax uri leave empty it):TEXT" \
			--field="rate (number of requests per second):NUM" \
			--field="number of connections:NUM" \
			--field="number of calls:NUM" \
			--field="time to test/seconds:NUM" \
			--button=$"attach file of uri:7" \
               --button=$"Test:8" \
			--button="more options:9" \
               --button="gtk-help:10" \
               --button="gtk-close:11"
               
      ))

ret=$?

IFS=',' read -a array <<< "$data"

#
#file of URLs
#
if [[ $ret -eq 7 ]]; then
    CHANGE=$(yad --title="$TITLE"" $VERSION" --window-icon=$ICON \
		--file --width=600 --height=500 \
		--text=$"<b>Choose your own audio file as alert!</b>
________________________________________________")
		if [ "$CHANGE" ];then 
			if [[ ! -z "${array[2]}" &&  ! -z "${array[1]}" &&  ! -z "${array[3]}" ]];then
				httperf --server "${array[0]}" --wsesslog ${array[4]%.*},${array[5]%.*},"$CHANGE"
			else
				yad --title $"$TITLE"" $VERSION" \
			    --button="gtk-ok:0" \
			    --width 300 \
			    --window-icon=$ICON \
			    --text=$"Your own file of URLs add successfully ... "
			fi
		else
			zenity --warning \
			--title='oh! your file could not attach ... ' \
			--text='please enter url or import txt file of urls ... '
		fi
menu		
fi
#
#Test url
#
if [[ $ret -eq 8 ]]; then
	if [[ -z "$CHANGE" ]]; then
		if [[ -z "${array[0]}" ]]; then
			zenity --warning \
			--title='wrong data ... !' \
			--text='please enter url or import txt file of urls ... '
		else
			port=${array[1]%.*}
			(httperf --server "${array[0]}" \
				   --port ${array[1]%.*} --uri "${array[2]}" \
				   --rate ${array[3]%.*} --num-conn ${array[4]%.*} \
				   --num-call ${array[5]%.*} --timeout ${array[6]%.*}
			) | yad --text-info \
					--width=1020 \
					--height=500 \
					--on-top \
					--center \
					--title="test resault" \
					--margins=15 \
					--image=$ICON \
					--image-on-top \
					--borders=10 
			#zenity --text-info \
			  #--title="License" \
			 # --filename=~/temp.txt
autobench --single_host --host1 www.test.com --uri1 /10K --quiet --low_rate 20 --high_rate 200 --rate_step 20 --num_call 10 --num_conn 5000 --timeout 5 --file results.tsv 
		fi
	else
		httperf --server "${array[0]}" --wsesslog ${array[4]%.*},${array[5]%.*},"$CHANGE"
	fi
menu                 
fi

#
#more options and help ...
#
if [[ $ret -eq 9 ]]; then
	terminator -x httperf --help
fi
autobench --single_host --host1 www.google.com --uri1 /10K --quiet --low_rate 20 --high_rate 200 --rate_step 20 --num_call 10 --num_conn 5000 --timeout 5 --file results.tsv 
if [[ $ret -eq 10 ]];then
	man httperf | yad --text-info \
					--maximized \
					--on-top \
					--center \
					--title="httperf man page" \
					--margins=15 \
					--image=$ICON \
					--image-on-top \
					--borders=10 \
					--text="you can use these options and examples in terminal"
fi

[[ $ret -eq 11 ]] && exit 0


}
menu
