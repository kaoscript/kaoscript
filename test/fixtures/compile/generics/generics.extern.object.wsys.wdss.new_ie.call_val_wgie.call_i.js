const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Object = {};
	const CardSuit = Helper.enum(Number, 0, "Clubs", 0, "Diamonds", 1, "Hearts", 2, "Spades", 3);
	function print() {
		return print.__ks_rt(this, arguments);
	};
	print.__ks_0 = function(values) {
	};
	print.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, Type.isNumber);
		if(args.length === 1) {
			if(t0(args[0])) {
				return print.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const $precedence = (() => {
		const o = new OBJ();
		o[CardSuit.Clubs] = 0;
		o[CardSuit.Diamonds] = 0;
		return o;
	})();
	print.__ks_0(Object.values($precedence));
};