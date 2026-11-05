package com.sleepyhead.packbuddy

open class PackBuddyExpenseWidgetProvider : PackBuddyWidgetProvider() {
    override val defaultLayoutSize: WidgetLayoutSize = WidgetLayoutSize.SMALL
    override val inherentMode: String = "quick_expense"
}

class PackBuddyExpenseMediumWidgetProvider : PackBuddyWidgetProvider() {
    override val defaultLayoutSize: WidgetLayoutSize = WidgetLayoutSize.MEDIUM
    override val inherentMode: String = "quick_expense"
}

class PackBuddyExpenseLargeWidgetProvider : PackBuddyWidgetProvider() {
    override val defaultLayoutSize: WidgetLayoutSize = WidgetLayoutSize.LARGE
    override val inherentMode: String = "quick_expense"
}

