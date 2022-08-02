extern console

func print(heroes) {
	var dyn hero

	for hero of heroes {
		console.log(hero.name)
	}
}