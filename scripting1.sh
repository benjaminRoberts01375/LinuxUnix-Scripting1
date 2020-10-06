#!/bin/bash

##### Functions #####

NEW_LINE=%

checkForRoot()
{
	if [ $(id -u) == "0" ]; then
		#echo "Is root"
		return 0
	else
		#echo "Is not root"
		return 1
	fi
}

systemInfo()
{
	DISTRO=$(uname -n)
	KERNAL_VAR=$(uname -v | cut -d ' ' -f 1)
	CPU_ARCH=$(uname -i)
	echo "Distro: $DISTRO $NEW_LINE Kernal Version: $KERNAL_VAR $NEW_LINE $CPU Architecture: $CPU_ARCH"
}

memInfo()
{
	PHY_MEM=$(free -h | tr -s "[:blank:]" | cut -d ' ' -f 4 | head -n 2 | tail -n 1)
	SWAP_MEM=$(free -h | tr -s "[:blank:]" | cut -d ' ' -f 4 |  tail -n 1)

	echo "Free physical memory: $PHY_MEM $NEW_LINE Free swap memory: $SWAP_MEM"
}

sysDisks()
{
	output=""
	DISK_COUNT=$(df | tail -n +2 | cut -d ' ' -f 1 | wc -l)

	for i in `seq 1 $DISK_COUNT`;
	do
		output="$output $(df | tail -n +2 | cut -d ' ' -f 1 | head -n $i | tail -n 1)"

		output="$output $(df -h | tail -n +2 | head -n $i | tail -n 1 | tr -s '[:blank:]' | cut -d ' ' -f 4)"
		if [ "$i" -lt "$DISK_COUNT" ]
		then
			output="$output $NEW_LINE"
		fi
	done

	echo "$output"
}

usersGroups()
{
	output=""
	users="$(ls /home/ | tr ' ' '\n')"
	userCount="$(echo $X | wc -l)"

	for i in `seq 1 $userCount`;
	do
		currentUser="$(echo $users | head -n $i | tail -n 1)"
		groupList="$(groups $currentUser | tr ' ' '\n' | tail -n +3)"
		output="$output $currentUser is in groups: $groupList "

		if [ "$i" -lt "$userCount" ]
		then
			output="$output $NEW_LINE"
		fi
	done

	echo "$output"
}

getSystemIP()
{
	SYSTEM_IP=$(ifconfig | head -n 2 | tail -n 1 | tr -s "[:blank:]" | cut -d ' ' -f 3)
	echo "System IP: $SYSTEM_IP"
}

getCurrentDate()
{
	DATE=$(date +"%A, %B %d, %Y @ %r")
	echo "Date: $DATE"
}

getCPUUsage()
{
	USAGE=$(expr 100 - $(printf "%.0f" $(iostat | tr -s "[:blank:]" | head -n 4 | tail -n 1 | cut -d ' ' -f 7)))
	echo "CPU Usage: $USAGE%"
}

getHomeDir()
{
	STUFF=$(ls -l /home/benroberts | wc -l)
	echo "There are $STUFF items in Ben's home folder"
}

##### Main #####

if checkForRoot
then
	#echo "Is root"

	### Setting up vars ###
	system=$(systemInfo)
	mem=$(memInfo)
	drives=$(sysDisks)
	usrGrps=$(usersGroups)
	ip=$(getSystemIP)
	currentDate=$(getCurrentDate)

	CPU=$(getCPUUsage)
	homeItems=$(getHomeDir)

	title="$(whoami) – $currentDate"

	cat > /var/www/html/index.html <<- _EOF_
		<!DOCTYPE html>
		<html>
		<head>
			<title>$title</title>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no"/>
		</head>

		<body>
			<h1>System Configuration:</h1>
			<ul>
				<li> $echo ${system//$NEW_LINE/"</li><li>"} </li>
			</ul>

			<h1>System Resources:</h1>
			<ul>
                                <li> $echo ${mem//$NEW_LINE/"</li><li>"} </li>
				<li> $CPU </li>
                        </ul>

			<h1>Groups and Users</h1>
			<ul>
				<li>$echo ${usrGrps//$NEW_LINE/"<li></li>"} </li>
			</ul>

			<h1>Available Disks:</h1>
			<ul>
				<li> $echo ${drives//$NEW_LINE/"</li><li>"} </li>
			</ul>

			<h1>Additional Info:</h1>
			<ul>
				<li> $ip </li>
				<li> $homeItems </li>
			</ul>
		</body>
		</html>
	_EOF_
else
	echo "Please run this script as root/sudo."
fi
