const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isRegExpExecArray: value => Type.isArray(value, value => Type.isString(value) || Type.isNull(value)) && Type.isDexObject(value, 1, 0, {index: Type.isNumber, input: Type.isString})
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
			return Helper.assertArray(this.replace(/\r\n/g, "\n").replace(/\r/g, "\n").split("\n"), 0);
		}
		else {
			let __ks_0;
			return Helper.assertArray(Type.isValue(__ks_0 = this.match(/[^\r\n]+/g)) ? __ks_0 : [], 0);
		}
	};
	__ks_String.__ks_func_lower_0 = function() {
		return Helper.assertString(this.toLowerCase(), 0);
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
		if(that.lines) {
			return that.lines(...args);
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
		if(that.lower) {
			return that.lower(...args);
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
		if(that.toFloat) {
			return that.toFloat(...args);
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
		if(that.toInt) {
			return that.toInt(...args);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_RegExp: {},
		__ks_String,
		__ksType: [__ksType.isRegExpExecArray]
	};
};