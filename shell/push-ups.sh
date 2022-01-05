#!/bin/bash
# push-up super-set script.
# each push-up should last for 2 seconds.

TIER=1 #interval
REP=1 #push-up

setterm -bold on

# enable gnome sound effects (on systems without built-in speaker)
dconf write /org/gnome/desktop/sound/event-sounds true

# clear bold, and disable sound effects if script is aborted.
trap "setterm -bold off; echo ""; dconf write /org/gnome/desktop/sound/event-sounds false; exit 0" 2

while [ $TIER -lt 8 ]; do

	clear
	echo tier: $TIER / 7
 	TIER=$((TIER + 1))
	sleep 5

	while [ $REP -lt 6 ]; do
		printf '\a\tpush-up: %d / 5\n' $REP
		DURATION=$((REP * 2 + 10))
		REP=$((REP + 1))
		sleep $DURATION
	done

	REP=1
	
	if [ $TIER -ne 8 ]; then
		echo rest for 60 seconds
		sleep 60
	fi

done

clear
echo all done!
setterm -bold off

# disable sound effects
dconf write /org/gnome/desktop/sound/event-sounds false
