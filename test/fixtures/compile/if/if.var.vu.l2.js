const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const o = new OBJ();
		o.message = "hello";
		return o;
	})();
	if(test === true) {
		let message;
		if((message = foo.message).length > 0) {
			console.log(message);
		}
	}
};