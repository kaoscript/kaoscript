const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Weekday = Helper.enum(Number, 0, "MONDAY", 1, "TUESDAY", 2, "WEDNESDAY", 3, "THURSDAY", 4, "FRIDAY", 5, "SATURDAY", 6, "SUNDAY", 7);
	const CardSuit = Helper.enum(Number, 0, "Clubs", 1, "Diamonds", 2, "Hearts", 3, "Spades", 4);
	const Color = Helper.enum(Number, 0, "Red", 0, "Green", 1, "Blue", 2);
	const Card = Helper.alias((value, cast) => Type.isDexObject(value, 1, 0, {color: () => Helper.castEnum(value, "color", Color, cast), suit: () => Helper.castEnum(value, "suit", CardSuit, cast), value: Type.isNumber}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(card) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Card.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		Weekday,
		CardSuit,
		Color,
		Card,
		foobar
	};
};