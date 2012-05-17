#
#  ResultsTableController.rb
#  AddressBooklet
#
#  Created by Krzysztof Wicher on 30/04/2012.
#  Copyright 2012 MiK. All rights reserved.
#


class ResultCell < NSTableCellView
    #Table cell attributes
    attr_accessor :name
    attr_accessor :parent
    attr_accessor :row
    attr_accessor :table    
  
    #========
    def mouseEntered(theEvent)
        point = superview.superview.convertPoint(theEvent.locationInWindow, fromView:nil)
        @row=superview
        @table=row.superview
        row_no = @table.rowAtPoint(point)
        if row_no>-1            
            @row.setBackgroundColor(NSColor.colorWithDeviceRed(0.3,green:0.3,blue:0.3,alpha:0.12))
            @table.setNeedsDisplayInRect(@row.frame)
             parent.showInfo(@row.frame,row_no)
        end
    end
    
    def mouseExited(theEvent)
        if @row
            @row.setBackgroundColor(NSColor.whiteColor)
            @table.setNeedsDisplayInRect(@row.frame)
        end

    end
    def mouseMoved(theEvent)
    end
    
end

class ResultsTableController
    attr_accessor :results
    attr_accessor :results_view
    attr_accessor :people
    attr_accessor :tmpResults
    attr_accessor :infoPopUp
    attr_accessor :searchField
    attr_accessor :personId

    def initialize
        NSNotificationCenter.defaultCenter.addObserver(self,selector:"receiveNotification:", name:"viewControllerCNotification",object:@results)
        @results=[]

        
    end
    def receiveNotification(notification)
        @results = notification.object
        updateResults
    end
    def updateResults
        @results_view.reloadData
    end
        
    def awakeFromNib
        
        @results_view.dataSource = self
        @results_view.target=self
        @results_view.doubleAction="showInfo:"  

        
    end
   
    def numberOfRowsInTableView(view)
        
        @results.size
        
                
    end


    def tableView(view, viewForTableColumn:column, row:index)
        
        cell=view.makeViewWithIdentifier(column.identifier, owner:self)
        cell.name.stringValue=@results[index][0].to_s
        trackingArea =NSTrackingArea.alloc.initWithRect(cell.frame,options: (NSTrackingMouseEnteredAndExited |NSTrackingMouseMoved | NSTrackingActiveInActiveApp),owner:cell, userInfo:nil)
        cell.addTrackingArea(trackingArea)
        cell.parent=self
        return cell
    end
    def openAddressbook(sender)
        url = NSString.stringWithFormat("addressbook://%@", @personId)
        NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString(url))
        closeInfo(self)
        NSApp.delegate.hideSearch(nil)
    end

    def showInfo(theRow,rowNo)
            
        infoPopUp.showRelativeToRect(theRow,ofView:results_view, preferredEdge:NSMinXEdge)  
        
        infoPopUp.name.value.setStringValue(@results[rowNo][0])
        @personId=@results[rowNo][1]
        person =ABAddressBook.addressBook.recordForUniqueId(@personId)
        
        person.valueForProperty(KABEmailProperty)? infoPopUp.email.value.setStringValue(person.valueForProperty(KABEmailProperty).valueAtIndex(0)):infoPopUp.email.value.setStringValue("-----")
        
        person.valueForProperty(KABAddressProperty)? infoPopUp.address.value.setStringValue(person.valueForProperty(KABAddressProperty).valueAtIndex(0).values.join(", ")) : infoPopUp.address.value.setStringValue("-----")
        
        person.valueForProperty(KABPhoneProperty)? infoPopUp.phone.value.setStringValue(person.valueForProperty(KABPhoneProperty).valueAtIndex(0)) : infoPopUp.phone.value.setStringValue("-----")
        
    end
    def closeInfo(sender)
        infoPopUp.close
    end
    
    
end