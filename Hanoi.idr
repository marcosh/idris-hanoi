module Main

import Data.Vect
import Effects
import Effect.StdIO

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

-- draw Hanoi Tower
finToNatProof : (n: Nat) -> Fin n -> (m: Nat ** LTE m n)
finToNatProof (S k) FZ = (0 ** LTEZero)
finToNatProof (S k) (FS x) = let prev = finToNatProof k x in
    (S (fst prev) ** (LTESucc (snd prev)))

diskLength : (n: Nat) -> Fin n -> Nat
diskLength totalDiskNumber disk = let diskAsNatWithProof = finToNatProof totalDiskNumber disk in
    (-) totalDiskNumber (fst diskAsNatWithProof) {smaller = snd diskAsNatWithProof}

drawDisk : (n: Nat) -> Fin n -> String
drawDisk totalDiskNumber disk = let margin = replicate (finToNat disk) " " in
    concat $ margin ++ (Prelude.List.replicate (2 * (diskLength totalDiskNumber disk) + 1) "_") ++ margin

addEmptyLines : (n : Nat) -> List String -> List String
addEmptyLines n xs = if (length xs < n)
    then addEmptyLines n $ concat (Prelude.List.replicate (2 * n + 1) " ") :: xs
    else xs

drawPeg : (n: Nat) -> List (Fin n) -> List String
drawPeg totalDiskNumber disks = addEmptyLines totalDiskNumber $ map (drawDisk totalDiskNumber) disks

concat3 : String -> String -> String -> String
concat3 x y z = x ++ y ++ z

drawHanoiTower : (n: Nat) -> Vect 3 (List (Fin n)) -> String
drawHanoiTower diskNumber [firstPeg, secondPeg, thirdPeg] =
    let
        drawFirstPeg = drawPeg diskNumber firstPeg
        drawSecondPeg = drawPeg diskNumber secondPeg
        drawThirdPeg = drawPeg diskNumber thirdPeg
    in
        unlines $ zipWith3 concat3 drawFirstPeg drawSecondPeg drawThirdPeg

draw : Disposition n -> String
draw {n} = (drawHanoiTower n) . perPegRepresentation

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

-- wrongMove : move Second Third [First, First, Third] = Nothing
-- wrongMove = Refl

move' : (from : Peg) ->
    (to : Peg) ->
    {auto prf : (from /= to) = True} ->
    (disposition : Disposition n) ->
    {auto justPrf : IsJust (move from to disposition)} ->
    Disposition n
move' from to disposition with (move from to disposition)
    | Just newDisposition = newDisposition
    | Nothing impossible

parseInput : String -> Maybe Int
parseInput input = toMaybe (all isDigit (unpack input)) (cast input)

parseInputToPeg : String -> Maybe Peg
parseInputToPeg input = (parseInput input) >>= intToPeg

readPegFromConsole : String -> Eff Peg [STDIO]
readPegFromConsole string = do
    putStrLn string
    let maybePeg = parseInputToPeg !getStr
    case maybePeg of
        Nothing => do
            putStrLn "Wrong input. Please enter 1, 2 or 3"
            readPegFromConsole $ string
        Just peg => do
            putStrLn $ "You chose peg: " ++ show peg
            pure peg

differ : (a: Peg) -> (b: Peg) -> Maybe ((a /= b) = True)
differ a b with (a /= b)
  | True = Just Refl
  | False = Nothing

moveIsJust : (from : Peg) ->
    (to : Peg) ->
    {auto prf: (from /= to) = True} ->
    (disposition: Disposition n) ->
    Maybe (IsJust (move from to disposition))
moveIsJust from to disposition with (move from to disposition)
    | Nothing = Nothing
    | Just newDisposition = Just ItIsJust

mutual
    wrongMove : Disposition n -> Disposition n -> String -> Eff () [STDIO]
    wrongMove startDisposition winningDisposition message = do
        putStrLn message
        play startDisposition winningDisposition

    play : Disposition n -> Disposition n -> Eff () [STDIO]
    play {n} startDisposition winningDisposition = do
        putStrLn $ draw startDisposition
        from <- readPegFromConsole "From"
        to <- readPegFromConsole "To"
        case (differ from to) of
            Nothing => wrongMove startDisposition winningDisposition "Invalid move: from and to are equal"
            Just prf => do
                case (moveIsJust from to startDisposition) of
                    Nothing => wrongMove startDisposition winningDisposition "Invalid move. Try again"
                    Just justPrf => do
                        let newDisposition = move' from to startDisposition
                        if (newDisposition == winningDisposition)
                            then do
                                putStrLn $ draw newDisposition
                                putStrLn "You made it!!"
                            else play newDisposition winningDisposition

main : IO ()
main = run $ play (startingDisposition {n=3}) (winningDisposition {n=3})
