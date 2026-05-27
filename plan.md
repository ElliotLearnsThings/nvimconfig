we have now that dhtn - hjkl

### if I make a map \phi such that:

d --> h
h --> j
t --> k
n --> l
then the kernal is hkjl, but h is in the image so the kernal is just
dtn, we want a bijection so we need to create a second map for the duplicates such that we pass each duplicate into one other element, we then find the non injecive elements of the preimage that are not a part of the kernal are
jkl
(note this means that d --> h and h --> d would make a bijection, thus we use this to simplify into just 3 elements we need to map)
and we have dnt to create the surjection, thus I need to pick 3 disjoint 2 cycle permutations of elements to make the mapping \phi_2(\phi_1(x)) a bijection, we must have that all these cycles are unique (by halls theorum), thus, we rate the preimage choice by ease to type and the image choice by common use, we have ntd, n is next, t is to and d is delete.
| key | usefulness |
| - | - |
| n | .5 |
| t | .4 |
| d | .8 |

| key | ease |
| --- | ---- |
| l   | .7   |
| j   | .75  |
| k   | .5   |

thus we can create the following otimate permutation to make our map a bijection:

\phi_2 is defined by
t --> k
n --> l
d --> j

or in cycle notation we have:
(dj)(nl)(tk)(dh)

but we have the constaint that we must have hjkl in that order, so we cannot choose this freely by this constaint - and by halls and a fixed automorphism there is only one complete valid matching, which by cycle notation is:

(nl)(tk)(dj)(dh), this is a bijection that preserves hjkl positions in the image and keeps dvorak positions everywhere else for normal mode in vim. The total permutation is thus

(nl)(tk)(jdh) - this is the final permutaion for normal mode

is it injective? we only care about our base elements but given a single application - this is a subelement of S_7 so yes it if I make a map such thatis it surjective? by being a set of disjoint cycles - yes it is surjective in n = 7, and the only valid solution

thus (nl)(tk)(jdh) is the only solution permutation to preserve hjkl positions in nvim normal mode
