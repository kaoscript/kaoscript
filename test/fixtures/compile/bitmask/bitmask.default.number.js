const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const AnimalFlags = Helper.bitmask(Number, ["None", 0, "HasClaws", 1, "CanFly", 2, "EatsFish", 4, "Endangered", 8], ["EndangeredFlyingClawedFishEating", 15, "Predator", 3]);
	function printAnimalAbilities() {
		return printAnimalAbilities.__ks_rt(this, arguments);
	};
	printAnimalAbilities.__ks_0 = function(animal) {
		const animalFlags = animal.flags.value;
		if((animalFlags & AnimalFlags.HasClaws.value) !== 0) {
			console.log("animal has claws");
		}
		if((animalFlags & AnimalFlags.CanFly.value) !== 0) {
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
		const o = new OBJ();
		o.flags = AnimalFlags.None;
		return o;
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