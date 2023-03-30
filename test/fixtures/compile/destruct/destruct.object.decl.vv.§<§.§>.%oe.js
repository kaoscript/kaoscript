const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		Helper.assertDexObject(values, 0, 0, {bar: value => Type.isDexObject(value, 1, 0, {n1: Type.isValue, n2: Type.isValue})});
		const {bar: {n1, n2}} = values;
		console.log(Helper.concatString(n1, ", ", n2));
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isObject;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};