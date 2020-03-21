.PHONY: test

test:
	lepton-netlist -L. -g test -o /dev/null test.sch 2>result.txt
	diff result.txt expected.txt
	rm -f result.txt
