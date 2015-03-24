# Makefile for XPL
# ---------------------------------------------------------
# GEN: Where to put generated intermediate files.
# warning: gen directory gets wiped out, so use a temp dir!
GEN = ./.gen
# BIN: where to put the final executables
BIN = ./bin

FPC = fpc -Mobjfpc -FE$(BIN) -Fu$(GEN) -Fi$(GEN) -Fu./code -Fi./code -gl
PY = python2.7
TANGLE = ./etc/tangle.el

targets:
	@echo
	@echo 'available targets:'
	@echo
	@echo '  test    : run test cases'
	@echo '  clean   : delete compiled binaries and backup files'
	@echo
	@echo '  repl    : simple lisp-like RPL [like a REPL but no "eval" yet :)]'
	@echo '  xt256   : 256 color console demo for term'
	@echo
	@echo 'also:'
	@echo '   bin/%   : compiles demo/%.pas to bin/%'
	@echo

# init contains all the stuff that has to run up front
init:
	@mkdir -p $(GEN)
	@mkdir -p $(BIN)

# 'always' is just a dummy thing that always runs
always:

bin/%: demo/%.pas tidy
	rm -f $@
	$(FPC) $<

# tidy just moves all the units and whatnot to the gen directory
tidy:
	mv $(BIN)/*.o $(GEN) || true
	mv $(BIN)/*.ppu $(GEN) || true

# clean removes all the generated files
clean:
	@rm -f *~ *.gpi *.o *.pyc
	@delp $(BIN)
	@rm -rf $(GEN) ; mkdir -p $(GEN)

# we use always here, else it'll see the test directory and assume we're done.
test: always init clean tangle test-runner
	@bin/run-tests $(paramline)
test-runner: test/*.pas code/*.pas
	cd test; $(PY) gen-tests.py ../$(GEN)
	$(FPC) -B test/run-tests.pas

#-- org-mode stuff ----------------------------

tangle:
	$(PY) etc/tangle-all.py

#-- units -------------------------------------

gen/%.ppu: /%.pas
	make init
	$(FPC) $<

ll:   bin/ll.ppu
cw:   bin/cw.ppu
fs:   bin/fs.ppu    ustr
ustr: bin/ustr.ppu
num:  bin/num.ppu

#-- demos --------------------------------------
repl: bin/repl
	$(BIN)/repl
xt256: bin/xterm256color
	$(BIN)/xterm256color
