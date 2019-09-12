var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	if(Type.isValue(a) ? a.b === true : false) {
		console.log(a);
	}
};