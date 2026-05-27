// ============================================================
// 02_betting_logic.cypher
// Tworzenie kuponów i zakładów dla wszystkich graczy
// ============================================================

// 1. Kupon Kuba_Kiler #1 (Wygrany, tasiemiec 2 zdarzenia)
MATCH (p:Player {username: 'Kuba_Kiler'}), (m1:Match {id: 101}), (m2:Match {id: 102})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C1', stake: 100, status: 'WON'})
CREATE (c)-[:CONTAINS]->(b1:Bet {type: '1', odds: 2.10, description: 'Home Win'})-[:ON_MATCH]->(m1)
CREATE (c)-[:CONTAINS]->(b2:Bet {type: 'X', odds: 3.40, description: 'Draw'})-[:ON_MATCH]->(m2);

// 2. Kupon Kuba_Kiler #2 (Przegrany, single)
MATCH (p:Player {username: 'Kuba_Kiler'}), (m4:Match {id: 104})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C8', stake: 50, status: 'LOST'})
CREATE (c)-[:CONTAINS]->(b:Bet {type: '2', odds: 2.80, description: 'Away Win'})-[:ON_MATCH]->(m4);

// 3. Kupon Analityk99 (W toku, single)
MATCH (p:Player {username: 'Analityk99'}), (m1:Match {id: 101})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C2', stake: 500, status: 'PENDING'})
CREATE (c)-[:CONTAINS]->(b:Bet {type: '1', odds: 2.15, description: 'Home Win'})-[:ON_MATCH]->(m1);

// 4. Kupon Analityk99 #2 (Wygrany, tasiemiec 3 zdarzenia)
MATCH (p:Player {username: 'Analityk99'}), (m3:Match {id: 103}), (m4:Match {id: 104}), (m6:Match {id: 106})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C9', stake: 200, status: 'WON'})
CREATE (c)-[:CONTAINS]->(b1:Bet {type: '1', odds: 1.50, description: 'Home Win'})-[:ON_MATCH]->(m3)
CREATE (c)-[:CONTAINS]->(b2:Bet {type: '1', odds: 1.80, description: 'Home Win'})-[:ON_MATCH]->(m4)
CREATE (c)-[:CONTAINS]->(b3:Bet {type: 'X', odds: 3.10, description: 'Draw'})-[:ON_MATCH]->(m6);

// 5. Kupon LuckyShot (Przegrany, tasiemiec 2 zdarzenia)
MATCH (p:Player {username: 'LuckyShot'}), (m1:Match {id: 101}), (m3:Match {id: 103})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C3', stake: 10, status: 'LOST'})
CREATE (c)-[:CONTAINS]->(b1:Bet {type: '2', odds: 1.90, description: 'Away Win'})-[:ON_MATCH]->(m1)
CREATE (c)-[:CONTAINS]->(b2:Bet {type: '1', odds: 1.50, description: 'Home Win'})-[:ON_MATCH]->(m3);

// 6. Kupon LuckyShot #2 (Wygrany, single)
MATCH (p:Player {username: 'LuckyShot'}), (m5:Match {id: 105})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C10', stake: 25, status: 'WON'})
CREATE (c)-[:CONTAINS]->(b:Bet {type: '2', odds: 2.50, description: 'Away Win'})-[:ON_MATCH]->(m5);

// 7. Kupon BetMaster (Wygrany, single, wysoka stawka)
MATCH (p:Player {username: 'BetMaster'}), (m3:Match {id: 103})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C4', stake: 1000, status: 'WON'})
CREATE (c)-[:CONTAINS]->(b:Bet {type: '1', odds: 1.45, description: 'Home Win'})-[:ON_MATCH]->(m3);

// 8. Kupon BetMaster #2 (Przegrany, tasiemiec 2 zdarzenia)
MATCH (p:Player {username: 'BetMaster'}), (m5:Match {id: 105}), (m6:Match {id: 106})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C11', stake: 500, status: 'LOST'})
CREATE (c)-[:CONTAINS]->(b1:Bet {type: '1', odds: 1.60, description: 'Home Win'})-[:ON_MATCH]->(m5)
CREATE (c)-[:CONTAINS]->(b2:Bet {type: '1', odds: 1.70, description: 'Home Win'})-[:ON_MATCH]->(m6);

// 9. Kupon OstryTyper (Wygrany, tasiemiec 3 zdarzenia)
MATCH (p:Player {username: 'OstryTyper'}), (m1:Match {id: 101}), (m2:Match {id: 102}), (m3:Match {id: 103})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C5', stake: 300, status: 'WON'})
CREATE (c)-[:CONTAINS]->(b1:Bet {type: '1', odds: 2.10, description: 'Home Win'})-[:ON_MATCH]->(m1)
CREATE (c)-[:CONTAINS]->(b2:Bet {type: '2', odds: 2.20, description: 'Away Win'})-[:ON_MATCH]->(m2)
CREATE (c)-[:CONTAINS]->(b3:Bet {type: '1', odds: 1.50, description: 'Home Win'})-[:ON_MATCH]->(m3);

// 10. Kupon OstryTyper #2 (W toku, single)
MATCH (p:Player {username: 'OstryTyper'}), (m5:Match {id: 105})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C12', stake: 150, status: 'PENDING'})
CREATE (c)-[:CONTAINS]->(b:Bet {type: '1', odds: 1.85, description: 'Home Win'})-[:ON_MATCH]->(m5);

// 11. Kupon RiskQueen (Przegrany, tasiemiec 4 zdarzenia - najdłuższy kupon)
MATCH (p:Player {username: 'RiskQueen'}), (m1:Match {id: 101}), (m2:Match {id: 102}), (m4:Match {id: 104}), (m5:Match {id: 105})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C6', stake: 20, status: 'LOST'})
CREATE (c)-[:CONTAINS]->(b1:Bet {type: '1', odds: 2.10, description: 'Home Win'})-[:ON_MATCH]->(m1)
CREATE (c)-[:CONTAINS]->(b2:Bet {type: 'X', odds: 3.40, description: 'Draw'})-[:ON_MATCH]->(m2)
CREATE (c)-[:CONTAINS]->(b3:Bet {type: '1', odds: 1.80, description: 'Home Win'})-[:ON_MATCH]->(m4)
CREATE (c)-[:CONTAINS]->(b4:Bet {type: '2', odds: 2.50, description: 'Away Win'})-[:ON_MATCH]->(m5);

// 12. Kupon SafePlay (Wygrany, single, niska stawka)
MATCH (p:Player {username: 'SafePlay'}), (m4:Match {id: 104})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C7', stake: 50, status: 'WON'})
CREATE (c)-[:CONTAINS]->(b:Bet {type: '1', odds: 1.80, description: 'Home Win'})-[:ON_MATCH]->(m4);

// 13. Kupon SafePlay #2 (W toku, tasiemiec 2 zdarzenia)
MATCH (p:Player {username: 'SafePlay'}), (m5:Match {id: 105}), (m6:Match {id: 106})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C13', stake: 100, status: 'PENDING'})
CREATE (c)-[:CONTAINS]->(b1:Bet {type: '2', odds: 2.50, description: 'Away Win'})-[:ON_MATCH]->(m5)
CREATE (c)-[:CONTAINS]->(b2:Bet {type: 'X', odds: 3.00, description: 'Draw'})-[:ON_MATCH]->(m6);

// 14. Kupon DarkHorse (Wygrany, tasiemiec 2 zdarzenia)
MATCH (p:Player {username: 'DarkHorse'}), (m1:Match {id: 101}), (m5:Match {id: 105})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C14', stake: 75, status: 'WON'})
CREATE (c)-[:CONTAINS]->(b1:Bet {type: '1', odds: 2.10, description: 'Home Win'})-[:ON_MATCH]->(m1)
CREATE (c)-[:CONTAINS]->(b2:Bet {type: '1', odds: 1.60, description: 'Home Win'})-[:ON_MATCH]->(m5);

// 15. Kupon DarkHorse #2 (Przegrany, single)
MATCH (p:Player {username: 'DarkHorse'}), (m6:Match {id: 106})
CREATE (p)-[:PLACED]->(c:Coupon {id: 'C15', stake: 40, status: 'LOST'})
CREATE (c)-[:CONTAINS]->(b:Bet {type: '2', odds: 3.20, description: 'Away Win'})-[:ON_MATCH]->(m6);
