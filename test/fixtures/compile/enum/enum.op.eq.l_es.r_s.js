var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let CardSuit = Helper.enum(String, {
		Clubs: "clubs",
		Diamonds: "diamonds",
		Hearts: "hearts",
		Spades: "spades"
	});
	function foobar(card) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(card === void 0 || card === null) {
			throw new TypeError("'card' is not nullable");
		}
		else if(!Type.isEnumInstance(card, CardSuit)) {
			throw new TypeError("'card' is not of type 'CardSuit'");
		}
		if(card.value === "hearts") {
		}
	}
};