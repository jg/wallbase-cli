Wallbase.cc CLI utility
=======================

Usage
-----
	Usage:
		ws.rb -u <username> -p <password> [options] 

	--list-albums, -l:   List albums
	--get-image-urls, -g <s>:   Get list of image urls for a given album url
	--get-incremental-image-urls, -i <s>:   Get incremental list of image urls for a given album url
	--help, -h:   Show this message
Examples:
--------
	List albums 
		ws.rb -u user -p pass -l
	Get image links from album url 
		ws.rb -u user -p pass -g <url>
