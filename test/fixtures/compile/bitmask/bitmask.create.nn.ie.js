const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const AnimalFlags = Helper.enum(Number, {
		None: 0,
		HasClaws: 1,
		CanFly: 2,
		EatsFish: 4,
		Endangered: 8,
		EndangeredFlyingClawedFishEating: 15,
		Predator: 3
	});
	function flags() {
		return flags.__ks_rt(this, arguments);
	};
	flags.__ks_0 = function(value) {
		return AnimalFlags(value);
	};
	flags.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return flags.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};