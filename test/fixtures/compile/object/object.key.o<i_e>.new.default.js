const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const CardSuit = Helper.enum(Number, "Clubs", 0, "Diamonds", 1, "Hearts", 2, "Spades", 3);
	const $precedence = (() => {
		const o = new OBJ();
		o[CardSuit.Clubs] = 0;
		o[CardSuit.Diamonds] = 0;
		return o;
	})();
};