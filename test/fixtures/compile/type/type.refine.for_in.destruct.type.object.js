const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isCoord: value => Type.isDexObject(value, 1, 0, {x: Type.isNumber, y: Type.isNumber, z: Type.isNumber})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		let r = 0;
		for(let __ks_1 = 0, __ks_0 = values.length, x, y, z; __ks_1 < __ks_0; ++__ks_1) {
			({x, y, z} = values[__ks_1]);
			r += Number.parseInt((x * y) / z);
		}
		return r;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, __ksType.isCoord);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};