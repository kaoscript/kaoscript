const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let tt = (Type.isValue(foo) ? foo.foo === true : false) || (bar.bar === true);
};