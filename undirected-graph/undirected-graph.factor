! Copyright (C) 2011 Brendan MacDonell.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel ;
IN: undirected-graph

TUPLE: undirected-graph edges values ;

: <undirected-graph> ( -- graph )
    H{ } clone dup clone undirected-graph boa ;

: set-vertex ( value key graph -- )
    values>> set-at ;

: get-vertex ( key graph -- value )
    values>> at ;

: add-edge ( a b graph -- )
    edges>> [ push-at ] [ swapd push-at ] 3bi ;

: neighbours ( vertex graph -- seq )
    edges>> at ;
