enum PetKind {
	Cat
	Dog
}

class Pet {
	kind() => PetKind.Cat
}

var cat = Pet.new()

echo(cat.kind^^()())