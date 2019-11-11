# AD-Powershell---Telephone-Numbers-Format-Cleanup

####   Active Directory Telephone Number Cleanup Script by Chris Barcala -2018
####   Typical Scenario, your AD Environment has users with telephone numbers with format xxx-xxx-xxx, xxxxxxxxx, yxxxxxxxxx, (xxx)xxx-xxxx, and so on. You need to clean up the number to remove all characters and keep a standard of 10 digits as in xxxxxxxxx. 
####   Format should end up xxxxxxxxxx , if it is a bad number or one that could not be fixed, it is exported to a CSV and appended with username
####   Write outs are commented out and you can remove or uncomment to see expected results when testing.
####   Script by Chris Barcala 2018

![Screen Shot 2019-11-10 at 4 00 00 PM](https://user-images.githubusercontent.com/54015205/68553127-535fee00-03d3-11ea-9310-06b00061c364.png)
