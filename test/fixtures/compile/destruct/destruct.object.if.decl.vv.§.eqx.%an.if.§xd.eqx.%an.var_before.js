const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return null;
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let x;
	let __ks_x_1, __ks_0;
	if(((Type.isDexObject(__ks_0 = foobar.__ks_0(), 1, 0, {x: Type.isValue})) ? (({x: __ks_x_1} = __ks_0), true) : false)) {
	}
	if((Type.isDexObject(__ks_0 = foobar.__ks_0(), 1, 0, {x: Type.isValue})) ? (({x} = __ks_0), true) : false) {
	}
};