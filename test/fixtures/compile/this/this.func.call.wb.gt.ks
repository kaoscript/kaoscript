enum PetKind {
	Cat
	Dog
}

class Pet {
	kind() => PetKind.Cat
}

func isCat(this: Pet) {
    return this.kind() == PetKind.Cat
}

var nya = Pet.new()

echo(isCat*$(nya))