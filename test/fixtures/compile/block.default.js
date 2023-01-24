const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	top: {
		console.log("entering block");
		for(let i = 1; i <= 10; ++i) {
			for(let j = 1; j <= 10; ++j) {
				console.log(Helper.concatString("looping ", i, ".", j));
				if(i === 5) {
					break top;
				}
			}
		}
		console.log("still in block");
	}
};