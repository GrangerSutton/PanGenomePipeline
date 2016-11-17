#!/usr/bin/env sh

# Bash script to make UPGMA and Neighbor-Joining trees of core and all proteins using the PanOCT BSR distance matrices in a pseudo Phylip format (PanOCT Phylip matrix was not quite right before - may be fixed now:

# 0_pairwise_BSR_distance_matrix_phylip.txt = ALL protein BSR distance matrix
# 100_pairwise_BSR_distance_matrix_phylip.txt = CORE protein BSR distance matrix

# Usage: make_BSR_UPGMA_trees.sh <complete_path_to_pan-genome_base_directory> <path to source dir>

# declare variables
base_dir=$1
results_dir="$base_dir/results"
BSR_trees_dir="$results_dir/BSR_trees"
core_trees_dir="$BSR_trees_dir/core_trees"
all_trees_dir="$BSR_trees_dir/all_trees"
cdm="100_pairwise_BSR_distance_matrix_phylip.txt"
adm="0_pairwise_BSR_distance_matrix_phylip.txt"
# Will want to change srcdir to the pan-genome bin directory
src_dir=$2

# declare function create_dir that first checks for the presence of a directory, then creates it if absent

function create_dir {
   name=$1
   if [ ! -d $name ]
     then
       echo " $name is not present, generating ..."
       mkdir $name
   fi
}

# delcare function make_trees to make infile, generate tree and make a pdf file

function make_trees {
   file=$1 # file is the name of the appropriate BSR distance matrix
   name=$2 # second variable passed is "core" or "all"

 # make the required Phylip "infile" from the appropriate BSR distance matrix
   echo " creating Phylip infile from $file ..."
   cat $results_dir/$file | perl -ne 'chomp; @a=split(/\t/); $line = join("  ", @a); print "$line\n";' > infile

 # generate a UPGMA tree using the Phylip program neighbor
   echo " generating UPGMA $name tree ..."
   $src_dir/UPGMA_tree_batch

 # rename the UPGMA output files
   mv outfile outfile\_$name\_panBSR_UPGMA
   mv outtree outtree\_$name\_panBSR_UPGMA.tre

 # generate Neighbor-Joining tree
   echo " generating Neighbor-Joining $name tree ..."
   $src_dir/neighbor_joining_tree_batch

 # rename the Neighbor-Joining output files
   mv outfile outfile\_$name\_panBSR_NJ
   mv outtree outtree\_$name\_panBSR_NJ.tre

 # to make a pretty picture of the tree files (i.e., .pdf files)
 # you will want to move this to the src directory for the pan-genome pipeline
   echo " making .pdf files ..."
   ruby -I $src_dir/../lib/ruby $src_dir/Newick-ruby/newickDraw outtree\_$name\_panBSR_UPGMA.tre
   ruby -I $src_dir/../lib/ruby $src_dir/Newick-ruby/newickDraw outtree\_$name\_panBSR_NJ.tre
}

# Check for presence of BSR_trees directory. If not, create it
create_dir $BSR_trees_dir

############## CORE proteins ##############

# Check if core_trees directory is present.  If not, make it and move to it
create_dir $core_trees_dir

# move to newly created directory
echo "Working on core pan-genome:"
cd $core_trees_dir

# call make_trees subroutine to generate the tree
make_trees $cdm "core"

############## ALL proteins ##############

# Check if all_trees directory is present.  If not, make it and move to it
create_dir $all_trees_dir

# move to newly created directory
echo "Working on ALL pan-genome:"
cd $all_trees_dir

# call make_trees subroutine to generate the tree
make_trees $adm "all"

echo "Finished making UPGMA BSR trees"
exit
