#
#  SearWindow.rb
#  AddressBooklet
#
#  Created by Krzysztof Wicher on 29/04/2012.
#  Copyright 2012 MiK. All rights reserved.
#

#Class for the search panel defining methods among others making it interactive
class SearchWindow < NSWindow
    attr_accessor :view

    def canBecomeKeyWindow 
        return true
    end
    
    def canBecomeMainWindow 
        return true
    end
    
    def windowShouldClose(sender)
        true
    end
       
end
#========
