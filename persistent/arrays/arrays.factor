! Copyright (C) 2011 Brendan MacDonell.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel lists locals math sequences
sequences.private persistent.sequences ;
IN: persistent.arrays

TUPLE: tree  { value read-only } { left read-only }
    { right read-only } { size read-only } ;

TUPLE: persistent-array { size read-only } { trees read-only } ;

: tree-size ( tree -- size )
    dup nil? [ drop 0 ] [ size>> ] if ; inline

: <tree> ( v l r -- tree )
    2dup [ tree-size ] bi@ + 1 + tree boa ; inline

: <singleton-tree> ( v -- tree )
    nil nil 1 tree boa ; inline

: <persistent-array> ( -- array )
    0 nil persistent-array boa ; inline

: llength>= ( l n -- ? )
    [ 2dup [ nil? not ] [ 0 > ] bi* and ]
    [ [ cdr ] [ 1 - ] bi* ] while nip zero? ; inline

: first-lengths-match? ( trees -- ? )
    2car [ size>> ] bi@ = ; inline

: nth-in-list? ( n list -- n list ? )
    2dup car size>> < ;

: offset-in-rest ( n list -- n' cdr )
    uncons [ size>> - ] dip ; inline

: find-tree-for-nth ( n list -- n' tree )
    [ nth-in-list? ] [ offset-in-rest ] until car ; inline

: potential-nodes ( tree n -- tree nl nr )
    1 - 2dup swap size>> 1 - 2 / - ; inline

: subtree-for-nth ( tree n -- tree' n' left? )
    potential-nodes dup 0 <
    [ drop [ left>> ] dip t ]
    [ nip [ right>> ] dip f ] if ; inline

: find-node-for-nth ( tree n -- tree' )
    [ dup zero? ] [ subtree-for-nth drop ] until drop ; inline

M: persistent-array length ( seq -- n ) size>> ; inline

M: persistent-array nth-unsafe ( n seq -- elt )
    trees>> find-tree-for-nth swap find-node-for-nth value>> ;

: jn-singleton ( car cdr -- car' cdr )
    [ <singleton-tree> ] dip ; inline

: jn-with-list ( car cdr -- car' cdr' )
    dup first-lengths-match?
    [ uncons uncons [ <tree> ] dip ] [ jn-singleton ] if ; inline

M: persistent-array ppush ( car array -- array' )
    [ size>> ] [ trees>> ] bi swapd
    dup 2 llength>= [ jn-with-list ] [ jn-singleton ] if
    cons [ 1 + ] dip persistent-array boa ;

: >persistent-array ( seq -- array )
    T{ persistent-array } like ;

: hd ( array -- car )
    trees>> car value>> ; inline

: (tl) ( cdr car -- list )
    [ right>> ] [ left>> ] bi [ swons ] [ swons ] bi* ; inline

M: persistent-array ppop ( array -- array' )
    [ size>> ] [ trees>> ] bi unswons
    dup size>> 1 = [ drop ] [ (tl) ] if
    [ 1 - ] dip persistent-array boa ;

: tree-with-value ( v tree -- tree' )
    [ left>> ] [ right>> ] bi <tree> ; inline

:: tree-with-left ( l tree -- tree' )
    tree value>> l tree right>> <tree> ; inline

:: tree-with-right ( r tree -- tree' )
    tree value>> tree left>> r <tree> ; inline

DEFER: replace-nth-in-tree

: (replace-nth-in-tree) ( v tree n -- tree' )
    [ subtree-for-nth [ replace-nth-in-tree ] dip ] [ drop ] 2bi
    swap [ tree-with-left ] [ tree-with-right ] if ; inline

: replace-nth-in-tree ( v tree n -- tree' )
    dup 0 =
    [ drop tree-with-value ] [ (replace-nth-in-tree) ] if ;

: replace-nth-in-car ( v n list -- car' cdr )
    [ car swap replace-nth-in-tree ] [ 2nip cdr ] 3bi ; inline

DEFER: replace-nth-in-list

: replace-nth-in-cdr ( v n list -- car cdr' )
    [ 2nip car ]
    [ offset-in-rest replace-nth-in-list ] 3bi ; inline

: replace-nth-in-list ( v n list -- list' )
    nth-in-list?
    [ replace-nth-in-car ] [ replace-nth-in-cdr ] if cons ;

M: persistent-array new-nth ( v n array -- array' )
    2dup size>> >= [ [ drop ] 2dip bounds-error ] when
    [ trees>> replace-nth-in-list ] keep
    size>> swap persistent-array boa ;

INSTANCE: persistent-array immutable-sequence
