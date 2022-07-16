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
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(__ks_tuple_1) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isTuple;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0(Pair);
};