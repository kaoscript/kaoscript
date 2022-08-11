const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(item) {
		const _ = new Dictionary();
		_.item = item;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isDictionary(value, void 0, {values: value => Type.isArray(value, Type.isString) || Type.isNull(value)});
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_new(args[0]);
			}
		}
		throw Helper.badArgs();
	});
	return {
		Foobar
	};
};