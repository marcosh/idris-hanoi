module Main

import Data.Vect

Disposition : Type
Disposition = Vect 4 (Fin 3)

exampleDisposition : Disposition
exampleDisposition = [0, 1, 2, 0]

-- fourthPegDisposition : Disposition
-- fourthPegDisposition = [0, 1, 2, 3]
