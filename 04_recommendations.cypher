// ============================================================
// 04_recommendations.cypher
// System rekomendacji oparty na strukturze grafu
// ============================================================

// 1. Collaborative Filtering: "Gracze tacy jak Ty obstawiali również..."
//    Szuka meczy, które obstawiali gracze pokrywający się z Kuba_Kiler, ale których Kuba jeszcze nie obstawił
MATCH (p1:Player {username: 'Kuba_Kiler'})-[:PLACED]->(:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(m:Match)
MATCH (m)<-[:ON_MATCH]-(:Bet)<-[:CONTAINS]-(:Coupon)<-[:PLACED]-(p2:Player)
WHERE p1 <> p2
MATCH (p2)-[:PLACED]->(:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(rec:Match)
WHERE NOT (p1)-[:PLACED]->(:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(rec)
RETURN rec.id AS recommended_match_id,
       rec.date,
       collect(DISTINCT p2.username) AS recommended_by,
       count(*) AS strength
ORDER BY strength DESC LIMIT 5;

// 2. Lojalność: Obstaw mecz swojej ulubionej drużyny, którego jeszcze nie masz na kuponie
MATCH (p:Player)-[:FOLLOWS]->(t:Team)-[:PLAYS_HOME|PLAYS_AWAY]-(m:Match)
WHERE NOT (p)-[:PLACED]->(:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(m)
RETURN p.username,
       t.name AS team_to_bet_on,
       m.id AS match_id,
       m.date,
       m.importance
ORDER BY p.username, m.importance DESC;

// 3. High-Stakes: Najczęściej obstawiane mecze przez graczy VIP
MATCH (p:Player {level: 'VIP'})-[:PLACED]->(c:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(m:Match)
RETURN m.id,
       m.date,
       count(*) AS vip_bets,
       sum(c.stake) AS vip_volume
ORDER BY vip_bets DESC, vip_volume DESC;

// 4. Trend miejski: Co jest popularne w Twojej okolicy?
//    Dla każdego gracza — mecze obstawiane przez innych z tego samego miasta
MATCH (p1:Player {username: 'LuckyShot'})
MATCH (p2:Player {city: p1.city})-[:PLACED]->(:Coupon)-[:CONTAINS]->(b:Bet)-[:ON_MATCH]->(m:Match)
WHERE p1 <> p2
RETURN m.id,
       count(DISTINCT p2) AS local_bettors,
       collect(DISTINCT b.type) AS popular_types,
       count(*) AS local_popularity
ORDER BY local_popularity DESC;

// 5. Safe Bet: Mecze drużyn z TOP 3 rankingu grających z drużynami spoza TOP 3
MATCH (fav:Team)-[:PLAYS_HOME]->(m:Match)<-[:PLAYS_AWAY]-(under:Team)
WHERE fav.rank <= 3 AND under.rank > 3
RETURN m.id, m.date,
       fav.name AS favorite, fav.rank AS fav_rank,
       under.name AS underdog, under.rank AS under_rank;

// 6. Social Bet: Rekomendacja na podstawie zakładów znajomych (FRIENDS_WITH)
//    "Twoi znajomi obstawiają te mecze — dołącz!"
MATCH (p1:Player {username: 'Kuba_Kiler'})-[:FRIENDS_WITH]-(friend:Player)
MATCH (friend)-[:PLACED]->(:Coupon)-[:CONTAINS]->(b:Bet)-[:ON_MATCH]->(m:Match)
WHERE NOT (p1)-[:PLACED]->(:Coupon)-[:CONTAINS]->(:Bet)-[:ON_MATCH]->(m)
RETURN m.id,
       m.date,
       collect(DISTINCT friend.username) AS friends_betting,
       collect(DISTINCT b.type) AS their_picks
ORDER BY size(collect(DISTINCT friend.username)) DESC;

// 7. Contrarian Bet: Mecze, na które większość stawia "1", ale kurs sugeruje wartość w "2"
MATCH (b:Bet)-[:ON_MATCH]->(m:Match)
WITH m,
     sum(CASE WHEN b.type = '1' THEN 1 ELSE 0 END) AS home_bets,
     sum(CASE WHEN b.type = '2' THEN 1 ELSE 0 END) AS away_bets,
     max(CASE WHEN b.type = '2' THEN b.odds ELSE 0 END) AS away_odds,
     count(b) AS total_bets
WHERE toFloat(home_bets) / total_bets > 0.6 AND away_odds > 2.0
RETURN m.id, m.date,
       home_bets, away_bets, total_bets,
       away_odds AS value_away_odds;
