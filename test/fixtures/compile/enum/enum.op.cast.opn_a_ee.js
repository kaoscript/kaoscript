const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const CardSuit = Helper.enum(Number, 0, "Clubs", 0, "Diamonds", 1, "Hearts", 2, "Spades", 3);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(data) {
		return CardSuit(data);
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