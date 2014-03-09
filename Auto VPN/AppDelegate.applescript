--
--  AppDelegate.applescript
--  Auto VPN
--
--  Created by Grimmer Kang on 2014/3/8.
--  Copyright (c) 2014年 Grimmer Kang. All rights reserved.
--

script AppDelegate
	--property parent : class "NSObject"
    property parent : class "Enhancer" of current application
    
    property NSUserDefaults : class "NSUserDefaults" of current application
    
    property LoginHelper : class "LoginHelper"

    property NSStatusBar : class "NSStatusBar"
    property NSMenu : class "NSMenu"
	property NSImage : class "NSImage"
	property NSMenuItem : class "NSMenuItem"
	property NSString : class "NSString"
	property NSWorkspace : class "NSWorkspace"
	property sysStatusBar : missing value
	property statusItem : missing value
	property statusMenu : missing value
    
    property runnableMenuItem : missing value
    property startupMenuItem : missing value
    property resetinfoMenuItem : missing value
    
    property appList : {}
    property ssidSET : {}
    property myVPNService : ""
    property ifExclusemode : true
    property ifRunnable :true
    
    property appRunningList : {}
    property idleTime : 2.0
    
    on setupVPN()
        
        log "setup vpn1"
        set vpnStr to do shell script "networksetup -listnetworkserviceorder |sed -n '/Port: PPTP/{g;1!p;};h' | sed 's/.[0-9]*..//' |tr \"\n\" \";\""
        
        
        set vpnList1 to my theSplit(vpnStr, ";")
        
        if(vpnList1 as text) = ""
            log "vpn is empty"
        end if
        
        --log "setup vpn2:" & (vpnList1 as text)

        set vpnList2 to {}
        
        repeat with theItem in vpnList1
            if (theItem as text) is not equal to "" then
                set the end of vpnList2 to (theItem as text)
            end if
        end repeat
        
        set defaultNumber to 1
        
        repeat with i from 1 to count of vpnList2
            set theItem to item i of vpnList2
            if (theItem as text) = myVPNService
                set defaultNumber to i
            end if
        end repeat
    
        log "setup vpn3"

        set messageBody to "Usually you need to use this VPN to access some resources, e.g. company internel network."

        if (count of vpnList2) =0 then
            set dialogresult to the text returned of (display dialog messageBody default answer myVPNService with title "VPN Setup")
            if dialogresult is not equal to "" then
                set myVPNService to dialogresult
            end if
        else
            set chooseresult to (choose from list vpnList2 with prompt messageBody default items (text item defaultNumber of vpnList2) with title "VPN Selection" OK button name "OK")
            
            if (chooseresult as text) is "false"
            --cancel
            else
                set myVPNService to (chooseresult as text)
            end if
        end if

        --repeat with theItem in ssidSET
        --    display dialog "ssid:" & theItem
        --end repeat
        
        --set myVPNService to the text returned of (display dialog "What is your vpn's name?" default answer "" buttons {"OK"}

    end setupVPN
    
    on setupSSID()

        set messageBody to ""
        if ifExclusemode = true then
    
            set messageBody to "What are company internal SSIDs? e.g. office-ap. Use command " & («data utxt2318» as Unicode text) & " to multi-select."


            --set ssidSET to my theSplit(ssidSTR, ";")
        else
            set messageBody to "What are your SSIDs? e.g. office-ap. Use command "& («data utxt2318» as Unicode text) & " to multi-select."
            --set ssidSTR to the text returned of (display dialog "What are your SSIDs? use ; to seperate. e.g. office-public;home-ap" default answer "" buttons {"OK"})
            --set ssidSET to my theSplit(ssidSTR, ";")
        end if
        
        set prefssidStr to do shell script "networksetup -listpreferredwirelessnetworks `/usr/sbin/networksetup -listnetworkserviceorder | grep -i 'Wi-Fi\\|AirPort' | grep -iow en.` | sed '1d' |sed 's/^[ 	]*//g' | tr \"\n\" \";\""
        
        set prefssidList1 to my theSplit(prefssidStr, ";")
        
        set prefssidList2 to {}
        
        repeat with theItem in prefssidList1
            if (theItem as text) is not equal to "" then
                set the end of prefssidList2 to (theItem as text)
            end if
        end repeat
        
        set chooseresult to choose from list prefssidList2 with prompt (messageBody as text) default items ssidSET with title "SSID Selection" OK button name "OK" with multiple selections allowed
        
        if (chooseresult as text) is "false"
        --cancel
        else
            set ssidSET to chooseresult
        end if

        --repeat with theItem in ssidSET
        --    display dialog "ssid:" & theItem
        --end repeat
        
    end setupSSID
    
    on setupAppRunninglist()
        set appRunningList to {}
        
        repeat with theItem in appList
            if ApplicationIsRunning(theItem) then
                set the end of appRunningList to true
                else
                set the end of appRunningList to false
            end if
        end repeat
    end setupAppRunninglist
    
    on setupApplist()
        
        set tmplist to {}
        set filelist to {}
        
        tell application "Finder"
            -- ~set a to "Macintosh HD:Applications:" as alias
            --set filelist to name of every file in
            --set appList to get name of folders of folder ("/Applications/" as POSIX file)
            set appPath to "Macintosh HD:Applications:" as alias
            --tell application "Finder"
            set tmplist to name of every file in appPath
            --end tell
        end tell
        
        repeat with theItem in tmplist
            set the end of filelist to (trimAppExtension(theItem) as text)
        end repeat
    
        set messageBody to "e.g. Cornerstone, svnX. Use command " & («data utxt2318» as Unicode text) & " to multi-select."
        
        
        set chooseresult to choose from list filelist with prompt messageBody default items appList with title "App Selection" OK button name "OK" with multiple selections allowed
        
        if (chooseresult as text) is "false"
        --cancel
        else
            set appList to chooseresult
        end if

--        set tmpStr to the text returned of (display dialog "What are your apps? use ; to seperate. e.g.  default answer "" buttons {"OK"})
--        set appList to my theSplit(tmpStr, ";")


        repeat with theItem in appList
            log "app:" & theItem
            --set the end of filelist to (trimAppExtension(theItem) as text)
        end repeat

        setupAppRunninglist()
    end setupApplist

    on setupSSIDmode()
        
        set messageBody to "Mode1: autovpn will try to connect when connecting these SSIDs and using specified apps meanwhile.\n\nMode2: autovpn will try to connect when NOT connecting these SSIDs and using specified apps meanwhile. The SSIDs are usually company internal SSIDs."
        
        if ifExclusemode is true
            set mode to the button returned of (display dialog messageBody buttons {"Mode1:Include mode", "Mode2:Exclude mode"} default button 2 with title "Choose SSID detection mode.")
        else
            set mode to the button returned of (display dialog messageBody buttons {"Mode1:Include mode", "Mode2:Exclude mode"} default button 1 with title "Choose SSID detection mode.")
        end if
    
        if (mode as string) = "Include mode" then
            set ifExclusemode to false
        end if
    end setupSSIDmode

    on getData()
        
        tell standardUserDefaults() of current application's NSUserDefaults
            registerDefaults_({myVPNService:myVPNService}) -- register the starting user default key:value items
            
            registerDefaults_({ifRunnable:ifRunnable})
            registerDefaults_({ifExclusemode:ifExclusemode})
            registerDefaults_({ssidSET:ssidSET})
            registerDefaults_({appList:appList})
            
            
            set myVPNService to objectForKey_("myVPNService") as text -- read any previously saved items (which will update the values)
            
            set ifRunnable to objectForKey_("ifRunnable") as boolean
            set ifExclusemode to objectForKey_("ifExclusemode") as boolean
            set ssidSET to objectForKey_("ssidSET") as list
            set appList to objectForKey_("appList") as list
            
            log "vpn:" & myVPNService
            
            if ifExclusemode = true
                log "company ssid:" & ssidSET
            else
                log "home ssid:" & ssidSET
            end if
        
            if ifRunnable is true
                log "is in running mode"
            else
                log "is in disable mode"
            end if

            log "app:" & appList

        end tell

        setupAppRunninglist()

    end getData

    on setupParametersAtStartup()
        --set myVPNService to ""

        if (myVPNService is "") or  (count of ssidSET is 0) or (count of appList is 0)
            if ifRunnable is true
                setupAllsetting()
            end if
        end if

        resetInfoOnStatus()

    end setupParameters

    on resetInfoOnStatus()
        log "adjust reset info"
        if (myVPNService is "") or  (count of ssidSET is 0) or (count of appList is 0)
            log "reset info, not enough"
            resetinfoMenuItem's setTitle_ ("Reset setting. (Current info is not enough, so not in detection mode)")
        end if
    end resetInfoOnStatus

    on trimAppExtension(theString)
        
        -- save delimiters to restore old settings
        set oldDelimiters to AppleScript's text item delimiters
        
        -- set delimiters to delimiter to be used
        set AppleScript's text item delimiters to ".app"
        -- create the array
        set Array to every text item of theString
        -- restore the old setting
        
        set AppleScript's text item delimiters to oldDelimiters
        
        return text item 1 of Array

    end trimAppExtension
    
    on theSplit(theString, theDelimiter)
        -- save delimiters to restore old settings
        set oldDelimiters to AppleScript's text item delimiters
        -- set delimiters to delimiter to be used
        set AppleScript's text item delimiters to theDelimiter
        -- create the array
        set theArray to every text item of theString
        -- restore the old setting
        set AppleScript's text item delimiters to oldDelimiters
        -- return the result
        return theArray
    end theSplit
    
    
    --idle handler, handler~function
    on idler()
        
        if ifRunnable is false
            return idleTime
        end if
        
        if (count of ssidSET) is 0 then
            return idleTime
        end if
        
        if myVPNService is "" then
            return idleTime
        end if
        
        if (count of appList) is 0 then
            return idleTime
        end if
        
        --log "run loop"
        
        --start loop
        set isConnectedHomeAP to false
        set isVpnConnected to false
        set isVpnConnecting to false
        set isAnyAppRunning to false
        
        --judge if at home
        set SSID to do shell script "/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | awk '/ SSID: / {print $2}'"
        
        if (SSID as string) = "" then
            return idleTime
        end if
        
        if ifExclusemode = false then
            repeat with theItem in ssidSET
                if SSID = (theItem as string) then
                    set isConnectedHomeAP to true
                end if
            end repeat
            else
            set isConnectedHomeAP to true
            repeat with theItem in ssidSET
                if SSID = (theItem as string) then
                    set isConnectedHomeAP to false
                end if
            end repeat
            
        end if
        
        --return if not at home
        if isConnectedHomeAP is false then
            return idleTime
        end if

        -- judge if vpn connected
        try
            tell application "System Events"
                    tell current location of network preferences
                        
                        set myConnection to the service myVPNService
                        
                        if current configuration of myConnection is not connected then
                            
                        else
                            set isVpnConnected to true
                        end if
                    end tell
               
            end tell
        end try

        --log "after try vpn info"

        --judge if apps are running
        repeat with i from 1 to count of appList

            set theItem to item i of appList
            try
                if ApplicationIsRunning(theItem) then
                
                    set isAnyAppRunning to true
                
                    set item i of appRunningList to true
                
                    if isVpnConnected is false then
                        --reConnect vpn
                        if isVpnConnecting is false then
                            set isVpnConnecting to true
                            log "try to connect:" & myVPNService
                            tell application "System Events"
                                tell current location of network preferences
                                    set myConnection to the service myVPNService
                                    connect myConnection
                                end tell
                            end tell
                            delay 7
                        end if
                        --quit app
                        try
                            do shell script "killall " & theItem
                        end try
                        delay 0.2
                        try
                            tell application theItem
                                quit
                            end tell
                        end try
                        
                        delay 0.2
                        --without delay, restart app will fail and happen error
                        --reRun app 
                        tell application theItem
                            run
                        end tell
                    
                    end if
                else
                    set item i of appRunningList to false
                end if
            end try
            -- do something with thisItem
        end repeat
        
        if (isAnyAppRunning = false) and (isVpnConnected = true) then
            --if (application "Safari" is running) or (application "Google Chrome" is running) or (application "Microsoft Outlook" is running) then
            --maybe users are using browsers to see teamroom, don't stop vpn
            --else
            --stop vpn
            log "try to disconnect:" & myVPNService
            tell application "System Events"
                tell current location of network preferences
                    try
                        set myConnection to the service myVPNService
                            disconnect myConnection
                    end try
                end tell
            end tell
            --end if
        end if
        return idleTime
    end idle

    on ApplicationIsRunning(appName)
        tell application "System Events" to set appNameIsRunning to exists (processes where name is appName)
        return appNameIsRunning
    end ApplicationIsRunning

    on btnQuit_(sender)
        tell current application to quit
	end btnQuit_

    on addToStart_(sender)
        LoginHelper's toggleLaunchAtStartup()
        
        set isStartup to (LoginHelper's isLaunchAtStartup() as boolean)
        if isStartup = false
            log "is not in startup"
            startupMenuItem's setTitle_ ("Add to system startup list ")
        else
            log "is in startup"
            startupMenuItem's setTitle_ ("Revmoe from system startup list ")
        end if

    end addToStart_

    on toggleRunMode_(sender)
        if ifRunnable = false then
            set ifRunnable to true
            log "try to become enable mode"
            runnableMenuItem's setTitle:"In Running mode. Click here to disable."
            
            if (myVPNService is "") or  (count of ssidSET is 0) or (count of appList is 0)
                setupAllsetting()
            end if

            resetInfoOnStatus()

        else
            set ifRunnable to false
            log "try to become disable mode"
            runnableMenuItem's setTitle:"In Disable mode. Click here to run up."
        end if
        
        tell standardUserDefaults() of current application's NSUserDefaults
            setObject_forKey_(ifRunnable, "ifRunnable") -- update the default items
        end tell
        
    end toggleRunMode_

    on setupAllsetting()
        try
            setupVPN()
        on error errMsg number errorNumber
            display dialog "no vpn"
        end try
        
        setupSSIDmode()
        
        try
            setupSSID()
        end try
        
        try
            setupApplist()
        end try
        
        saveData()
        
    end setupAllsetting

    on reset_(sender)
        setupAllsetting()
        resetInfoOnStatus()
        --tell current application to quit
	end reset_
    
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened
        
        set statusMenu to (NSMenu's alloc)'s initWithTitle_("VPNStatus")
        
		set sysStatusBar to NSStatusBar's systemStatusBar
        set statusItem to sysStatusBar's statusItemWithLength_(32)
        tell statusItem to setMenu_(statusMenu)
		tell statusItem to setHighlightMode_(1)
        
		set menuImage to NSImage's imageNamed_("autovpnStatusBarIcon.png")
		tell statusItem to setImage_(menuImage)
        
        --reset info menu
        set resetinfoMenuItem to (my NSMenuItem's alloc) 's init
        resetinfoMenuItem's setTitle_ ("Reset setting")
        resetinfoMenuItem's setTarget_ (me)
        resetinfoMenuItem's setAction_ ("reset:")
        --menuItem's setKeyEquivalent_ ("q")
        resetinfoMenuItem's setEnabled_ (true)
        statusMenu's addItem_ (resetinfoMenuItem)
        
        --start up menu
        set startupMenuItem to (my NSMenuItem's alloc) 's init
        set isStartup to (LoginHelper's isLaunchAtStartup() as boolean)
        if isStartup = false
            log "is not in startup"
            startupMenuItem's setTitle_ ("Add to system startup list ")
        else
            log "is in startup"
            startupMenuItem's setTitle_ ("Revmoe from system startup list ")
        end if
        startupMenuItem's setTarget_ (me)
        startupMenuItem's setAction_ ("addToStart:")
        --menuItem's setKeyEquivalent_ ("q")
        startupMenuItem's setEnabled_ (true)
        statusMenu's addItem_ (startupMenuItem)

        getData()

        --runnable menu
        set runnableMenuItem to (my NSMenuItem's alloc)'s init
        if ifRunnable = false then
            log "is in disable mode"
            runnableMenuItem's setTitle:"In Disable mode. Click here to run up."
        else
            log "is in enable mode"
            runnableMenuItem's setTitle:"In Running mode. Click here to disable."
        end if
        runnableMenuItem's setTarget:me
        runnableMenuItem's setAction:"toggleRunMode:"
        --menuItem's setKeyEquivalent_ ("q")
        runnableMenuItem's setEnabled:true
        statusMenu's addItem_ (runnableMenuItem)

        --quit menu
        set menuItem to (my NSMenuItem's alloc) 's init
        menuItem's setTitle_ ("Quit")
        menuItem's setTarget_ (me)
        menuItem's setAction_ ("btnQuit:")
        menuItem's setKeyEquivalent_ ("q")
        menuItem's setEnabled_ (true)
        statusMenu's addItem_ (menuItem)

        --start script
        setupParametersAtStartup()

        my enableIdleWithHandler_("idler")

	end applicationWillFinishLaunching_

    on saveData()
        tell standardUserDefaults() of current application's NSUserDefaults
            setObject_forKey_(myVPNService, "myVPNService") -- update the default items
            setObject_forKey_(ifExclusemode, "ifExclusemode") -- update the default items
            setObject_forKey_(ssidSET, "ssidSET") -- update the default items
            setObject_forKey_(appList, "appList") -- update the default items
        end tell
    end saveData
    
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits
        
        --display dialog "applicationShouldTerminate"
        
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
end script