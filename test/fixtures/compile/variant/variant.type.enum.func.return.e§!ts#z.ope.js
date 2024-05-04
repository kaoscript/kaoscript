const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isDayData: (value, cast, filter) => Type.isDexObject(value, 1, 0, {kind: variant => {
			if(cast) {
				if((variant = Weekday(variant)) === null) {
					return false;
				}
				value["kind"] = variant;
			}
			else if(!Type.isEnumInstance(variant, Weekday)) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant === Weekday.SATURDAY) {
				return Type.isDexObject(value, 0, 0, {message: Type.isString});
			}
			if(variant === Weekday.SUNDAY) {
				return Type.isDexObject(value, 0, 0, {message: Type.isString});
			}
			return true;
		}}),
		is__ks_0: value => value === Weekday.MONDAY || value === Weekday.TUESDAY || value === Weekday.WEDNESDAY || value === Weekday.THURSDAY || value === Weekday.FRIDAY
	};
	const Weekday = Helper.enum(Number, 0, "MONDAY", 0, "TUESDAY", 1, "WEDNESDAY", 2, "THURSDAY", 3, "FRIDAY", 4, "SATURDAY", 5, "SUNDAY", 6);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(kind) {
		return (() => {
			const o = new OBJ();
			o.kind = kind;
			return o;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType.is__ks_0;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};