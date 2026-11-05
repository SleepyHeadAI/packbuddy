package com.sleepyhead.packbuddy

open class PackBuddyCurrencyWidgetProvider : PackBuddyWidgetProvider() {
    override val defaultLayoutSize: WidgetLayoutSize = WidgetLayoutSize.SMALL
    override val inherentMode: String = "currency_converter"
}

class PackBuddyCurrencyMediumWidgetProvider : PackBuddyWidgetProvider() {
    override val defaultLayoutSize: WidgetLayoutSize = WidgetLayoutSize.MEDIUM
    override val inherentMode: String = "currency_converter"
}

class PackBuddyCurrencyLargeWidgetProvider : PackBuddyWidgetProvider() {
    override val defaultLayoutSize: WidgetLayoutSize = WidgetLayoutSize.LARGE
    override val inherentMode: String = "currency_converter"
}

