// 1. Degree Centrality: Mecz będący największym "łącznikiem" w bazie
MATCH (m:Match)
RETURN m.id AS match, COUNT { (m)<-[:ON_MATCH]-() } AS degree
ORDER BY degree DESC;

// 2. Wykrywanie społeczności (Louvain-like): Grupowanie graczy po wspólnych meczach i miastach
MATCH (p1:Player)-[:PLACED]->(:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(m:Match)<-[:ON_MATCH]-(:Bet)<-[:CONTAINS]-(:Coupon)<-[:PLACED]-(p2:Player)
WHERE p1.city = p2.city AND id(p1) < id(p2)
RETURN p1.username, p2.username, p1.city, count(m) AS shared_bets
ORDER BY shared_bets DESC;

// 3. Prosty PageRank: Ranking siły drużyn na podstawie rankingu przeciwników, z którymi grają
MATCH (t1:Team)-[:PLAYS_HOME|PLAYS_AWAY]-(m:Match)-[:PLAYS_HOME|PLAYS_AWAY]-(t2:Team)
WHERE t1 <> t2
WITH t1, sum(1.0 / t2.rank) AS prestige
RETURN t1.name, prestige ORDER BY prestige DESC;

// 4. Triangle Count: Wykrywanie "trójkątów" (np. 3 graczy obstawiających te same 3 mecze - podejrzenie botów)
MATCH (p1:Player)-[:PLACED]->(c1)-[:CONTAINS]->(b1)-[:ON_MATCH]->(m)
MATCH (p2:Player)-[:PLACED]->(c2)-[:CONTAINS]->(b2)-[:ON_MATCH]->(m)
MATCH (p3:Player)-[:PLACED]->(c3)-[:CONTAINS]->(b3)-[:ON_MATCH]->(m)
WHERE id(p1) < id(p2) AND id(p2) < id(p3)
RETURN m.id, count(*) AS suspect_intensity;

// 5. Shortest Path: Znajdź najkrótszą ścieżkę powiązań między dwoma graczami z różnych miast
MATCH p = shortestPath((p1:Player {username: 'Kuba_Kiler'})-[*]-(p2:Player {username: 'BetMaster'}))
RETURN p;