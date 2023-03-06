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

var nya = new Pet()

echo(isCat^^(nya)())