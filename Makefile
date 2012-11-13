XPL = ~/x/code
FPC = fpc -Mobjfpc  -FE./bin -Fu./code -Fi./code -gl

default: test

bin/%.ppu: /%.pas
	@mkdir -p bin
	$(FPC) $<

bin/%: progs/%.pas
	@mkdir -p bin
	$(FPC) -gl $<

clean:
	@rm -f *~ *.gpi *.o *.pyc
	@rm -f bin/*


test: always run-tests
	@bin/run-tests
run-tests: test/*.pas code/*.pas
	cd test; python gen-tests.py
	@$(FPC) test/run-tests.pas && clear

always:

#-- units -------------------------------------

ll:   bin/ll.ppu
cw:   bin/cw.ppu
fs:   bin/fs.ppu    stri
stri: bin/stri.ppu
num:  bin/num.ppu

#-- progs -------------------------------------


