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
		(h === true ? Type.isValue(writer) ? (__ks_0 = writer.code("#"), true) : false : (__ks_0 = writer, true)) ? q(writer) === true ? __ks_0.code(" ").code("?") : null : null;
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