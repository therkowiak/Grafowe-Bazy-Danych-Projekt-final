// 1. Zakład Kuby (Wygrany)
MATCH (p:Player {username: 'Kuba_Kiler'}), (m1:Match {id: 101}), (m2:Match {id: 102})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C1', stake: 100, status: 'WON'})
CREATE (c)-[:CONTAINS]->(b1:Bet {type: '1', odds: 2.10, description: 'Home Win'})-[:ON_MATCH]->(m1)
CREATE (c)-[:CONTAINS]->(b2:Bet {type: 'X', odds: 3.40, description: 'Draw'})-[:ON_MATCH]->(m2);

// 2. Zakład Analityka (W toku)
MATCH (p:Player {username: 'Analityk99'}), (m1:Match {id: 101})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C2', stake: 500, status: 'PENDING'})
CREATE (c)-[:CONTAINS]->(b:Bet {type: '1', odds: 2.15})-[:ON_MATCH]->(m1);

// 3. Zakład LuckyShot (Przegrany)
MATCH (p:Player {username: 'LuckyShot'}), (m1:Match {id: 101}), (m3:Match {id: 103})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C3', stake: 10, status: 'LOST'})
CREATE (c)-[:CONTAINS]->(b1:Bet {type: '2', odds: 1.90})-[:ON_MATCH]->(m1)
CREATE (c)-[:CONTAINS]->(b2:Bet {type: '1', odds: 1.50})-[:ON_MATCH]->(m3);

// 4. Zakład BetMastera (Wysoka stawka)
MATCH (p:Player {username: 'BetMaster'}), (m3:Match {id: 103})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C4', stake: 1000, status: 'WON'})
CREATE (c)-[:CONTAINS]->(b:Bet {type: '1', odds: 1.45})-[:ON_MATCH]->(m3);