Radiant Images
==============

(NOTE: Some sensitive information has been truncated and will need to be filled in before running the app.  If you attempt to run the app in simulator before filling in this information, it will fail compile.  Please read the section on Order Submittal below for instructions on how to add this necessary information.)


1. ABOUT THE APP
=======================================

The Radiant Images app is a catalog / shopping cart style universal native iOS application.  It allows users to browse the companies
inventory of products and prepare and submit rental quote requests.  This app is used by clients of Radiant Images who regularly
rent equipment for various movie and television productions.


Native calatog for iOS is a universal native application that provides a catalog and shopping cart functionality. It allows customers to browser inventory, select items and submit orders from a iOS device. Payments aren't processed in-app and therefore this application is best suited for businesses that operate with a pay-on-deliver model rather than pay on order.

This app was first developed for use by a company prominent as a rental house for the film industry, credited for provided the camera equipment used to shoot such Hollywood hits as Need for Speed (2014), House of Lies (HBO), and countless other films, and television shows.

Radiant images continues to use the app and it serves as a living demonstration of this project.

Radiant Images is currently available on the Apple App Store as a free download here:  Download Now

(note: when previewing the demo, please note that not all of the content was ever completely filled out for all the various sections. In order to see all of the app's features, it's best to browse through the Cameras > Digital Cinema > Arri sections as this area is the most content filled)

1.1. Features
---------------------------------------

1)  Universal app - works on iPhone, iPad and iPad mini.
2)  Sync with hosted database in the background - allows you to update the
    catalog in the background.
3)  Accept order requests, invoices and quotes. Best for pay-on-receipt
    businesses like restaurants or rental companies. Not payment is involved.
4)  Handle creation and management of unlimited orders.
5)  Browse, search and navigate through the alphabet.
6)  Display thumbnail images of products on all navigation pages.
7)  Stream HD video to the app on product detail pages and assign unique
    videos for each product.
8)  Load remote web content such as 360 degree interactive product panoramas.
9)  Display swipeable, zoomable image gallery with up to 7 images per product. 10) Easily modifiable to support an unlimited number of images if desired.
11) Display product textual details and technical specs or other tabular data.
12) User can add items, adjust quantity and leave comments for orders.

2. Database
=======================================

It may be a good idea to open up the app and browse through it a bit to familiarize yourself with the different views so as I explain how the database is organized it may make a bit more sense.

As far as opening the database.  There are several free and paid applications that you can get for OSX, Windows, or Linux.  Though you could even do it all from a command line interface as well if you wanted to.  My preference is to use NaviCat which is not free but is quite full featured and easy to use.

You can find the demo database file in the data folder.  It's named 'radical_v2-506.sqlite'.  Once you open it up don't let it overwhelm you.  There are several tables and it may appear to be a pretty complex database but it's actually very simple.  It just looks intimidating because of it's size.

The database used is SQLite.  The demo database consists of 10 separate tables, I'll go over each one in alphabetical order:

2.1. Cart
---------------------------------------

The ultimate design of the app is to allow customers to submit orders or quotes and one of the special features is the ability for users to create, save, and switch between several different projects or 'carts' before submitting one.  In a typical shopping app, you'd only have 1 shopping cart available.  You pick your items and if you want to order something else and order the items you chose earlier, you have to start all over again.  This multi-cart feature lets users start a cart, and if they need to prepare an order for a separate project, they can save the previous order for later and create a new one completely separate.  In fact you can create virtually an infinite number of simultaneous carts and switching between them is just a matter of 3 clicks.

The cart table is where the information for each of these carts is stored.

The photofield columns 1 thru 5 are currently not in use and are placeholders for a future feature.

2.2. DetailsKeyValues
---------------------------------------

This table is an important table to keep organized.  This table defines the labels of the data displayed on each products detail page.  Items of the same type are designed to share the same labels but in case some of them don't, you just add another row to this table and assign it properly.

Note how each value in the columns is prefixed with an extra letter.  This extra letter is necessary but will not display in the app.  It's just a simple way of keeping them in the order they're designed to be displayed in because without the letters they would get sorted by alphabet.  Thus why column 1 is prefixed 'a', column 2 is prefixed 'b', etc..  Just make sure the first letter in each column is the appropriate letter for alphabetizing the list.  It doesn't matter if it's followed by a dash or space, or anything..  The app is just going to sort based on the first letter, and hide that first letter so your users don't see it.

2.3. Hierarchy
---------------------------------------

This is the table that defines the drill-down menu's and submenu's.  There is no preset requirement that you limit yourself to only having 2 or any specific number of submenu levels like you'll find in many tutorials and sample code.  This is designed to be infinitely expandable so you can have 1 menu with 1 submenu, you can have a menu with 10 levels of submenu's if you want.  It's all up to you and what you enter here.

The first several rows you'll notice coorespond to the first menu options when you open the app.  We have columns for the key_id, menu_title, menu_icon, level, and parent.  The first set of menu's are assigned level 1 because they are displayed first, and assigned a parent of 0 because they are the top level menus.

As you look at the subsequent rows you'll notice we go to level 2 menus, level 3 menus, etc..  Each one is also assigned it's parent which related to the key_id of the higher level menu it should coorespond to.

For the most part you'll see that the levels all go in order but this is not a requirement.  For example, if you go to the end of the table, the last value is 'Novo' level 3 parent 18 because it's displayed under 'Digital Cinema with key_id 18 and even though there is a level 4, Digital Cinema doesn't have a level 4.

This table should really be self explanatory.  My best advice is just don't overthink it.

2.4. mfg
---------------------------------------

This is another table that is tied closely to the table which contains all our product information.  The manufacturer name listed in this table should match exactly to the manufacturer name that we will write in the product table.

All this table does is specify a logo for the manufacturer which is displayed if a product has no images, or also if the app is offline, or while the high resolution images are downloading because we do not store the high resolution images within the app.. More on that later.

2.5. Product_Assets
---------------------------------------

Product_Assets is likely to be the largest table in the database.  If you open up the app and drill down to a product, notice there is a tab called 'Kit'.  The idea is that each product includes several smaller parts, so we want to let the user have an inventory sheet so they know what is included with each item.  For example, a camera is generally going to have batteries, media, a port cap over the lens, and various cinemagraphic support hardware.

This is the table for listing al that information.

2.6. Product_Catalog
---------------------------------------

The one we've been waiting for.  This is where all of our product information goes and this is the most complex table of the whole database because it ties in with some of the table's I've already mentioned.

Columns 1 thru 5 define the URLs to any videos we want to make avaialble for each product.  In the demo, most of the cameras have several videos that can be opened which are camera tests illustrating the iris range, dynamic range, color rendition, green screen composition, and an additional promotional video in some cases.

The next column is product_ID which cooresponds to the kitID in the Product_Assets table.  Then we have the Product (name), the Manufacturer (which coorelates to the manufacturer name in the mfg table), cat which corresponds to the menu it should be displayed under (as relates to the Hierarchy table), followed by display order so we can display each product not necessarily in alphabetical order.  If you don't specify a display order they will display in alphabetical order.

After that we have the display_Thumbnail which is displayed in the menu's, and we have columns to define images 1 through 5.  If you want to have more than 5 images all you have to do is add another column after display_Image05.

After the images we have a web url for panorama which is where we store the 360 degree content.  Followed by the description.

It's important to point out that the description content is also the field used when you search for a product in the app.  If you type in a search query it will return all products which have words within it's description that match the query.

info_DetailsKey cooresponds to the DetailsKeyValues table and the subsequent columns (info_spec_a - q) are the values which will be assigned the labels in DetailsKeyValue.

Finallym, the last column is keyid, which serves no major purpose other than keeping the table organized.

2.7. rfq
---------------------------------------

Closely related to the cart table.  This is where the information that users store about each of their projects is stored.

2.8. version
---------------------------------------

If you do not care about having the ability to update the content of the app after users have downloaded it then you can disregard this table.  But if you want to be able to adjust the content this is a very important table.

One of the key features of this app is it's ability to be updated to users local device without them having to download an app update.  In fact the updates happen in the background and may never even be noticed by the user.

If you take a closer look at the console while running the app in the simulator, you'll notice that it attempts to connect to a database each time you open the app.  Each time the app is opened, if there is an active internet connection it will ping a remote database (which you would store in a folder on your webhost or somewhere publically assessible but hidden).  The URL to that remote database is specified in the project 

Rather than connecting to the remote database and downloading it every time, that would take a long time, it just connects to the database and reads the version table. If the versionid matches the vesionid of the local database then nothing happens.  But if the versionid is larger than the versionid of the local database it will take a look at the updatecatalogrow and updateassetrow values and download any new content in teh Product_Catalog and Product_Assets tables.

So, for example, the current versionid of the demo is 6 with nothing in updatecatalogrow or updateassetrow.  If I want to add some more products I would change that to versionid = 7, updatecatalogrow = 1000 (because there are currently 999 rows.. any new content is going to start at row 1000), and updateassetrow = 4560 because again there are currently 4559 entries, any new content is going to be starting at 4560.

Specifying these values is important because if it were not set up this way the app would have no way of knowing where the new content is.  This makes it very fast for the app to only download the new content rather than downloading the whole database or an entire table.  Perhaps if the database were smaller this wouldn't be important but when you deal with a large database of products and you want to update the app without making the user wait it needs to happen instantaneously wtihout any lag.

3. Order Submittal
=======================================

To enable the receiving of orders you'll need to setup a new Gmail account.  I suggest you create an account with an obscure name and a very long random password.  For example, though it's truncated from the code, the account that was used by Radiant Images was something like radiantimages_iosorders@gmail.com and the password to that account was a 30 to 45 alphanumeric string of random characters.

Go ahead and setup your own account and save the login information somewhere.

In the project code, go to SubmitController.m and take a look at the lines between 78 and 104.  Enter the username and password in the appropriate places.

Now whenever a user is ready to submit an order, all of their information will be sent via Gmail's SMTP server using that account.  The user will never see this information or never be able to change the email address or even know that it was sent over email.  All the user will see is that they're order has been submitted or their order was not successfully submitted if it fails.