const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(xy) {
		if(xy === void 0) {
			xy = null;
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => (Type.isDictionary(value) && Type.isNumber(value.x) && Type.isNumber(value.y)) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};