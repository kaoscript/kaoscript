const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const AnimalFlags = Helper.bitmask(Number, ["None", 0, "HasClaws", 1, "CanFly", 2, "EatsFish", 4, "Endangered", 8]);
	let animal;
	animal = AnimalFlags(AnimalFlags.HasClaws | AnimalFlags.CanFly);
};