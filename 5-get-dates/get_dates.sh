#!bin/bash

set -e
echo "starting..."

# ensure GNU is used
PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

date
echo "======================="

res=()

function get_dates__() {
	start_date=$1
	end_date=$2
	res=()

	epoch_start_date=$(date -d "$start_date" "+%s")
	epoch_end_date=$(date -d "$end_date" "+%s")
	if [ "$epoch_start_date" -ge "$epoch_end_date" ]; then
		echo "ensure end_date > start_date"
		exit 1
	fi

	cur_date=$start_date
	res+=("$cur_date")
	while [ "$cur_date" != "$end_date" ]; do
		cur_date=$(date -d "$cur_date 1 days" "+%Y-%m-%d")
		res+=("$cur_date")
	done
}

get_dates__ "2023-10-18" "2023-10-21"

for cur_date in "${res[@]}"; do
	year=$(echo $cur_date | cut -d "-" -f1)
	month=$(echo $cur_date | cut -d "-" -f2)
	day=$(echo $cur_date | cut -d "-" -f3)

	echo "$year$month$day"
done

echo "========================"
date
echo "ending"
