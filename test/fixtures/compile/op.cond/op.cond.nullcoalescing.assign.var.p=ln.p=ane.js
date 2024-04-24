const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y) {
		if(x === void 0) {
			x = null;
		}
		if(y === void 0) {
			y = null;
		}
		if(!Type.isValue(x) && (Type.isArray(y))) {
			x = y;
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value) || Type.isNull(value);
		if(args.length === 2) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};