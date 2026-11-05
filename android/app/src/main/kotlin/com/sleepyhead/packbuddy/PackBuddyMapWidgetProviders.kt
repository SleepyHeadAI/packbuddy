package com.sleepyhead.packbuddy

open class PackBuddyMapWidgetProvider : PackBuddyWidgetProvider() {
    override val defaultLayoutSize: WidgetLayoutSize = WidgetLayoutSize.SMALL
    override val inherentMode: String = "world_map"
}

class PackBuddyMapMediumWidgetProvider : PackBuddyWidgetProvider() {
    override val defaultLayoutSize: WidgetLayoutSize = WidgetLayoutSize.MEDIUM
    override val inherentMode: String = "world_map"
}

class PackBuddyMapLargeWidgetProvider : PackBuddyWidgetProvider() {
    override val defaultLayoutSize: WidgetLayoutSize = WidgetLayoutSize.LARGE
    override val inherentMode: String = "world_map"
}

