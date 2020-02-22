var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let AnimalFlags = Helper.enum(Number, {
		None: 0,
		HasClaws: 1,
		CanFly: 2,
		EatsFish: 4,
		Endangered: 8
	});
	function abilities() {
		return AnimalFlags.None;
	}
	let __ks_0;
	if(((__ks_0 = abilities()) & AnimalFlags.CanFly) !== 0 || (__ks_0 & AnimalFlags.EatsFish) !== 0) {
	}
};