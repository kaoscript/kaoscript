const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const CardSuit = Helper.enum(Number, {
		Clubs: 1,
		Diamonds: 2,
		Hearts: 3,
		Spades: 4
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(card) {
		let __ks_0;
		if(!((__ks_0 = Helper.valueOf(card.suit)) === CardSuit.Diamonds.value || __ks_0 === CardSuit.Hearts.value || __ks_0 === CardSuit.Spades.value)) {
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