// ============================================================
// 03_complex_queries.cypher
// Złożone podzapytania z funkcjami agregującymi
// ============================================================

// 1. ROI (Zwrot z inwestycji) dla każdego gracza — iloczyn kursów przez exp(sum(log()))
MATCH (p:Player)-[:PLACED]->(c:Coupon {status: 'WON'})-[:CONTAINS]->(b:Bet)
WITH p, c, exp(sum(log(b.odds))) AS combined_odds
WITH p, sum(c.stake) AS total_staked, sum(c.stake * combined_odds) AS total_won
RETURN p.username,
       total_staked,
       round(total_won, 2) AS total_won,
       round(((total_won - total_staked) / total_staked) * 100, 1) AS roi_percent
ORDER BY roi_percent DESC;

// 2. Ranking popularności drużyn na kuponach (ile razy obstawiano ich mecze)
MATCH (t:Team)-[:PLAYS_HOME|PLAYS_AWAY]-(m:Match)<-[:ON_MATCH]-(b:Bet)
RETURN t.name,
       count(b) AS times_bet_on,
       collect(DISTINCT b.type) AS bet_types,
       round(avg(b.odds), 2) AS avg_odds
ORDER BY times_bet_on DESC;

// 3. Analiza ryzyka: średnia stawka kuponu vs liczba zdarzeń (tasiemce vs single)
MATCH (c:Coupon)-[:CONTAINS]->(b:Bet)
WITH c, count(b) AS event_count
RETURN event_count,
       count(c) AS coupon_count,
       round(avg(c.stake), 2) AS avg_stake,
       sum(c.stake) AS total_volume,
       collect(DISTINCT c.status) AS statuses
ORDER BY event_count;

// 4. Podzapytanie: gracze, którzy postawili więcej niż średnia krajowa (WITH + filtr)
MATCH (:Player)-[:PLACED]->(all:Coupon)
WITH avg(all.stake) AS global_avg
MATCH (p:Player)-[:PLACED]->(c:Coupon)
WHERE c.stake > global_avg
RETURN p.username,
       p.city,
       c.id AS coupon_id,
       c.stake,
       round(global_avg, 2) AS avg_krajowa
ORDER BY c.stake DESC;

// 5. Procentowy udział wygranych kuponów w podziale na poziom gracza (VIP vs Standard)
MATCH (p:Player)-[:PLACED]->(c:Coupon)
WITH p.level AS lv,
     count(c) AS total,
     sum(CASE WHEN c.status = 'WON' THEN 1 ELSE 0 END) AS wins,
     sum(CASE WHEN c.status = 'LOST' THEN 1 ELSE 0 END) AS losses,
     sum(CASE WHEN c.status = 'PENDING' THEN 1 ELSE 0 END) AS pending
RETURN lv, total, wins, losses, pending,
       round((toFloat(wins) / total) * 100, 1) AS win_rate_percent
ORDER BY win_rate_percent DESC;

// 6. Najbardziej dochodowy mecz — łączna suma stawek i liczba unikalnych graczy
MATCH (b:Bet)-[:ON_MATCH]->(m:Match)<-[:PLAYS_HOME|PLAYS_AWAY]-(t:Team)
MATCH (c:Coupon)-[:CONTAINS]->(b)
MATCH (p:Player)-[:PLACED]->(c)
WITH m,
     collect(DISTINCT t.name) AS teams,
     sum(c.stake) AS total_volume,
     count(DISTINCT p) AS unique_bettors,
     count(DISTINCT c) AS coupon_count
RETURN m.id, m.date, teams,
       total_volume, unique_bettors, coupon_count
ORDER BY total_volume DESC;

// 7. UNWIND + agregacja: rozbicie typów zakładów i ich statystyki globalne
MATCH (b:Bet)<-[:CONTAINS]-(c:Coupon)
WITH b.type AS bet_type,
     count(b) AS total_bets,
     round(avg(b.odds), 2) AS avg_odds,
     min(b.odds) AS min_odds,
     max(b.odds) AS max_odds,
     collect(DISTINCT c.status) AS coupon_statuses
RETURN bet_type, total_bets, avg_odds, min_odds, max_odds, coupon_statuses
ORDER BY total_bets DESC;
