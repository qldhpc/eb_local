#!bin/bash
for i in $(ls /pkg/suse12/software/) 
do 
	echo "grep -irs ".qut.edu.au" $i >> out.txt &"
	grep -irs ".qut.edu.au" $i >> out.txt &
done
