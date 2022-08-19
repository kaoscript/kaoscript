const {Helper} = require("@kaoscript/runtime");
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
};