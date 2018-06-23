MINGW32 ?= i686-w64-mingw32
ifeq ($(MINGW32), "mingw32")
	DLLTOOL=dlltool
else
	DLLTOOL=$(MINGW32)-dlltool
endif

TOOLCHAIN_ARCH = $(firstword $(subst -, ,$(MINGW32)))
UNAME_S := $(shell uname -s)

CXXFLAGS=-std=c++98 -fpermissive -Wno-write-strings
CPPFLAGS=-MMD -MF $*.d
LDLIBS=-lgdi32 -lversion -ldiabloui -lstorm
LDFLAGS=-L./

# Determine compiler
ifneq ($(CC),)
	# If using generic 'cc', expose the symlink
	ifeq ($(findstring cc,$(CC)),cc)
		ifeq ($(UNAME_S),Darwin)
			CC = $(shell readlink /usr/bin/cc)
		else
			CC = $(shell readlink -f /usr/bin/cc)
		endif
	endif

	# If clang
	ifeq ($(findstring clang,$(CC)),clang)
		CXXFLAGS += --target=$(MINGW32)
		ifeq ($(UNAME_S),Darwin)
			MINGW_VERSION := $(shell brew list --versions mingw-w64)
			CXXFLAGS += -I$(shell brew --cellar mingw-w64)/$(subst mingw-w64 ,,$(MINGW_VERSION))/toolchain-$(TOOLCHAIN_ARCH)/$(MINGW32)/include/
			LDFLAGS += -L$(shell brew --cellar mingw-w64)/$(subst mingw-w64 ,,$(MINGW_VERSION))/toolchain-$(TOOLCHAIN_ARCH)/$(MINGW32)/lib/
		endif
	# If GCC/G++
	else ifeq ($(findstring gcc,$(CC)),gcc)
		CXX := $(MINGW32)-g++
		CC := $(MINGW32)-($CC)
	endif
else
	# Undefined - use OS defaults
	ifeq ($(UNAME_S),Linux)
		CXX := $(MINGW32)-g++
		CXX := $(MINGW32)-gcc
	endif
	ifeq ($(UNAME_S),Darwin)
		MINGW_VERSION := $(shell brew list --versions mingw-w64)\
		CXXFLAGS += -I$(shell brew --cellar mingw-w64)/$(subst mingw-w64 ,,$(MINGW_VERSION))/toolchain-$(TOOLCHAIN_ARCH)/$(MINGW32)/include/
		LDFLAGS += -L$(shell brew --cellar mingw-w64)/$(subst mingw-w64 ,,$(MINGW_VERSION))/toolchain-$(TOOLCHAIN_ARCH)/$(MINGW32)/lib/
		CXXFLAGS += --target=$(MINGW32)
	endif
endif

all: devilution.exe

include 3rdParty/PKWare/objs.mak
include Source/objs.mak

devilution.exe: $(OBJS) $(PKWARE_OBJS) diabloui.lib storm.lib
	$(CXX) $(LDFLAGS) -o $@ $^ $(LDLIBS)

diabloui.lib: diabloui.dll DiabloUI/diabloui_gcc.def
	$(DLLTOOL) -d DiabloUI/diabloui_gcc.def -D $< -l $@

diabloui.dll:
	$(warning Please copy diabloui.dll (version 1.09b) here)

storm.lib: storm.dll 3rdParty/Storm/Source/storm_gcc.def
	$(DLLTOOL) -d 3rdParty/Storm/Source/storm_gcc.def -D $< -l $@

storm.dll:
	$(warning Please copy storm.dll (version 1.09b) here)

clean:
	@$(RM) -v $(OBJS) $(OBJS:.o=.d) $(PKWARE_OBJS)  $(PKWARE_OBJS:.o=d)

.PHONY: clean all
