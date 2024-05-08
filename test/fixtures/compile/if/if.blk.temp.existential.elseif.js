const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function parse() {
		return parse.__ks_rt(this, arguments);
	};
	parse.__ks_0 = function(color) {
		if(Type.isString(color)) {
			let match;
			let __ks_0;
			if(Type.isValue(__ks_0 = /^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/.exec(color)) ? (match = __ks_0, true) : false) {
				console.log(match);
			}
			else if(Type.isValue(__ks_0 = /^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/.exec(color)) ? (match = __ks_0, true) : false) {
				console.log(match);
			}
			else if(Type.isValue(__ks_0 = /^#?([0-9a-f])([0-9a-f])([0-9a-f])([0-9a-f])$/.exec(color)) ? (match = __ks_0, true) : false) {
				console.log(match);
			}
			else if(Type.isValue(__ks_0 = /^#?([0-9a-f])([0-9a-f])([0-9a-f])$/.exec(color)) ? (match = __ks_0, true) : false) {
				console.log(match);
			}
			else if(Type.isValue(__ks_0 = /^rgba?\((\d{1,3}),(\d{1,3}),(\d{1,3})(,([0-9.]+)(\%)?)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
				console.log(match);
			}
			else if(Type.isValue(__ks_0 = /^rgba?\(([0-9.]+\%),([0-9.]+\%),([0-9.]+\%)(,([0-9.]+)(\%)?)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
				console.log(match);
			}
			else if(Type.isValue(__ks_0 = /^rgba?\(#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2}),([0-9.]+)(\%)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
				console.log(match);
			}
			else if(Type.isValue(__ks_0 = /^rgba\(#?([0-9a-f])([0-9a-f])([0-9a-f]),([0-9.]+)(\%)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
				console.log(match);
			}
			else if(Type.isValue(__ks_0 = /^(\d{1,3}),(\d{1,3}),(\d{1,3})(?:,([0-9.]+))?$/.exec(color)) ? (match = __ks_0, true) : false) {
				console.log(match);
			}
		}
	};
	parse.__ks_rt = function(that, args) {
		const t0 = value => Type.isString(value) || Type.isObject(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return parse.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};