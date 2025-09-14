KDIR ?= $(HOME)/r4l-linux/build
PWD := $(shell pwd)

obj-m += hello.o
hello-rust := hello.rs

all:
	make -C $(KDIR) M=$(PWD) LLVM=1 modules

clean:
	make -C $(KDIR) M=$(PWD) LLVM=1 clean
