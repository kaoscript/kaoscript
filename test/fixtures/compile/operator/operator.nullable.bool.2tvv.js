const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	if(Type.isValue(foo) ? foo.bar === true : false) {
	}
};