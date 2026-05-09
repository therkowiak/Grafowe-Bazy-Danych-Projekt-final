// Zliczanie wszystkiego
MATCH (n) RETURN labels(n) AS label, count(*) AS count;

// Podgląd grafu (tylko dla małych zbiorów!)
MATCH (n) RETURN n LIMIT 50;

// Sprawdzenie czy są niepowiązane mecze
MATCH (m:Match) WHERE NOT (m)--() RETURN m;