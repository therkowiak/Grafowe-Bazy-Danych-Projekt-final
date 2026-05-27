// ============================================================
// 01_setup_and_data.cypher
// Inicjalizacja bazy: czyszczenie, constrainty, dane startowe
// ============================================================

// 1. Czyszczenie bazy
MATCH (n) DETACH DELETE n;

// 2. Definicja więzów spójności (Constraints)
CREATE CONSTRAINT player_unique_username IF NOT EXISTS FOR (p:Player) REQUIRE p.username IS UNIQUE;
CREATE CONSTRAINT team_unique_name IF NOT EXISTS FOR (t:Team) REQUIRE t.name IS UNIQUE;
CREATE CONSTRAINT match_unique_id IF NOT EXISTS FOR (m:Match) REQUIRE m.id IS UNIQUE;

// 3. Tworzenie Drużyn (8 drużyn, 4 kraje)
CREATE (t1:Team {name: 'Real Madrid', country: 'Spain', rank: 1}),
       (t2:Team {name: 'FC Barcelona', country: 'Spain', rank: 2}),
       (t3:Team {name: 'Arsenal', country: 'UK', rank: 5}),
       (t4:Team {name: 'Bayern Munich', country: 'Germany', rank: 3}),
       (t5:Team {name: 'Manchester City', country: 'UK', rank: 1}),
       (t6:Team {name: 'Borussia Dortmund', country: 'Germany', rank: 4}),
       (t7:Team {name: 'Liverpool', country: 'UK', rank: 6}),
       (t8:Team {name: 'PSG', country: 'France', rank: 7});

// 4. Tworzenie Graczy (8 graczy, 4 miasta, 2 poziomy)
CREATE (p1:Player {username: 'Kuba_Kiler', balance: 500, city: 'Warszawa', level: 'VIP'}),
       (p2:Player {username: 'Analityk99', balance: 1200, city: 'Kraków', level: 'Standard'}),
       (p3:Player {username: 'LuckyShot', balance: 50, city: 'Warszawa', level: 'Standard'}),
       (p4:Player {username: 'BetMaster', balance: 3000, city: 'Gdańsk', level: 'VIP'}),
       (p5:Player {username: 'OstryTyper', balance: 800, city: 'Warszawa', level: 'VIP'}),
       (p6:Player {username: 'RiskQueen', balance: 200, city: 'Kraków', level: 'Standard'}),
       (p7:Player {username: 'SafePlay', balance: 1500, city: 'Gdańsk', level: 'Standard'}),
       (p8:Player {username: 'DarkHorse', balance: 100, city: 'Poznań', level: 'VIP'});

// 5. Tworzenie Meczy i relacji między drużynami (6 meczy)
MATCH (t1:Team {name: 'Real Madrid'}), (t2:Team {name: 'FC Barcelona'})
CREATE (m1:Match {id: 101, date: '2024-05-10', importance: 'HIGH'})
CREATE (t1)-[:PLAYS_HOME]->(m1)<-[:PLAYS_AWAY]-(t2);

MATCH (t3:Team {name: 'Arsenal'}), (t4:Team {name: 'Bayern Munich'})
CREATE (m2:Match {id: 102, date: '2024-05-11', importance: 'MEDIUM'})
CREATE (t3)-[:PLAYS_HOME]->(m2)<-[:PLAYS_AWAY]-(t4);

MATCH (t5:Team {name: 'Manchester City'}), (t1:Team {name: 'Real Madrid'})
CREATE (m3:Match {id: 103, date: '2024-05-12', importance: 'HIGH'})
CREATE (t5)-[:PLAYS_HOME]->(m3)<-[:PLAYS_AWAY]-(t1);

MATCH (t6:Team {name: 'Borussia Dortmund'}), (t7:Team {name: 'Liverpool'})
CREATE (m4:Match {id: 104, date: '2024-05-13', importance: 'MEDIUM'})
CREATE (t6)-[:PLAYS_HOME]->(m4)<-[:PLAYS_AWAY]-(t7);

MATCH (t8:Team {name: 'PSG'}), (t2:Team {name: 'FC Barcelona'})
CREATE (m5:Match {id: 105, date: '2024-05-14', importance: 'HIGH'})
CREATE (t8)-[:PLAYS_HOME]->(m5)<-[:PLAYS_AWAY]-(t2);

MATCH (t4:Team {name: 'Bayern Munich'}), (t5:Team {name: 'Manchester City'})
CREATE (m6:Match {id: 106, date: '2024-05-15', importance: 'HIGH'})
CREATE (t4)-[:PLAYS_HOME]->(m6)<-[:PLAYS_AWAY]-(t5);

// 6. Relacje społecznościowe (obserwowanie drużyn)
MATCH (p:Player {username: 'Kuba_Kiler'}), (t:Team {name: 'Real Madrid'}) CREATE (p)-[:FOLLOWS]->(t);
MATCH (p:Player {username: 'Kuba_Kiler'}), (t:Team {name: 'Bayern Munich'}) CREATE (p)-[:FOLLOWS]->(t);
MATCH (p:Player {username: 'Analityk99'}), (t:Team {name: 'Manchester City'}) CREATE (p)-[:FOLLOWS]->(t);
MATCH (p:Player {username: 'LuckyShot'}), (t:Team {name: 'Real Madrid'}) CREATE (p)-[:FOLLOWS]->(t);
MATCH (p:Player {username: 'BetMaster'}), (t:Team {name: 'PSG'}) CREATE (p)-[:FOLLOWS]->(t);
MATCH (p:Player {username: 'BetMaster'}), (t:Team {name: 'Bayern Munich'}) CREATE (p)-[:FOLLOWS]->(t);
MATCH (p:Player {username: 'OstryTyper'}), (t:Team {name: 'Arsenal'}) CREATE (p)-[:FOLLOWS]->(t);
MATCH (p:Player {username: 'RiskQueen'}), (t:Team {name: 'FC Barcelona'}) CREATE (p)-[:FOLLOWS]->(t);
MATCH (p:Player {username: 'SafePlay'}), (t:Team {name: 'Liverpool'}) CREATE (p)-[:FOLLOWS]->(t);
MATCH (p:Player {username: 'DarkHorse'}), (t:Team {name: 'Borussia Dortmund'}) CREATE (p)-[:FOLLOWS]->(t);
MATCH (p:Player {username: 'DarkHorse'}), (t:Team {name: 'PSG'}) CREATE (p)-[:FOLLOWS]->(t);

// 7. Relacje między graczami (znajomości)
MATCH (p1:Player {username: 'Kuba_Kiler'}), (p2:Player {username: 'LuckyShot'}) CREATE (p1)-[:FRIENDS_WITH]->(p2);
MATCH (p1:Player {username: 'Kuba_Kiler'}), (p2:Player {username: 'OstryTyper'}) CREATE (p1)-[:FRIENDS_WITH]->(p2);
MATCH (p1:Player {username: 'Analityk99'}), (p2:Player {username: 'RiskQueen'}) CREATE (p1)-[:FRIENDS_WITH]->(p2);
MATCH (p1:Player {username: 'BetMaster'}), (p2:Player {username: 'SafePlay'}) CREATE (p1)-[:FRIENDS_WITH]->(p2);
MATCH (p1:Player {username: 'OstryTyper'}), (p2:Player {username: 'DarkHorse'}) CREATE (p1)-[:FRIENDS_WITH]->(p2);
MATCH (p1:Player {username: 'LuckyShot'}), (p2:Player {username: 'RiskQueen'}) CREATE (p1)-[:FRIENDS_WITH]->(p2);
