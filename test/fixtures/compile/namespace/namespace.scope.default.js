const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Float = Helper.namespace(function() {
		const PI = 3.14;
		function toFloat() {
			return toFloat.__ks_rt(this, arguments);
		};
		toFloat.__ks_0 = function(value) {
			return PI * parseFloat(value);
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
			return Helper.assertString(value.toString(), 0);
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
			PI,
			toFloat,
			toString
		};
	});
	console.log(Float.PI);
	console.log(Float.toFloat.__ks_0("3.14"));
	console.log(Float.toString.__ks_0(3.14));
};