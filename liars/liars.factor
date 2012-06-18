! Copyright (C) 2011 Brendan MacDonell.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs io io.encodings.utf8 io.files kernel locals
math.parser sequences splitting undirected-graph ;
IN: liars

: write-number ( n -- )
    number>string write ;

: read-group-header ( lines -- name lines' rest )
    unclip " " split1 string>number swapd cut-slice ;

: insert-vertex ( name graph -- )
    0 -rot set-vertex ;

: insert-link ( from to graph -- )
    3dup [ insert-vertex ] curry bi@ add-edge ;

:: read-group ( lines graph -- rest graph' )
    lines read-group-header :> rest ! name lines'
    [ graph insert-link ] with each
    rest graph ;

: read-groups ( lines -- graph )
    <undirected-graph> [ over empty? ] [ read-group ] until nip ;

: read-file ( name -- graph )
    utf8 file-lines 1 tail read-groups ;

DEFER: color-vertex

:: color-vertices ( color vertices graph -- )
    color not :> color
    vertices [ color swap graph color-vertex ] each ;

: color-vertex ( color vertex graph -- )
    2dup get-vertex 0 =
    [ 3dup set-vertex [ neighbours ] keep color-vertices ]
    [ 3drop ] if ;

: color-graph ( graph -- graph' )
    t over [ values>> keys first ] keep color-vertex ;

: report-liars ( vertices -- )
    [ [ ] count ] [ [ not ] count ] bi
    write-number " " write write-number nl ;

: solve-liars ( name -- )
    read-file color-graph values>> values report-liars ;
