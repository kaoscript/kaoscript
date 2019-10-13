var {Dictionary, Helper: KSHelper, Type: KSType} = require("@kaoscript/runtime");
module.exports = function() {
	function $clone(value = null) {
		if(value === null) {
			return null;
		}
		else if(KSType.isArray(value)) {
			return __ks_Array._im_clone(value);
		}
		else if(KSType.isDictionary(value)) {
			return __ks_Dictionary._cm_clone(value);
		}
		else {
			return value;
		}
	}
	const $merge = (() => {
		const d = new Dictionary();
		d.merge = function(source, key, value) {
			if(arguments.length < 3) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
			}
			if(source === void 0 || source === null) {
				throw new TypeError("'source' is not nullable");
			}
			if(key === void 0 || key === null) {
				throw new TypeError("'key' is not nullable");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			if(KSType.isArray(value)) {
				source[key] = __ks_Array._im_clone(value);
			}
			else if(!KSType.isPrimitive(value)) {
				if(KSType.isDictionary(source[key]) || KSType.isObject(source[key])) {
					$merge.object(source[key], value);
				}
				else {
					source[key] = $clone(value);
				}
			}
			else {
				source[key] = value;
			}
			return source;
		};
		d.object = function(source, current) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(source === void 0 || source === null) {
				throw new TypeError("'source' is not nullable");
			}
			if(current === void 0 || current === null) {
				throw new TypeError("'current' is not nullable");
			}
			for(const key in current) {
				if(KSType.isValue(source[key])) {
					$merge.merge(source, key, current[key]);
				}
				else {
					source[key] = current[key];
				}
			}
		};
		return d;
	})();
	var __ks_Array = {};
	var __ks_Dictionary = {};
	__ks_Array.__ks_func_append_0 = function(...args) {
		let l, i, j, arg;
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
	__ks_Array.__ks_func_appendUniq_0 = function(...args) {
		if(args.length === 1) {
			__ks_Array._im_pushUniq.apply(null, [this].concat(args[0]));
		}
		else {
			for(let i = 0, __ks_0 = args.length; i < __ks_0; ++i) {
				__ks_Array._im_pushUniq.apply(null, [this].concat(args[i]));
			}
		}
		return this;
	};
	__ks_Array.__ks_func_any_0 = function(fn) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(fn === void 0 || fn === null) {
			throw new TypeError("'fn' is not nullable");
		}
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
			clone[--i] = $clone(this[i]);
		}
		return clone;
	};
	__ks_Array.__ks_func_contains_0 = function(item, from) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(item === void 0 || item === null) {
			throw new TypeError("'item' is not nullable");
		}
		if(from === void 0 || from === null) {
			from = 0;
		}
		return this.indexOf(item, from) !== -1;
	};
	__ks_Array.__ks_func_last_0 = function(index) {
		if(index === void 0 || index === null) {
			index = 1;
		}
		else if(!KSType.isNumber(index)) {
			throw new TypeError("'index' is not of type 'Number'");
		}
		return (this.length !== 0) ? this[this.length - index] : null;
	};
	__ks_Array.__ks_func_remove_0 = function(...items) {
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
	__ks_Array.__ks_sttc_merge_0 = function(...args) {
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
					__ks_Array._im_pushUniq(source, value);
				}
			}
			++i;
		}
		return source;
	};
	__ks_Array.__ks_func_pushUniq_0 = function(...args) {
		if(args.length === 1) {
			if(!__ks_Array._im_contains(this, args[0])) {
				this.push(args[0]);
			}
		}
		else {
			for(let __ks_0 = 0, __ks_1 = args.length, item; __ks_0 < __ks_1; ++__ks_0) {
				item = args[__ks_0];
				if(!__ks_Array._im_contains(this, item)) {
					this.push(item);
				}
			}
		}
		return this;
	};
	__ks_Array.__ks_sttc_same_0 = function(a, b) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(a === void 0 || a === null) {
			throw new TypeError("'a' is not nullable");
		}
		if(b === void 0 || b === null) {
			throw new TypeError("'b' is not nullable");
		}
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
	__ks_Array._im_append = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		return __ks_Array.__ks_func_append_0.apply(that, args);
	};
	__ks_Array._im_appendUniq = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		return __ks_Array.__ks_func_appendUniq_0.apply(that, args);
	};
	__ks_Array._im_any = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 1) {
			return __ks_Array.__ks_func_any_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Array._im_clear = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Array.__ks_func_clear_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Array._im_clone = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Array.__ks_func_clone_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Array._im_contains = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length >= 1 && args.length <= 2) {
			return __ks_Array.__ks_func_contains_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Array._im_last = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length >= 0 && args.length <= 1) {
			return __ks_Array.__ks_func_last_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Array._im_remove = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		return __ks_Array.__ks_func_remove_0.apply(that, args);
	};
	__ks_Array._cm_merge = function() {
		var args = Array.prototype.slice.call(arguments);
		return __ks_Array.__ks_sttc_merge_0.apply(null, args);
	};
	__ks_Array._im_pushUniq = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		return __ks_Array.__ks_func_pushUniq_0.apply(that, args);
	};
	__ks_Array._cm_same = function() {
		var args = Array.prototype.slice.call(arguments);
		if(args.length === 2) {
			return __ks_Array.__ks_sttc_same_0.apply(null, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Dictionary.__ks_sttc_clone_0 = function(dict) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(dict === void 0 || dict === null) {
			throw new TypeError("'dict' is not nullable");
		}
		if(KSType.isFunction(dict.clone)) {
			return dict.clone();
		}
		let clone = new Dictionary();
		for(const key in dict) {
			const value = dict[key];
			clone[key] = $clone(value);
		}
		return clone;
	};
	__ks_Dictionary.__ks_sttc_defaults_0 = function(...args) {
		return __ks_Dictionary._cm_merge(new Dictionary(), ...args);
	};
	__ks_Dictionary.__ks_sttc_isEmpty_0 = function(item) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(item === void 0 || item === null) {
			throw new TypeError("'item' is not nullable");
		}
		return KSHelper.isEmptyDictionary(item);
	};
	__ks_Dictionary.__ks_sttc_merge_0 = function(...args) {
		let source = new Dictionary();
		let i = 0;
		let l = args.length;
		while((i < l) && !((KSType.isValue(args[i]) ? (source = args[i], true) : false) && KSType.isDictionary(source))) {
			++i;
		}
		++i;
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
	__ks_Dictionary._cm_clone = function() {
		var args = Array.prototype.slice.call(arguments);
		if(args.length === 1) {
			return __ks_Dictionary.__ks_sttc_clone_0.apply(null, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Dictionary._cm_defaults = function() {
		var args = Array.prototype.slice.call(arguments);
		return __ks_Dictionary.__ks_sttc_defaults_0.apply(null, args);
	};
	__ks_Dictionary._cm_isEmpty = function() {
		var args = Array.prototype.slice.call(arguments);
		if(args.length === 1) {
			return __ks_Dictionary.__ks_sttc_isEmpty_0.apply(null, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Dictionary._cm_merge = function() {
		var args = Array.prototype.slice.call(arguments);
		return __ks_Dictionary.__ks_sttc_merge_0.apply(null, args);
	};
};