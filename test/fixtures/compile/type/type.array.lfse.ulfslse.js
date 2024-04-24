const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isRegExpExecArray: value => Type.isArray(value, value => Type.isString(value) || Type.isNull(value)) && Type.isDexObject(value, 1, 0, {index: Type.isNumber, input: Type.isString})
	};
	function filter() {
		return filter.__ks_rt(this, arguments);
	};
	filter.__ks_0 = function(match) {
		const result = [];
		for(let __ks_1 = 0, __ks_0 = match.length, line; __ks_1 < __ks_0; ++__ks_1) {
			line = match[__ks_1];
			if(Type.isValue(line)) {
				result.push(line);
			}
		}
		return result;
	};
	filter.__ks_rt = function(that, args) {
		const t0 = __ksType.isRegExpExecArray;
		if(args.length === 1) {
			if(t0(args[0])) {
				return filter.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const __ks_String = {};
	__ks_String.__ks_func_lines_0 = function() {
		let lines, __ks_0;
		if((Type.isValue(__ks_0 = this.match(/[^\r\n]+/g)) ? (lines = __ks_0, true) : false)) {
			return filter.__ks_0(lines);
		}
		return [];
	};
	__ks_String._im_lines = function(that, ...args) {
		return __ks_String.__ks_func_lines_rt(that, args);
	};
	__ks_String.__ks_func_lines_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_lines_0.call(that);
		}
		throw Helper.badArgs();
	};
};