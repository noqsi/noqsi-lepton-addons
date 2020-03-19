.PHONY: test

test:
	make -C tsv/test test
	make -C pincount/test test
	make -C check-duplicates/test test

