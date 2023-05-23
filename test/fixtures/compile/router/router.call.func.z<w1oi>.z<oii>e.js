const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isFoobar: value => Type.isDexObject(value, 1, 0, {x: Type.isNumber, y: Type.isNumber})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		quxbaz.__ks_0(value);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isFoobar(value) && Type.isDexObject(value, 1, 0, {z: Type.isNumber});
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
	quxbaz.__ks_0 = function(value) {
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = __ksType.isFoobar;
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};