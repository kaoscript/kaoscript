require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var {Weekday, Weekend} = require("./.enum.view.list.export.ks.j5k8r9.ksb")();
	function isWeekend() {
		return isWeekend.__ks_rt(this, arguments);
	};
	isWeekend.__ks_0 = function(day) {
		return Weekend.is(day);
	};
	isWeekend.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, Weekday);
		if(args.length === 1) {
			if(t0(args[0])) {
				return isWeekend.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};