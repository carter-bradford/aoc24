# Sorts the lists, subtracts their values and takes the absolute value
# then reduces (sums) the result
PairWiseDistance ← +´∘|(-○∧)

# Converts the lists into two dimenional arrays (one row-wise and one column-wise)
# and then compares them.   Then sums up the columns in each row to get the number of
# occurences of each value in the first list.
# Does a pairwise multiplication of list1 and the occurence count 
# and then sums/reduces the result
SimilarityScore ← +´(⊣×(+˝˘(⊢⌜)=(⊣⌜)))

# Read the lines from each list
list1 ← •ParseFloat¨ •FLines "list1.txt"
list2 ← •ParseFloat¨ •FLines "list2.txt"

•Show list1 PairWiseDistance list2
•Show list1 SimilarityScore list2
