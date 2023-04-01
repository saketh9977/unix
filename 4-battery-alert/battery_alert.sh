
set -e

battery_percentage=""
battery_status=""

# battery percentage bounds
lower_bound=40
upper_bound=80

function notify(){
	title_=$1
	body_=$2
	
	echo "notifying title=$title_, body=$body_..."
	osascript -e "display notification \"$body_\" with title \"$title_\""
	echo "notified"
}

function get_battery_percentage(){
	battery_percentage=$(pmset -g batt | tail -1 | awk -F '\t' '{print $2}' | awk -F '; ' '{print $1}' | awk -F '%' '{print $1}')
	echo "$battery_percentage%"
}

function get_battery_status(){
	# discharging? or charging?
	battery_status=$(pmset -g batt | tail -1 | awk -F '\t' '{print $2}' | awk -F '; ' '{print $2}')
	echo $battery_status
}

function notify_if_needed(){
	if (( $battery_percentage <= $lower_bound ))
	then
		echo "1"
		if [ "$battery_status" == "discharging" ]
		then
			echo "2"
			notify "Battery Low" "$battery_percentage%, battery $battery_status"
			exit 0
		fi
	elif (( $battery_percentage >= $upper_bound ))
	then
		echo "3"
		if [ "$battery_status" != "discharging" ]
                then
			echo "4"
                        notify "Unplug charger" "$battery_percentage%, battery $battery_status"
                        exit 0
                fi
	fi
}

date
get_battery_percentage
get_battery_status
notify_if_needed

