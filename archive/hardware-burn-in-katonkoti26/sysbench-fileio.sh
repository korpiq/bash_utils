#!/bin/bash

CPU_TAG="$(lscpu | sed -ne 's/^Model name:.* //p')"

mkdir -p test-fileio
(
    set -e
    cd test-fileio
    for t in seqwr seqrewr seqrd rndrd rndwr rndrw
    do
        CMD="sysbench fileio --num-threads=40 --validate --file-total-size=10G --file-test-mode=$t"
        $CMD prepare
        time $CMD run 2>&1 | tee "../$CPU_TAG-sysbench-fileio-$t.txt"
        $CMD cleanup
    done
)
rmdir test-fileio
