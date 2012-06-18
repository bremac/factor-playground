! Copyright (C) 2011 Brendan MacDonell.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel literals math math.vectors sequences words
;
IN: deadlock-detection

TUPLE: process pid requested allocated ;

CONSTANT: unstable $[ gensym ]

: <process> ( pid requested allocated -- process )
    process boa ;

: until-stable ( ... body: ( ... -- ... b ) -- ... )
    unstable swap '[ _ dip over = not ] loop drop ; inline

<PRIVATE
: partition-processes ( v p -- safe p' )
    [ requested>> v>= vall? ] with partition ;

: iterate-deadlocks ( v p -- v' p' )
    dupd partition-processes
    [ swap [ allocated>> v+ ] reduce ] dip ;

: (find-deadlocks) ( v p -- p' )
    [ iterate-deadlocks dup length ] until-stable nip ;

: eliminate-unused ( p -- p' )
    [ allocated>> sum 0 > ] filter ;
PRIVATE>

: find-deadlocks ( v p -- p' )
    eliminate-unused (find-deadlocks) ;
