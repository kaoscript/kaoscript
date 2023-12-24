require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var {DayAttr, Weekday, __ksType: __ksType0} = require("./.enum.view.smart.export.attr.value.ks.j5k8r9.ksb")();
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(day) {
		console.log(day.value);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType0[0];
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};