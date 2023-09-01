const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const AnimalFlags = Helper.enum(Number, {
		None: 0,
		HasClaws: 1,
		CanFly: 2,
		EatsFish: 4,
		Endangered: 8
	});
	AnimalFlags.Predator = AnimalFlags(AnimalFlags.CanFly | AnimalFlags.HasClaws);
	AnimalFlags.FlyingPredator = AnimalFlags.CanFly;
};