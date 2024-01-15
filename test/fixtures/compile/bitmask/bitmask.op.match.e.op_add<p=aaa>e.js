const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const AnimalFlags = Helper.bitmask(Number, ["None", 0, "HasClaws", 1, "CanFly", 2, "EatsFish", 4, "Endangered", 8]);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(animal, req1, req2, req3) {
		let __ks_0;
		if(Operator.bitAnd(animal, __ks_0 = Operator.add(req1, req2, req3)) == __ks_0) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isBitmaskInstance(value, AnimalFlags);
		const t1 = Type.isValue;
		if(args.length === 4) {
			if(t0(args[0]) && t1(args[1]) && t1(args[2]) && t1(args[3])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2], args[3]);
			}
		}
		throw Helper.badArgs();
	};
};