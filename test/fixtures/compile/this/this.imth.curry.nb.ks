enum PetKind {
	Cat
	Dog
}

class Pet {
	kind() => PetKind.Cat
}


var cat = new Pet()

echo(cat.kind^^()())