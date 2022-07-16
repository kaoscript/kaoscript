const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let b;
	if(Type.isValue((b = a.b).c)) {
		console.log(b);
	}
};