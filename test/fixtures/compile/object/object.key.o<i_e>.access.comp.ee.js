const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const CardSuit = Helper.enum(Number, {
		Clubs: 0,
		Diamonds: 1,
		Hearts: 2,
		Spades: 3
	});
	const $precedence = (() => {
		const o = new OBJ();
		o[CardSuit.Clubs] = 0;
		o[CardSuit.Diamonds] = 0;
		return o;
	})();
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(suit) {
		const precedence = $precedence[suit];
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, CardSuit);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};