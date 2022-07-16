const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Float = Helper.namespace(function() {
		function toFloat() {
			return toFloat.__ks_rt(this, arguments);
		};
		toFloat.__ks_0 = function(value) {
			return parseFloat(value);
		};
		toFloat.__ks_rt = function(that, args) {
			const t0 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return toFloat.__ks_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		};
		function toString() {
			return toString.__ks_rt(this, arguments);
		};
		toString.__ks_0 = function(value) {
			return value.toString();
		};
		toString.__ks_rt = function(that, args) {
			const t0 = Type.isNumber;
			if(args.length === 1) {
				if(t0(args[0])) {
					return toString.__ks_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		};
		return {
			toFloat,
			toString
		};
	});
	return {
		Float
	};
};