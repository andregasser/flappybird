extends Node

const POOL: Array = [
	{
		"question": "Wie viele Beine hat eine Spinne?",
		"options": ["6", "8", "10", "4"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier macht 'Muh'?",
		"options": ["Schaf", "Kuh", "Ziege", "Pferd"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier kann fliegen, ist aber kein Vogel?",
		"options": ["Eichhörnchen", "Fledermaus", "Frosch", "Eidechse"],
		"correct_index": 1,
	},
	{
		"question": "Was ist das grösste Säugetier?",
		"options": ["Elefant", "Blauwal", "Giraffe", "Eisbär"],
		"correct_index": 1,
	},
	{
		"question": "Wie schläft ein Flamingo?",
		"options": ["liegend", "auf einem Bein", "im Wasser", "fliegend"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier hat einen Höcker?",
		"options": ["Pferd", "Kamel", "Zebra", "Elefant"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier legt Eier und ist ein Säugetier?",
		"options": ["Igel", "Schnabeltier", "Maus", "Hase"],
		"correct_index": 1,
	},
	{
		"question": "Wie viele Herzen hat ein Oktopus?",
		"options": ["1", "2", "3", "8"],
		"correct_index": 2,
	},
	{
		"question": "Welches Tier wechselt seine Farbe?",
		"options": ["Frosch", "Schlange", "Chamäleon", "Eidechse"],
		"correct_index": 2,
	},
	{
		"question": "Welcher Vogel kann nicht fliegen?",
		"options": ["Adler", "Spatz", "Pinguin", "Taube"],
		"correct_index": 2,
	},
	{
		"question": "Welches Tier hat ein Geweih?",
		"options": ["Wildschwein", "Hirsch", "Wolf", "Bär"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier lebt im Polarkreis?",
		"options": ["Löwe", "Tiger", "Eisbär", "Giraffe"],
		"correct_index": 2,
	},
	{
		"question": "Welches Tier hört mit den Beinen?",
		"options": ["Schmetterling", "Käfer", "Grille", "Biene"],
		"correct_index": 2,
	},
	{
		"question": "Was frisst ein Panda hauptsächlich?",
		"options": ["Fisch", "Fleisch", "Bambus", "Insekten"],
		"correct_index": 2,
	},
	{
		"question": "Welches Tier hat die längste Zunge im Verhältnis zum Körper?",
		"options": ["Schlange", "Frosch", "Chamäleon", "Kuh"],
		"correct_index": 2,
	},
	{
		"question": "Welches ist das schnellste Landtier?",
		"options": ["Gepard", "Löwe", "Pferd", "Antilope"],
		"correct_index": 0,
	},
	{
		"question": "Welches Tier hat den längsten Hals?",
		"options": ["Strauss", "Giraffe", "Pferd", "Zebra"],
		"correct_index": 1,
	},
	{
		"question": "Wie viele Augen hat eine Spinne meistens?",
		"options": ["2", "4", "6", "8"],
		"correct_index": 3,
	},
	{
		"question": "Welches Tier ist als König der Tiere bekannt?",
		"options": ["Tiger", "Löwe", "Elefant", "Adler"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier baut Staudämme?",
		"options": ["Otter", "Biber", "Bisamratte", "Marder"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier hat Stacheln auf dem Rücken?",
		"options": ["Maus", "Igel", "Hase", "Eichhörnchen"],
		"correct_index": 1,
	},
	{
		"question": "Welche Farbe hat das Blut eines Tintenfisches?",
		"options": ["Rot", "Blau", "Grün", "Weiss"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier kann am höchsten springen im Verhältnis zur Körpergrösse?",
		"options": ["Känguru", "Floh", "Frosch", "Heuschrecke"],
		"correct_index": 1,
	},
	{
		"question": "Wo lebt ein Eisbär?",
		"options": ["Antarktis", "Arktis", "Wüste", "Regenwald"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier hat einen langen Rüssel?",
		"options": ["Giraffe", "Elefant", "Zebra", "Nilpferd"],
		"correct_index": 1,
	},
	{
		"question": "Welcher Vogel ist das Wappentier der USA?",
		"options": ["Adler", "Pelikan", "Eule", "Pfau"],
		"correct_index": 0,
	},
	{
		"question": "Welches Tier produziert Honig?",
		"options": ["Schmetterling", "Wespe", "Biene", "Hummel"],
		"correct_index": 2,
	},
	{
		"question": "Welches Tier ist Symbol für Weisheit?",
		"options": ["Rabe", "Eule", "Schwan", "Pfau"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier hat vier Mägen?",
		"options": ["Schwein", "Kuh", "Pferd", "Schaf"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier kräht am Morgen?",
		"options": ["Truthahn", "Hahn", "Ente", "Taube"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier hat schwarze und weisse Streifen?",
		"options": ["Pferd", "Antilope", "Zebra", "Tapir"],
		"correct_index": 2,
	},
	{
		"question": "Wo leben Pinguine?",
		"options": ["Arktis", "Antarktis", "Tropen", "Wüste"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier ist das grösste Landtier?",
		"options": ["Nashorn", "Elefant", "Giraffe", "Nilpferd"],
		"correct_index": 1,
	},
	{
		"question": "Was frisst eine Eule meistens?",
		"options": ["Insekten", "Mäuse", "Fische", "Beeren"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier ist berühmt für seine schlechte Sehkraft?",
		"options": ["Adler", "Maulwurf", "Eule", "Falke"],
		"correct_index": 1,
	},
	{
		"question": "Wie nennt man ein junges Pferd?",
		"options": ["Welpe", "Fohlen", "Kalb", "Ferkel"],
		"correct_index": 1,
	},
	{
		"question": "Wie nennt man ein junges Schwein?",
		"options": ["Ferkel", "Kalb", "Lamm", "Fohlen"],
		"correct_index": 0,
	},
	{
		"question": "Wie viele Pfoten hat eine Katze?",
		"options": ["2", "4", "6", "8"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier hat Federn?",
		"options": ["Fledermaus", "Hai", "Spatz", "Eidechse"],
		"correct_index": 2,
	},
	{
		"question": "Welche Spinne ist berühmt für ihren giftigen Biss?",
		"options": ["Tarantel", "Schwarze Witwe", "Hauswinkelspinne", "Kreuzspinne"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier ist eng verwandt mit dem Wolf?",
		"options": ["Katze", "Hund", "Bär", "Fuchs"],
		"correct_index": 1,
	},
	{
		"question": "Welcher Fisch ist berühmt für seine scharfen Zähne?",
		"options": ["Karpfen", "Hering", "Hai", "Forelle"],
		"correct_index": 2,
	},
	{
		"question": "Welches Tier ist für sein Schneckenhaus bekannt?",
		"options": ["Wurm", "Schnecke", "Spinne", "Käfer"],
		"correct_index": 1,
	},
	{
		"question": "Wie atmen Fische?",
		"options": ["Lunge", "Kiemen", "Haut", "Nase"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier ist berühmt für sein langes Gedächtnis?",
		"options": ["Hund", "Elefant", "Affe", "Hai"],
		"correct_index": 1,
	},
	{
		"question": "Welcher Vogel ist berühmt für sein farbiges Gefieder?",
		"options": ["Krähe", "Spatz", "Pfau", "Taube"],
		"correct_index": 2,
	},
	{
		"question": "Welches Tier kann am tiefsten tauchen?",
		"options": ["Delfin", "Pottwal", "Hai", "Robbe"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier baut Spinnennetze?",
		"options": ["Käfer", "Spinne", "Ameise", "Biene"],
		"correct_index": 1,
	},
	{
		"question": "Was frisst ein Tiger hauptsächlich?",
		"options": ["Pflanzen", "Insekten", "Fleisch", "Früchte"],
		"correct_index": 2,
	},
	{
		"question": "Welches Tier hält einen Winterschlaf?",
		"options": ["Falke", "Bär", "Pferd", "Reh"],
		"correct_index": 1,
	},
]

var remaining: Array = []


func start_round() -> void:
	remaining = POOL.duplicate()
	remaining.shuffle()


func next_puzzle() -> Dictionary:
	if remaining.is_empty():
		# Refill if exhausted (rare: ≥15 collisions in one round)
		remaining = POOL.duplicate()
		remaining.shuffle()
	return remaining.pop_back()
