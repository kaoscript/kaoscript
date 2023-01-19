const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let x = 24;
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o[x] = 42;
			return o;
		})();
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};