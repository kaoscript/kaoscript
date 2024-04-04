const {Helper, initFlag, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Date = {};
	__ks_Date.__ks_get_timezone = function(that) {
		if(!that[initFlag]) {
			__ks_Date.__ks_init(that);
		}
		return that._timezone;
	};
	__ks_Date.__ks_set_timezone = function(that, value) {
		if(!that[initFlag]) {
			__ks_Date.__ks_init(that);
		}
		that._timezone = value;
	};
	__ks_Date.__ks_new_4 = function(...args) {
		return __ks_Date.__ks_cons_4(...args);
	};
	__ks_Date.__ks_cons_4 = function(year, month, day, hours, minutes, seconds, milliseconds, timezone) {
		if(day === void 0 || day === null) {
			day = 0;
		}
		if(hours === void 0 || hours === null) {
			hours = 0;
		}
		if(minutes === void 0 || minutes === null) {
			minutes = 0;
		}
		if(seconds === void 0 || seconds === null) {
			seconds = 0;
		}
		if(milliseconds === void 0 || milliseconds === null) {
			milliseconds = 0;
		}
		var that = __ks_Date.new(year, month, day, hours, minutes, seconds, milliseconds);
		if(!that[initFlag]) {
			__ks_Date.__ks_init(that);
		}
		if(Type.isString(timezone)) {
			that._timezone = timezone;
		}
		return that;
	};
	__ks_Date.__ks_init = function(that) {
		that._timezone = "Etc/UTC";
		that[initFlag] = true;
	};
	__ks_Date.new = function() {
		const t0 = Type.isNumber;
		const t1 = value => Type.isClassInstance(value, Date);
		const t2 = Type.isValue;
		if(arguments.length === 0) {
			return new Date();
		}
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return new Date(arguments[0]);
			}
			if(t1(arguments[0])) {
				return new Date(arguments[0]);
			}
			throw Helper.badArgs();
		}
		if(arguments.length === 2) {
			if(t2(arguments[0]) && t2(arguments[1])) {
				return new Date(arguments[0], arguments[1], void 0, void 0, void 0, void 0, void 0);
			}
			throw Helper.badArgs();
		}
		if(arguments.length === 3) {
			if(t2(arguments[0]) && t2(arguments[1])) {
				if(t2(arguments[2])) {
					return __ks_Date.__ks_cons_4(arguments[0], arguments[1], void 0, void 0, void 0, void 0, void 0, arguments[2]);
				}
				return new Date(arguments[0], arguments[1], arguments[2], void 0, void 0, void 0, void 0);
			}
			throw Helper.badArgs();
		}
		if(arguments.length === 4) {
			if(t2(arguments[0]) && t2(arguments[1])) {
				if(t2(arguments[3])) {
					return __ks_Date.__ks_cons_4(arguments[0], arguments[1], arguments[2], void 0, void 0, void 0, void 0, arguments[3]);
				}
				return new Date(arguments[0], arguments[1], arguments[2], arguments[3], void 0, void 0, void 0);
			}
			throw Helper.badArgs();
		}
		if(arguments.length === 5) {
			if(t2(arguments[0]) && t2(arguments[1])) {
				if(t2(arguments[4])) {
					return __ks_Date.__ks_cons_4(arguments[0], arguments[1], arguments[2], arguments[3], void 0, void 0, void 0, arguments[4]);
				}
				return new Date(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], void 0, void 0);
			}
			throw Helper.badArgs();
		}
		if(arguments.length === 6) {
			if(t2(arguments[0]) && t2(arguments[1])) {
				if(t2(arguments[5])) {
					return __ks_Date.__ks_cons_4(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], void 0, void 0, arguments[5]);
				}
				return new Date(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], void 0);
			}
			throw Helper.badArgs();
		}
		if(arguments.length === 7) {
			if(t2(arguments[0]) && t2(arguments[1])) {
				if(t2(arguments[6])) {
					return __ks_Date.__ks_cons_4(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], void 0, arguments[6]);
				}
				return new Date(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6]);
			}
			throw Helper.badArgs();
		}
		if(arguments.length === 8) {
			if(t2(arguments[0]) && t2(arguments[1]) && t2(arguments[7])) {
				return __ks_Date.__ks_cons_4(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], arguments[7]);
			}
		}
		throw Helper.badArgs();
	};
	const d = __ks_Date.__ks_new_4(2015, 6, 15, 9, 3, 1, 550, "Europe/Paris");
	return {
		__ks_Date
	};
};