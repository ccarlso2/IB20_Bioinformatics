# this script will align files of interest and will search comparing to the other files; then, it'll create a file for each $1=firstrefgenefile $2=secondrefgenefiles and it will finally create a table with the number of gene hits in each proteome for each of the genes specified
# the script is flexible enough for 2 genes
# the outputs for the searches will be found in subdirectories in a directory calle output; directories will be created by the shell script 
# usage: bash projectbeta.sh refsequencesfilesforgene1 refsequencesfilesforgene2 
# specific usage for hsp/mcrA: bash projectbeta.sh ref_sequences/hsp70*.fasta ref_sequences/mcrA*.fasta 
# ---------------------------------------------------------------------------------------------------

# this part will create the directories where the search files and final table will be stored
# if you want to change the name of these directories, you can, but you will have to also change the locations in both for loops that are found below 
# gene1output will have the search results for the first gene specified
# gene2output will have the search results for the second gene specified
# output will have the final table with the name of the proteome and number of hits for each gene

mkdir output 
mkdir ./output/gene1output 
mkdir ./output/gene2output

# this part will put all of the reference files for each gene into the same file; you will end with two files that will be stored in your current directory (not in output) 
# the second step of this will align the reference files using muscle and will create profile with muscle; depending on the computer you're using to run this, you will have to change where hmmbuild and muscle are located 
# usage for muscle: path_to_muscle -in gene1.fasta gene1v1.fasta
# usage for hmmbuild: path_to_hmmbuild gene1v2.fasta gene1v1.fasta
# all of the files are fasta for now but can be changed to hmm (check with professor before handing in project)

cat $1 > gene1.fasta ~/muscle -in gene1.fasta -out gene1v1.fasta 
~/local/bin/hmmbuild gene1v2.fasta gene1v1.fasta 
cat $2 > gene2.fasta ~/muscle -in gene2.fasta -out gene2v1.fasta 
~/local/bin/hmmbuild gene2v2.fasta gene2v1.fasta 


#do not change ./proteomes/*.fasta for $3 because it hasn't been working (check with prof before handing in project)
# this loop will search each proteome file against the hmmr files created for each gene 
# once again, make sure to change path to hmmsearch depending on where it is relative to the directory you're running this in 


for files in ./proteomes/*.fasta
do
echo $files
name=$(echo $files | cut -d / -f 3 | cut -d . -f 1)
~/local/bin/hmmsearch --tblout ./output/gene1output/${name}_search1output.fasta gene1v2.fasta ${files}
~/local/bin/hmmsearch --tblout ./output/gene2output/${name}_search2output.fasta gene2v2.fasta ${files}
done 

# this part will create a table with the name of the proteome, the number of hits of gene 1, and the number of hits of gene 2; table will be found in output directory
# hits will be calculate by inverse grepping for # and wc the number of lines = number of hits
# then you will create variables for these (see below) and append to the file finaltable1.csv


cd output
echo "name of proteome,gene1 hits,gene2 hits" > finaltable1.csv
cat finaltable1.csv

for files in ./gene1output/*.fasta
do
#echo hola (use to troubleshoot for loop)
proteome=$(echo $files | cut -d / -f 3 | cut -d _ -f 1,2) 
gene1_hits=$(cat $files | grep -v "#" | wc -l)
gene2_hits=$(cat $(find ./gene2output/${proteome}_search2output.fasta)|  grep -v "#" | wc -l)
#echo $proteome (use to troubleshoot the name of the proteome)
#echo $gene2_hits (use to troubleshoot that find, grep, and wc are working for gene2)
echo ${proteome},${gene1_hits},${gene2_hits} >> finaltable1.csv
#echo "last step"
done

echo "Your table has been created. Go to output directory and cat finaltable1.csv to call to stdout the contents of your table. If error in any step, go to nano projectbeta.sh and remove # from the troubleshoot lines. Have a good day!"


