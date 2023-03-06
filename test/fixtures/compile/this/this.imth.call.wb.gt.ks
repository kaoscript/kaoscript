enum PetKind {
	Cat
	Dog
}

class Pet {
	kind() => PetKind.Cat
}

var cat = new Pet()
var nya = new Pet()

echo(cat.kind*$(nya))