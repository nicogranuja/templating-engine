#!/bin/bash

set -eo pipefail

# Bash variables
dataDir="$1"
template="$2"
date="$3"
outputDir="$4"

openSymbol="<<"
closeSymbol=">>"


# Check for at least 4 arguments
if [[ "$#" -lt 4 ]]; then
    echo "Illegal number of arguments expected at least 4 got $#"
    exit 1
fi

# Create output directory if it doesn't exist
if [[ ! -d $outputDir ]]; then
    echo "Output directory does not exist creating it..."
    mkdir $outputDir
fi

# Check for 5th and 6th parameters to change these symbols
if [[ "$#" -eq 6 ]];then
    openSymbol="$5"
    closeSymbol="$6"
fi

# Returns true if the 10% of the inventory is greater than or equal to the qty
function isLessThanTenPercent {
    qty=$1
    inventory=$2
    tenPercentOfValue=$(( $inventory * 10 / 100))

    if [[ $tenPercentOfValue -ge $qty ]];then
        return 0
    fi

    return 1
}

# Get the files from the data directory
fileArray=($(ls $dataDir))

# Loop through the files individually
for file in "${fileArray[@]}"
do
    filePath="$dataDir/$file"
    qtyLine=$(sed '2q;d' $filePath)

    # If the inventory is not less than 10% continue to check the next file in the folder
    if ! isLessThanTenPercent $qtyLine; then
        continue
    fi

    itemNameLine=$(sed '1q;d' $filePath)
    descriptionLine=$(sed '3q;d' $filePath)

    # Get item name and simple name
    simpleName=$(echo $itemNameLine | awk '{ print $1; }')
    itemName=$(echo $itemNameLine | awk '{ for(i=2;i<NF;i++) printf("%s ",$i); printf("%s",$NF); }')

    # Get quantity and inventory
    qty=$(echo $qtyLine | awk '{ print $1; }')
    maxQTY=$(echo $qtyLine | awk '{ print $2; }')

    # Store value of template in templateOutput
    templateOutput="$(cat $template)"

    tmpIFS=$IFS
    IFS=$'\n'

    # Replace values using the template and create new file
    searchTerms=("${openSymbol}simple_name${closeSymbol}" "${openSymbol}item_name${closeSymbol}" "${openSymbol}current_quantity${closeSymbol}" "${openSymbol}max_quantity${closeSymbol}" "${openSymbol}body${closeSymbol}" "${openSymbol}date${closeSymbol}")
    replaceTerms=($simpleName $itemName $qty $maxQTY $descriptionLine $date)
    
    for i in "${!searchTerms[@]}"
    do
        searchTerm="${searchTerms[i]}"
        replaceTerm="${replaceTerms[i]}"
        templateOutput=$(echo "$templateOutput" | sed -e "s@$searchTerm@$replaceTerm@")
    done
    
    IFS=$tmpIFS

    # Get the output file name
    outputFileName=$(echo $file | awk -F "." '{ printf $1 }')
    outputFileName="${outputFileName}.out"

    # Save generated template
    echo "$templateOutput" > "$outputDir/$outputFileName"
done
