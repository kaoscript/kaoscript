var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let Foobar = Helper.namespace(function() {
		return {};
	});
	require("./import.require.namespace.source.ks")(Foobar);
};