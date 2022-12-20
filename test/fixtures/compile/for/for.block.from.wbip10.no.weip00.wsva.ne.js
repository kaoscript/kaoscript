const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let y = -2;
	Helper.assertNumber("y", y, 1);
	for(let x = 10; x >= 0; x += y) {
		console.log(x);
	}
};