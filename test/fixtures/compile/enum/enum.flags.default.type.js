var {Helper, Type} = require("@kaoscript/runtime");
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
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isNumber(x)) {
			throw new TypeError("'x' is not of type 'Number'");
		}
	}
	foobar(AnimalFlags.Predator.value);
	function printAnimalAbilities(abilities) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(abilities === void 0 || abilities === null) {
			throw new TypeError("'abilities' is not nullable");
		}
		else if(!Type.isEnumMember(abilities, AnimalFlags)) {
			throw new TypeError("'abilities' is not of type 'AnimalFlags'");
		}
		if((abilities & AnimalFlags.HasClaws) !== 0) {
			console.log("animal has claws");
		}
		if((abilities & AnimalFlags.CanFly) !== 0) {
			console.log("animal can fly");
		}
		if(abilities === AnimalFlags.None) {
			console.log("nothing");
		}
	}
	let abilities = AnimalFlags.None;
	printAnimalAbilities(abilities);
	abilities = AnimalFlags(abilities | AnimalFlags.HasClaws);
	printAnimalAbilities(abilities);
	abilities = AnimalFlags(abilities & ~AnimalFlags.HasClaws);
	printAnimalAbilities(abilities);
	abilities = AnimalFlags(abilities | AnimalFlags.HasClaws | AnimalFlags.CanFly);
	printAnimalAbilities(abilities);
	printAnimalAbilities(AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly));
	printAnimalAbilities(AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly | AnimalFlags.Endangered));
	function quxbaz(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
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
	}
	const abyx = AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly);
	const abyy = AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly | AnimalFlags.Endangered);
};