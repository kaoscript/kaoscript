var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	if(Type.isValue(foo) ? foo.bar === true : false) {
	}
};