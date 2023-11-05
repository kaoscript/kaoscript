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
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(flags) {
		if(flags.value === 42) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, AnimalFlags);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};