const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(args) {
		let i;
		let __ks_0, __ks_1, __ks_2, __ks_3;
		[__ks_0, __ks_1, __ks_2, __ks_3] = Helper.assertLoopBounds(0, "", 0, "", args.length, Infinity, "", 1);
		for(let __ks_4 = __ks_0; __ks_4 < __ks_1; __ks_4 += __ks_2) {
			i = __ks_3(__ks_4);
			console.log(args[i]);
		}
		let j = 42;
		[__ks_0, __ks_1, __ks_2, __ks_3] = Helper.assertLoopBounds(0, "", 0, "", args.length, Infinity, "", 1);
		for(let __ks_5 = __ks_0; __ks_5 < __ks_1; __ks_5 += __ks_2) {
			j = __ks_3(__ks_5);
			console.log(args[j]);
		}
		[__ks_0, __ks_1, __ks_2, __ks_3] = Helper.assertLoopBounds(0, "", 0, "", args.length, Infinity, "", 1);
		for(let __ks_6 = __ks_0; __ks_6 < __ks_1; __ks_6 += __ks_2) {
			j = __ks_3(__ks_6);
			console.log(args[j]);
		}
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return foo.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
};