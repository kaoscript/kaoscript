const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let tt = foo();
	if(!Type.isValue(tt.uu)) {
		tt.uu = bar;
	}
};