ifeq ($(MINGW32), "mingw32")
	DLLTOOL=dlltool
else
	DLLTOOL=$(MINGW32)-dlltool
endif

CXXFLAGS=-std=c++98 -fpermissive -Wno-write-strings --target=i686-w64-mingw32
CPPFLAGS=-MMD -MF $*.d
LDLIBS=-lgdi32 -lversion -ldiabloui -lstorm
LDFLAGS=-L./

ifneq ($(OS),Windows_NT)
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
	CXXFLAGS += -I /usr/i686-w64-mingw32/include/
    endif
    ifeq ($(UNAME_S),Darwin)
	MINGW_VERSION := $(shell brew list --versions mingw-w64)
	CXXFLAGS += -I $(shell brew --cellar mingw-w64)/$(subst mingw-w64 ,,$(MINGW_VERSION))/toolchain-i686/i686-w64-mingw32/include/ 
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
