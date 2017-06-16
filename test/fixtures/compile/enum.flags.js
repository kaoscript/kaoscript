module.exports = function() {
	let AnimalFlags = {
		None: 0,
		HasClaws: 1,
		CanFly: 2,
		EatsFish: 4,
		Endangered: 8
	};
	AnimalFlags.EndangeredFlyingClawedFishEating = AnimalFlags.HasClaws | AnimalFlags.CanFly | AnimalFlags.EatsFish | AnimalFlags.Endangered;
	AnimalFlags.Predator = AnimalFlags.CanFly | AnimalFlags.HasClaws;
	function printAnimalAbilities(animal) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(animal === void 0 || animal === null) {
			throw new TypeError("'animal' is not nullable");
		}
		let animalFlags = animal.flags;
		if(animalFlags & AnimalFlags.HasClaws) {
			console.log("animal has claws");
		}
		if(animalFlags & AnimalFlags.CanFly) {
			console.log("animal can fly");
		}
		if(animalFlags === AnimalFlags.None) {
			console.log("nothing");
		}
	}
	let animal = {
		flags: AnimalFlags.None
	};
	printAnimalAbilities(animal);
	animal.flags |= AnimalFlags.HasClaws;
	printAnimalAbilities(animal);
	animal.flags &= ~AnimalFlags.HasClaws;
	printAnimalAbilities(animal);
	animal.flags |= AnimalFlags.HasClaws | AnimalFlags.CanFly;
	printAnimalAbilities(animal);
}