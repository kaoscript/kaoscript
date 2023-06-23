const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const TupleA = Helper.tuple(function(foobar, quxbaz) {
		return [foobar, quxbaz];
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
};