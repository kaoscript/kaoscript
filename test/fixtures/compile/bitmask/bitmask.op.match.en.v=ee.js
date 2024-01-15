const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const AnimalFlags = Helper.bitmask(Number, ["None", 0, "HasClaws", 1, "CanFly", 2, "EatsFish", 4, "Endangered", 8]);
	function isEndangered() {
		return isEndangered.__ks_rt(this, arguments);
	};
	isEndangered.__ks_0 = function(animal) {
		if(animal === void 0) {
			animal = null;
		}
		return (animal & AnimalFlags.Endangered) == AnimalFlags.Endangered;
	};
	isEndangered.__ks_rt = function(that, args) {
		const t0 = value => Type.isBitmaskInstance(value, AnimalFlags) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return isEndangered.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};