XPL = ~/x/code
FPC = fpc -Mobjfpc  -FE./bin -Fu./code -Fi./code -gl

targets:
	@echo
	@echo 'available targets:'
	@echo
	@echo '  test    : run test cases'
	@echo '  clean   : delete compiled binaries and backup files'
	@echo
	@echo 'also:'
	@echo '   bin/%   : compiles demo/%.pas'
	@echo

bin/%.ppu: /%.pas
	@mkdir -p bin
	$(FPC) $<

bin/%: demo/%.pas
	@mkdir -p bin
	$(FPC) -gl $<

clean:
	@rm -f *~ *.gpi *.o *.pyc
	@rm -f bin/*


test: always run-tests
	@bin/run-tests
run-tests: test/*.pas code/*.pas
	cd test; python gen-tests.py
	@$(FPC) -B test/run-tests.pas

always:

#-- units -------------------------------------

ll:   bin/ll.ppu
cw:   bin/cw.ppu
fs:   bin/fs.ppu    stri
stri: bin/stri.ppu
num:  bin/num.ppu

#-- demos -------------------------------------
