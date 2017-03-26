module Fibi.Parse
( parse
) where

import Fibi.Types

--- ***********************************************************************
--- Here is our normalisation step, taking an AST in and generating a DOM
--- ***********************************************************************

parse :: [Token] -> Either FibiError Dom
parse ts = case (parse' ts (Fragment [], [])) of Left e -> Left e
                                                 Right (t, _) -> Right t

parse' :: [Token] -> DomZipper -> Either FibiError DomZipper
parse' [] z = Right z
parse' (TextTag str : ts) z = parse' ts $ modify (appendChild (Text str)) $ z
parse' (CommentTag str : ts) z = parse' ts $ modify (appendChild (Comment str)) $ z
parse' (StartTag str as : ts) z
    | isVoidElement str = parse' ts $ modify (appendChild (VoidElement str as)) $ z
    | otherwise = parse' ts $ goDown $ modify (appendChild (Element str as [])) $ z
parse' (EndTag str : ts) z =
    let z' = goUp z
    in case z of (Element n _ _, _) -> if n == str then parse' ts z' else Left (NestingError ("Misnested tag " ++ str ++ " in " ++ (show z')))
                 _                  -> Left (NestingError ("Misnested tag " ++ str ++ " in " ++ (show z')))

goUp :: DomZipper -> DomZipper
goUp (el, [Crumb _ _ cs]) = (Fragment (el : cs), [])
goUp (el, Crumb s a cs : bs) = (Element s a (el : cs), bs)

goDown :: DomZipper -> DomZipper
goDown (Fragment ns, []) =
    let (el : ns') = ns
    in (el, [(Crumb "#fragment" [] ns')])
goDown (Element s as ns, bs) =
    let (el : ns') = ns
    in (el, (Crumb s as ns') : bs)

modify :: (Dom -> Dom) -> DomZipper -> DomZipper
modify f (n, bs) = (f n, bs)

appendChild :: Dom -> Dom -> Dom
appendChild c (Fragment cs) = Fragment (c : cs)
appendChild c (Element n as cs) = Element n as (c : cs)

isVoidElement :: String -> Bool
isVoidElement e = e `elem` [ "area", "base", "br", "col", "embed"
                           , "hr", "img", "input", "keygen", "link"
                           , "menuitem", "meta", "param", "source"
                           , "track", "wbr"
                           ]
