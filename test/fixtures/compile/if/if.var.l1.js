var {Dictionary, Operator} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const d = new Dictionary();
		d.message = "hello";
		return d;
	})();
	let message;
	if(Operator.gt((message = foo.message).length, 0)) {
		console.log(message);
	}
};