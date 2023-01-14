const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(heroes, inc) {
		let __ks_0, __ks_1, __ks_2, __ks_3;
		[__ks_0, __ks_1, __ks_2, __ks_3] = Helper.assertLoop(0, "", 0, "", Infinity, heroes.length - 1, "inc", inc);
		for(let __ks_4 = __ks_0, index, hero; __ks_4 <= __ks_1; __ks_4 += __ks_2) {
			index = __ks_3(__ks_4);
			hero = heroes[index];
			console.log("The hero at index %d is %s", index, hero);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};