module.exports = function() {
	let Foobar = (function() {
		return {};
	})();
	require("./import.require.namespace.source.ks")(Foobar);
};