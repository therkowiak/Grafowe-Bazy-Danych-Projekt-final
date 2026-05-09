// 1. Czyszczenie bazy
MATCH (n) DETACH DELETE n;

// 2. Definicja więzów spójności (Constraints)
CREATE CONSTRAINT player_unique_username FOR (p:Player) REQUIRE p.username IS UNIQUE;
CREATE CONSTRAINT team_unique_name FOR (t:Team) REQUIRE t.name IS UNIQUE;
CREATE CONSTRAINT match_unique_id FOR (m:Match) REQUIRE m.id IS UNIQUE;

// 3. Tworzenie Drużyn
CREATE (t1:Team {name: 'Real Madrid', country: 'Spain', rank: 1}),
       (t2:Team {name: 'FC Barcelona', country: 'Spain', rank: 2}),
       (t3:Team {name: 'Arsenal', country: 'UK', rank: 5}),
       (t4:Team {name: 'Bayern Munich', country: 'Germany', rank: 3}),
       (t5:Team {name: 'Manchester City', country: 'UK', rank: 1});

// 4. Tworzenie Graczy
CREATE (p1:Player {username: 'Gracz1', balance: 500, city: 'Warszawa', level: 'VIP'}),
       (p2:Player {username: 'Gracz2', balance: 1200, city: 'Kraków', level: 'Standard'}),
       (p3:Player {username: 'Gracz3', balance: 50, city: 'Warszawa', level: 'Standard'}),
       (p4:Player {username: 'Gracz4', balance: 3000, city: 'Gdańsk', level: 'VIP'});

// 5. Tworzenie Meczy i relacji między drużynami
MATCH (t1:Team {name: 'Real Madrid'}), (t2:Team {name: 'FC Barcelona'})
CREATE (m1:Match {id: 101, date: '2024-05-10', importance: 'HIGH'})
CREATE (t1)-[:PLAYS_HOME]->(m1)<-[:PLAYS_AWAY]-(t2);

MATCH (t3:Team {name: 'Arsenal'}), (t4:Team {name: 'Bayern Munich'})
CREATE (m2:Match {id: 102, date: '2024-05-11', importance: 'MEDIUM'})
CREATE (t3)-[:PLAYS_HOME]->(m2)<-[:PLAYS_AWAY]-(t4);

MATCH (t5:Team {name: 'Manchester City'}), (t1:Team {name: 'Real Madrid'})
CREATE (m3:Match {id: 103, date: '2024-05-12', importance: 'HIGH'})
CREATE (t5)-[:PLAYS_HOME]->(m3)<-[:PLAYS_AWAY]-(t1);

// 6. Relacje społecznościowe (obserwowanie drużyn)
MATCH (p1:Player {username: 'Gracz1'}), (t1:Team {name: 'Real Madrid'}) CREATE (p1)-[:FOLLOWS]->(t1);
MATCH (p2:Player {username: 'Gracz2'}), (t5:Team {name: 'Manchester City'}) CREATE (p2)-[:FOLLOWS]->(t5);
MATCH (p3:Player {username: 'Gracz3'}), (t1:Team {name: 'Real Madrid'}) CREATE (p3)-[:FOLLOWS]->(t1);