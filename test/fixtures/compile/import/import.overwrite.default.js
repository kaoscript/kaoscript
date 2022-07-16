require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var {Date, __ks_Date} = require("../implement/.implement.overwrite.pi.ks.j5k8r9.ksb")();
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(d) {
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
	const d = new Date();
	foobar.__ks_0(__ks_Date.__ks_func_setDate_1.call(d, 1));
	return {
		Date,
		__ks_Date
	};
};