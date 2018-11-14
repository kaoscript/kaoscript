require("kaoscript/register");
module.exports = function() {
	var Message = require("../class/class.constructor.rest.ks")().Message;
	const m0 = new Message();
	const m1 = new Message("foo");
	const m2 = new Message("foo", "bar");
};