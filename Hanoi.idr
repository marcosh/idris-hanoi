module Main

import Data.Vect

Disposition : Nat -> Type
Disposition numberOfDisks = Vect numberOfDisks (Fin 3)

exampleDisposition : Disposition 4
exampleDisposition = [0, 1, 2, 0]

-- fourthPegDisposition : Disposition
-- fourthPegDisposition = [0, 1, 2, 3]
