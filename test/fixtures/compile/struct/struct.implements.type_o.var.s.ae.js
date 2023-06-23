const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isTypeA: value => Type.isDexObject(value, 1, 0, {name: Type.isString})
	};
	const StructA = Helper.struct(function(name) {
		const _ = new OBJ();
		_.name = name;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_new(args[0]);
			}
		}
		throw Helper.badArgs();
	});
	const x = StructA.__ks_new("");
	console.log(x.name);
};