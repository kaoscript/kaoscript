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
		Type.isValue(writer) && (__ks_0 = writer.code(" "), true) ? (w === true ? Type.isValue(__ks_0) ? (__ks_0 = __ks_0.code("*"), true) : false : true) : false && Type.isValue(__ks_0) ? __ks_0.code(" ") : null;
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