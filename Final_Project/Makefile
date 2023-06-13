# First target
PROCC=proc code=ANSI_C include=./include
CC=gcc -std=gnu99
INC=-I. -I./include -I$(ORACLE_HOME)/sdk/include
CFLAGS=-Wall -g $(INC)
LIBS=-L$(ORACLE_HOME)/lib/ -lclntsh

HEADERS=$(shell find . -name "*.h")
PCFILES=$(shell find ./procsrc -name "*.pc")
CFILES=$(shell find ./csrc -name "*.c")
CSRC=$(PCFILES:.pc=.c)
LSRC=$(PCFILES:.pc=.lis)
OBJ=$(PCFILES:.pc=.o) $(CFILES:.c=.o)
TARGET1=project_prog

%.c:%.pc
	$(PROCC) $<

%.o:%.c $(HEADERS)
	$(CC) $(CFLAGS) $< -c -o $@

$(TARGET1): $(OBJ)
	$(CC) $(LIBS) $^ -o $@

# Second target
PROCC=proc code=ANSI_C include=./include
CC=gcc -std=gnu99
INC=-I. -I./include -I$(ORACLE_HOME)/sdk/include -I./report/include
CFLAGS=-Wall -g $(INC)
LIBS=-L$(ORACLE_HOME)/lib -lclntsh
HEADERS=$(shell find ./include -name "*.h") $(shell find ./report/include -name "*.h")
PCFILES=$(shell find ./report/procsrc -name "*.pc") $(shell find ./procsrc -name "*.pc" -not -name "main.pc")
CFILES=$(shell find ./report/csrc -name "*.c")
CSRC=$(PCFILES:.pc=.c)
LSRC=$(PCFILES:.pc=.lis)
OBJ=$(PCFILES:.pc=.o) $(CFILES:.c=.o)
TARGET2=report_prog

%.c:%.pc
	$(PROCC) $<

%.o:%.c $(HEADERS)
	$(CC) $(CFLAGS) $< -c -o $@

$(TARGET2): $(OBJ)
	$(CC) $(LIBS) $^ -o $@

# Third target
PROCC=proc code=ANSI_C include=./include
CC=gcc -std=gnu99
INC=-I. -I./include -I$(ORACLE_HOME)/sdk/include -I./batch_1/include
CFLAGS=-Wall -g $(INC)
LIBS=-L$(ORACLE_HOME)/lib -lclntsh
HEADERS=$(shell find ./include -name "*.h") $(shell find ./batch_1/include -name "*.h")
PCFILES=$(shell find ./batch_1/procsrc -name "*.pc") $(shell find ./procsrc -name "*.pc" -not -name "main.pc")
CFILES=$(shell find ./batch_1/csrc -name "*.c")
CSRC=$(PCFILES:.pc=.c)
LSRC=$(PCFILES:.pc=.lis
tOBJ=$(PCFILES:.pc=.o) $(CFILES:.c=.o)
TARGET3=batch1

%.c:%.pc
	$(PROCC) $<

%.o:%.c $(HEADERS)
	$(CC) $(CFLAGS) $< -c -o $@

$(TARGET3): $(OBJ)
	$(CC) $(LIBS) $^ -o $@

# Fourth target
PROCC=proc code=ANSI_C include=./include
CC=gcc -std=gnu99
INC=-I. -I./include -I$(ORACLE_HOME)/sdk/include -I./batch_2/include
CFLAGS=-Wall -g $(INC)
LIBS=-L$(ORACLE_HOME)/lib -lclntsh
HEADERS=$(shell find ./include -name "*.h") $(shell find ./batch_2/include -name "*.h")
PCFILES=$(shell find ./batch_2/procsrc -name "*.pc") $(shell find ./procsrc -name "*.pc" -not -name "main.pc")
CFILES=$(shell find ./batch_2/csrc -name "*.c")
CSRC=$(PCFILES:.pc=.c)
LSRC=$(PCFILES:.pc=.lis)
OBJ=$(PCFILES:.pc=.o) $(CFILES:.c=.o)
TARGET4=batch2

%.c:%.pc
	$(PROCC) $<

%.o:%.c $(HEADERS)
	$(CC) $(CFLAGS) $< -c -o $@

$(TARGET4): $(OBJ)
	$(CC) $(LIBS) $^ -o $@


# Build both targets
all: $(TARGET1) $(TARGET2) $(TARGET3) $(TARGET4)

.PHONY: clean

clean:
	rm -f $(TARGET1) $(TARGET2) $(TARGET3) $(TARGET4) $(OBJ) $(CSRC) $(LSRC)
