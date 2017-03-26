module Fibi.Tokenize
( tokenize
) where

import Fibi.Types
import Data.Char (toLower)
import Text.ParserCombinators.Parsec

--- ***********************************************************************
--- Let's parse that motherfucker
--- ***********************************************************************

tokenize :: String -> Either ParseError [Token]
tokenize html = parse htmlFrag "(unknown)" html

htmlFrag = many (comment <|> endTag <|> startTag <|> text)

comment = do
    chars <- try (string "<!--") *> many (try (singleDash <|> noDash)) <* string "-->"
    return $ CommentTag (concat chars)

singleDash :: Parser String
singleDash = do
    char '-'
    nxtChar <- noneOf "-"
    return ['-', nxtChar]

noDash :: Parser String
noDash = do
    ch <- noneOf "-"
    return [ch]

--- End tags match /<\/[\w\d]+\s*>/
endTag = do
    tagName <- try (string "</") *> many1 alphaNum
    spaces
    char '>'
    return $ EndTag (map toLower tagName)

--- Start tags match /<[\w\d]+(:attribute:)*\s*\/?>/
startTag = do
    tagName <- char '<' *> many1 alphaNum
    attrs <- many attribute
    spaces
    char '>'
    return $ StartTag (map toLower tagName) attrs

--- Attributes (single-quoted) match /\s+[^'"\/<=\s]\s*=\s*'[^']'/
attribute = do
    many1 space
    name <- fibiExpr
    spaces
    char '='
    spaces
    value <- quotedValue '\'' <|> quotedValue '"' <|> unquotedValue <?> "attribute value missing"
    return (name, value)

quotedValue :: Char -> Parser FibiExpr
quotedValue sep = between (char sep) (char sep) fibiExpr

unquotedValue = fibiExpr

fibiExpr = do
    exprs <- many1 (fibiVar <|> fibiString)
    return $ buildExpr exprs

fibiVar = do
    str <- try (string "{{" >> spaces) *> symbol <* (spaces >> string "}}")
    return $ FibiVar str

fibiString = do
    str <- many1 $ noneOf "\"'>/=\t\n\r\f\v{"
    return $ FibiString str

symbol = many1 (alphaNum <|> oneOf "-_:")

buildExpr :: [FibiExpr] -> FibiExpr
buildExpr (e1 : e2 : es) = FibiSeq e1 (buildExpr (e2 : es))
buildExpr [e1] = e1

--- Parsing text is simple: it's everything that isn't <
text :: Parser Token
text = do
    txt <- many1 $ noneOf "<"
    return $ TextTag txt
