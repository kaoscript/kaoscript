const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function print() {
		return print.__ks_rt(this, arguments);
	};
	print.__ks_0 = function(heroes) {
		let hero;
		for(let __ks_0 = 0, __ks_1 = heroes.length; __ks_0 < __ks_1; ++__ks_0) {
			hero = heroes[__ks_0];
			console.log(hero.name);
		}
	};
	print.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return print.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};