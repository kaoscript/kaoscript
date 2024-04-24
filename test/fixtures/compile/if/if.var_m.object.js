const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.x = 1;
			o.y = 2;
			return o;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let x, y, __ks_0;
	if(((Type.isDexObject(__ks_0 = foobar.__ks_0(), 1, 0, {x: Type.isValue, y: Type.isValue})) ? (({x, y} = __ks_0), true) : false)) {
		console.log(Helper.toString(x));
	}
};