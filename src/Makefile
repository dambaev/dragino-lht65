######
#
# Note that
# certain installations require the following changes:
#
# atscc -> patscc
# atsopt -> patsopt
# ATSHOME -> PATSHOME
#
######
#
#
######
#
ATSHOME=$(shell dirname $(shell dirname $(shell readlink $(shell which patscc))))
ATSCC=patscc
ATSOPT=patsopt
#
ATSCCFLAGS=-O2 -DATS_MEMALLOC_LIBC -I"../libs/"
ATSLIBS=
# ATSCCFLAGS=-O2
#
# '-flto' enables link-time optimization such as inlining lib functions
#
# ATSCCFLAGS=-O2 -flto
#
#
ATS_DATS=\
	../libs/ats-bytestring/DATS/bytestring_flat.dats \
	DATS/dragino-lht65.dats
ATS_SATS=\
	../libs/ats-bytestring/SATS/bytestring.sats \
	SATS/dragino-lht65.sats
######
#

ATS_OBJS= $(ATS_SATS:.sats=_sats.o) $(ATS_DATS:.dats=_dats.o)

.PHONY: all clean

all: test

cleanall::
#
######
#
# Please uncomment the following three lines and replace the name [foo]
# with the name of the file you want to compile
#


test: \
		test7 \
		test6 \
		test5 \
		test4 \
		test3 \
		test2 \
		test1

test7: $(ATS_OBJS)
	$(ATSCC) $(ATSCCFLAGS) -o $@_bin $(ATS_OBJS) TEST/$@.dats $(ATSLIBS)
	./$@_bin
	@touch $@
test6: $(ATS_OBJS)
	$(ATSCC) $(ATSCCFLAGS) -o $@_bin $(ATS_OBJS) TEST/$@.dats $(ATSLIBS)
	./$@_bin
	@touch $@
test5: $(ATS_OBJS)
	$(ATSCC) $(ATSCCFLAGS) -o $@_bin $(ATS_OBJS) TEST/$@.dats $(ATSLIBS)
	./$@_bin
	@touch $@
test4: $(ATS_OBJS)
	$(ATSCC) $(ATSCCFLAGS) -o $@_bin $(ATS_OBJS) TEST/$@.dats $(ATSLIBS)
	./$@_bin
	@touch $@
test3: $(ATS_OBJS)
	$(ATSCC) $(ATSCCFLAGS) -o $@_bin $(ATS_OBJS) TEST/$@.dats $(ATSLIBS)
	./$@_bin
	@touch $@
test2: $(ATS_OBJS)
	$(ATSCC) $(ATSCCFLAGS) -o $@_bin $(ATS_OBJS) TEST/$@.dats $(ATSLIBS)
	./$@_bin
	@touch $@
test1: $(ATS_OBJS)
	$(ATSCC) $(ATSCCFLAGS) -o $@_bin $(ATS_OBJS) TEST/$@.dats $(ATSLIBS)
	./$@_bin
	@touch $@
cleanall:: ; $(RMF) test*
#
######
#
# You may find these rules useful
#
%_sats.o: %.sats ; $(ATSCC) $(ATSCCFLAGS) -c -o $@ $<
%_dats.o: %.dats ; $(ATSCC) $(ATSCCFLAGS) -c -o $@ $<
#
######
#
RMF=rm -f
#
######
#
clean:: ; $(RMF) test*
clean:: ; $(RMF) *~
clean:: ; find -name '*_?ats.o' -exec $(RMF) {} \;
clean:: ; find -name '*_?ats.c' -exec $(RMF) {} \;
#
cleanall:: clean
#
###### end of [Makefile] ######

