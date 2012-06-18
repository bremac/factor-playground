! Copyright (C) 2011 Brendan MacDonell.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel literals lists lists.lazy math ;
IN: binary-skew-numbers

CONSTANT: BINARY-SKEW-NUMBERS $[ 1 [ 2 * 1 + ] lfrom-by ]

: llength>= ( l n -- ? )
    [ 2dup [ nil? not ] [ 0 > ] bi* and ]
    [ [ cdr ] [ 1 - ] bi* ] while nip zero? ;

: lmap' ( ... list quot: ( ... elt -- ... newelt ) -- ... result )
    [ nil ] dip [ swapd dip cons ] curry foldl lreverse ; inline

: binary-skew-below ( n -- ns )
    BINARY-SKEW-NUMBERS [ >= ] with lwhile lreverse ;

: (>binary-skew) ( n bsn -- n bsn/f )
    [ ] [ >= ] 2bi [ [ - ] keep ] [ drop f ] if ;

: >binary-skew ( n -- ns )
    dup binary-skew-below
    [ (>binary-skew) ] lmap' [ ] lfilter lreverse
    swap 0 > [ [ car ] keep cons ] when ;

: binary-skew+1 ( ns -- ns' )
    dup 2 llength>= [
      dup 2car =
      [ uncons cdr [ 2 * 1 + ] dip cons ] [ 1 swons ] if
    ] [ 1 swons ] if ;

: binary-skew-1 ( ns -- ns' )
    dup car 1 =
    [ cdr ] [ unswons 1 - 2 / [ swons ] [ swons ] bi ] if ;
