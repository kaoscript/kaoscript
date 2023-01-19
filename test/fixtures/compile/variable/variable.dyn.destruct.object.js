const {Helper, OBJ} = require("@kaoscript/runtime");
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
	let {x, y} = foo.__ks_0();
	console.log(x, y);
};