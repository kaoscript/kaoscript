const {Dictionary, Helper: KSHelper, Type: KSType} = require("@kaoscript/runtime");
module.exports = function() {
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
		else if(KSType.isDictionary(value)) {
			return __ks_Dictionary.__ks_sttc_clone_0(value);
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
	const $merge = (() => {
		const d = new Dictionary();
		d.merge = (() => {
			const __ks_rt = (...args) => {
				const t0 = KSType.isValue;
				if(args.length === 3) {
					if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
						return __ks_rt.__ks_0.call(null, args[0], args[1], args[2]);
					}
				}
				throw KSHelper.badArgs();
			};
			__ks_rt.__ks_0 = function(source, key, value) {
				if(KSType.isArray(value)) {
					source[key] = __ks_Array.__ks_func_clone_0.call(value);
				}
				else if(!KSType.isPrimitive(value)) {
					if(KSType.isDictionary(source[key]) || KSType.isObject(source[key])) {
						$merge.object(source[key], value);
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
			return __ks_rt;
		})();
		d.object = (() => {
			const __ks_rt = (...args) => {
				const t0 = KSType.isValue;
				if(args.length === 2) {
					if(t0(args[0]) && t0(args[1])) {
						return __ks_rt.__ks_0.call(null, args[0], args[1]);
					}
				}
				throw KSHelper.badArgs();
			};
			__ks_rt.__ks_0 = function(source, current) {
				for(const key in current) {
					if(KSType.isValue(source[key])) {
						$merge.merge(source, key, current[key]);
					}
					else {
						source[key] = current[key];
					}
				}
			};
			return __ks_rt;
		})();
		return d;
	})();
	var __ks_Array = {};
	var __ks_Dictionary = {};
	__ks_Array.__ks_func_append_0 = function(args) {
		let l = null, i = null, j = null, arg = null;
		for(let k = 0, __ks_0 = args.length; k < __ks_0; ++k) {
			arg = KSHelper.array(args[k]);
			if((l = arg.length) > 50000) {
				i = 0;
				j = 50000;
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
		if(args.length === 1) {
			__ks_Array.__ks_func_pushUniq_0.call(this, [].concat(args[0]));
		}
		else {
			for(let i = 0, __ks_0 = args.length; i < __ks_0; ++i) {
				__ks_Array.__ks_func_pushUniq_0.call(this, [].concat(args[i]));
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
		let clone = new Array(i);
		while(i > 0) {
			clone[--i] = $clone.__ks_0(this[i]);
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
		let seen = null;
		for(let __ks_0 = 0, __ks_1 = this.length, value; __ks_0 < __ks_1; ++__ks_0) {
			value = this[__ks_0];
			seen = true;
			for(let __ks_2 = 0, __ks_3 = arrays.length, array; __ks_2 < __ks_3 && seen; ++__ks_2) {
				array = arrays[__ks_2];
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
			for(let __ks_0 = 0, __ks_1 = items.length, item; __ks_0 < __ks_1; ++__ks_0) {
				item = items[__ks_0];
				for(let i = this.length - 1; i >= 0; --i) {
					if(this[i] === item) {
						this.splice(i, 1);
					}
				}
			}
		}
		return this;
	};
	__ks_Array.__ks_sttc_merge_0 = function(args) {
		let source = [];
		let i = 0;
		let l = args.length;
		while((i < l) && !((KSType.isValue(args[i]) ? (source = args[i], true) : false) && KSType.isArray(source))) {
			++i;
		}
		++i;
		while(i < l) {
			if(KSType.isArray(args[i])) {
				for(let __ks_0 = 0, __ks_1 = args[i].length, value; __ks_0 < __ks_1; ++__ks_0) {
					value = args[i][__ks_0];
					__ks_Array.__ks_func_pushUniq_0.call(source, [value]);
				}
			}
			++i;
		}
		return source;
	};
	__ks_Array.__ks_func_pushUniq_0 = function(args) {
		if(args.length === 1) {
			if(!__ks_Array.__ks_func_contains_0.call(this, args[0])) {
				this.push(args[0]);
			}
		}
		else {
			for(let __ks_0 = 0, __ks_1 = args.length, item; __ks_0 < __ks_1; ++__ks_0) {
				item = args[__ks_0];
				if(!__ks_Array.__ks_func_contains_0.call(this, item)) {
					this.push(item);
				}
			}
		}
		return this;
	};
	__ks_Array.__ks_sttc_same_0 = function(a, b) {
		if(a.length !== b.length) {
			return false;
		}
		for(let i = 0, __ks_0 = a.length; i < __ks_0; ++i) {
			if(a[i] !== b[i]) {
				return false;
			}
		}
		return true;
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
	__ks_Array._im_remove = function(that, ...args) {
		return __ks_Array.__ks_func_remove_rt(that, args);
	};
	__ks_Array.__ks_func_remove_rt = function(that, args) {
		return __ks_Array.__ks_func_remove_0.call(that, Array.from(args));
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
	__ks_Array._im_pushUniq = function(that, ...args) {
		return __ks_Array.__ks_func_pushUniq_rt(that, args);
	};
	__ks_Array.__ks_func_pushUniq_rt = function(that, args) {
		return __ks_Array.__ks_func_pushUniq_0.call(that, Array.from(args));
	};
	__ks_Array._sm_same = function() {
		const t0 = KSType.isValue;
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
	__ks_Dictionary.__ks_sttc_clone_0 = function(dict) {
		if(KSType.isFunction(dict.clone)) {
			return dict.clone();
		}
		let clone = new Dictionary();
		for(const key in dict) {
			const value = dict[key];
			clone[key] = $clone.__ks_0(value);
		}
		return clone;
	};
	__ks_Dictionary.__ks_sttc_defaults_0 = function(args) {
		return __ks_Dictionary.__ks_sttc_merge_0([new Dictionary(), ...args]);
	};
	__ks_Dictionary.__ks_sttc_isEmpty_0 = function(dict) {
		for(let __ks_0 in dict) {
			const value = dict[__ks_0];
			return false;
		}
		return true;
	};
	__ks_Dictionary.__ks_sttc_key_0 = function(dict, index) {
		let i = -1;
		for(const key in dict) {
			if(++i === index) {
				return key;
			}
		}
		return null;
	};
	__ks_Dictionary.__ks_sttc_length_0 = function(dict) {
		return Dictionary.keys(dict).length;
	};
	__ks_Dictionary.__ks_sttc_merge_0 = function(args) {
		let source = new Dictionary();
		let i = 0;
		let l = args.length;
		let src = null;
		while((i < l) && !((KSType.isValue(args[i]) ? (src = args[i], true) : false) && KSType.isDictionary(src))) {
			++i;
		}
		++i;
		if(KSType.isValue(src) && KSType.isDictionary(src)) {
			source = src;
		}
		while(i < l) {
			if(KSType.isDictionary(args[i]) || KSType.isObject(args[i])) {
				for(const key in args[i]) {
					const value = args[i][key];
					$merge.merge(source, key, value);
				}
			}
			++i;
		}
		return source;
	};
	__ks_Dictionary.__ks_sttc_value_0 = function(dict, index) {
		let i = -1;
		for(let __ks_0 in dict) {
			const value = dict[__ks_0];
			if(++i === index) {
				return value;
			}
		}
		return null;
	};
	__ks_Dictionary._sm_clone = function() {
		const t0 = KSType.isDictionary;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Dictionary.__ks_sttc_clone_0(arguments[0]);
			}
		}
		if(Dictionary.clone) {
			return Dictionary.clone(...arguments);
		}
		throw KSHelper.badArgs();
	};
	__ks_Dictionary._sm_defaults = function() {
		const t0 = KSType.isValue;
		const te = (pts, idx) => KSHelper.isUsingAllArgs(arguments, pts, idx);
		let pts;
		if(KSHelper.isVarargs(arguments, 0, arguments.length, t0, pts = [0], 0) && te(pts, 1)) {
			return __ks_Dictionary.__ks_sttc_defaults_0(KSHelper.getVarargs(arguments, 0, pts[1]));
		}
		if(Dictionary.defaults) {
			return Dictionary.defaults(...arguments);
		}
		throw KSHelper.badArgs();
	};
	__ks_Dictionary._sm_isEmpty = function() {
		const t0 = KSType.isDictionary;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Dictionary.__ks_sttc_isEmpty_0(arguments[0]);
			}
		}
		if(Dictionary.isEmpty) {
			return Dictionary.isEmpty(...arguments);
		}
		throw KSHelper.badArgs();
	};
	__ks_Dictionary._sm_key = function() {
		const t0 = KSType.isDictionary;
		const t1 = KSType.isNumber;
		if(arguments.length === 2) {
			if(t0(arguments[0]) && t1(arguments[1])) {
				return __ks_Dictionary.__ks_sttc_key_0(arguments[0], arguments[1]);
			}
		}
		if(Dictionary.key) {
			return Dictionary.key(...arguments);
		}
		throw KSHelper.badArgs();
	};
	__ks_Dictionary._sm_length = function() {
		const t0 = KSType.isDictionary;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Dictionary.__ks_sttc_length_0(arguments[0]);
			}
		}
		if(Dictionary.length) {
			return Dictionary.length(...arguments);
		}
		throw KSHelper.badArgs();
	};
	__ks_Dictionary._sm_merge = function() {
		return __ks_Dictionary.__ks_sttc_merge_0(Array.from(arguments));
	};
	__ks_Dictionary._sm_value = function() {
		const t0 = KSType.isDictionary;
		const t1 = KSType.isNumber;
		if(arguments.length === 2) {
			if(t0(arguments[0]) && t1(arguments[1])) {
				return __ks_Dictionary.__ks_sttc_value_0(arguments[0], arguments[1]);
			}
		}
		if(Dictionary.value) {
			return Dictionary.value(...arguments);
		}
		throw KSHelper.badArgs();
	};
};