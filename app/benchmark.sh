#!/bin/bash
clear

OUTDIR="./results"
RESULTFILE="result.fiobench.csv"
TESTLISTE=(
  "Read-Max-BW"
  "Write-Max-BW"
  "Read-Max-IO"
  "Write-Max-IO"
  "Read-Rnd-Max-IO"
  "Write-Rnd-Max-IO"
)

function pre-checks {

    if [ ! -d $OUTDIR ]; then
        mkdir -p $OUTDIR
    fi
    if ! command -v jq &> /dev/null; then
        echo "jq könnte nicht gefunden werden. Bitte installiere jq, um fortzufahren."
        exit 1
    fi
    if ! command -v fio &> /dev/null; then
        echo "fio könnte nicht gefunden werden. Bitte installiere fio, um fortzufahren."
        exit 1
    fi
    if ! command -v bc &> /dev/null; then
        echo "bc könnte nicht gefunden werden. Bitte installiere bc, um fortzufahren."
        exit 1
    fi
    if ! command -v figlet &> /dev/null; then
        echo "figlet könnte nicht gefunden werden. Bitte installiere figlet, um fortzufahren."
        exit 1
    fi

    figlet FIO Bench

}

###########################################################################################################################

function runtest {   
    testname=$1
    echo "$testname" && echo ""
    rm ${OUTDIR}/${testname}.json > /dev/null 2>&1
    fio fio-settings.fio --eta-newline=1 --output-format=json --output=./results/${testname}.json --section=${testname}
    echo "" && echo ""
}

###########################################################################################################################

function write_values {
    
    json_file="${OUTDIR}/$1.json"
    testname=$1

    if [[ "$json_file" == *"Read"* ]]; then
        operation="read"
    elif [[ "$json_file" == *"Write"* ]]; then
        operation="write"
    else
        echo "Whut?"
        exit 1
    fi

    bw_min=$(jq ".jobs[0].${operation}.bw_min" $json_file)
    bw=$(jq ".jobs[0].${operation}.bw" $json_file)
    bw_min_mb=$(echo "$bw_min / 1024" | bc | xargs printf "%.0f\n")
    bw_mb=$(echo "$bw / 1024" | bc | xargs printf "%.0f\n")

    iops_min=$(jq ".jobs[0].${operation}.iops_min" $json_file)
    iops=$(jq ".jobs[0].${operation}.iops" $json_file)
    iops_min=$(echo "$iops_min" | bc | xargs printf "%.0f\n")
    iops=$(echo "$iops" | bc | xargs printf "%.0f\n")

    lat_ns_max=$(jq ".jobs[0].${operation}.lat_ns.max" $json_file)
    lat_ns_mean=$(jq ".jobs[0].${operation}.lat_ns.mean" $json_file)
    lat_ns_max_ms=$(echo "$lat_ns_max / 1000000" | bc | xargs printf "%.0f")
    lat_ns_mean_ms=$(echo "$lat_ns_mean / 1000000" | bc | xargs printf "%.0f")

    echo "${testname};${bw_mb};${bw_min_mb};${iops};${iops_min};${lat_ns_mean_ms};${lat_ns_max_ms}" >> ${OUTDIR}/${RESULTFILE}
}

###########################################################################################################################

function prep-result-file {
    rm ${OUTDIR}/${RESULTFILE} > /dev/null 2>&1
    echo "Test-Name;Bandbreite;Bandbreite-Min;Iops;Iops-Min;Latenz;Latenz-Max" >> ${OUTDIR}/${RESULTFILE}
}

###########################################################################################################################

function run-all-tests {

    for test in "${TESTLISTE[@]}"; do
    figlet ${test}
    runtest "$test"
    done
    
    for test in "${TESTLISTE[@]}"; do
    write_values "$test"
    done

    rm /fiodata/fio_data.bin > /dev/null 2>&1
}

###########################################################################################################################

pre-checks
prep-result-file
run-all-tests