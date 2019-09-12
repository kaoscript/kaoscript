var Type = require("@kaoscript/runtime").Type;
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
	foobar(AnimalFlags.Predator);
	function printAnimalAbilities(abilities) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(abilities === void 0 || abilities === null) {
			throw new TypeError("'abilities' is not nullable");
		}
		else if(!Type.is(abilities, AnimalFlags)) {
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
};