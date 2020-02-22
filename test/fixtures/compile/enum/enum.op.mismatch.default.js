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
	function foobar(abilities) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(abilities === void 0 || abilities === null) {
			throw new TypeError("'abilities' is not nullable");
		}
		else if(!Type.isEnumInstance(abilities, AnimalFlags)) {
			throw new TypeError("'abilities' is not of type 'AnimalFlags'");
		}
		if((abilities & AnimalFlags.CanFly) !== 0) {
		}
		if((abilities & AnimalFlags.CanFly) === 0) {
		}
	}
};