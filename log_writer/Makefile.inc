#
# Compilers and utilities settings.
#
CC	= gcc
CFLAGS	= -Wall
LD	= gcc
LDFLAGS	=
AR	= ar
ARFLAGS	=
RANLIB	= ranlib
STRIP	= strip
MV	= mv
RM	= rm
CAT	= cat
ECHO	= echo
SHELL	= /bin/sh

#
# Macro definitions required in the log writer
# source code.
#

# Change this to where the log file lives
LOGDIR="/logtest"

#
# Names of executables to be produced
#
LOGWRITER=writelog

# 
# Nothing beyond here should need to be changed
#

#
# Project directories
#
UNITTESTS = unit_tests
LOGWRITERDIR = log_writer

#
# Debug build settings
#
DBGCFLAGS	= -g -DDEBUG
DBGDIR	= debug

#
# Release build settings
#
RELCFLAGS	= -DNDEBUG
RELDIR	= release
