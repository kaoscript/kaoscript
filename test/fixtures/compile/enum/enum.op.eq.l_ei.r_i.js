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
	function foobar(flags) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(flags === void 0 || flags === null) {
			throw new TypeError("'flags' is not nullable");
		}
		else if(!Type.isEnumInstance(flags, AnimalFlags)) {
			throw new TypeError("'flags' is not of type 'AnimalFlags'");
		}
		if(flags.value === 42) {
		}
	}
};