const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Pair = Helper.tuple(function(__ks_0, __ks_1) {
		return [__ks_0, __ks_1];
	}, function(__ks_new, args) {
		const t0 = Type.isString;
		const t1 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return __ks_new(args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	});
	const Triple = Helper.tuple(function(__ks_0, __ks_1, __ks_2) {
		const _ = Pair.__ks_builder(__ks_0, __ks_1);
		_.push(__ks_2);
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isString;
		const t1 = Type.isNumber;
		const t2 = Type.isBoolean;
		if(args.length === 3) {
			if(t0(args[0]) && t1(args[1]) && t2(args[2])) {
				return __ks_new(args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	}, Pair);
	const triple = Triple.__ks_new("x", 0.1, true);
	console.log(triple[0], triple[1] + 1, !triple[2]);
	return {
		Pair,
		Triple
	};
};