################################################################################
#
# Makefile @[parse_expr]
#
################################################################################

default: all



################################################################################
#
# generate C source files
#
################################################################################

GEN_SRC_FILES += lexer.h
GEN_SRC_FILES += parser.h
GEN_SRC_FILES += lex.yy.c
GEN_SRC_FILES += parser.tab.c

lexer.h lex.yy.c: lexer.flex
	flex --header-file=lexer.h $^

parser.h parser.tab.c: parser.y
	bison --defines=parser.h $^

gen: $(GEN_SRC_FILES)

gen.clean:
	rm -f $(GEN_SRC_FILES)



################################################################################
#
# build
#
################################################################################

HEADER_FILES += lexer.h parser.h

OBJFILES += lex.yy.o
OBJFILES += parser.tab.o
OBJFILES += final.o

%.o: $(HEADER_FILES) %.c
	gcc -DDEGBU -c -I. $*.c 

final.exe: $(OBJFILES)
	gcc -DDEGBU $(OBJFILES) -lfl -o $@

build: final.exe

build.clean:
	rm -f *.o
	rm -f *.exe



################################################################################
#
# user interface
#
################################################################################

all: final.exe

clean_tmp: build.clean

clean: gen.clean build.clean
