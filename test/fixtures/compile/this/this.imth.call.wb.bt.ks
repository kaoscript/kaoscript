enum PetKind {
	Cat
	Dog
}

class Pet {
	kind() => PetKind.Cat
}

var cat = new Pet()
var nya = {}

echo(cat.kind*$(nya))