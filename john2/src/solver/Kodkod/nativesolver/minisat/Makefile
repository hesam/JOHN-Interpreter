CC = g++
COMPILE = $(CC) -Wall -O3 -c
LINK = $(CC) -dynamiclib

CHEADERS = Heap.h SolverTypes.h VarOrder.h Sort.h Solver.h Global.h 
CSRCS = Solver.C 
COBJS = Solver.o 

U0=$(shell uname)
U1=$(subst SunOS,solaris,${U0})
U2=$(subst CYGWIN.*,cygwin,${U1})
U3=$(subst Darwin,darwin,${U2})
OS=$(subst Linux,linux,${U3})

JNIDIR = /System/Library/Frameworks/JavaVM.framework/Versions/1.5.0/Headers
JLIBDIR = /Library/Java/Extensions/
JNILIB = libminisat.jnilib

JHEADERS = kodkod_engine_satlab_MiniSat.h 
JSRCS = kodkod_engine_satlab_MiniSat.cpp 
JOBJS = $(JSRCS:.cpp=.o)

$(COBJS):  $(CHEADERS)
	$(COMPILE) $(CSRCS)

$(JOBJS):  $(COBJS) $(JHEADERS)
	$(COMPILE) -I$(JNIDIR) -I. $(JSRCS)

EXTRALIBS=
ifeq "${OS}" "darwin"
	EXTRALIBS += -framework JavaVM
endif

$(JLIBDIR):
	mkdir -vp $@

$(JNILIB): $(JLIBDIR) $(COBJS) $(JOBJS)
	$(LINK) -o $(JLIBDIR)$(JNILIB) $(COBJS) $(JOBJS) $(EXTRALIBS)

clean:
	rm -f *.o

all: $(JNILIB)
