module.exports = function(Node) {
	const right = new Node("e");
	let __ks_0, __ks_1;
	__ks_1 = new Node("b");
	__ks_1.left = new Node("c");
	__ks_0 = new Node("a");
	__ks_0.left = __ks_1;
	__ks_0.right = new Node("d");
	const root = new Node("root");
	root.left = __ks_0;
	root.right = right;
};