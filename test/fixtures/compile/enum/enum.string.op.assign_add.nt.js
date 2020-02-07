var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let CardSuit = Helper.enum(String, {
		Clubs: "clubs",
		Diamonds: "diamonds",
		Hearts: "hearts",
		Spades: "spades"
	});
	function foobar() {
		let card = CardSuit.Clubs;
		card += "clubs";
		return card;
	}
};