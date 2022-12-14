const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return (() => {
			const d = new OBJ();
			d.x = 1;
			d.y = 2;
			return d;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let x, y, __ks_0;
	if(Type.isValue(__ks_0 = foobar.__ks_0()) ? ({x, y} = __ks_0, true) : false) {
		console.log(Helper.toString(x));
	}
};