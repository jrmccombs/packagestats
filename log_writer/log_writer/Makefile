include ../Makefile.inc

SRCS = log_writer.c
OBJS = ${SRCS:.c=.o}

DBGDIR	:= ../$(DBGDIR)
RELDIR	:= ../$(RELDIR)

DBGOBJDIR	= $(DBGDIR)/$(LOGWRITERDIR)
RELOBJDIR	= $(RELDIR)/$(LOGWRITERDIR)

INCLUDES =
LIBS = 

#DBGLIBDIRS = -L$(DBGDIR)/$(CLASSIFIERDIR)
#RELLIBDIRS = -L$(RELDIR)/$(CLASSIFIERDIR)
DBGLIBDIRS = 
RELLIBDIRS = 

SRCDIR	= ./src

DBGEXE = $(addprefix $(DBGDIR)/$(LOGWRITERDIR)/, $(LOGWRITER))
RELEXE = $(addprefix $(RELDIR)/$(LOGWRITERDIR)/, $(LOGWRITER))

DBGOBJS = $(addprefix $(DBGDIR)/$(LOGWRITERDIR)/, $(OBJS))
RELOBJS = $(addprefix $(RELDIR)/$(LOGWRITERDIR)/, $(OBJS))

VPATH = $(SRCDIR)

.PHONY: all print_vars clean dbg_all rel_all

all: dbg_all rel_all
dbg_all: $(DBGEXE)
rel_all: $(RELEXE)

print_vars:
	@$(ECHO) DBGDIR = $(DBGDIR)
	@$(ECHO) RELDIR = $(RELDIR)
	@$(ECHO) DBGOBJDIR = $(DBGOBJDIR)
	@$(ECHO) RELOBJDIR = $(RELOBJDIR)
	@$(ECHO) DBGEXE = $(DBGEXE)
	@$(ECHO) RELEXE = $(RELEXE)
	@$(ECHO) DBGOBJS = $(DBGOBJS)
	@$(ECHO) RELOBJS = $(RELOBJS)
	@$(ECHO) DBGLIBDIRS = $(DBGLIBDIRS)
	@$(ECHO) RELLIBDIRS = $(RELLIBDIRS)
	@$(ECHO) LIBS = $(LIBS)
	@$(ECHO) VPATH = $(VPATH)

clean:
	@$(ECHO) Cleaning in $(DBGDIR) 
	-$(RM) -f $(DBGOBJS) $(DBGEXE)
	@$(ECHO)
	@$(ECHO) Cleaning in $(RELDIR) 
	-$(RM) -f $(RELOBJS) $(RELEXE)
	@$(ECHO)

#
# Debug targets
#
$(DBGEXE): $(DBGOBJS)
	@$(ECHO) Creating debug driver executable: $@
	$(LD) -o $@ $^ $(DBGLIBDIRS) $(LIBS)
	@$(ECHO)

$(DBGOBJDIR)/%.o: %.c
	@$(ECHO) Compiling source file: $<
	$(CC) -c $(CFLAGS) $(DBGCFLAGS) -DLOGDIR=\"$(LOGDIR)\" $(INCLUDES) -o $@ $<
	@$(ECHO)

#
# Release targets
#
$(RELEXE): $(RELOBJS)
	@$(ECHO) Creating release driver executable: $@
	$(LD) -o $@ $^ $(RELLIBDIRS) $(LIBS)
	$(STRIP) $@
	@$(ECHO)

$(RELOBJDIR)/%.o: %.c
	@$(ECHO) Compiling source file: $<
	$(CC) -c $(CFLAGS) $(RELCFLAGS) -DLOGDIR=\"$(LOGDIR)\" $(INCLUDES) -o $@ $<
	@$(ECHO)



