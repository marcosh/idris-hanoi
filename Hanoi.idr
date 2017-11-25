module Main

import Data.Vect

data Peg
    = First
    | Second
    | Third

Disposition : Nat -> Type
Disposition numberOfDisks = Vect numberOfDisks Peg

exampleDisposition : Disposition 4
exampleDisposition = [First, Second, Third, First]

-- fourthPegDisposition : Disposition
-- fourthPegDisposition = [0, 1, 2, 3]
