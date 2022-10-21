const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_substringBefore_0 = function(pattern, position, missingValue) {
		if(missingValue === void 0 || missingValue === null) {
			missingValue = "";
		}
		if(position) {
			return __ks_String._im_substringBefore(this, pattern, -1, missingValue);
		}
		else {
			return __ks_String._im_substringBefore(this, pattern, 0, missingValue);
		}
	};
	__ks_String.__ks_func_substringBefore_1 = function(pattern, position, missingValue) {
		if(position === void 0 || position === null) {
			position = 0;
		}
		if(missingValue === void 0 || missingValue === null) {
			missingValue = "";
		}
		return this;
	};
	__ks_String.__ks_func_substringBefore_2 = function(pattern, position, missingValue) {
		if(position === void 0 || position === null) {
			position = 0;
		}
		if(missingValue === void 0 || missingValue === null) {
			missingValue = "";
		}
		return this;
	};
	__ks_String._im_substringBefore = function(that, ...args) {
		return __ks_String.__ks_func_substringBefore_rt(that, args);
	};
	__ks_String.__ks_func_substringBefore_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isRegExp;
		const t2 = Type.isBoolean;
		const t3 = value => Type.isNumber(value) || Type.isNull(value);
		const t4 = value => Type.isString(value) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_String.__ks_func_substringBefore_1.call(that, args[0], void 0, void 0);
			}
			if(t1(args[0])) {
				return __ks_String.__ks_func_substringBefore_2.call(that, args[0], void 0, void 0);
			}
		}
		if(args.length === 2) {
			if(t0(args[0])) {
				if(t2(args[1])) {
					return __ks_String.__ks_func_substringBefore_0.call(that, args[0], args[1], void 0);
				}
				if(t3(args[1])) {
					return __ks_String.__ks_func_substringBefore_1.call(that, args[0], args[1], void 0);
				}
				if(t4(args[1])) {
					return __ks_String.__ks_func_substringBefore_1.call(that, args[0], void 0, args[1]);
				}
				throw Helper.badArgs();
			}
			if(t1(args[0])) {
				if(t2(args[1])) {
					return __ks_String.__ks_func_substringBefore_0.call(that, args[0], args[1], void 0);
				}
				if(t3(args[1])) {
					return __ks_String.__ks_func_substringBefore_2.call(that, args[0], args[1], void 0);
				}
				if(t4(args[1])) {
					return __ks_String.__ks_func_substringBefore_2.call(that, args[0], void 0, args[1]);
				}
				throw Helper.badArgs();
			}
		}
		if(args.length === 3) {
			if(t0(args[0])) {
				if(t2(args[1])) {
					if(t4(args[2])) {
						return __ks_String.__ks_func_substringBefore_0.call(that, args[0], args[1], args[2]);
					}
					throw Helper.badArgs();
				}
				if(t3(args[1]) && t4(args[2])) {
					return __ks_String.__ks_func_substringBefore_1.call(that, args[0], args[1], args[2]);
				}
				throw Helper.badArgs();
			}
			if(t1(args[0])) {
				if(t2(args[1])) {
					if(t4(args[2])) {
						return __ks_String.__ks_func_substringBefore_0.call(that, args[0], args[1], args[2]);
					}
					throw Helper.badArgs();
				}
				if(t3(args[1]) && t4(args[2])) {
					return __ks_String.__ks_func_substringBefore_2.call(that, args[0], args[1], args[2]);
				}
				throw Helper.badArgs();
			}
		}
		if(that.substringBefore) {
			return that.substringBefore(...args);
		}
		throw Helper.badArgs();
	};
};