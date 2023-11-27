import './bitmask.export.default.ks'

func printAnimalAbilities(abilities: AnimalFlags) {
	if abilities ~~ AnimalFlags.HasClaws {
		echo('animal has claws')
	}

	if abilities ~~ AnimalFlags.CanFly {
		echo('animal can fly')
	}

	if abilities == AnimalFlags.None {
		echo('nothing')
	}
}
