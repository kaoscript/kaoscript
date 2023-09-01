const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(quxbaz) {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(test) {
		let __ks_0;
		__ks_0 = quxbaz();
		__ks_0.foobar();
		return __ks_0;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};