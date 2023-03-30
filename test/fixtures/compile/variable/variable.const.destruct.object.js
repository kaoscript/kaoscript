const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.x = 1;
			o.y = 2;
			return o;
		})();
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let  __ks_0 = foo.__ks_0();
	Helper.assertDexObject(__ks_0, 1, 0, {x: Type.isValue, y: Type.isValue});
	const {x, y} = __ks_0;
	console.log(x, y);
};