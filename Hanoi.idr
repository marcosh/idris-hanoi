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

startingDisposition : Disposition n
startingDisposition = replicate _ First

winningDisposition : Disposition n
winningDisposition = replicate _ Second
