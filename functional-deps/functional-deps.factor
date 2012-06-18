! Copyright (C) 2011 Brendan MacDonell.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs deadlock-detection fry hash-sets kernel
math.statistics prettyprint.backend prettyprint.custom sequences sets
simple-tokenizer splitting strings.parser vectors ;
IN: functional-deps

TUPLE: dependency lhs rhs ;

ERROR: bad-dep-string line ;

: group-by ( seq quot: ( elt -- key ) -- hashtable )
    '[ [ dup @ ] dip push-at ] sequence>hashtable ; inline

: <dependency> ( lhs rhs -- dep )
    [ members <hash-set> ] bi@ dependency boa ; inline foldable

: parse-dep ( str -- dep )
    ">" split1 dup [ over bad-dep-string ] unless
    [ tokenize ] bi@ <dependency> ; inline foldable

: parse-deps ( str -- deps )
    [ CHAR: \n = not ] filter ";" split harvest
    [ parse-dep ] map ; inline foldable

SYNTAX: Fs"
    parse-multiline-string parse-deps suffix! ;

: format-dep ( dep -- str )
    [ lhs>> ] [ rhs>> ] bi
    [ members " " join ] bi@ " > " glue ; inline

: format-deps ( deps -- str )
    [ format-dep ] map ";\n" join ;

M: dependency pprint*
    [ format-dep "F\" " "\"" surround ] keep present-text ;

: reflexive? ( dep -- ? )
    [ rhs>> ] [ lhs>> ] bi subset? ; inline

: transitive-deps ( lhs deps -- rhs+ )
    [ dup ] dip [ lhs>> swap subset? ] with filter
    [ rhs>> ] map combine union ; inline

: closure ( lhs deps -- rhs+ )
    [ [ transitive-deps ] keep over ] until-stable drop ;

: implied? ( dep deps -- ? )
    [ [ rhs>> ] [ lhs>> ] bi ] dip closure subset? ; inline

: split-dep ( dep -- deps )
    [ lhs>> clone ] [ rhs>> ] bi members
    [ 1array <dependency> ] with map ; inline

: split-deps ( deps -- deps )
    [ split-dep ] map concat ; inline

: lhs- ( attr dep -- dep' )
    [ lhs>> clone [ delete ] keep ] [ rhs>> ] bi
    <dependency> ; inline

: ((lhs-minimize)) ( attr dep deps -- )
    [ 2dup lhs- ] dip implied?
    [ lhs>> delete ] [ 2drop ] if ; inline

: (lhs-minimize) ( dep deps -- )
    [ [ lhs>> members ] keep ] dip
    [ ((lhs-minimize)) ] 2curry each ; inline

: lhs-minimize ( deps -- deps- )
    dup dup [ (lhs-minimize) ] curry each ;

: ((minimize-deps)) ( dep deps -- )
    2dup [ delete ] [ implied? ] 2bi
    [ 2drop ] [ adjoin ] if ; inline

: (minimize-deps) ( deps -- deps- )
    lhs-minimize split-deps [ reflexive? not ] filter
    [ >vector ] keep over [ ((minimize-deps)) ] curry each ; inline
 
: minimize-deps ( deps -- deps- )
    (minimize-deps) [ lhs>> ] group-by
    [ [ rhs>> members ] map concat <dependency> ] { } assoc>map ;
