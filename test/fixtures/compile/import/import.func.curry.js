require("kaoscript/register");
const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Function = require("../export/.export.func.curry.ks.j5k8r9.ksb")().__ks_Function;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(prefix, name) {
		return Operator.add(prefix, name);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	const f = __ks_Function.__ks_sttc_curry_0(foobar, ["Hello "]);
};