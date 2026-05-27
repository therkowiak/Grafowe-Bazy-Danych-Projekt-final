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

// 8. Pełny pipeline: gracz → kupon → zakład → mecz → drużyny → ligi (end-to-end)
MATCH (p:Player {username: 'BetMaster'})-[r1:PLACED]->(c:Coupon)-[r2:CONTAINS]->(b:Bet)-[r3:ON_MATCH]->(m:Match)
MATCH (t1:Team)-[r4:PLAYS_HOME]->(m)<-[r5:PLAYS_AWAY]-(t2:Team)
MATCH (t1)-[r6:BELONGS_TO]->(l1:League {tier: 1})
MATCH (t2)-[r7:BELONGS_TO]->(l2:League {tier: 1})
RETURN p, r1, c, r2, b, r3, m, r4, t1, r5, t2, r6, l1, r7, l2;

// 9. Mecze półfinałowe: drużyny, wyniki i zakłady na najważniejszą fazę turnieju
MATCH (t1:Team)-[r1:PLAYS_HOME]->(m:Match {stage: 'Semi-final'})<-[r2:PLAYS_AWAY]-(t2:Team)
OPTIONAL MATCH (b:Bet)-[r3:ON_MATCH]->(m)
RETURN t1, r1, m, r2, t2, b, r3;

// 10. Ekosystem drużyny: liga, rywale, mecze, obserwujący gracze
MATCH (t:Team {name: 'Bayern Munich'})-[r1:BELONGS_TO]->(l:League)
OPTIONAL MATCH (t)-[r2:RIVAL]-(rival:Team)
OPTIONAL MATCH (t)-[r3:PLAYS_HOME|PLAYS_AWAY]-(m:Match)
OPTIONAL MATCH (p:Player)-[r4:FOLLOWS]->(t)
RETURN t, r1, l, r2, rival, r3, m, r4, p;
