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

// 7. Podgląd grafu (tylko dla małych zbiorów)
MATCH (n) RETURN n LIMIT 50;
