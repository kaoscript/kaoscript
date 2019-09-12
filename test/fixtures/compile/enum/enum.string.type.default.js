var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let CardSuit = {
		Clubs: "clubs",
		Diamonds: "diamonds",
		Hearts: "hearts",
		Spades: "spades"
	};
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
	}
	foobar(CardSuit.Hearts);
	function quxbaz(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.is(x, CardSuit)) {
			throw new TypeError("'x' is not of type 'CardSuit'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.is(y, CardSuit)) {
			throw new TypeError("'y' is not of type 'CardSuit'");
		}
		return x + y;
	}
};