const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isNamed: value => Type.isDexObject(value, 1, 0, {name: Type.isString})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		return values[0];
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, __ksType.isNamed);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(values) {
		const value = foobar.__ks_0(values);
		return value;
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, __ksType.isNamed);
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};