import Fibi.Tokenize (tokenize)
import Fibi.Parse (parse)
import Fibi.Write (write)

--- interact is a standard IO function that will read from standard input,
--- pass the result to its argument as a string, and write the result to
--- standard output
--- interact :: (String -> String) -> IO () -> IO String
main = interact fibi

--- Our runner will just pipe the three components together:
fibi :: String -> String
fibi html =
    let res = tokenize html >>= parse >>= write
    in case res of Left err -> show err
                   Right js -> js
