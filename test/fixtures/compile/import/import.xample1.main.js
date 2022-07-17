require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Date = require("./.import.xample1.core.ks.np51g.ksb")().__ks_Date;
	var __ks_Date = require("./.import.xample1.extra.ks.1c97coh.ksb")(__ks_Date).__ks_Date;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(d) {
		const t = __ks_Date.__ks_func_getEpochTime_1.call(d);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Date);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};