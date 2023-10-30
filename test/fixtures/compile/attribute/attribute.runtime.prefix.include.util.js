const {Helper: KSHelper, OBJ, Type: KSType} = require("@kaoscript/runtime");
module.exports = function() {
	var TimSort = require("timsort");
	function $clone() {
		return $clone.__ks_rt(this, arguments);
	};
	$clone.__ks_0 = function(value = null) {
		if(value === null) {
			return null;
		}
		else if(KSType.isArray(value)) {
			return __ks_Array.__ks_func_clone_0.call(value);
		}
		else if(KSType.isObject(value)) {
			return __ks_Object.__ks_sttc_clone_0(value);
		}
		else {
			return value;
		}
	};
	$clone.__ks_rt = function(that, args) {
		if(args.length <= 1) {
			return $clone.__ks_0.call(that, args[0]);
		}
		throw KSHelper.badArgs();
	};
	function $merge() {
		return $merge.__ks_rt(this, arguments);
	};
	$merge.__ks_0 = function(source, key, value) {
		if(KSType.isArray(value)) {
			source[key] = __ks_Array.__ks_func_clone_0.call(value);
		}
		else if(!KSType.isPrimitive(value)) {
			if(KSType.isObject(source[key])) {
				$mergeObject.__ks_0(source[key], value);
			}
			else {
				source[key] = $clone.__ks_0(value);
			}
		}
		else {
			source[key] = value;
		}
		return source;
	};
	$merge.__ks_rt = function(that, args) {
		const t0 = KSType.isValue;
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
				return $merge.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw KSHelper.badArgs();
	};
	function $mergeObject() {
		return $mergeObject.__ks_rt(this, arguments);
	};
	$mergeObject.__ks_0 = function(source, current) {
		for(const key in current) {
			if(KSType.isValue(source[key])) {
				$merge(source, key, current[key]);
			}
			else {
				source[key] = current[key];
			}
		}
	};
	$mergeObject.__ks_rt = function(that, args) {
		const t0 = KSType.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return $mergeObject.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw KSHelper.badArgs();
	};
	var __ks_Array = {};
	var __ks_Object = {};
	__ks_Array.__ks_sttc_merge_0 = function(args) {
		const l = args.length;
		let source = [];
		let i = 0;
		while((i < l) && !((KSType.isValue(args[i]) ? (source = args[i], true) : false) && KSType.isArray(source))) {
			i += 1;
		}
		i += 1;
		while(i < l) {
			if(KSType.isArray(args[i])) {
				for(let __ks_1 = 0, __ks_0 = args[i].length, value; __ks_1 < __ks_0; ++__ks_1) {
					value = args[i][__ks_1];
					__ks_Array.__ks_func_pushUniq_0.call(source, [value]);
				}
			}
			i += 1;
		}
		return source;
	};
	__ks_Array.__ks_sttc_same_0 = function(a, b) {
		if(a.length !== b.length) {
			return false;
		}
		let __ks_0, __ks_1, __ks_2, __ks_3;
		[__ks_0, __ks_1, __ks_2, __ks_3] = KSHelper.assertLoop(0, "", 0, "", a.length, Infinity, "", 1);
		for(let __ks_4 = __ks_0, i; __ks_4 < __ks_1; __ks_4 += __ks_2) {
			i = __ks_3(__ks_4);
			if(a[i] !== b[i]) {
				return false;
			}
		}
		return true;
	};
	__ks_Array.__ks_func_append_0 = function(args) {
		let __ks_0, __ks_1, __ks_2, __ks_3;
		[__ks_0, __ks_1, __ks_2, __ks_3] = KSHelper.assertLoop(0, "", 0, "", args.length, Infinity, "", 1);
		for(let __ks_4 = __ks_0, k; __ks_4 < __ks_1; __ks_4 += __ks_2) {
			k = __ks_3(__ks_4);
			const arg = KSHelper.array(args[k]);
			const l = arg.length;
			if(l > 50000) {
				let i = 0;
				let j = 50000;
				while(i < l) {
					this.push(...arg.slice(i, j));
					i = j;
					j += 50000;
				}
			}
			else {
				this.push(...arg);
			}
		}
		return this;
	};
	__ks_Array.__ks_func_appendUniq_0 = function(args) {
		let __ks_0, __ks_1, __ks_2, __ks_3;
		[__ks_0, __ks_1, __ks_2, __ks_3] = KSHelper.assertLoop(0, "", 0, "", args.length, Infinity, "", 1);
		for(let __ks_4 = __ks_0, i; __ks_4 < __ks_1; __ks_4 += __ks_2) {
			i = __ks_3(__ks_4);
			if(KSType.isArray(args[i])) {
				__ks_Array.__ks_func_pushUniq_0.call(this, args[i]);
			}
			else {
				__ks_Array.__ks_func_pushUniq_0.call(this, [args[i]]);
			}
		}
		return this;
	};
	__ks_Array.__ks_func_any_0 = function(fn) {
		for(let index = 0, __ks_0 = this.length, item; index < __ks_0; ++index) {
			item = this[index];
			if(fn(item, index, this) === true) {
				return true;
			}
		}
		return false;
	};
	__ks_Array.__ks_func_clear_0 = function() {
		this.length = 0;
		return this;
	};
	__ks_Array.__ks_func_clone_0 = function() {
		let i = this.length;
		const clone = new Array(i);
		while(i > 0) {
			i -= 1;
			clone[i] = $clone.__ks_0(this[i]);
		}
		return clone;
	};
	__ks_Array.__ks_func_contains_0 = function(item, from) {
		if(item === void 0) {
			item = null;
		}
		if(from === void 0 || from === null) {
			from = 0;
		}
		return this.indexOf(item, from) !== -1;
	};
	__ks_Array.__ks_func_intersection_0 = function(arrays) {
		const result = [];
		let seen = false;
		for(let __ks_1 = 0, __ks_0 = this.length, value; __ks_1 < __ks_0; ++__ks_1) {
			value = this[__ks_1];
			seen = true;
			for(let __ks_3 = 0, __ks_2 = arrays.length, array; __ks_3 < __ks_2 && seen; ++__ks_3) {
				array = arrays[__ks_3];
				if(array.indexOf(value) === -1) {
					seen = false;
				}
			}
			if(seen) {
				result.push(value);
			}
		}
		return result;
	};
	__ks_Array.__ks_func_last_0 = function(index) {
		if(index === void 0 || index === null) {
			index = 1;
		}
		return (this.length !== 0) ? this[this.length - index] : null;
	};
	__ks_Array.__ks_func_pushUniq_0 = function(args) {
		if(args.length === 1) {
			if(!__ks_Array.__ks_func_contains_0.call(this, args[0])) {
				this.push(args[0]);
			}
		}
		else {
			for(let __ks_1 = 0, __ks_0 = args.length, item; __ks_1 < __ks_0; ++__ks_1) {
				item = args[__ks_1];
				if(!__ks_Array.__ks_func_contains_0.call(this, item)) {
					this.push(item);
				}
			}
		}
		return this;
	};
	__ks_Array.__ks_func_remove_0 = function(items) {
		if(items.length === 1) {
			let item = items[0];
			for(let i = this.length - 1; i >= 0; --i) {
				if(this[i] === item) {
					this.splice(i, 1);
				}
			}
		}
		else {
			for(let __ks_1 = 0, __ks_0 = items.length, item; __ks_1 < __ks_0; ++__ks_1) {
				item = items[__ks_1];
				for(let i = this.length - 1; i >= 0; --i) {
					if(this[i] === item) {
						this.splice(i, 1);
					}
				}
			}
		}
		return this;
	};
	__ks_Array.__ks_func_sort_0 = function(compareFn) {
		TimSort.sort(this, compareFn);
		return this;
	};
	__ks_Array._sm_merge = function() {
		const t0 = KSType.isValue;
		const te = (pts, idx) => KSHelper.isUsingAllArgs(arguments, pts, idx);
		let pts;
		if(KSHelper.isVarargs(arguments, 0, arguments.length, t0, pts = [0], 0) && te(pts, 1)) {
			return __ks_Array.__ks_sttc_merge_0(KSHelper.getVarargs(arguments, 0, pts[1]));
		}
		if(Array.merge) {
			return Array.merge(...arguments);
		}
		throw KSHelper.badArgs();
	};
	__ks_Array._sm_same = function() {
		const t0 = KSType.isArray;
		if(arguments.length === 2) {
			if(t0(arguments[0]) && t0(arguments[1])) {
				return __ks_Array.__ks_sttc_same_0(arguments[0], arguments[1]);
			}
		}
		if(Array.same) {
			return Array.same(...arguments);
		}
		throw KSHelper.badArgs();
	};
	__ks_Array._im_append = function(that, ...args) {
		return __ks_Array.__ks_func_append_rt(that, args);
	};
	__ks_Array.__ks_func_append_rt = function(that, args) {
		return __ks_Array.__ks_func_append_0.call(that, Array.from(args));
	};
	__ks_Array._im_appendUniq = function(that, ...args) {
		return __ks_Array.__ks_func_appendUniq_rt(that, args);
	};
	__ks_Array.__ks_func_appendUniq_rt = function(that, args) {
		return __ks_Array.__ks_func_appendUniq_0.call(that, Array.from(args));
	};
	__ks_Array._im_any = function(that, ...args) {
		return __ks_Array.__ks_func_any_rt(that, args);
	};
	__ks_Array.__ks_func_any_rt = function(that, args) {
		const t0 = KSType.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Array.__ks_func_any_0.call(that, args[0]);
			}
		}
		if(that.any) {
			return that.any(...args);
		}
		throw KSHelper.badArgs();
	};
	__ks_Array._im_clear = function(that, ...args) {
		return __ks_Array.__ks_func_clear_rt(that, args);
	};
	__ks_Array.__ks_func_clear_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Array.__ks_func_clear_0.call(that);
		}
		if(that.clear) {
			return that.clear(...args);
		}
		throw KSHelper.badArgs();
	};
	__ks_Array._im_clone = function(that, ...args) {
		return __ks_Array.__ks_func_clone_rt(that, args);
	};
	__ks_Array.__ks_func_clone_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Array.__ks_func_clone_0.call(that);
		}
		if(that.clone) {
			return that.clone(...args);
		}
		throw KSHelper.badArgs();
	};
	__ks_Array._im_contains = function(that, ...args) {
		return __ks_Array.__ks_func_contains_rt(that, args);
	};
	__ks_Array.__ks_func_contains_rt = function(that, args) {
		const t0 = value => KSType.isNumber(value) || KSType.isNull(value);
		const te = (pts, idx) => KSHelper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1 && args.length <= 2) {
			if(KSHelper.isVarargs(args, 0, 1, t0, pts = [1], 0) && te(pts, 1)) {
				return __ks_Array.__ks_func_contains_0.call(that, args[0], KSHelper.getVararg(args, 1, pts[1]));
			}
		}
		if(that.contains) {
			return that.contains(...args);
		}
		throw KSHelper.badArgs();
	};
	__ks_Array._im_intersection = function(that, ...args) {
		return __ks_Array.__ks_func_intersection_rt(that, args);
	};
	__ks_Array.__ks_func_intersection_rt = function(that, args) {
		const t0 = KSType.isValue;
		const te = (pts, idx) => KSHelper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(KSHelper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return __ks_Array.__ks_func_intersection_0.call(that, KSHelper.getVarargs(args, 0, pts[1]));
		}
		if(that.intersection) {
			return that.intersection(...args);
		}
		throw KSHelper.badArgs();
	};
	__ks_Array._im_last = function(that, ...args) {
		return __ks_Array.__ks_func_last_rt(that, args);
	};
	__ks_Array.__ks_func_last_rt = function(that, args) {
		const t0 = value => KSType.isNumber(value) || KSType.isNull(value);
		const te = (pts, idx) => KSHelper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(KSHelper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return __ks_Array.__ks_func_last_0.call(that, KSHelper.getVararg(args, 0, pts[1]));
			}
		}
		if(that.last) {
			return that.last(...args);
		}
		throw KSHelper.badArgs();
	};
	__ks_Array._im_pushUniq = function(that, ...args) {
		return __ks_Array.__ks_func_pushUniq_rt(that, args);
	};
	__ks_Array.__ks_func_pushUniq_rt = function(that, args) {
		return __ks_Array.__ks_func_pushUniq_0.call(that, Array.from(args));
	};
	__ks_Array._im_remove = function(that, ...args) {
		return __ks_Array.__ks_func_remove_rt(that, args);
	};
	__ks_Array.__ks_func_remove_rt = function(that, args) {
		return __ks_Array.__ks_func_remove_0.call(that, Array.from(args));
	};
	__ks_Array._im_sort = function(that, ...args) {
		return __ks_Array.__ks_func_sort_rt(that, args);
	};
	__ks_Array.__ks_func_sort_rt = function(that, args) {
		const t0 = KSType.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Array.__ks_func_sort_0.call(that, args[0]);
			}
		}
		if(that.sort) {
			return that.sort(...args);
		}
		throw KSHelper.badArgs();
	};
	__ks_Object.__ks_sttc_clone_0 = function(object) {
		if(KSType.isFunction(object.clone)) {
			return object.clone();
		}
		const clone = new OBJ();
		for(const key in object) {
			const value = object[key];
			clone[key] = $clone.__ks_0(value);
		}
		return clone;
	};
	__ks_Object.__ks_sttc_defaults_0 = function(args) {
		return __ks_Object.__ks_sttc_merge_0([new OBJ(), ...args]);
	};
	__ks_Object.__ks_sttc_delete_0 = function(object, property) {
		KSHelper.delete(object, property);
	};
	__ks_Object.__ks_sttc_isEmpty_0 = function(object) {
		for(let __ks_0 in object) {
			const value = object[__ks_0];
			return false;
		}
		return true;
	};
	__ks_Object.__ks_sttc_key_0 = function(object, index) {
		let i = 0;
		for(const key in object) {
			if(i === index) {
				return key;
			}
			i += 1;
		}
		return null;
	};
	__ks_Object.__ks_sttc_length_0 = function(object) {
		return Object.keys(object).length;
	};
	__ks_Object.__ks_sttc_map_0 = function(object, fn) {
		return Object.entries(object).map(fn);
	};
	__ks_Object.__ks_sttc_merge_0 = function(args) {
		let source = new OBJ();
		let i = 0;
		const l = args.length;
		let src;
		while((i < l) && !((KSType.isValue(args[i]) ? (src = args[i], true) : false) && KSType.isObject(src))) {
			i += 1;
		}
		i += 1;
		if(KSType.isValue(src) && KSType.isObject(src)) {
			source = src;
		}
		while(i < l) {
			if(KSType.isObject(args[i])) {
				for(const key in args[i]) {
					const value = args[i][key];
					$merge(source, key, value);
				}
			}
			i += 1;
		}
		return source;
	};
	__ks_Object.__ks_sttc_same_0 = function(a, b) {
		if(!__ks_Array.__ks_sttc_same_0(Object.keys(a), Object.keys(b))) {
			return false;
		}
		for(const key in a) {
			const value = a[key];
			if(value !== b[key]) {
				return false;
			}
		}
		return true;
	};
	__ks_Object.__ks_sttc_value_0 = function(object, index) {
		let i = 0;
		for(let __ks_0 in object) {
			const value = object[__ks_0];
			if(i === index) {
				return value;
			}
			i += 1;
		}
		return null;
	};
	__ks_Object._sm_clone = function() {
		const t0 = KSType.isObject;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Object.__ks_sttc_clone_0(arguments[0]);
			}
		}
		if(Object.clone) {
			return Object.clone(...arguments);
		}
		throw KSHelper.badArgs();
	};
	__ks_Object._sm_defaults = function() {
		const t0 = KSType.isValue;
		const te = (pts, idx) => KSHelper.isUsingAllArgs(arguments, pts, idx);
		let pts;
		if(KSHelper.isVarargs(arguments, 0, arguments.length, t0, pts = [0], 0) && te(pts, 1)) {
			return __ks_Object.__ks_sttc_defaults_0(KSHelper.getVarargs(arguments, 0, pts[1]));
		}
		if(Object.defaults) {
			return Object.defaults(...arguments);
		}
		throw KSHelper.badArgs();
	};
	__ks_Object._sm_delete = function() {
		const t0 = KSType.isObject;
		const t1 = KSType.isValue;
		if(arguments.length === 2) {
			if(t0(arguments[0]) && t1(arguments[1])) {
				return __ks_Object.__ks_sttc_delete_0(arguments[0], arguments[1]);
			}
		}
		if(Object.delete) {
			return Object.delete(...arguments);
		}
		throw KSHelper.badArgs();
	};
	__ks_Object._sm_isEmpty = function() {
		const t0 = KSType.isObject;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Object.__ks_sttc_isEmpty_0(arguments[0]);
			}
		}
		if(Object.isEmpty) {
			return Object.isEmpty(...arguments);
		}
		throw KSHelper.badArgs();
	};
	__ks_Object._sm_key = function() {
		const t0 = KSType.isObject;
		const t1 = KSType.isNumber;
		if(arguments.length === 2) {
			if(t0(arguments[0]) && t1(arguments[1])) {
				return __ks_Object.__ks_sttc_key_0(arguments[0], arguments[1]);
			}
		}
		if(Object.key) {
			return Object.key(...arguments);
		}
		throw KSHelper.badArgs();
	};
	__ks_Object._sm_length = function() {
		const t0 = KSType.isObject;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Object.__ks_sttc_length_0(arguments[0]);
			}
		}
		if(Object.length) {
			return Object.length(...arguments);
		}
		throw KSHelper.badArgs();
	};
	__ks_Object._sm_map = function() {
		const t0 = KSType.isObject;
		const t1 = KSType.isFunction;
		if(arguments.length === 2) {
			if(t0(arguments[0]) && t1(arguments[1])) {
				return __ks_Object.__ks_sttc_map_0(arguments[0], arguments[1]);
			}
		}
		if(Object.map) {
			return Object.map(...arguments);
		}
		throw KSHelper.badArgs();
	};
	__ks_Object._sm_merge = function() {
		return __ks_Object.__ks_sttc_merge_0(Array.from(arguments));
	};
	__ks_Object._sm_same = function() {
		const t0 = KSType.isObject;
		if(arguments.length === 2) {
			if(t0(arguments[0]) && t0(arguments[1])) {
				return __ks_Object.__ks_sttc_same_0(arguments[0], arguments[1]);
			}
		}
		if(Object.same) {
			return Object.same(...arguments);
		}
		throw KSHelper.badArgs();
	};
	__ks_Object._sm_value = function() {
		const t0 = KSType.isObject;
		const t1 = KSType.isNumber;
		if(arguments.length === 2) {
			if(t0(arguments[0]) && t1(arguments[1])) {
				return __ks_Object.__ks_sttc_value_0(arguments[0], arguments[1]);
			}
		}
		if(Object.value) {
			return Object.value(...arguments);
		}
		throw KSHelper.badArgs();
	};
	const __ks_String = {};
	__ks_String.__ks_func_dasherize_0 = function() {
		return this.replace(/([A-Z])/g, "-$1").replace(/[^A-Za-z0-9]+/g, "-").toLowerCase();
	};
	__ks_String.__ks_func_toFirstLowerCase_0 = function() {
		return KSHelper.cast(this.charAt(0).toLowerCase(), "String", false, KSType.isString) + KSHelper.cast(this.substring(1), "String", false, KSType.isString);
	};
	__ks_String._im_dasherize = function(that, ...args) {
		return __ks_String.__ks_func_dasherize_rt(that, args);
	};
	__ks_String.__ks_func_dasherize_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_dasherize_0.call(that);
		}
		if(that.dasherize) {
			return that.dasherize(...args);
		}
		throw KSHelper.badArgs();
	};
	__ks_String._im_toFirstLowerCase = function(that, ...args) {
		return __ks_String.__ks_func_toFirstLowerCase_rt(that, args);
	};
	__ks_String.__ks_func_toFirstLowerCase_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_toFirstLowerCase_0.call(that);
		}
		if(that.toFirstLowerCase) {
			return that.toFirstLowerCase(...args);
		}
		throw KSHelper.badArgs();
	};
};