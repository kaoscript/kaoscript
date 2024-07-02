const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const TypeA = Helper.alias(value => Type.isDexArray(value, 1, 1, 0, 0, [Type.isString]));
	const TypeB = Helper.alias(value => Type.isDexArray(value, 1, 2, 0, 0, [Type.isValue, Type.isNumber]));
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