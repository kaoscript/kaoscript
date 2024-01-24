extern {
	class UIView
	class UIImageView extends UIView
	class UILabel extends UIView
	class UITableView extends UIView
}

func foobar(view: UIView) {
	match view {
		is UIImageView					=> echo(`It's an image view`)
		is UILabel		with var label	=> echo(`It's a label`)
		is UITableView	with var tblv	{
			var sectionCount = tblv.numberOfSections()

			echo(`It's a table view with \(sectionCount) sections`)
		}
		else							=> echo(`It's some other UIView or subclass`)
	}
}