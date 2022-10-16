const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(values) {
		const _ = new Dictionary();
		_.values = values;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isArray(value, Type.isString);
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_new(args[0]);
			}
		}
		throw Helper.badArgs();
	});
	const foo = Foobar.__ks_new([]);
};