// ============================================================
// 05_graph_algorithms.cypher
// Algorytmy grafowe zaimplementowane w czystym Cypherze
// ============================================================

// 1. Degree Centrality: Mecz będący największym "łącznikiem" w bazie
//    Liczymy wszystkie relacje wchodzące do węzła Match (zakłady + drużyny)
MATCH (m:Match)
RETURN m.id AS match,
       m.date,
       COUNT { (m)<-[:ON_MATCH]-() } AS bet_degree,
       COUNT { (m)<-[:PLAYS_HOME|PLAYS_AWAY]-() } AS team_degree,
       COUNT { (m)--() } AS total_degree
ORDER BY total_degree DESC;

// 2. Wykrywanie społeczności (Community Detection):
//    Grupowanie graczy po wspólnych meczach i miastach
MATCH (p1:Player)-[:PLACED]->(:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(m:Match)
      <-[:ON_MATCH]-(:Bet)<-[:CONTAINS]-(:Coupon)<-[:PLACED]-(p2:Player)
WHERE id(p1) < id(p2)
WITH p1, p2,
     count(DISTINCT m) AS shared_bets,
     p1.city = p2.city AS same_city
RETURN p1.username, p2.username,
       p1.city AS city_1, p2.city AS city_2,
       shared_bets, same_city,
       CASE WHEN shared_bets >= 2 AND same_city THEN 'STRONG'
            WHEN shared_bets >= 2 THEN 'MEDIUM'
            ELSE 'WEAK' END AS community_strength
ORDER BY shared_bets DESC, same_city DESC;

// 3. PageRank uproszczony: Ranking siły drużyn na podstawie prestiżu przeciwników
//    Im wyżej w rankingu przeciwnik (niższy rank), tym więcej "prestiżu" przekazuje
MATCH (t1:Team)-[:PLAYS_HOME|PLAYS_AWAY]-(m:Match)-[:PLAYS_HOME|PLAYS_AWAY]-(t2:Team)
WHERE t1 <> t2
WITH t1,
     count(t2) AS matches_played,
     sum(1.0 / t2.rank) AS prestige,
     collect(t2.name) AS opponents
RETURN t1.name, t1.rank,
       matches_played,
       round(prestige, 3) AS prestige_score,
       opponents
ORDER BY prestige_score DESC;

// 4. Triangle Count: Wykrywanie "trójkątów" graczy obstawiających ten sam mecz (podejrzenie botów)
MATCH (p1:Player)-[:PLACED]->(:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(m:Match)
MATCH (p2:Player)-[:PLACED]->(:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(m)
MATCH (p3:Player)-[:PLACED]->(:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(m)
WHERE id(p1) < id(p2) AND id(p2) < id(p3)
WITH m, collect(DISTINCT p1.username) + collect(DISTINCT p2.username) + collect(DISTINCT p3.username) AS players,
     count(*) AS triangle_count
RETURN m.id, triangle_count, players
ORDER BY triangle_count DESC;

// 5. Shortest Path: Najkrótsza ścieżka powiązań między dwoma graczami z różnych miast
MATCH path = shortestPath(
  (p1:Player {username: 'Kuba_Kiler'})-[*]-(p2:Player {username: 'BetMaster'})
)
RETURN p1.username AS from_player,
       p2.username AS to_player,
       length(path) AS hops,
       [n IN nodes(path) | coalesce(n.username, n.name, n.id)] AS path_nodes,
       [r IN relationships(path) | type(r)] AS path_relations;

// 6. Betweenness Centrality (uproszczona):
//    Który gracz leży na największej liczbie najkrótszych ścieżek między innymi graczami?
MATCH (p1:Player), (p2:Player)
WHERE id(p1) < id(p2)
MATCH path = shortestPath((p1)-[*]-(p2))
UNWIND nodes(path) AS intermediate
WITH intermediate, p1, p2
WHERE intermediate:Player AND intermediate <> p1 AND intermediate <> p2
RETURN intermediate.username AS bridge_player,
       count(*) AS betweenness_score,
       collect(DISTINCT [p1.username, p2.username]) AS connects_pairs
ORDER BY betweenness_score DESC;

// 7. Graph Diameter: Najdłuższa najkrótsza ścieżka w sieci graczy (średnica grafu)
MATCH (p1:Player), (p2:Player)
WHERE id(p1) < id(p2)
MATCH path = shortestPath((p1)-[*]-(p2))
WITH p1, p2, length(path) AS dist
ORDER BY dist DESC LIMIT 1
RETURN p1.username AS player_a,
       p2.username AS player_b,
       dist AS graph_diameter;
