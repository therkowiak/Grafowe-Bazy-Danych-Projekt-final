// 1. ROI (Zwrot z inwestycji) dla graczy, którzy wygrali
MATCH (p:Player)-[:PLACED]->(c:Coupon {status: 'WON'})
MATCH (c)-[:CONTAINS]->(b:Bet)
WITH p, c, exp(sum(log(b.odds))) AS final_odds // Matematyczne obliczenie iloczynu kursów
RETURN p.username, sum(c.stake) AS total_staked, sum(c.stake * final_odds) AS total_won
ORDER BY total_won DESC;

// 2. Ranking popularności drużyn na kuponach (ile razy obstawiano ich mecze)
MATCH (t:Team)-[:PLAYS_HOME|PLAYS_AWAY]-(m:Match)<-[:ON_MATCH]-(b:Bet)
RETURN t.name, count(b) AS times_bet_on, collect(DISTINCT b.type) AS bet_types
ORDER BY times_bet_on DESC;

// 3. Analiza ryzyka: Średnia stawka kuponu w zależności od liczby zdarzeń (tasiemce vs single)
MATCH (c:Coupon)-[:CONTAINS]->(b:Bet)
WITH c, count(b) AS event_count
RETURN event_count, avg(c.stake) AS avg_stake, count(c) AS coupon_count
ORDER BY event_count;

// 4. Podzapytanie: Gracze z Warszawy, którzy postawili więcej niż średnia krajowa
MATCH (all:Coupon)
WITH avg(all.stake) AS global_avg
MATCH (p:Player {city: 'Warszawa'})-[:PLACED]->(c:Coupon)
WHERE c.stake > global_avg
RETURN p.username, c.id, c.stake, global_avg;

// 5. Agregacja: Procentowy udział wygranych kuponów w podziale na poziom gracza (VIP vs Standard)
MATCH (p:Player)-[:PLACED]->(c:Coupon)
WITH p.level AS lv, count(c) AS total
MATCH (p2:Player {level: lv})-[:PLACED]->(win:Coupon {status: 'WON'})
RETURN lv, total, count(win) AS wins, (toFloat(count(win))/total)*100 AS win_rate_percent;