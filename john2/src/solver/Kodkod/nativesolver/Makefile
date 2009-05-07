SUBDIRS = minisat minisatprover zchaff zchaffmincost 
TARGET = 
.PHONY:  $(SUBDIRS) all clean

$(SUBDIRS):
	$(MAKE) -C $@ $(TARGET)

all: TARGET = all
all: $(SUBDIRS)

clean: TARGET = clean
clean: $(SUBDIRS)

