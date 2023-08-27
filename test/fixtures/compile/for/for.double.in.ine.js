const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(suits, ranks) {
		for(let __ks_1 = 0, __ks_0 = suits.length, suit; __ks_1 < __ks_0; ++__ks_1) {
			suit = suits[__ks_1];
			for(let __ks_3 = 0, __ks_2 = ranks.length, rank; __ks_3 < __ks_2; ++__ks_3) {
				rank = ranks[__ks_3];
				console.log(suit + "-" + rank);
			}
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, Type.isString);
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};