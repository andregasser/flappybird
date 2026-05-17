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
