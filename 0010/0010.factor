! Copyright (C) 2011 Brendan MacDonell.
! See http://factorcode.org/license.txt for BSD license.
USING: math.primes prettyprint sequences ;
IN: 0010

<PRIVATE
: prime-sum ( -- ) 2000000 primes-upto sum . ;
PRIVATE>

MAIN: prime-sum
