const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y) {
		if(x === void 0) {
			x = null;
		}
		const z = Helper.toString(Type.isValue(x) ? x : y);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isNull(value);
		const t1 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};