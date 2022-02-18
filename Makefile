###############################################################################
# Flags & Folders
###############################################################################
FOLDER_BIN=bin
FOLDER_BUILD=build
FOLDER_BUILD_CPP=build/cpp
FOLDER_LIB=lib

UNAME=$(shell uname)

CC=gcc
CPP=g++

CC_FLAGS=-Wall -g

AR=ar
AR_FLAGS=-rsc

###############################################################################
# Configuration rules
###############################################################################
LIB_WFA=$(FOLDER_LIB)/libwfa.a
LIB_WFA_CPP=$(FOLDER_LIB)/libwfacpp.a
SUBDIRS=alignment \
        bindings/cpp \
        system \
        utils \
        wavefront
TOOLS=tools/generate_dataset \
      tools/align_benchmark \
      tools/examples
               

release: CC_FLAGS+=-O3 -march=native -flto
release: build

all: CC_FLAGS+=-O3 -march=native
all: build

debug: build

# ASAN: ASAN_OPTIONS=detect_leaks=1:symbolize=1 LSAN_OPTIONS=verbosity=2:log_threads=1
asan: CC_FLAGS+=-fsanitize=address -fno-omit-frame-pointer -fno-common
asan: build

###############################################################################
# Build rules
###############################################################################
build: setup
build: $(SUBDIRS) 
build: lib_wfa 
build: $(TOOLS)

setup:
	@mkdir -p $(FOLDER_BIN) $(FOLDER_BUILD) $(FOLDER_BUILD_CPP) $(FOLDER_LIB)
	
lib_wfa: $(SUBDIRS)
	$(AR) $(AR_FLAGS) $(LIB_WFA) $(FOLDER_BUILD)/*.o 2> /dev/null
	$(AR) $(AR_FLAGS) $(LIB_WFA_CPP) $(FOLDER_BUILD)/*.o $(FOLDER_BUILD_CPP)/*.o 2> /dev/null

clean:
	rm -rf $(FOLDER_BIN) $(FOLDER_BUILD) $(FOLDER_LIB)
	$(MAKE) --directory=tools/align_benchmark clean
	$(MAKE) --directory=tools/examples clean
	
###############################################################################
# Build external libs (for align-benchmark)
###############################################################################
external: external-all
	
external-all:
	$(MAKE) --directory=tools/align_benchmark/external all
	
external-clean:
	$(MAKE) --directory=tools/align_benchmark/external clean
	
###############################################################################
# Subdir rule
###############################################################################
export
$(SUBDIRS):
	$(MAKE) --directory=$@ all
	
$(TOOLS):
	$(MAKE) --directory=$@ all

.PHONY: $(SUBDIRS) $(TOOLS)

