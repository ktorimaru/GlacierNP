# GlacierNP
This is a coding sample featuring the use of MapKit
The app does the following:
1. Uses the Open Street Map tile set
2. Represents an area in Glacier National Park
3. Creates fictitious Campgrounds
  - Infomation about each campground is displayed when tapped on
  - Campgrounds can be opened and closed
  - Campgrounds can be moved by dragging when the detail is displayed
  - Starting campgrounds are loaded from a JSON file
  - A persistent datastore is created in the document directory
  - Campground changes are maintained in the data store
4. Fictitious Campers are created
  - Campers have a name, location, description and phone number
  - Tapping the camper displays their information
  - A starting set of campers is generated at the start of the app, after that a new camper is add every 30 seconds
  - Campers cluster depending on there location and zoom level
  - A special icon is used for clusters and includes the number of campers in the cluster


