require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = require("../_/._string.ks.j5k8r9.ksb")().__ks_String;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		return Type.isValue(values[0]) ? __ks_String.__ks_func_toInt_0.call(values[0]) : null;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, Type.isString);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};