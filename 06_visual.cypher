// 1. Wyświetla 50 dowolnych węzłów i ich relacje
MATCH (n)-[r]->(m) 
RETURN n, r, m 
LIMIT 50;

// 2. sprawdzenie konkretnego gracza
MATCH (p:Player {username: 'Gracz1'})-[r1:PLACED]->(c)-[r2:CONTAINS]->(b)-[r3:ON_MATCH]->(m)
RETURN p, r1, c, r2, b, r3, m;

//3. Sprawdzenie liczb czy wygrał
MATCH (n)
RETURN labels(n) AS Typ_Wezla, count(*) AS Ilosc
ORDER BY Ilosc DESC;