const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(writer, w, q, h) {
		if(writer === void 0) {
			writer = null;
		}
		let __ks_0, __ks_1, __ks_2;
		((w(writer) === true ? Type.isValue(__ks_1 = writer.code("")) ? (__ks_0 = __ks_1.code("*"), true) : false : (__ks_0 = writer, true))) && (q(writer) === true ? Type.isValue(__ks_2 = __ks_0.code("")) ? (__ks_0 = __ks_2.code("?"), true) : false : true) ? h === true ? Type.isValue(__ks_0) ? __ks_0.code("#") : null : null : null;
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
};