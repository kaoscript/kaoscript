const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(Writer) {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(writer, w, q, h) {
		let __ks_0;
		(__ks_0 = writer.__ks_func_code_0("|>"), h === true ? __ks_0.__ks_func_code_0("#") : __ks_0).__ks_func_code_0(" ");
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Writer);
		const t1 = Type.isValue;
		if(args.length === 4) {
			if(t0(args[0]) && t1(args[1]) && t1(args[2]) && t1(args[3])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2], args[3]);
			}
		}
		throw Helper.badArgs();
	};
};