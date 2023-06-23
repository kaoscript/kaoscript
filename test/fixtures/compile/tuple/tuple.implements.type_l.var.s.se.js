const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const TupleA = Helper.tuple(function(name) {
		return [name];
	}, function(__ks_new, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_new(args[0]);
			}
		}
		throw Helper.badArgs();
	});
};