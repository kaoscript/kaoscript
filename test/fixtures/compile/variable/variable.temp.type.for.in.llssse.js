require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = require("../_/._array.last.ks.ri6kvh.ksb")(__ks_Array).__ks_Array;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		for(let __ks_1 = 0, __ks_0 = values.length, vals; __ks_1 < __ks_0; ++__ks_1) {
			vals = values[__ks_1];
			const last = __ks_Array.__ks_func_last_0.call(vals);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, value => Type.isArray(value, Type.isString));
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};