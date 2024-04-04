const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Float = Helper.namespace(function() {
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
			toString
		};
	});
	console.log(Float.toString.__ks_0(3.14));
};