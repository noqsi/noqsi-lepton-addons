.PHONY: test

test:
	if lepton-netlist -L ../src/ -g check-duplicates bad.sch; \
		then false; \
		else true; \
	fi && \
	lepton-netlist -L ../src/ -g check-duplicates good.sch && \
	rm output.net
	
	
