const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isCard: (value, filter) => Type.isDexObject(value, 1, 0, {suit: variant => {
			if(!Type.isEnumInstance(variant, CardSuit)) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant === CardSuit.Clubs) {
				return Type.isDexObject(value, 0, 0, {names: value => Type.isArray(value, Type.isString)});
			}
			return true;
		}, rank: Type.isNumber})
	};
	const CardSuit = Helper.enum(Number, {
		Clubs: 1,
		Diamonds: 2,
		Hearts: 3,
		Spades: 4
	});
	CardSuit.__ks_eq_Blacks = value => value === CardSuit.Clubs || value === CardSuit.Spades;
	CardSuit.__ks_eq_Reds = value => value === CardSuit.Diamonds || value === CardSuit.Hearts;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(card) {
		if(CardSuit.__ks_eq_Blacks(card.suit)) {
			for(let __ks_1 = 0, __ks_0 = card.names.length, name; __ks_1 < __ks_0; ++__ks_1) {
				name = card.names[__ks_1];
				console.log(name);
			}
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType.isCard;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};