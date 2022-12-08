const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function filter() {
		return filter.__ks_rt(this, arguments);
	};
	filter.__ks_0 = function(match) {
		const result = [];
		for(let __ks_0 = 0, __ks_1 = match.length, line; __ks_0 < __ks_1; ++__ks_0) {
			line = match[__ks_0];
			if(Type.isValue(line)) {
				result.push(line);
			}
		}
		return result;
	};
	filter.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, value => Type.isString(value) || Type.isNull(value)) && Type.isObject(value, void 0, {index: Type.isNumber, input: Type.isString});
		if(args.length === 1) {
			if(t0(args[0])) {
				return filter.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const __ks_String = {};
	__ks_String.__ks_func_lines_0 = function() {
		let lines = this.match(/[^\r\n]+/g);
		if(Type.isValue(lines)) {
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