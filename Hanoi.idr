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

Show Peg where
    show First = "First"
    show Second = "Second"
    show Third = "Third"

intToPeg : Int -> Maybe Peg
intToPeg i =
    if (i == 1) then Just First
    else if (i == 2) then Just Second
    else if (i == 3) then Just Third
    else Nothing

pegToFin : Peg -> Fin 3
pegToFin First = 0
pegToFin Second = 1
pegToFin Third = 2

Disposition : Nat -> Type
Disposition numberOfDisks = Vect numberOfDisks Peg

exampleDisposition : Disposition 4
exampleDisposition = [First, Second, Third, First]

startingDisposition : Disposition n
startingDisposition = replicate _ First

winningDisposition : Disposition n
winningDisposition = replicate _ Second

-- convert disposition to a data structure easier to draw
perPegRepresentation : Disposition n ->  Vect 3 (List (Fin n))
perPegRepresentation {n = Z} [] = [[], [], []]
perPegRepresentation {n = (S len)} (x :: xs) with (natToFin len (S len))
    | Just l = let previous = map (map weaken) (perPegRepresentation xs) in
        updateAt (pegToFin x) (l ::) previous
    | Nothing = [[], [], []]

-- test perPegRepresentation
emptyTest : perPegRepresentation [] = [[], [], []]
emptyTest = Refl

oneDiskTest : perPegRepresentation [First] = [[FZ], [], []]
oneDiskTest = Refl

twoDisksOnTheSamePegTest : perPegRepresentation [First, First] = [[FS FZ, FZ],[],[]]
twoDisksOnTheSamePegTest = Refl

twoDisksOnDifferentPegsTest : perPegRepresentation [First, Second] = [[FS FZ],[FZ],[]]
twoDisksOnDifferentPegsTest = Refl

threeDisksTest : perPegRepresentation [First, Second, Third] = [[FS (FS FZ)], [FS FZ], [FZ]]
threeDisksTest = Refl

move : (from : Peg) -> (to : Peg) -> {auto prf : (from /= to) = True} -> Disposition n -> Maybe (Disposition n)
move from to [] = Nothing
move from to (smallestDiskPosition :: restOfTheDisposition) =
    if from == to
    then Nothing
    else if to == smallestDiskPosition
        then Nothing
        else if from == smallestDiskPosition
            then Just (to :: restOfTheDisposition)
            else map (smallestDiskPosition ::) (move from to restOfTheDisposition)

moveFirstToSecond : move First Second [First, First, First] = Just [Second, First, First]
moveFirstToSecond = Refl

moveSecondDisk : move Second Third [First, Second, Third] = Just [First, Third, Third]
moveSecondDisk = Refl

-- moveSamePeg : move First First [First, First, First] = Nothing
-- moveSamePeg = Refl

wrongMove : move Second Third [First, First, Third] = Nothing
wrongMove = Refl

move' : (from : Peg) ->
    (to : Peg) ->
    {auto prf : (from /= to) = True} ->
    (disposition : Disposition n) ->
    {auto justPrf : IsJust (move from to disposition)} ->
    Disposition n
move' from to disposition with (move from to disposition)
    | Just newDisposition = newDisposition
    | Nothing impossible
