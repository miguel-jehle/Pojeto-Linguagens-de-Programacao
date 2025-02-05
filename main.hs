{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use foldr" #-}
main :: IO ()
main = do
    a <- leitura "A.txt"
    b <- leitura "B.txt"
    diffHa a b 1.0 0.0 

leitura :: FilePath -> IO [String]
leitura arquivo = lines <$> readFile arquivo

distancia :: String -> String -> Float
distancia [] [] = 0.0
distancia (ha:ta) [] = 1.0 + distancia ta []
distancia [] (hb:tb) = 1.0 + distancia [] tb
distancia (ha:ta) (hb:tb)
    |ha == hb = distancia ta tb
    |ha /= hb = 1.0 + distancia ta tb

compara :: String -> String -> Bool
compara a b = (distancia a b / fromIntegral (length a) ) <= 0.6 {-Retorna TRUE se eh igual ou modificada e FALSE se eh realmente uma linha diferente-}

procura :: String -> [String] -> Bool
procura a [] = False
procura a (h_b:t_b) = compara a h_b || procura a t_b

diffHa ::  [String] ->  [String] -> Float -> Float-> IO ()
diffHa [] [] linhas_mi diferencas = putStrLn " "
diffHa (h_arqA:t_arqA) [] linhas_mi diferencas = putStrLn ("--LINHA REMOVIDA-- : " ++ h_arqA) >> diffHa t_arqA [] linhas_mi diferencas
diffHa [] (h_arqB:t_arqB) linhas_mi diferencas = putStrLn ("++LINHA ADICIONADA++ : " ++ h_arqB) >> diffHa [] t_arqB linhas_mi diferencas
diffHa (h_arqA:t_arqA) (h_arqB:t_arqB) linhas_mi diferencas = 
    let dist = distancia h_arqA h_arqB in
    if compara h_arqA h_arqB {- Se sao iguais ou modificadas-}
        then 
            if dist == 0.0 
                then {-Se sao iguais-}
                    putStrLn ("==LINHA INALTERADA== : " ++ h_arqA) >> 
                    diffHa t_arqA t_arqB (linhas_mi + 1) diferencas
                else {-Se sao modificadas-}
                    putStrLn ("**LINHA ALTERADA** : " ++ h_arqA ++ " -> " ++ h_arqB ++ " | MEDIA: " ++ show ((diferencas+dist) / linhas_mi) ++ " | LINHAS VALIDAS: " ++ show linhas_mi ++ " | ERROS: " ++ show (dist + diferencas)) >> 
                    diffHa t_arqA t_arqB (linhas_mi + 1) (diferencas + dist)
        else {-Se sao diferentes-}  
            if procura h_arqA t_arqB {-Se achou-}
                then 
                    putStrLn ("++LINHA ADICIONADA++ : " ++ h_arqB) >>
                    diffHa (h_arqA:t_arqA) t_arqB linhas_mi diferencas 
                else{-Se nao achou-}
                    putStrLn ("--LINHA REMOVIDA-- : " ++  h_arqA) >>
                    diffHa t_arqA (h_arqB:t_arqB) linhas_mi diferencas
