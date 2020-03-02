require|import './import.xample1.core.ks'

impl Date {
	overwrite getTime(): Number => 0
	overwrite getEpochTime(): Number => this.getTime()
}

export Date