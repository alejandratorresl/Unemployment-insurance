********************************************************************************
* Main file
********************************************************************************

global dir "C:\Users\MTORRESLEON\Dropbox\Alejandra_RA\Unemployment insurance"
cd "$dir\Do files"

do "1. IPUMS.do" // Arrange data from IPUMS

do "1.1. Clean data.do" // Create useful variables

do "2. Probabilities.do" // Calculate transition probabilities

do "3. Graphs.do" // Graphs

do "4. Estimations.do" // FE and probability estimations

cd "$dir\Do files"
do "4.1. estimations dissagregated.do"

cd "$dir\Do files"
do "4.2. estimations dynamic.do"