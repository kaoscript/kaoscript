var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let a = Helper.newArrayRange(1, 5, 1, true, true);
	let b = Helper.newArrayRange(1, 5, 1, true, false);
	let c = Helper.newArrayRange(1, 5, 1, false, true);
	let d = Helper.newArrayRange(1, 5, 1, false, false);
	let e = Helper.newArrayRange(1, 6, 2, true, true);
	let f = Helper.newArrayRange(1, 6, 2, false, false);
	let g = Helper.newArrayRange(5, 1, 1, true, true);
	let h = Helper.newArrayRange(5, 1, 2, true, true);
	let i = Helper.newArrayRange(1, 2, 0.3, true, true);
};