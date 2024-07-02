const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Weekday = Helper.enum(Number, 0, "MONDAY", 0, "TUESDAY", 1, "WEDNESDAY", 2, "THURSDAY", 3, "FRIDAY", 4, "SATURDAY", 5, "SUNDAY", 6);
	const Weekend = Helper.alias(value => value === Weekday.SATURDAY || value === Weekday.SUNDAY);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(day) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Weekend.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0(Weekday.SUNDAY);
};