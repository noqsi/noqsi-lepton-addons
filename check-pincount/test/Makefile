.PHONY :	test

test :
	if lepton-netlist -L . -L ../src/ -g check-pincount -o /dev/null bad.sch; \
		then false; \
		else true; \
	fi 
