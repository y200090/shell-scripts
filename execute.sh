#!/bin/bash

FILENAME=$1
if [ -z $FILENAME ]; then
    return 0
fi

case "$FILENAME" in
    *\.py)
        echo "python $FILENAME"
        python $FILENAME
        ;;
    *\.c)
        echo "cc $FILENAME && ./a.out" 
        # cc $FILENAME && ./a.out
        ;;
    *)
        echo "Invalid execution."
        return 0
        ;;
esac
