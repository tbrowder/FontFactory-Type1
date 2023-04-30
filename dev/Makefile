#all: test4
#all: test5
#all: test6
#all: test6
#all: test7
all: all-tests

all-tests:
	raku -I.. ../t/*1*t
	raku -I.. ../t/*2*t
	raku -I.. ../t/*3*t
	raku -I.. ../t/*4*t
	raku -I.. ../t/*5*t
	raku -I.. ../t/*6*t
	(cd ..; raku -I. ./t/*7*t)

test3:
	raku -I.. ../t/*3*t

test4:
	raku -I.. ../t/*4*t

test5:
	raku -I.. ../t/*5*t

test6:
	raku -I.. ../t/*6*t

test7:
	(cd ..; raku -I. ./t/*7*t)
