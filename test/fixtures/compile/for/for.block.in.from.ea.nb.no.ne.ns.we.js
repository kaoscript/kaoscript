const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(heroes) {
		if(0 < heroes.length) {
			for(let index = 0, __ks_0 = heroes.length, hero; index < __ks_0; ++index) {
				hero = heroes[index];
				console.log("The hero at index %d is %s", index, hero);
			}
		}
		else {
			console.log("no heroes");
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