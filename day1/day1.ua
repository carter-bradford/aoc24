# Experimental!

FirstFileString  ← &fras "list1.txt"
SecondFileString ← &fras "list2.txt"

FirstList  ← ⍆⋕⊜□ ⊸≠@\n FirstFileString
SecondList ← ⍆⋕⊜□ ⊸≠@\n SecondFileString

PartOneResult ← /+ ⌵ - FirstList SecondList

&p PartOneResult

# Convert First List to a 2D array
PartTwoResult ← /+×(≡/+⊞= FirstList SecondList) FirstList
&p PartTwoResult
