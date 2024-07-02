const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType0 = Helper.alias(value => value === Weekday.WEDNESDAY || value === Weekday.THURSDAY || value === Weekday.SATURDAY || value === Weekday.SUNDAY);
	const Weekday = Helper.enum(Number, 0, "MONDAY", 0, "TUESDAY", 1, "WEDNESDAY", 2, "THURSDAY", 3, "FRIDAY", 4, "SATURDAY", 5, "SUNDAY", 6);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(day) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType0.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function get() {
		return get.__ks_rt(this, arguments);
	};
	get.__ks_0 = function() {
		return 0;
	};
	get.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return get.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function() {
		let __ks_0 = get.__ks_0();
		if(__ks_0 === 0) {
			foobar.__ks_0(Weekday.SUNDAY);
		}
	};
	quxbaz.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return quxbaz.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};