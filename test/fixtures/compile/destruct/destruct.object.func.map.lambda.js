const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(x, y) {
		const _ = new OBJ();
		_.x = x;
		_.y = y;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return __ks_new(args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	});
	[Foobar.__ks_new(0, 0)].map(Helper.function(({x}, __ks_0, __ks_1) => {
		return x;
	}, (fn, ...args) => {
		const t0 = value => Type.isDexObject(value, 1, 0, {x: Type.isValue});
		const t1 = Type.isValue;
		if(args.length === 3) {
			if(t0(args[0]) && t1(args[1]) && t1(args[2])) {
				return fn.call(null, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	}));
};