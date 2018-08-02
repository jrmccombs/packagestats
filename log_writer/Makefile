include Makefile.inc

PROJECTDIRS = $(LOGWRITERDIR)
ALLDIRS = $(UNITTESTS) $(PROJECTDIRS)

.PHONY: all prep_build_dirs prep_unit_tests clean dbg_all rel_all dbg_logwriter rel_logwriter test

all: prep_build_dirs prep_unit_tests dbg_all rel_all
dbg_all: dbg_logwriter
rel_all: rel_logwriter

prep_build_dirs:
	-@for d in $(PROJECTDIRS); do (mkdir -p $(DBGDIR)/$$d); done
	-@for d in $(PROJECTDIRS); do (mkdir -p $(RELDIR)/$$d); done
	@$(ECHO) Created debug and release build artifact directories
	@$(ECHO)

prep_unit_tests:
#	$(MAKE) -C $(UNITTESTS) all

clean:
	@$(ECHO) Cleaning debug and release directories
	-@for d in $(ALLDIRS); do ($(MAKE) -C $$d clean); done


#
# Debug executable
#
dbg_logwriter:
	@$(ECHO) "*******************************"
	@$(ECHO) Making debug log writer
	@$(ECHO) "*******************************"
	$(MAKE) -C $(LOGWRITERDIR) dbg_all
	@$(ECHO)

#
# Release executable
#
rel_logwriter:
	@$(ECHO) "*******************************"
	@$(ECHO) Making release log writer
	@$(ECHO) "*******************************"
	$(MAKE) -C $(LOGWRITERDIR) rel_all
	@$(ECHO)

