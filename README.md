Yes, there's an awful lot to do. This file is for noting improvements which we could go back and apply to code we've already written.

* NSFileManager -- change attribute methods to call fstat64/lstat64, if possible, to retrieve eg. file creation date


* Collections -- expose setCapacity functions in CFLite and call them in the corresponding initWithCapacity: methods.


* NSArray -- sort with hint; NSIndexSet methods; NSSortDescriptor methods; URL methods

* NSDictionary -- keysSortedByValue; descriptions; URL methods

* NSCalendar -- auto-updating callendar

* NSError -- recovery options and recovery attempt

* NSLocale -- auto-updating locale; something needs to set the actual locale

* NSSet -- descriptions

* NSCountedSet -- everything (based on CFBag).



