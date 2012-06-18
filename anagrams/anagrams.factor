! Copyright (C) 2011 Brendan MacDonell.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs hashtables io io.encodings.utf8
io.files kernel locals math math.vectors sequences sets ;
IN: anagrams

TUPLE: phrase pvector pstring ;
C: <phrase> phrase

: make-alphabet ( s -- alphabet )
    unique keys dup length <hashtable>
    [ [ swapd set-at ] curry each-index ] keep ;

: inc-nth ( n v -- )
    [ nth 1 + ] [ set-nth ] 2bi ; inline

: count-letter ( alphabet v c -- alphabet v )
    pick at dup [ over inc-nth ] [ drop ] if ; inline

: make-phrase-vector ( alphabet s -- v )
    [ dup assoc-size 0 <repetition> >array ] dip
    [ count-letter ] each nip ; inline

: phrase-with-count ( alphabet s -- phrase )
    [ make-phrase-vector ] [ <phrase> ] bi ; inline

: phrases-with-counts ( alphabet ss -- phrases )
    [ phrase-with-count ] with map
    [ [ pvector>> sum ] [ pstring>> length ] bi = ] filter ;

: append-phrase ( phrase accum -- accum' )
    [ pstring>> ] dip dup
    empty? [ drop ] [ swap " " glue ] if ; inline

: suffix-to! ( elt seq -- )
    swap suffix! drop ; inline

:: (anagrams) ( remaining accum phrases results -- )
    phrases [ pvector>> remaining v<= vall? ] filter :> phrases
    phrases [
        [ pvector>> remaining swap v- ]
        [ accum append-phrase ] bi
        over sum zero?
        [ nip results suffix-to! ]
        [ phrases results (anagrams) ] if
    ] each ;

: preprocess-sentence ( sentence -- alphabet v )
    >lower [ blank? not ] filter
    [ make-alphabet dup ] keep make-phrase-vector ;

: load-phrase-list ( path min-length -- phrases )
    [ utf8 file-lines [ >lower ] map ] dip
    [ [ length ] dip >= ] curry filter ;

: anagrams ( sentence words -- phrases )
    [ preprocess-sentence swap ] dip
    phrases-with-counts [ "" ] dip V{ } clone
    [ (anagrams) ] keep ;
