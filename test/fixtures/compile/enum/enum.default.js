var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let Color = Helper.enum(Number, {
		Red: 0,
		Green: 1,
		Blue: 2
	});
	let color = Color.Red;
	console.log(color);
};