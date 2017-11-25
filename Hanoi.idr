module Main

import Data.Fin

Disposition : Type
Disposition = List (Fin 3)

exampleDisposition : Disposition
exampleDisposition = [0, 1, 2]

-- fourthPegDisposition : Disposition
-- fourthPegDisposition = [0, 1, 2, 3]
