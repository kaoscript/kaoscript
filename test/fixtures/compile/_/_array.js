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
	return {
		__ks_Array
	};
};