const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Weekday = Helper.enum(Number, 0, "MONDAY", 0, "TUESDAY", 1, "WEDNESDAY", 2, "THURSDAY", 3, "FRIDAY", 4, "SATURDAY", 5, "SUNDAY", 6);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(day, month) {
		return 0;
	};
	foobar.__ks_1 = function(day, month) {
		return 1;
	};
	foobar.__ks_2 = function(day, month) {
		return 2;
	};
	foobar.__ks_3 = function(day, month) {
		return 3;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, Weekday);
		const t1 = Type.isNumber;
		const t2 = Type.isString;
		if(args.length === 2) {
			if(t0(args[0])) {
				if(t1(args[1])) {
					return foobar.__ks_0.call(that, args[0], args[1]);
				}
				if(t2(args[1])) {
					return foobar.__ks_1.call(that, args[0], args[1]);
				}
				throw Helper.badArgs();
			}
			if(t2(args[0])) {
				if(t1(args[1])) {
					return foobar.__ks_2.call(that, args[0], args[1]);
				}
				if(t2(args[1])) {
					return foobar.__ks_3.call(that, args[0], args[1]);
				}
				throw Helper.badArgs();
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_2("", -1);
};