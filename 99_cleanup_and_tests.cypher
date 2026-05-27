// ============================================================
// 99_cleanup_and_tests.cypher
// Testy spójności danych i czyszczenie
// ============================================================

// 1. Zliczanie wszystkich typów węzłów
MATCH (n) RETURN labels(n) AS label, count(*) AS count ORDER BY count DESC;

// 2. Zliczanie wszystkich typów relacji
MATCH ()-[r]->() RETURN type(r) AS rel_type, count(*) AS count ORDER BY count DESC;

// 3. Sprawdzenie: czy są mecze bez przypisanych drużyn?
MATCH (m:Match) WHERE NOT (m)<-[:PLAYS_HOME]-() OR NOT (m)<-[:PLAYS_AWAY]-()
RETURN m.id AS orphan_match;

// 4. Sprawdzenie: czy są kupony bez zakładów?
MATCH (c:Coupon) WHERE NOT (c)-[:CONTAINS]->()
RETURN c.id AS empty_coupon;

// 5. Sprawdzenie: czy są zakłady bez przypisanego meczu?
MATCH (b:Bet) WHERE NOT (b)-[:ON_MATCH]->()
RETURN b AS orphan_bet;

// 6. Sprawdzenie: czy są gracze bez żadnego kuponu?
MATCH (p:Player) WHERE NOT (p)-[:PLACED]->()
RETURN p.username AS inactive_player;

// 7. Sprawdzenie: czy każda drużyna należy do ligi krajowej?
MATCH (t:Team)
WHERE NOT (t)-[:BELONGS_TO]->(:League {tier: 1})
RETURN t.name AS team_without_league;

// 8. Sprawdzenie: czy każdy mecz ma wynik (result)?
MATCH (m:Match) WHERE m.result IS NULL
RETURN m.id AS match_without_result;

// 9. Sprawdzenie: spójność relacji RIVAL (czy oba zespoły są z tego samego kraju?)
MATCH (t1:Team)-[r:RIVAL]->(t2:Team)
WHERE t1.country <> t2.country
RETURN t1.name, t2.name, r.type AS invalid_rival;

// 10. Sprawdzenie: czy format wyniku jest poprawny (X:Y)?
MATCH (m:Match)
WHERE NOT m.result =~ '\\d+:\\d+'
RETURN m.id AS bad_result_format, m.result;

// 11. Sprawdzenie: czy każda drużyna należy do Champions League?
MATCH (t:Team)
WHERE NOT (t)-[:BELONGS_TO]->(:League {name: 'Champions League'})
RETURN t.name AS team_not_in_cl;

// 12. Podsumowanie grafu: łączna liczba węzłów, relacji, constraintów
MATCH (n) WITH count(n) AS total_nodes
MATCH ()-[r]->() WITH total_nodes, count(r) AS total_rels
RETURN total_nodes, total_rels;

// 13. Podgląd grafu (tylko dla małych zbiorów)
MATCH (n) RETURN n LIMIT 50;
