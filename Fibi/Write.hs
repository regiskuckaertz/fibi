module Fibi.Write
( write
) where

import Fibi.Types
import Fibi.Utils

import Text.Printf (printf)

--- ***********************************************************************
--- Finally, the DOM tree needs to be converted into DOM API calls
--- ***********************************************************************

write :: Dom -> Either FibiError String
write d =
    let (_, _, js) = foldDom d (0, 1, [])
    in Right (unlines js)

foldDom :: Dom -> FoldAcc -> FoldAcc
foldDom (Text str) = fText str
foldDom (Comment str) = fComment str
foldDom (VoidElement n as) = fVoidElement (n, as)
foldDom (Element n as cs) = fElement (n, as, cs)
foldDom (Fragment cs) = fFragment cs

fText :: FibiExpr -> FoldAcc -> FoldAcc
fText str (pid, nid, p) =
    let str' = appendChildStr (var pid) $ printf "document.createTextNode(%s)" (show str)
    in (pid, nid, str' : p)

fComment :: String -> FoldAcc -> FoldAcc
fComment str (pid, nid, p) =
    let str' = appendChildStr (var pid) $ printf "document.createComment('%s')" (quote str)
    in (pid, nid, str' : p)

fVoidElement :: (String, [Attribute]) -> FoldAcc -> FoldAcc
fVoidElement (n, as) (pid, nid, p) =
    let decl = printf "var %s = document.createElement('%s')" (var nid) n in
    let app = appendChildStr (var pid) (var nid) in
    let attrs = map (setAttribute nid) as in
    (pid, nid + 1, (decl : app : attrs) ++ p)

fElement :: (String, [Attribute], [Dom]) -> FoldAcc -> FoldAcc
fElement (n, as, cs) (pid, nid, p) =
    let decl = printf "var %s = document.createElement('%s')" (var nid) n in
    let app = appendChildStr (var pid) (var nid) in
    let attrs = map (setAttribute nid) as in
    let (_, nid'', cs') = foldr foldDom (nid, nid + 1, p) cs in
    (pid, nid'', (decl : app : attrs) ++ cs')

fFragment :: [Dom] -> FoldAcc -> FoldAcc
fFragment cs acc@(pid, nid, p) =
    let intro = "function(context) {" in
    let decl = printf "var %s = document.createDocumentFragment()" (var pid) in
    let (_, _, cs') = foldr foldDom acc cs in
    let ret = printf "return %s" (var pid) in
    let outro = "}" in
    (0, 0, [intro, decl] ++ cs' ++ [ret, outro])

var :: Int -> String
var id = "v" ++ (show id)

nextVar :: Int -> Int
nextVar = (+1)

appendChildStr :: String -> String -> String
appendChildStr pv nv = printf "%s.insertBefore(%s, %s.firstChild)" pv nv pv

setAttribute :: Int -> Attribute -> String
setAttribute id (n, v) = printf "%s.setAttribute(%s, %s)" (var id) (show n) (show v)
