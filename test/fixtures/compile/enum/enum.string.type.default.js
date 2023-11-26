const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const CardSuit = Helper.enum(String, 0, "Clubs", "clubs", "Diamonds", "diamonds", "Hearts", "hearts", "Spades", "spades");
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0(CardSuit.Hearts.value);
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(x, y) {
		return x + y;
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, CardSuit);
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return quxbaz.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};