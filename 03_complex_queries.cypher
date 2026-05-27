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

// 6. Najbardziej dochodowy mecz — łączna suma stawek, wynik i faza turnieju
MATCH (b:Bet)-[:ON_MATCH]->(m:Match)<-[:PLAYS_HOME|PLAYS_AWAY]-(t:Team)
MATCH (c:Coupon)-[:CONTAINS]->(b)
MATCH (p:Player)-[:PLACED]->(c)
WITH m,
     collect(DISTINCT t.name) AS teams,
     sum(c.stake) AS total_volume,
     count(DISTINCT p) AS unique_bettors,
     count(DISTINCT c) AS coupon_count
RETURN m.id, m.date, m.result, m.stage, teams,
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

// 8. Statystyki per liga: wolumen zakładów i liczba graczy obstawiających daną ligę
MATCH (l:League {tier: 1})<-[:BELONGS_TO]-(t:Team)-[:PLAYS_HOME|PLAYS_AWAY]-(m:Match)
MATCH (b:Bet)-[:ON_MATCH]->(m)
MATCH (c:Coupon)-[:CONTAINS]->(b)
MATCH (p:Player)-[:PLACED]->(c)
WITH l,
     count(DISTINCT m) AS matches_in_league,
     count(DISTINCT b) AS total_bets,
     count(DISTINCT p) AS unique_bettors,
     sum(c.stake) AS total_volume
RETURN l.name AS league,
       matches_in_league, total_bets, unique_bettors,
       total_volume,
       round(toFloat(total_volume) / total_bets, 2) AS avg_stake_per_bet
ORDER BY total_volume DESC;

// 9. Analiza wyników: trafność zakładów vs rzeczywisty wynik meczu
//    Parsowanie result (np. '3:1') i porównanie z typem zakładu (1/X/2)
MATCH (b:Bet)-[:ON_MATCH]->(m:Match)
MATCH (c:Coupon)-[:CONTAINS]->(b)
WITH b, m, c,
     toInteger(split(m.result, ':')[0]) AS home_goals,
     toInteger(split(m.result, ':')[1]) AS away_goals
WITH b, m, c, home_goals, away_goals,
     CASE
       WHEN home_goals > away_goals THEN '1'
       WHEN home_goals = away_goals THEN 'X'
       ELSE '2'
     END AS actual_outcome
RETURN b.type AS bet_type,
       actual_outcome,
       CASE WHEN b.type = actual_outcome THEN 'HIT' ELSE 'MISS' END AS accuracy,
       count(*) AS bet_count,
       round(avg(b.odds), 2) AS avg_odds
ORDER BY bet_type, actual_outcome;

// 10. Derby premium: wolumen i intensywność zakładów na mecze rywali (RIVAL)
MATCH (t1:Team)-[r:RIVAL]-(t2:Team)
MATCH (t1)-[:PLAYS_HOME|PLAYS_AWAY]-(m:Match)-[:PLAYS_HOME|PLAYS_AWAY]-(t2)
OPTIONAL MATCH (b:Bet)-[:ON_MATCH]->(m)
OPTIONAL MATCH (c:Coupon)-[:CONTAINS]->(b)
WITH r.type AS rivalry, r.intensity AS intensity,
     t1.name AS team_1, t2.name AS team_2,
     m, collect(DISTINCT c.stake) AS stakes
RETURN rivalry, intensity, team_1, team_2,
       m.id AS match_id, m.result,
       size(stakes) AS coupon_count,
       reduce(s = 0, x IN stakes | s + x) AS total_volume
ORDER BY intensity, total_volume DESC;
