#
#  AppDelegate.rb
#  AddressBooklet
#
#  Created by Krzysztof Wicher on 29/04/2012.
#  Copyright 2012 MiK. All rights reserved.
#

#Application delegte class - does majorit of job 
#probably some part could be moved away to different classes but ... what the hell
class AppDelegate
    attr_accessor :window
    attr_accessor :searchView
    attr_accessor :searchField
    attr_accessor :statusMenu
    attr_accessor :testView
    attr_accessor :tmpPeople
    attr_accessor :results
    attr_accessor :resultsView
    attr_accessor :searchFieldCon
    attr_accessor :drawer
    attr_accessor :scrollView
    attr_accessor :app_info
    attr_accessor :app_settings
    attr_accessor :loginStartup
     
    #Initialization of various application tasks
    def applicationDidFinishLaunching(a_notification)
        
        #Get the records from system AddressBook
        tempBook =ABAddressBook.addressBook
        @tmpPeople=[]
        tempBook.people.each do |p|
            tmpPeople<< [p.valueForProperty(KABFirstNameProperty).to_s+" "+p.valueForProperty(KABMiddleNameProperty).to_s+" "+p.valueForProperty(KABLastNameProperty).to_s,p.valueForProperty(KABUIDProperty).to_s]
        end
        #========
        
        #Place the app in the System bar 
        systemBar=NSStatusBar.systemStatusBar
        @menu1=systemBar.statusItemWithLength(NSVariableStatusItemLength)
        ico=NSImage.imageNamed('ab1').setSize([21,21])
        @menu1.setImage(ico)
        @menu1.setAction("toggleView:")
        #========
        
        #Load and setup views
        NSBundle.loadNibNamed("SearchWindow", owner: self)
        NSBundle.loadNibNamed("searchResults", owner: self)
        @searchField.setSendsWholeSearchString(false)
        @searchField.setSendsSearchStringImmediately(false)
        #========

        #Add global hot key Cmd+Ctr+Esc
        addHotKey
        #========
        
        #Chenge the focus to Finder ... 
        NSWorkspace.sharedWorkspace.launchApplication("Finder")
        #========

    end
    
    #register the global listener to bring the app forward upon pressing of the hotkey
    def addHotKey
        
        eventMonitorG = NSEvent.addGlobalMonitorForEventsMatchingMask(
         (NSKeyDownMask),handler:Proc.new do |incomingEvent|
            targetWindowForEvent = incomingEvent.window
            if targetWindowForEvent!=@window
             if incomingEvent.type == NSKeyDown 
              if incomingEvent.keyCode == 53 #Esc
               if incomingEvent.modifierFlags==1310985 #Ctrl=Cmd
                @searchField.setStringValue("")
                x=@menu1.valueForKey("window").frame.origin.x
                y=@menu1.valueForKey("window").frame.origin.y
                @searchView.setFrameTopLeftPoint([x-@searchView.frame.size.width/2,y])
                @searchView.makeKeyAndOrderFront(self)
                NSApp.activateIgnoringOtherApps(true)
                @searchView.makeFirstResponder(@searchFieldCon)
               end                                                  
              end
             end
            end
          end)
 
    end
    #========
    
    #Re-filter the records to be displayed in the table
    def updateSearch(sender)
        
        a=sender.stringValue
        predicate=NSPredicate.predicateWithFormat("SELF[0] contains[c] \'#{a}\'")
        @results=@tmpPeople.filteredArrayUsingPredicate(predicate)
        
        #Open/close the drawer with the results table if records present/absent
        if @results.size>0
            drawer.openOnEdge(NSMinYEdge)
        else
            drawer.close
        end
        #========

        
        #Send the notification to the table controller that records were re-filtered
        NSNotificationCenter.defaultCenter.postNotificationName("viewControllerCNotification",object:@results)
        #========

    end
    #========

    #Hide the search window
    def hideSearch(sender)
        
        drawer.close
        searchField.setStringValue("")
        searchView.orderOut(self)

    end
    #========

    #Toggle the search window        
    def toggleView(sender)
        
        if searchView.isVisible           
            hideSearch(sender)
        else
            x=NSApp.currentEvent.window.frame.origin.x
            y=NSApp.currentEvent.window.frame.origin.y
            searchView.setFrameTopLeftPoint([x-searchView.frame.size.width/2,y])
            searchView.makeKeyAndOrderFront(self)
            NSApp.activateIgnoringOtherApps(true)
            searchView.makeFirstResponder(searchFieldCon)
        end
        
    end
    #========
    
    #Display/close app information
    def showAppInfo(sender)
        NSBundle.loadNibNamed("Info", owner: self)
        NSApp.beginSheet(app_info,modalForWindow:NSApp.mainWindow,modalDelegate:self,didEndSelector:nil,contextInfo:nil)
    end    
    
    def closAppInfo(sender)
        app_info.close
        NSApp.endSheet(app_info)
    end
    #========

    #Display/close the settings panel 
    def showAppSettings(sender)
        NSBundle.loadNibNamed("Settings", owner: self)
        loginStartup.state=runAtLogin?
        NSApp.beginSheet(app_settings,modalForWindow:NSApp.mainWindow,modalDelegate:self,didEndSelector:nil,contextInfo:nil)
    end
    def closAppSettings(sender)
        app_settings.close
        NSApp.endSheet(app_settings)
    end
    #========

    #Run at login setup
    # Very much based on Gmail Notifr by ashchan.com
    
    #Check if the app iset to be run at login
    def runAtLogin?
        pref = CFPreferencesCopyValue(
                                    "AutoLaunchedApplicationDictionary",
                                    "loginwindow",
                                    KCFPreferencesCurrentUser,
                                    KCFPreferencesAnyHost
                                    )
        
        return false unless pref
        
        pref.any? { |app| NSBundle.mainBundle.bundlePath == app["Path"] }
    end
    #========
    
    #Change whether the App should be run at login
    def toggleRunAtStartup(sender)
        
        pref=CFPreferencesCopyValue(
                                    "AutoLaunchedApplicationDictionary",
                                    "loginwindow",
                                    KCFPreferencesCurrentUser,
                                    KCFPreferencesAnyHost
                                    )
        if pref
            pref = pref.mutableCopy
        else
            pref = NSMutableArray.alloc.init
        end
        
        url = NSBundle.mainBundle.bundlePath

        if sender.state==NSOnState
            pref.addObject(NSDictionary.dictionaryWithObject(url, forKey:"Path"))        
        else
            pref.each do |item|
            pref.removeObject(item) if item.valueForKey("Path") == url
            end                    
        end
        
        CFPreferencesSetValue(
                              "AutoLaunchedApplicationDictionary",
                              pref,
                              "loginwindow",
                              KCFPreferencesCurrentUser,
                              KCFPreferencesAnyHost
                              )

        
        CFPreferencesSynchronize(
                                 "loginwindow",
                                 KCFPreferencesCurrentUser,
                                 KCFPreferencesAnyHost
                                 )
    end
    #========
    
    #Terminate the app
    def exit(sender)
        NSApp.terminate(nil)
    end
    #========

    #Drawer delegate methods
    def drawerShouldClose(sender)
        false
    end
    def drawerWillResizeContents(sender,toSize:size) 
        sender.contentSize
    end
    #========

    #Main window delegate methods
    def windowDidResignMain(notic)
        NSApp.endSheet(app_info) if app_info
        NSApp.endSheet(app_settings) if app_settings
        drawer.close
        searchField.setStringValue("")
        searchView.orderOut(self)
    end
    
    def acceptsFirstResponder
        return true
    end
    #========

end

