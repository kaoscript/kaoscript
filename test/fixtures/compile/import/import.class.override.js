require("kaoscript/register");
module.exports = function() {
	var {Shape, Rectangle} = require("../class/class.override.ndef.wk.default.ks")();
	let r = new Rectangle("black");
	console.log(r.draw());
};