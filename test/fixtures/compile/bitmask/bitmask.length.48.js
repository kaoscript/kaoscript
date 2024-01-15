const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const AnimalFlags = Helper.bitmask(Object, ["None", 0n, "HasClaws", 1n, "CanFly", 2n, "EatsFish", 4n, "Endangered", 8n], ["EndangeredFlyingClawedFishEating", 1n | 2n | 4n | 8n, "Predator", 2n | 1n]);
	function printAnimalAbilities() {
		return printAnimalAbilities.__ks_rt(this, arguments);
	};
	printAnimalAbilities.__ks_0 = function(abilities) {
		if((abilities & AnimalFlags.HasClaws) == AnimalFlags.HasClaws) {
			console.log("animal has claws");
		}
		if((abilities & AnimalFlags.CanFly) == AnimalFlags.CanFly) {
			console.log("animal can fly");
		}
		if(abilities === AnimalFlags.None) {
			console.log("nothing");
		}
	};
	printAnimalAbilities.__ks_rt = function(that, args) {
		const t0 = value => Type.isBitmaskInstance(value, AnimalFlags);
		if(args.length === 1) {
			if(t0(args[0])) {
				return printAnimalAbilities.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	let abilities = AnimalFlags.None;
	printAnimalAbilities.__ks_0(abilities);
	abilities = AnimalFlags(abilities | AnimalFlags.HasClaws);
	printAnimalAbilities.__ks_0(abilities);
	abilities = AnimalFlags(abilities & ~AnimalFlags.HasClaws);
	printAnimalAbilities.__ks_0(abilities);
	abilities = AnimalFlags((abilities | AnimalFlags.HasClaws) | AnimalFlags.CanFly);
	printAnimalAbilities.__ks_0(abilities);
	abilities = AnimalFlags((abilities | AnimalFlags.HasClaws) | AnimalFlags.CanFly | AnimalFlags.Endangered);
	printAnimalAbilities.__ks_0(abilities);
	abilities = AnimalFlags((abilities & ~AnimalFlags.HasClaws) & ~AnimalFlags.CanFly);
	printAnimalAbilities.__ks_0(abilities);
	abilities = AnimalFlags((abilities & ~AnimalFlags.HasClaws) & ~AnimalFlags.CanFly & ~AnimalFlags.Endangered);
	printAnimalAbilities.__ks_0(abilities);
	printAnimalAbilities.__ks_0(AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly));
	printAnimalAbilities.__ks_0(AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly | AnimalFlags.Endangered));
	printAnimalAbilities.__ks_0(AnimalFlags(AnimalFlags.EndangeredFlyingClawedFishEating & ~AnimalFlags.HasClaws));
	printAnimalAbilities.__ks_0(AnimalFlags(AnimalFlags.EndangeredFlyingClawedFishEating & ~AnimalFlags.HasClaws & ~AnimalFlags.CanFly));
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(x) {
		let abex;
		if(x === true) {
			abex = AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly | AnimalFlags.Endangered);
		}
		else {
			abex = AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly);
		}
		let abey;
		if(x === true) {
			abey = AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly | AnimalFlags.Endangered);
		}
		else {
			abey = AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly);
		}
		let abez;
		if(x === true) {
			abez = 11;
		}
		else {
			abez = 3;
		}
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const abyx = AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly);
	const abyy = AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly | AnimalFlags.Endangered);
};