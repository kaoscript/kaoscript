const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y) {
		if(y === void 0) {
			y = null;
		}
		return x && (y === true);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isBoolean;
		const t1 = value => Type.isBoolean(value) || Type.isNull(value);
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};