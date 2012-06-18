! Copyright (C) 2011 Brendan MacDonell.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test functional-deps ;
IN: functional-deps.tests

! Reflexive dependencies are eliminated
[ { } ] [ Fs" a > a" minimize-deps ] unit-test

! Transitive dependencies are compressed
[ Fs" a > b" ] [ Fs" a > a b" minimize-deps ] unit-test
[ Fs" a > b" ] [ Fs" a > b; a > b" minimize-deps ] unit-test
[ Fs" a > b; b > c" ] [ Fs" a > b; b > c" minimize-deps ] unit-test
[ Fs" a > b c" ] [ Fs" a > b; a b > c" minimize-deps ] unit-test
[ Fs" a > b c" ] [ Fs" a > b; a b > a b c" minimize-deps ] unit-test
