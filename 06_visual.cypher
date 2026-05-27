// ============================================================
// 06_visual.cypher
// Zapytania do wizualnej eksploracji grafu w Neo4j Browser
// ============================================================

// 1. Cały graf — wszystkie węzły i relacje (limit 100)
MATCH (n)-[r]->(m)
RETURN n, r, m
LIMIT 100;

// 2. Pełna ścieżka konkretnego gracza: gracz → kupon → zakład → mecz → drużyny
MATCH (p:Player {username: 'Kuba_Kiler'})-[r1:PLACED]->(c:Coupon)-[r2:CONTAINS]->(b:Bet)-[r3:ON_MATCH]->(m:Match)
MATCH (t1:Team)-[r4:PLAYS_HOME]->(m)<-[r5:PLAYS_AWAY]-(t2:Team)
RETURN p, r1, c, r2, b, r3, m, r4, t1, r5, t2;

// 3. Sieć społecznościowa graczy (FRIENDS_WITH + wspólne FOLLOWS)
MATCH (p1:Player)-[f:FRIENDS_WITH]-(p2:Player)
OPTIONAL MATCH (p1)-[fw1:FOLLOWS]->(t:Team)<-[fw2:FOLLOWS]-(p2)
RETURN p1, f, p2, fw1, t, fw2;

// 4. Statystyki węzłów — ile czego jest w bazie
MATCH (n)
RETURN labels(n) AS Typ_Wezla, count(*) AS Ilosc
ORDER BY Ilosc DESC;

// 5. Statystyki relacji
MATCH ()-[r]->()
RETURN type(r) AS Typ_Relacji, count(*) AS Ilosc
ORDER BY Ilosc DESC;

// 6. Struktura lig: drużyny → ligi krajowe + Champions League
MATCH (t:Team)-[b:BELONGS_TO]->(l:League)
RETURN t, b, l;

// 7. Mapa rywalizacji: drużyny połączone relacją RIVAL
MATCH (t1:Team)-[r:RIVAL]->(t2:Team)
OPTIONAL MATCH (t1)-[:PLAYS_HOME|PLAYS_AWAY]-(m:Match)-[:PLAYS_HOME|PLAYS_AWAY]-(t2)
RETURN t1, r, t2, m;
