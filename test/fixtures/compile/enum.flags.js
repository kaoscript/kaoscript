module.exports = function() {
	let AnimalFlags = {
		None: 0,
		HasClaws: 1,
		CanFly: 2,
		EatsFish: 4,
		Endangered: 8
	};
	AnimalFlags.EndangeredFlyingClawedFishEating = AnimalFlags.HasClaws | AnimalFlags.CanFly | AnimalFlags.EatsFish | AnimalFlags.Endangered;
	function printAnimalAbilities(animal) {
		if(animal === undefined || animal === null) {
			throw new Error("Missing parameter 'animal'");
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