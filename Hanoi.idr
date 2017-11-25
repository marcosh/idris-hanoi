module Main

import Data.Vect

data Peg
    = First
    | Second
    | Third

Eq Peg where
    First == First = True
    Second == Second = True
    Third == Third = True
    _ == _ = False

Disposition : Nat -> Type
Disposition numberOfDisks = Vect numberOfDisks Peg

exampleDisposition : Disposition 4
exampleDisposition = [First, Second, Third, First]

startingDisposition : Disposition n
startingDisposition = replicate _ First

winningDisposition : Disposition n
winningDisposition = replicate _ Second

move : (from : Peg) -> (to : Peg) -> (from /= to) = True -> Disposition n -> Maybe (Disposition n)
move from to prf [] = Nothing
move from to prf (smallestDiskPosition :: restOfTheDisposition) =
    if from == to
    then Nothing
    else if to == smallestDiskPosition
        then Nothing
        else if from == smallestDiskPosition
            then Just (to :: restOfTheDisposition)
            else map (smallestDiskPosition ::) (move from to prf restOfTheDisposition)

moveFirstToSecond : move First Second Refl [First, First, First] = Just [Second, First, First]
moveFirstToSecond = Refl

moveSecondDisk : move Second Third Refl [First, Second, Third] = Just [First, Third, Third]
moveSecondDisk = Refl

-- moveSamePeg : move First First Refl [First, First, First] = Nothing
-- moveSamePeg = Refl

wrongMove : move Second Third Refl [First, First, Third] = Nothing
wrongMove = Refl
