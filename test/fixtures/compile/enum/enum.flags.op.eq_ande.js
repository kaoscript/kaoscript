const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const AnimalFlags = Helper.enum(Object, {
		None: 0n,
		HasClaws: 1n,
		CanFly: 2n,
		EatsFish: 4n,
		Endangered: 8n
	});
	let animal = null;
	animal = AnimalFlags(AnimalFlags.HasClaws & ~AnimalFlags.CanFlyAnimalFlags);
};