#!/bin/bash

pattern=$1
shift
echo "Matching against '$pattern':"
for string; do
	case $string in
		$pattern) echo "$string: Match." ;;
		*) echo "$string: No match." ;;
	esac
done
