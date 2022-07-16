const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const AnimalFlags = Helper.enum(Object, {
		None: 0n,
		HasClaws: 1n,
		CanFly: 2n,
		EatsFish: 4n,
		Endangered: 8n
	});
	AnimalFlags.EndangeredFlyingClawedFishEating = AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly | AnimalFlags.EatsFish | AnimalFlags.Endangered);
	AnimalFlags.Predator = AnimalFlags(AnimalFlags.CanFly | AnimalFlags.HasClaws);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0(AnimalFlags.Predator.value);
	function printAnimalAbilities() {
		return printAnimalAbilities.__ks_rt(this, arguments);
	};
	printAnimalAbilities.__ks_0 = function(abilities) {
		if((abilities & AnimalFlags.HasClaws) !== 0n) {
			console.log("animal has claws");
		}
		if((abilities & AnimalFlags.CanFly) !== 0n) {
			console.log("animal can fly");
		}
		if(abilities === AnimalFlags.None) {
			console.log("nothing");
		}
	};
	printAnimalAbilities.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, AnimalFlags);
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
	abilities = AnimalFlags(abilities | AnimalFlags.HasClaws | AnimalFlags.CanFly);
	printAnimalAbilities.__ks_0(abilities);
	abilities = AnimalFlags(abilities | AnimalFlags.HasClaws | AnimalFlags.CanFly | AnimalFlags.Endangered);
	printAnimalAbilities.__ks_0(abilities);
	abilities = AnimalFlags(abilities & ~AnimalFlags.HasClaws & ~AnimalFlags.CanFly);
	printAnimalAbilities.__ks_0(abilities);
	abilities = AnimalFlags(abilities & ~AnimalFlags.HasClaws & ~AnimalFlags.CanFly & ~AnimalFlags.Endangered);
	printAnimalAbilities.__ks_0(abilities);
	printAnimalAbilities.__ks_0(AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly));
	printAnimalAbilities.__ks_0(AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly | AnimalFlags.Endangered));
	printAnimalAbilities.__ks_0(AnimalFlags(AnimalFlags.EndangeredFlyingClawedFishEating & ~AnimalFlags.HasClaws));
	printAnimalAbilities.__ks_0(AnimalFlags(AnimalFlags.EndangeredFlyingClawedFishEating & ~AnimalFlags.HasClaws & ~AnimalFlags.CanFly));
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(x) {
		let abex = null;
		if(x === true) {
			abex = AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly | AnimalFlags.Endangered);
		}
		else {
			abex = AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly);
		}
		let abey = null;
		if(x === true) {
			abey = AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly | AnimalFlags.Endangered);
		}
		else {
			abey = AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly);
		}
		let abez = null;
		if(x === true) {
			abez = AnimalFlags.HasClaws | AnimalFlags.CanFly | AnimalFlags.Endangered;
		}
		else {
			abez = AnimalFlags.HasClaws | AnimalFlags.CanFly;
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