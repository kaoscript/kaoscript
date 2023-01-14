extern console: {
	log(...args)
}

extern {
	class UIImageView
	class UILabel
	class UITableView
	class UIView
}

var mut view: UIView

match view {
	is UIImageView								=> console.log("It's an image view")
	is UILabel		with label as UILabel		=> console.log("It's a label")
	is UITableView	with tblv as UITableView	{
		var dyn sectionCount = tblv.numberOfSections()
		console.log(`It's a table view with \(sectionCount) sections`)
	}
	else										=> console.log("It's some other UIView or subclass")
}