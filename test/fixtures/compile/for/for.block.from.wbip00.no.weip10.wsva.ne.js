const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let y = 2;
	Helper.assertNumber("y", y, 2);
	for(let x = 0; x <= 10; x += y) {
		console.log(x);
	}
};