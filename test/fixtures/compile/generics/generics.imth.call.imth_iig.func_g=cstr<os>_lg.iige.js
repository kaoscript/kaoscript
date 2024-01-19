const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isNamed: value => Type.isDexObject(value, 1, 0, {name: Type.isString})
	};
	var __ks_Array = {};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		values.splice(0, 4, values[0]);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, () => true);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};