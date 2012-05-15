#
#  AppDelegate.rb
#  AddressBooklet
#
#  Created by Krzysztof Wicher on 29/04/2012.
#  Copyright 2012 MiK. All rights reserved.
#
#require "LaunchAtLoginController"

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

    def applicationDidFinishLaunching(a_notification)
        
        tempBook =ABAddressBook.addressBook
        @tmpPeople=[]
        tempBook.people.each do |p|
            tmpPeople<< [p.valueForProperty(KABFirstNameProperty).to_s+" "+p.valueForProperty(KABMiddleNameProperty).to_s+" "+p.valueForProperty(KABLastNameProperty).to_s,p.valueForProperty(KABUIDProperty).to_s]
        end
        systemBar=NSStatusBar.systemStatusBar
        menu1=systemBar.statusItemWithLength(NSVariableStatusItemLength)
        menu1.setTitle("AB")
        menu1.setAction("toggleView:")
        NSBundle.loadNibNamed("SearchWindow", owner: self)
        NSBundle.loadNibNamed("searchResults", owner: self)
        @searchField.setSendsWholeSearchString(false)
        searchField.setSendsSearchStringImmediately(false)
        
        #Add global hot key
        eventMonitorG = NSEvent.addGlobalMonitorForEventsMatchingMask(
                (NSKeyDownMask),handler:Proc.new do |incomingEvent|

                                targetWindowForEvent = incomingEvent.window
                                                                     if targetWindowForEvent!=@window
                if incomingEvent.type == NSKeyDown 
                 if incomingEvent.keyCode == 53 #Esc
                  if incomingEvent.modifierFlags==1310985 #Ctrl=Cmd
                                                                      puts "global"

                    x=menu1.valueForKey("window").frame.origin.x
                    y=menu1.valueForKey("window").frame.origin.y
                    searchView.setFrameTopLeftPoint([x-searchView.frame.size.width/2,y])
                    searchView.orderFront(self)
                    searchView.makeKeyWindow
                    NSApp.activateIgnoringOtherApps(true)
                   end                                                  
                end
            end
            
                                                                      end
        end)
                
    end
    def updateSearch(sender)
        a=sender.stringValue
        predicate=NSPredicate.predicateWithFormat("SELF[0] contains[c] \'#{a}\'")
        @results=@tmpPeople.filteredArrayUsingPredicate(predicate)
        if @results.size>0
            drawer.openOnEdge(NSMinYEdge)
        else
            drawer.close
          end
        NSNotificationCenter.defaultCenter.postNotificationName("viewControllerCNotification",object:@results)

    end
    def hideSearch(sender)
        drawer.close
        searchField.setStringValue("")
        searchView.orderOut(self)
 

    end
        
    def toggleView(sender)

        x=NSApp.currentEvent.window.frame.origin.x
        y=NSApp.currentEvent.window.frame.origin.y
        if searchView.isVisible           
            hideSearch(sender)
        else
            pos=sender.frame
            searchView.setFrameTopLeftPoint([x-searchView.frame.size.width/2,y])
            searchView.makeKeyAndOrderFront(self)
            NSApp.activateIgnoringOtherApps(true)
            searchView.makeFirstResponder(searchFieldCon)
        end

    end
    
    def showAppInfo(sender)
        NSBundle.loadNibNamed("Info", owner: self)
        NSApp.beginSheet(app_info,modalForWindow:NSApp.mainWindow,modalDelegate:self,didEndSelector:nil,contextInfo:nil)
    end
    def closAppInfo(sender)
        app_info.close
        NSApp.endSheet(app_info)
    end
    def showAppSettings(sender)
        NSBundle.loadNibNamed("Settings", owner: self)
        NSApp.beginSheet(app_settings,modalForWindow:NSApp.mainWindow,modalDelegate:self,didEndSelector:nil,contextInfo:nil)
    end
    def closAppSettings(sender)
        app_settings.close
        NSApp.endSheet(app_settings)
    end
    
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
        
        
        if sender.state==NSOnState
            url = NSBundle.mainBundle.bundlePath
            pref.addObject(NSDictionary.dictionaryWithObject(url, forKey:"Path"))        
        else
            pref.each do |item|
                pref.removeObject(item) and break if item.valueForKey("Path") == url
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

    def exit(sender)
        NSApp.terminate(nil)
    end
    def drawerShouldClose(sender)
        false
    end
    def drawerWillResizeContents(sender,toSize:size) 
        sender.contentSize
    end
end

