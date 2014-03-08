--
--  AppDelegate.applescript
--  Auto VPN
--
--  Created by Grimmer Kang on 2014/3/8.
--  Copyright (c) 2014年 Grimmer Kang. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
	
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened 
	end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
end script