var {Helper, Operator} = require("@kaoscript/runtime");
module.exports = function() {
	let AnimalFlags = Helper.enum(Number, {
		None: 0,
		HasClaws: 1,
		CanFly: 2,
		EatsFish: 4,
		Endangered: 8
	});
	AnimalFlags.EndangeredFlyingClawedFishEating = AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly | AnimalFlags.EatsFish | AnimalFlags.Endangered);
	AnimalFlags.Predator = AnimalFlags(AnimalFlags.CanFly | AnimalFlags.HasClaws);
	function printAnimalAbilities(animal) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(animal === void 0 || animal === null) {
			throw new TypeError("'animal' is not nullable");
		}
		const animalFlags = animal.flags;
		if((animalFlags & AnimalFlags.HasClaws) !== 0) {
			console.log("animal has claws");
		}
		if((animalFlags & AnimalFlags.CanFly) !== 0) {
			console.log("animal can fly");
		}
		if(animalFlags === AnimalFlags.None.value) {
			console.log("nothing");
		}
	}
	let animal = {
		flags: AnimalFlags.None
	};
	printAnimalAbilities(animal);
	animal.flags = Operator.bitwiseOr(animal.flags, AnimalFlags.HasClaws);
	printAnimalAbilities(animal);
	animal.flags = Operator.bitwiseAnd(animal.flags, ~AnimalFlags.HasClaws);
	printAnimalAbilities(animal);
	animal.flags = Operator.bitwiseOr(animal.flags, AnimalFlags.HasClaws, AnimalFlags.CanFly);
	printAnimalAbilities(animal);
};