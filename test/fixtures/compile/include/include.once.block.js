const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Array = {};
	__ks_Array.__ks_sttc_map_0 = function(array, iterator) {
		let results = [];
		for(let index = 0, __ks_0 = array.length, item; index < __ks_0; ++index) {
			item = array[index];
			results.push(iterator(item, index));
		}
		return results;
	};
	__ks_Array.__ks_sttc_map_1 = function(array, iterator, condition) {
		let results = [];
		for(let index = 0, __ks_0 = array.length, item; index < __ks_0; ++index) {
			item = array[index];
			if(condition(item, index) === true) {
				results.push(iterator(item, index));
			}
		}
		return results;
	};
	__ks_Array.__ks_func_last_0 = function(index) {
		if(index === void 0 || index === null) {
			index = 1;
		}
		return (this.length !== 0) ? this[this.length - index] : null;
	};
	__ks_Array._sm_map = function() {
		const t0 = Type.isArray;
		const t1 = Type.isFunction;
		if(arguments.length === 2) {
			if(t0(arguments[0]) && t1(arguments[1])) {
				return __ks_Array.__ks_sttc_map_0(arguments[0], arguments[1]);
			}
			throw Helper.badArgs();
		}
		if(arguments.length === 3) {
			if(t0(arguments[0]) && t1(arguments[1]) && t1(arguments[2])) {
				return __ks_Array.__ks_sttc_map_1(arguments[0], arguments[1], arguments[2]);
			}
		}
		throw Helper.badArgs();
	};
	__ks_Array._im_last = function(that, ...args) {
		return __ks_Array.__ks_func_last_rt(that, args);
	};
	__ks_Array.__ks_func_last_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return __ks_Array.__ks_func_last_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	const __ks_String = {};
	__ks_String.__ks_func_lines_0 = function(emptyLines) {
		if(emptyLines === void 0 || emptyLines === null) {
			emptyLines = false;
		}
		if(this.length === 0) {
			return [];
		}
		else if(emptyLines === true) {
			return this.replace(/\r\n/g, "\n").replace(/\r/g, "\n").split("\n");
		}
		else {
			let __ks_0;
			return Type.isValue(__ks_0 = this.match(/[^\r\n]+/g)) ? __ks_0 : [];
		}
	};
	__ks_String.__ks_func_lower_0 = function() {
		return this.toLowerCase();
	};
	__ks_String.__ks_func_toFloat_0 = function() {
		return parseFloat(this);
	};
	__ks_String.__ks_func_toInt_0 = function(base) {
		if(base === void 0 || base === null) {
			base = 10;
		}
		return parseInt(this, base);
	};
	__ks_String._im_lines = function(that, ...args) {
		return __ks_String.__ks_func_lines_rt(that, args);
	};
	__ks_String.__ks_func_lines_rt = function(that, args) {
		if(args.length <= 1) {
			return __ks_String.__ks_func_lines_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	__ks_String._im_lower = function(that, ...args) {
		return __ks_String.__ks_func_lower_rt(that, args);
	};
	__ks_String.__ks_func_lower_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_lower_0.call(that);
		}
		throw Helper.badArgs();
	};
	__ks_String._im_toFloat = function(that, ...args) {
		return __ks_String.__ks_func_toFloat_rt(that, args);
	};
	__ks_String.__ks_func_toFloat_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_toFloat_0.call(that);
		}
		throw Helper.badArgs();
	};
	__ks_String._im_toInt = function(that, ...args) {
		return __ks_String.__ks_func_toInt_rt(that, args);
	};
	__ks_String.__ks_func_toInt_rt = function(that, args) {
		if(args.length <= 1) {
			return __ks_String.__ks_func_toInt_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Array,
		__ks_String
	};
};