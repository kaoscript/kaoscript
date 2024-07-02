require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(Weekday, CardSuit, Color, Card, foobar) {
	var __ks_0_valuable = Type.isValue(Weekday);
	var __ks_1_valuable = Type.isValue(CardSuit);
	var __ks_2_valuable = Type.isValue(Color);
	var __ks_3_valuable = Type.isValue(Card);
	var __ks_4_valuable = Type.isValue(foobar);
	if(!__ks_0_valuable && !__ks_1_valuable && !__ks_2_valuable && !__ks_3_valuable && !__ks_4_valuable) {
		var {Weekday, CardSuit, Color, Card, foobar} = require("./.require.alt.roi.alias.e3e.genesis.ks.j5k8r9.ksb")();
	}
	else if(!(__ks_0_valuable || __ks_1_valuable || __ks_2_valuable || __ks_3_valuable || __ks_4_valuable)) {
		throw Helper.badRequirements();
	}
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(card) {
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Card.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		Weekday,
		CardSuit,
		Color,
		Card,
		foobar,
		quxbaz
	};
};