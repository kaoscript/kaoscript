const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(x, y) {
		const _ = new Dictionary();
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
	[Foobar.__ks_new(0, 0)].map((() => {
		const __ks_rt = (...args) => {
			const t0 = Type.isDestructurableObject;
			const t1 = Type.isValue;
			if(args.length === 3) {
				if(t0(args[0]) && t1(args[1]) && t1(args[2])) {
					return __ks_rt.__ks_0.call(this, args[0], args[1], args[2]);
				}
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = ({x}, __ks_0, __ks_1) => {
			return x;
		};
		return __ks_rt;
	})());
};