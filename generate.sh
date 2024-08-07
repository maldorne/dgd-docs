#!/bin/bash

# This script will convert the DGD documentation to markdown format.
# It will generate a README.md file with links to the converted files, and
# a markdown file for every kfun in the kfun directory.

echo "Converting documentation to markdown..."

# list of files to convert
FILES=( "ed-quickref" "editor" "Introduction" "parser" )

# copy every file in the list to a markdown file
for file in "${FILES[@]}"
do
  cp $file $file.md
  #   echo "---
  # title: $file
  # date: `date '+%Y-%m-%d %H:%M:%S'`
  # language: en
  # ---" | cat - $file.md > temp && mv temp $file.md

  # pandoc -f commonmark -t markdown -o $file.md $file
done


echo "# DGD Documentation" > index.md
echo "" >> index.md
echo "This is a collection of markdown files generated from the DGD documentation." >> index.md
echo "" >> index.md
echo "## General information" >> index.md
echo "" >> index.md
echo "* [LPC Reference Manual](LPC.md)" >> index.md

for file in "${FILES[@]}"
do
  echo "* ["$file"]("$file.md")" >> index.md
done

echo "" >> index.md
echo "## kfuns documentation" >> index.md
echo "" >> index.md

# remove previously generated markdown files
rm kfun/*.md
# list every file in the kfun directory, and store the names in an array
KFUN_FILES=( $(ls kfun) )

for file in "${KFUN_FILES[@]}"
do
  echo "# "\`$file\` >> kfun/$file.md
  echo "" >> kfun/$file.md

  echo "* ["$file"](kfun/"$file.md")" >> index.md

  # read line by line the file and see its contents
  while IFS= read -r line
  do
    # line starts with space
    if [[ $line == " "* ]]; then
      echo $line >> kfun/$file.md
    # line starts with tab
    elif [[ $line == $'\t'* ]]; then
      echo "$line" >> kfun/$file.md
    elif [ -z "$line" ]; then
      echo "" >> kfun/$file.md
    elif [[ $line == "SEE ALSO" ]]; then
      echo "## SEE ALSO" >> kfun/$file.md
      echo "" >> kfun/$file.md

      # read next line
      while read -r line
      do
        echo $line

        # if line is "NOTE", break the loop
        if [[ $line == "NOTE" ]]; then
          echo "" >> kfun/$file.md
          echo "## NOTE" >> kfun/$file.md
          break
        fi

        # separate the line by the commas
        IFS=', ' read -r -a array <<< "$line"
        for element in "${array[@]}"
        do
          echo "* ["$element"]("$element.md")" >> kfun/$file.md
        done
      done

      echo "" >> kfun/$file.md

    else
      echo "## "$line >> kfun/$file.md
      echo "" >> kfun/$file.md
    fi

    # if [ -z "$LAST_LINE" ]; then
    #   continue
    # fi

    LAST_LINE=$line

  done < kfun/$file

done
