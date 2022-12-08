const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(x) {
		if(x === void 0) {
			x = null;
		}
		const _ = new OBJ();
		_.x = x;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isString(value) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_new(args[0]);
			}
		}
		throw Helper.badArgs();
	});
	const f = Foobar.__ks_new("");
	f.x = null;
};