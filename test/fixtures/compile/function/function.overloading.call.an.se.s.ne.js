const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		if(x === void 0) {
			x = null;
		}
	};
	foobar.__ks_1 = function(x) {
		return x;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_1.call(that, args[0]);
			}
			return foobar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	console.log(foobar.__ks_1("foo"));
	console.log(Helper.toString(foobar.__ks_0(null)));
};