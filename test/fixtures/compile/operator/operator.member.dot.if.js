const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	if(Type.isValue(a) ? a.b === true : false) {
		console.log(a);
	}
};