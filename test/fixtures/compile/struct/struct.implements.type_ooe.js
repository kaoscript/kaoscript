const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isTypeA: value => Type.isDexObject(value, 1, 0, {foobar: Type.isString}),
		isTypeB: value => Type.isDexObject(value, 1, 0, {quxbaz: Type.isNumber})
	};
	const StructA = Helper.struct(function(foobar, quxbaz) {
		const _ = new OBJ();
		_.foobar = foobar;
		_.quxbaz = quxbaz;
		return _;
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