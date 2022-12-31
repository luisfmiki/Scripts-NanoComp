#!/bin/bash
#nmlsim truth table automation by luisfmiki

############### argument parsing section #################

counter_in=0
input_mags=()
counter_out=0
output_mags=()

while [ -n $1 ] && ! [ -z $1 ]
do
    case "$1" in
        -i)
            input_mags[$counter_in]=$2
            counter_in=$[$counter_in + 1]
            shift
            while [ $2 != "-o" ]
            do
                counter_in=$[$counter_in + 1]
                input_mags[$counter_in]=$2
                shift
            done
            shift
            while [ -n $2 ] && ! [ -z $2 ] && [ $2 != "-p" ]
            do
                output_mags[$counter_out]=$2
                counter_out=$[$counter_out + 1]
                shift
            done
            projectDir=$3;;
        -o)
            output_mags[$counter_out]=$2
            counter_out=$[$counter_out + 1]
            shift
            while [ $2 != "-i" ]
            do
                counter_out=$[$counter_out + 1]
                output_mags[$counter_out]=$2
                shift
            done
            shift
            while [ -n $2 ] && ! [ -z $2 ] && [ $2 != "-p" ]
            do
                input_mags[$counter_in]=$2
                counter_in=$[$counter_in + 1]
                shift
            done
            projectDir=$3;;
        -f)
            if [ -f $2 ]
            then
                magfile=$2
            else
                echo "Invalid file"
                exit
            fi;;
        -p)
            projectDir=$2
            shift;;
        -t)
            simTime=$2
            shift;;
        -*) 
            echo "Error: incorrect option"
            exit;;
    esac
    shift
done

unset counter_out
############### end of argument parsing section #################

############### file path extracting ############################
if [ -f "stpinfo.txt" ]
then
    configinfo=()
    counter=0
    for dir in `cat stpinfo.txt`
    do
        configinfo[$counter]=$dir
        counter=$[$counter+1]
    done
else
    echo "Execute o setup primero!"
    exit
fi

nmlpwd=${configinfo[0]}
projpwd=${configinfo[1]}/$projectDir
plotpwd=${configinfo[2]}
############### end of file path extracting #####################


############### setting the inputs in the xml file ##############
if [ -n "$simTime" ]
then
    sed -e "s/<property simTime=\"[0-9]\+\"\/>/<property simTime=\"${simTime}\"\/>/" \
    $projpwd/simulation.xml > $projpwd/simulationTemp0.xml
else
    cp $projpwd/simulation.xml $projpwd/simulationTemp0.xml
fi

for(( i=0;i<$counter_in;i++)) {
    sed -e "/<item name=\"Magnet_${input_mags[$i]}\">/,/<\/item>/ s/<property fixedMagnetization=\"false\"\/>/<property fixedMagnetization=\"true\"\/>/" \
    $projpwd/simulationTemp$i.xml > $projpwd/simulationTemp$[$i+1].xml
    rm $projpwd/simulationTemp$i.xml
}

getComb=`awk "NR==$counter_in" ./stpinfo.txt`

for comb in $getComb
do
    if [ 2 -eq $counter_in ]
    then
        mag1=${comb:0:5}
        mag2=${comb:5:5}

        sed -e "/<item name=\"Magnet_${input_mags[0]}\">/,/<\/item>/ s/<property magnetization=\"0.99,0.141,0\"\/>/<property magnetization=\"0.141,${mag1},0\"\/>/;\
        /<item name=\"Magnet_${input_mags[0]}\">/,/<\/item>/ s/<property magnetization=\"0.99,0.141,0,\"\/>/<property magnetization=\"0.141,${mag1},0\"\/>/" \
        $projpwd/simulationTemp$counter_in.xml > $projpwd/simulation${comb}t.xml
        sed -e "/<item name=\"Magnet_${input_mags[1]}\">/,/<\/item>/ s/<property magnetization=\"0.99,0.141,0\"\/>/<property magnetization=\"0.141,${mag2},0\"\/>/;\
        /<item name=\"Magnet_${input_mags[1]}\">/,/<\/item>/ s/<property magnetization=\"0.99,0.141,0,\"\/>/<property magnetization=\"0.141,${mag2},0\"\/>/" \
        $projpwd/simulation${comb}t.xml > $projpwd/simulation${comb}.xml
        
        rm $projpwd/simulation${comb}t.xml
    else
        #ToDo: aprimorar codiga acima e programar para entradas com n>2
        echo teste
    fi
done

rm $projpwd/simulationTemp$counter_in.xml
############### end of setting the inputs in the xml file ##############


############### simulation execution and plotting section ##############
j=0
for magnet in ${output_mags[*]}
do
    output_mags[$j]="Magnet_"$magnet
    j=$[$j+1]
done

if ! [ -d $projpwd/bashSims ]
then
    mkdir $projpwd/bashSims
fi

for comb in $getComb
do
    $nmlpwd/nmlsim $projpwd/simulation${comb}.xml $projpwd/simulation.csv
    python3 $nmlpwd/chartToFile.py $projpwd/simulation.csv $projpwd/bashSims/$comb.png ${output_mags[*]}
done

############### simulation execution and plotting section ##############