require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Shape = require("../export/.export.class.default.ks.j5k8r9.ksb")().Shape;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		return x;
	};
	foobar.__ks_1 = function(x) {
		return x;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = value => Type.isClassInstance(value, Shape);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
			if(t1(args[0])) {
				return foobar.__ks_1.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		foobar
	};
};