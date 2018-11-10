# templating-engine
Templating engine using AWK SED and BASH.

## description
It uses awk sed and bash to read data from expected .item files and insert it in the template passed as an arument creating a new generated template with the data.

## how to use
script takes 4 or 6 arguments
Example:
./assign4.bash ./data assign4.template 12/16/2021 ./output
* First argument is the data directory where the .item files will be in
* Second argument is the actual template
* Third is just a date
* Fourth is the output directory in which the generated templates with data will be written into

Optionals 5th and 6th are arguments are the characters that enclose the placeholders where the data will be inserted to.
