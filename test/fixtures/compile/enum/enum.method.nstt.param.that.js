const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const CardSuit = Helper.enum(Number, 0, "Clubs", 0, "Diamonds", 1, "Hearts", 2, "Spades", 3);
	CardSuit.__ks_func_foobar_0 = function(__ks_0, that) {
		const x = CardSuit.__ks_func_quxbaz_0(__ks_0);
		return that;
	};
	CardSuit.__ks_func_foobar = function(that, ...args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return CardSuit.__ks_func_foobar_0(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	CardSuit.__ks_func_quxbaz_0 = function(that) {
		return 0;
	};
	CardSuit.__ks_func_quxbaz = function(that, ...args) {
		if(args.length === 0) {
			return CardSuit.__ks_func_quxbaz_0(that);
		}
		throw Helper.badArgs();
	};
};