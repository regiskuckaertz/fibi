import Fibi.Types
import Fibi.Tokenize
import Fibi.Parse
import Fibi.Write

import qualified Text.ParserCombinators.Parsec as P

--- We just read whatever comes from standard input and spit out its conversion result
main = interact fibi

--- Our runner will just pipe the three components together:
fibi :: String -> String
fibi html =
    let res = (coerce . tokenize) html >>= parse >>= write
    in case res of Left err -> show err
                   Right js -> js


coerce :: Either P.ParseError [Token] -> Either FibiError [Token]
coerce (Left p) = Left (ParseError p)
coerce (Right ts) = Right ts
