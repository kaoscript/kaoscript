const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(writer, w, q, h) {
		if(writer === void 0) {
			writer = null;
		}
		let __ks_0;
		quxbaz.__ks_0(Type.isValue(writer) && (__ks_0 = writer.code(" "), true) ? w === true ? Type.isValue(__ks_0) ? __ks_0.code("*") : null : __ks_0 : null);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 4) {
			if(t0(args[1]) && t0(args[2]) && t0(args[3])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2], args[3]);
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(x) {
		if(x === void 0) {
			x = null;
		}
	};
	quxbaz.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return quxbaz.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};