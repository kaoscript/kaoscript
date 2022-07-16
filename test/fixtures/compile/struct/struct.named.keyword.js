const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(__ks_function_1) {
		const _ = new Dictionary();
		_.function = __ks_function_1;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_new(args[0]);
			}
		}
		throw Helper.badArgs();
	});
	const s = Foobar.__ks_new(42);
};