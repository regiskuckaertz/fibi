module Fibi.Types
( FibiError(ParseError, NestingError)
, FibiExpr(FibiString, FibiVar, FibiSeq)
, Token(StartTag, EndTag, CommentTag, TextTag)
, Attribute
, Dom(Fragment, Text, Comment, VoidElement, Element)
, DomCrumb(Crumb)
, DomZipper
, FoldAcc
) where

import Fibi.Utils

import qualified Text.ParserCombinators.Parsec as P

--- Two things can go wrong when parsing an HTML string:
--- either there's a forbidden or missing character somewhere (I'm not as
--- forgiving as web browsers), or there's a tag that should not be there
--- and is messing up the whole tree
--- TODO: improve the NestingError by keeping track of line and column positions
data FibiError = ParseError P.ParseError | NestingError String deriving Show

data FibiExpr = FibiString String
              | FibiVar Id
              | FibiSeq FibiExpr FibiExpr

instance Show FibiExpr where
    show (FibiString s) = "'" ++ quote s ++ "'"
    show (FibiVar i) = "context['" ++ (quote i) ++ "']"
    show (FibiSeq e1 e2) = show e1 ++ " + " ++ show e2

type Id = String

--- These are the HTML tokens the lexer will produce
data Token = StartTag String [Attribute]
           | EndTag String
           | CommentTag String
           | TextTag FibiExpr
    deriving Show

--- Attributes are simply pairs of strings ... for now ಠ‿ಠ
type Attribute = (FibiExpr, FibiExpr)

--- We need to build a DOM tree out of the tokens produced by the lexer.
--- The DOM tree is a recursive data structure, i.e. a document fragment
--- and a non-empty element both contain a list of DOM trees where each
--- of their children is the root
data Dom = Fragment [Dom]
          | Text FibiExpr
          | Comment String
          | VoidElement String [Attribute]
          | Element String [Attribute] [Dom]
    deriving Show

--- The parser will read tokens and build the DOM tree iteratively. This
--- process will require the ability to go up and down the tree. Zippers
--- are data structures to do just that, they keep track of the path from
--- a node up to the root of the tree
data DomCrumb = Crumb String [Attribute] [Dom] deriving Show
type DomZipper = (Dom, [DomCrumb])

--- The final stage of the process is generating a representation of the
--- tree using DOM API calls. This stage is a fold over the tree where the
--- JS code will be a list of strings. Now let's take two examples:
---
--- <!-- hello --> : this is a comment that needs to be inserted into its
--- parent node. The JS equivalent looks like this:
--- parentVar.appendChild(document.createComment(' hello '))
---
--- <img src="image.jpg"> : not only needs this element adding to its parent,
--- it also has attributes that need to be set:
--- var elemVar = document.createElement('img')
--- elemVar.setAttribute('src', 'image.jpg')
--- parentVar.appendChild(elemVar)
---
--- as we can see above, we need a way to define variables and keep track of
--- them. We'll be using unsigned integers for that, a cheap and deterministic
--- way to create unique variable names
type FoldAcc = (Int, Int, [String])
