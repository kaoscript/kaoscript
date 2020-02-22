var Helper = require("@kaoscript/runtime").Helper;
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
};