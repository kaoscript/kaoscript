const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isValues: value => Type.isDexObject(value, 1, value => Type.isNumber(value) || Type.isString(value))
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		const copy = (() => {
			const o = new OBJ();
			Helper.concatObject(o, values);
			return o;
		})();
		quxbaz.__ks_0(copy);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType.isValues;
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
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = __ksType.isValues;
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};