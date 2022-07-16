const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let tt = Type.isValue(foo) && Type.isValue(foo[bar]);
};