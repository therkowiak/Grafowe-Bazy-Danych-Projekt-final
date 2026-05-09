// 1. Rekomendacja Collaborative Filtering: "Gracze tacy jak Ty obstawiali również..."
MATCH (p1:Player {username: 'Kuba_Kiler'})-[:PLACED]->(:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(m:Match)
MATCH (m)<-[:ON_MATCH]-(:Bet)<-[:CONTAINS]-(:Coupon)<-[:PLACED]-(p2:Player)
WHERE p1 <> p2
MATCH (p2)-[:PLACED]->(:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(rec:Match)
WHERE NOT (p1)-[:PLACED]->(:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(rec)
RETURN rec.id AS recommended_match_id, count(*) AS strength
ORDER BY strength DESC LIMIT 5;

// 2. Rekomendacja "Lojalność": Obstaw mecz swojej ulubionej drużyny, którego jeszcze nie masz na kuponie
MATCH (p:Player)-[:FOLLOWS]->(t:Team)-[:PLAYS_HOME|PLAYS_AWAY]-(m:Match)
WHERE NOT (p)-[:PLACED]->(:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(m)
RETURN p.username, t.name AS team_to_bet_on, m.id AS match_id;

// 3. Rekomendacja "High-Stakes": Najczęściej obstawiane mecze przez graczy VIP
MATCH (p:Player {level: 'VIP'})-[:PLACED]->(:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(m:Match)
RETURN m.id, count(*) AS vip_bets
ORDER BY vip_bets DESC;

// 4. Rekomendacja "Trend miejski": Co jest popularne w Twojej okolicy?
MATCH (p1:Player {username: 'LuckyShot'})
MATCH (p2:Player {city: p1.city})
MATCH (p2)-[:PLACED]->(:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(m:Match)
WHERE p1 <> p2
RETURN m.id, count(*) AS local_popularity;

// 5. Rekomendacja "Safe Bet": Mecze drużyn z TOP 3 rankingu grających z drużynami spoza TOP 3
MATCH (t1:Team)-[:PLAYS_HOME]->(m:Match)<-[:PLAYS_AWAY]-(t2:Team)
WHERE t1.rank <= 3 AND t2.rank > 3
RETURN m.id, t1.name AS favorite, t2.name AS underdog;