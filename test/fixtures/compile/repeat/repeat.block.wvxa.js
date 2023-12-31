const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(n) {
		let __ks_0, __ks_1;
		__ks_0 = -1;
		__ks_1 = n();
		Helper.assertLoopBoundsEdge("n()", __ks_1, 3);
		while(++__ks_0 < __ks_1) {
			console.log("hello!");
		}
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