const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const AnimalFlags = Helper.bitmask(Number, ["None", 0, "HasClaws", 1, "CanFly", 2, "EatsFish", 4, "Endangered", 8]);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(abilities) {
		if((abilities & AnimalFlags.CanFly) == AnimalFlags.CanFly && (abilities & AnimalFlags.EatsFish) == AnimalFlags.EatsFish && (abilities & AnimalFlags.Endangered) == AnimalFlags.Endangered) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isBitmaskInstance(value, AnimalFlags);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};