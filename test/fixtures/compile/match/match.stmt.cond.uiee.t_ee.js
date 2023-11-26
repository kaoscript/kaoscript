const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.enum(Number, "Foobar", 0);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return "";
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let __ks_0 = foobar.__ks_0();
	if(Type.isString(__ks_0)) {
	}
	else if(__ks_0 === Foobar.Foobar) {
	}
};