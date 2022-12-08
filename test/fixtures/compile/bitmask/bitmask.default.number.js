const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const AnimalFlags = Helper.enum(Number, {
		None: 0,
		HasClaws: 1,
		CanFly: 2,
		EatsFish: 4,
		Endangered: 8
	});
	AnimalFlags.EndangeredFlyingClawedFishEating = AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly | AnimalFlags.EatsFish | AnimalFlags.Endangered);
	AnimalFlags.Predator = AnimalFlags(AnimalFlags.CanFly | AnimalFlags.HasClaws);
	function printAnimalAbilities() {
		return printAnimalAbilities.__ks_rt(this, arguments);
	};
	printAnimalAbilities.__ks_0 = function(animal) {
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
	};
	printAnimalAbilities.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return printAnimalAbilities.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	let animal = (() => {
		const d = new OBJ();
		d.flags = AnimalFlags.None;
		return d;
	})();
	printAnimalAbilities.__ks_0(animal);
	animal.flags = AnimalFlags(animal.flags | AnimalFlags.HasClaws);
	printAnimalAbilities.__ks_0(animal);
	animal.flags = AnimalFlags(animal.flags & ~AnimalFlags.HasClaws);
	printAnimalAbilities.__ks_0(animal);
	animal.flags = AnimalFlags((animal.flags | AnimalFlags.HasClaws) | AnimalFlags.CanFly);
	printAnimalAbilities.__ks_0(animal);
	return {
		AnimalFlags,
		printAnimalAbilities
	};
};