module Fibi.Utils
( quote ) where

quote :: String -> String
quote []          = []
quote ('\n' : cs) = '\\' : 'n' : (quote cs)
quote ('\'' : cs) = '\\' : '\'' : (quote cs)
quote (c : cs)    = c : quote cs
