var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let CardSuit = Helper.enum(String, {
		Clubs: "clb",
		Diamonds: "dmd",
		Hearts: "hrt",
		Spades: "spd"
	});
	let card = CardSuit.Clubs;
	console.log(card);
};