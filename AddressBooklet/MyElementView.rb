#
#  MyElementView.rb
#  AddressBooklet
#
#  Created by Krzysztof Wicher on 05/05/2012.
#  Copyright 2012 MiK. All rights reserved.
#

class DetailsPopover < NSPopover
    attr_accessor :name
    attr_accessor :email
    attr_accessor :address
    attr_accessor :phone
   
    def initialize
        super
    end    
    
end
class MyElementView < NSView
    attr_accessor :name
    attr_accessor :label
    attr_accessor :value
    attr_accessor :clicked
    def initWithFrame(frame)
        super
        trackingArea1 =NSTrackingArea.alloc.initWithRect(self.bounds,options: (NSTrackingMouseEnteredAndExited |NSTrackingMouseMoved | NSTrackingActiveInActiveApp),owner:self, userInfo:nil)
        addTrackingArea(trackingArea1)
        @clicked=false
          return self
    end
   
   
    def mouseEntered(theEvent)
        @label.setHidden(false)
  
    end
    
    def mouseExited(theEvent)
        @label.setHidden(true)
        @clicked=false
        
    end
    def mouseMoved(theEvent)
    end
    def mouseDown(theEvent)
        @clicked=true
    end
    def mouseUp(theEvent)
        copyToClipboard(self) if @clicked
    end
    def copyToClipboard(sender)
        pasteboard=NSPasteboard.generalPasteboard
        pasteboard.clearContents
        pasteboard.writeObjects([value.stringValue])
        NSApp.delegate.hideSearch(NSApp.delegate)
    end
    
end

