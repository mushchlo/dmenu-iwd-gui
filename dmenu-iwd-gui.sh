#!/bin/bash

[[ -z $(iwctl station wlan0 get-networks | grep '>') ]] && iwctl station wlan0 scan		#Refreshes nearby network cache, only works properly when disconnected from network, not fixable, it says 'Operation already in progress' on my machine
iwddir='/var/lib/iwd'				#Where IWD operates. MUST BE READABLE/WRITEABLE BY ANYONE
nets=$(iwctl station wlan0 get-networks)	#The backend of this script. Lists all networks nearby
dmenuopt="-i -c -l 10 -h 25 -nb #F0F0F0 -nf #777777 -sb #c0a4bb -sf #000000"	#Dmenu options, so as not to clutter the rest of the script. These are the options that I use, change them if you'd like
function login () {
	pass="$(echo "" | dmenu $(echo $dmenuopt) -p Password:)" || exit 1	#This is called when doing a user-entered passphrase. Exits the program if a null value is entered, as that means no password, user is probably trying to leave
        [[ $pass == "" ]] && exit 1		#Exits if [Enter] is pressed, thus selecting an empty character. different from null character
	iwctl station wlan0 connect "$selname" --passphrase "$pass" --dont-ask && exit 0 || echo "Password incorrect, please try again" | dmenu $(echo $dmenuopt) && exit 1	#Attempts authentication, could run a script but that's optional, then exits, OR, if authentication failed, exits and gives error message
}
for x in $(seq $(grep -c '*' <<< "$nets")); do #For as many numbers as there are networks detected;
	[[ "$con" != "1" ]] && [[ "$(awk -v c=$((8+($x-1)*3)) '{ FS = " " ; RS = "" ; print $c }' <<< \"$nets\" | sed 's/\x1B\[.*m//g' | tr -d '\n')" == '>' ]] && con=1        #If connection line (line that contains an extra field, a > to indicate a connection to the next network) hasn't been reached, and if this is the connection line, then con=1
        name=$(awk -v c=$((8+$con+($x-1)*3)) '{ FS = " " ; RS = "" ; print $c }' <<< "$nets" | sed 's/\x1B\[.*m//g' | tr -d '\n')	#Finds name. Dependent on whether we've reached the connection line yet
        sec=$(awk -v c=$((9+$con+($x-1)*3)) '{ FS = " " ; RS = "" ; print $c }' <<< "$nets" | tr -d '\n')	#Finds security
        str="1"	#Assumes strength is weak. If it gets changed later, it isn't weak.
	[[ $(awk -v c=$((10+$con+($x-1)*3)) '{ FS = " " ; RS = "" ; print $c }' <<< "$nets" | sed 's/\x1B\[.*m//g' | tr -d '\n') == '***' ]] && str="2"	#Sets connection symbol/string
        [[ $(awk -v c=$((10+$con+($x-1)*3)) '{ FS = " " ; RS = "" ; print $c }' <<< "$nets" | sed 's/\x1B\[.*m//g' | tr -d '\n') == '****' ]] && str="3"	#Same as before
        [[ "$x" != "1" ]] && netsorted="$netsorted\n"	#If this isn't the first line, add a separator.
        [[ "$con" == 1 ]] && [[ "$concheck" != "1" ]] && netsorted="$netsorted>   $str $name   [ $sec ]" && concheck=1 || netsorted="$netsorted$str  $name   [ $sec ]"	#If we've reached the connection line, and we haven't already done this, add a check mark to the current line, and then add all of the info to the end of the sorted variable.
done
sel=$(echo -e "$netsorted" | dmenu $(echo $dmenuopt)) || exit 1	#Allow user to select line (network)
selname=$(awk '{ FS = " " ; print $2 }' <<< "$sel")	#Parses the selected name for future use
selsec=$(awk '{ FS = " " ; print $4 }' <<< "$sel")	#Parses the selected security standard for future use 
if [[ "$selsec" == "psk" ]]; then	#If the security standard is psk;
	if [[ -f "$iwddir/$selname.psk" ]]; then	#If we have a saved password;
		if [[ "$(echo -e "Y\nN" | dmenu $(echo $dmenuopt) -p "Use the saved password? [Y/n]" | awk '{ print tolower($0) }')" == "y" ]]	#If the user wants to use the saved password;
                then
			iwctl station wlan0 connect "$selname" --dont-ask && exit 0 || echo "The saved password is incorrect" | dmenu $(echo $dmenuopt)	#Connect!
                else
			login	#Otherwise, login with user password
                fi
        else
		login
		fi
fi
[[ "$selsec" == "open" ]] && iwctl station wlan0 connect "$selname" && exit 0	#Log in to network automatically if its open
echo "You have tried to connect to a network that isn't open or psk. Please file a bug report, thanks! :)" | dmenu $(echo $dmenuopt) && exit 1		#debug message
