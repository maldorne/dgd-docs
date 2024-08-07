#!/bin/bash

# This script will convert the DGD documentation to markdown format.
# It will generate a README.md file with links to the converted files, and
# a markdown file for every kfun in the kfun directory.

echo "Converting documentation to markdown..."

# create directory 'pages' if it doesn't exist
mkdir -p pages

# copy the lpc reference manual
mkdir -p pages/lpc
cp LPC.md pages/lpc/index.md
  echo "---
title: LPC Reference Manual
date: `date '+%Y-%m-%d %H:%M:%S'`
language: en
---" | cat - pages/lpc/index.md > temp && mv temp pages/lpc/index.md

# copy every file in the list to a markdown file

# list of files to convert
FILES=( "Introduction" "parser" "editor" "ed-quickref" )

for file in "${FILES[@]}"
do
  mkdir -p pages/$file
  cp $file pages/$file/index.md
  echo "---
title: $file
date: `date '+%Y-%m-%d %H:%M:%S'`
language: en
---
\`\`\`" | cat - pages/$file/index.md > temp && mv temp pages/$file/index.md
  echo "\`\`\`" >> pages/$file/index.md
done

# generate a general index
echo "---
title: DGD Documentation
date: `date '+%Y-%m-%d %H:%M:%S'`
language: en
---" > index.md
echo "This is a collection of markdown files automatically generated from [the official DGD documentation](https://github.com/dworkin/lpc-ext)." >> index.md
echo "" >> index.md
echo "## General information" >> index.md
echo "" >> index.md
echo "* [LPC Reference Manual](pages/lpc/)" >> index.md

for file in "${FILES[@]}"
do
  echo "* ["$file"](pages/"$file"/)" >> index.md
done

echo "" >> index.md
echo "## Kernel functions (_kfuns_) documentation" >> index.md
echo "" >> index.md

# remove previously generated kfuns markdown files
rm -Rf kfuns
# list every file in the kfun directory, and store the names in an array
KFUN_FILES=( $(ls kfun) )

for file in "${KFUN_FILES[@]}"
do
  mkdir -p kfuns/$file

  # echo "# "\`$file\` >> kfun/$file.md
  # echo "" >> kfun/$file.md
  echo "---
title: Kernel function $file
date: `date '+%Y-%m-%d %H:%M:%S'`
language: en
---" >> kfun/$file.md
  echo "" >> kfun/$file.md



  echo "* [\`"$file"\`](kfuns/"$file")" >> index.md

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
        # echo $line

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
          # change kfun to kfuns inside element
          element=$(echo $element | sed 's/kfun/kfuns/g')
          echo "* [\`"$element"\`](../../"$element"/)" >> kfun/$file.md
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

  mv kfun/$file.md kfuns/$file/index.md

done
