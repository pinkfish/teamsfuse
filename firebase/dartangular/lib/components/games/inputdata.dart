import 'package:google_maps/google_maps_places.dart';
import 'package:google_maps/google_maps.dart';
import 'dart:js';
import 'dart:js_util';

class InputData {
  static const String CROSSFIRE_2017 =
      '''01/27/2017,12:19 PM,"",12:19 PM,at Seattle United G06 Copa A,TBD,,
03/25/2017, 6:13 PM,"", 6:13 PM,State Cup Playoffs,TBD,,
05/01/2017, 7:30 PM,"", 7:30 PM,Parent Meeting (all 06 teams),Redmond High School,"7272 NE 104th St, Redmond, WA 98052",
05/09/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear white),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
05/16/2017, 5:30 PM, 7:00 PM, 5:30 PM,"Training(Wear White shirt,Black Shorts,Black socks)",Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
05/18/2017, 5:30 PM, 7:00 PM, 5:30 PM,"Training (Wear Black Shirt,Black Shorts,Black Socks)",Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
05/20/2017, 3:00 PM,"", 3:00 PM,Crossfire scrimmage vs Boys 06B,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
05/22/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
05/23/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
05/25/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
05/30/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear white),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
05/31/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
06/01/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear white),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
06/05/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
06/06/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
06/07/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
06/08/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),Lake Washington High School,12033 NE 80th St Kirkland 98033,
06/09/2017, 5:00 PM, 7:00 PM, 5:00 PM,Team Dinner,Rusak's Home,7520 196th Ave NE Redmond WA 98053,
06/12/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Lake Washington High School,12033 NE 80th St Kirkland 98033,
06/13/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),Lake Washington High School,12033 NE 80th St Kirkland 98033,
06/14/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Lake Washington High School,12033 NE 80th St Kirkland 98033,
06/15/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Lake Washington High School,12033 NE 80th St Kirkland 98033,
06/19/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (wear white),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
06/20/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (wear black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
06/21/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear white),Lake Washington High School,12033 NE 80th St Kirkland 98033,
06/23/2017, 8:00 PM, 9:05 PM, 7:15 PM,Rainier Challenge Tournament vs. Seattle United Tango,WPFC Soccer Complex,"5702 44th St E  Puyallup, WA  98371-3601",W 2-0
06/24/2017, 9:15 AM,10:20 AM, 8:30 AM,Rainier Challenge Tournament at Harbor Premier Green,WPFC Soccer Complex,"5702 44th St E  Puyallup, WA  98371-3601",W 4-1
06/24/2017, 2:15 PM, 3:20 PM, 1:30 PM,Rainier Challenge Tournament vs. WPFC G06 Black A,WPFC Soccer Complex,"5702 44th St E  Puyallup, WA  98371-3601",L 1-4
06/25/2017,10:30 AM,11:35 AM, 9:45 AM,Rainier Challenge Cup,WPFC Soccer Complex,"5702 44th St E  Puyallup, WA  98371-3601",
06/27/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training with Lindsey's team (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
06/29/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training with Lindsey's team (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
07/03/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Redmond High School,"7272 NE 104th St, Redmond, WA 98052",
07/05/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),Redmond High School,"7272 NE 104th St, Redmond, WA 98052",
07/06/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Lake Washington High School,12033 NE 80th St Kirkland 98033,
07/10/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
07/11/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
07/12/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
07/13/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
07/17/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
07/18/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
07/19/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
07/21/2017, 3:45 PM, 4:50 PM, 3:00 PM,Crossfire Challenge Tournament at Whitfield SC,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",L 0-4
07/22/2017, 8:15 AM, 9:20 AM, 7:30 AM,Crossfire Challenge Tournament at FC Portland,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",T 2-2
07/23/2017, 8:00 AM, 9:05 AM, 7:15 AM,Crossfire Challenge Tournament at Federal Way,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",W 2-0
07/23/2017, 3:50 PM,"", 3:20 PM,vs. Foothills FC,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
07/25/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
07/26/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
07/27/2017, 9:00 AM,10:30 AM, 9:00 AM,Training (Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
07/27/2017, 3:00 PM,"", 3:00 PM,USWNT vs Austrailia and Japan vs Brazil,CenturyLink,,
07/31/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/01/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/02/2017, 5:30 PM, 6:45 PM, 5:30 PM,Training (Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/04/2017, 7:00 PM,"", 7:00 PM,Team Dinner,Nucci's Italian Cafe,1580 S Melrose Dr. 108 Vista CA,
08/05/2017, 1:35 PM, 2:40 PM,12:50 PM,Surf Cup Tournament (San Diego) vs. San Diego Surf Academy Lowrey,OC (SoCal Sports Complex),"3300 El Corazon Drive Oceanside, CA 92056-2691",W 2-0
08/05/2017, 5:35 PM, 6:40 PM, 4:50 PM,Surf Cup Tournament (San Diego) vs. Beach FC,OC (SoCal Sports Complex),"3300 El Corazon Drive Oceanside, CA 92056-2691",W 2-1
08/06/2017, 8:15 AM, 9:20 AM, 7:30 AM,Surf Cup Tournament (San Diego) vs. PSV Union,OC (SoCal Sports Complex),"3300 El Corazon Drive Oceanside, CA 92056-2691",T 3-3
08/06/2017,12:15 PM,"",11:30 AM,vs. Santa Rosa United,OC (SoCal Sports Complex),"3300 El Corazon Drive Oceanside, CA 92056-2691",T 0-0
08/07/2017, 9:35 AM,"", 8:50 AM,vs. Rebels,OC (SoCal Sports Complex),"3300 El Corazon Drive Oceanside, CA 92056-2691",L 0-2
08/09/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/10/2017, 5:30 PM,"", 5:30 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
08/11/2017, 2:30 PM, 3:35 PM, 1:45 PM,Redapt Cup Tournament at Crossfire Select CFS Gold Jordan,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",T 0-0
08/11/2017, 7:00 PM,"", 6:15 PM,Redapt Cup Tournament vs. OPS FC Fischer 05,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",W 1-0
08/12/2017, 8:45 AM,"", 8:45 AM,Redapt Cup Tournament at Crossfire 05C,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",L 1-2
08/12/2017, 1:45 PM, 2:50 PM, 1:00 PM,Redapt Cup Tournament at Crossfire 05B,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",L 0-2
08/14/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/15/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/17/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/18/2017, 5:30 PM,"", 4:45 PM,vs. Academy of Soccer Excellence,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",W 3-0
08/19/2017,12:30 PM, 1:35 PM,11:45 AM,NWCL Tournament at Westside Timbers WT 06G Copa TS,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",W 10-1
08/19/2017, 6:30 PM, 7:35 PM, 5:45 PM,at Indie Chicas,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",W 7-0
08/20/2017, 8:00 AM, 9:05 AM, 7:15 AM,NWCL Tournament Semi-finals at TBD,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",W 1-1 (PK 3-1)
08/20/2017,12:30 PM, 1:35 PM,11:45 AM,NWCL Tournament Final vs. SPOKANE SOUNDERS G06-A VALLEY,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",L 3-3 (PK 2-3)
08/22/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/24/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/25/2017, 4:00 PM,"", 4:00 PM,Scrimmage Boys U12C at Crossfire Boys,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
08/28/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/29/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/31/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/01/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
09/04/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/05/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/06/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/07/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
09/08/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
09/09/2017, 3:30 PM, 4:35 PM, 2:45 PM,at Seattle United G06 Copa A,Jefferson Park Plateau,3801 Beacon Ave South Seattle 98108,W 3-1
09/11/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training(Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/12/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/14/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
09/15/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
09/17/2017, 4:00 PM, 5:05 PM, 3:15 PM,at G06 Eastside Reign PA,Preston,30634 SE 87th Place Preston WA 98027,
09/18/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training(Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/18/2017, 6:30 PM, 7:10 PM, 6:20 PM,Parent Meeting Mandatory,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/19/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
09/21/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/22/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/23/2017, 2:00 PM, 3:05 PM, 1:15 PM,vs. WPFC G06 Black A,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",T 1-1
09/25/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training(Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/26/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/28/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
09/29/2017, 4:00 PM, 5:00 PM, 4:00 PM,Training (wear black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
09/30/2017, 9:00 AM,10:05 AM, 8:15 AM,at Federal Way,Karl Grosch,2620 South 312th St Federal Way 98003,T 1-1
10/02/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training(Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
10/03/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
10/05/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
10/06/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
10/07/2017,12:00 AM, 1:05 AM,11:15 PM,NWCL Tournament vs. TBD,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
10/07/2017,12:30 PM,"",11:45 AM,vs. GS Surf G06-A,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",W 4-0
10/08/2017,12:00 AM, 1:05 AM,11:15 PM,NWCL Tournament vs. TBD,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
10/09/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training(Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
10/10/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
10/12/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
10/13/2017, 4:30 PM, 5:30 PM, 4:30 PM,Training (wear black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
10/13/2017, 6:00 PM, 6:30 PM, 6:00 PM,Pasta Feed,Rusak's Home,7520 196th Ave NE Redmond WA 98053,
10/14/2017,12:00 PM,"",11:15 AM,at Seattle United Tango,Jefferson Park Plateau,3801 Beacon Ave South Seattle 98108,W 3-1
10/15/2017, 9:00 AM,"", 8:15 AM,vs. Seattle United G06 Copa A,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",L 0-3
10/16/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training(Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
10/17/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
10/19/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
10/20/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
10/20/2017, 6:30 PM,"", 5:45 PM,vs. PacNW G06 Maroon A,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",W 4-0
10/21/2017, 5:30 PM,"", 5:30 PM,Crossfire Auction,Marriott Hotel Redmond Town Center,7401 164th Ave NE Redmond 98052,
10/23/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training(Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
10/24/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
10/26/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
10/27/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
10/30/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training(Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
10/31/2017,11:25 AM,"",11:25 AM,Happy Halloween!,TBD,,
11/01/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/02/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
11/03/2017, 4:00 PM, 5:15 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
11/04/2017,10:30 AM,"", 9:45 AM,vs. G06 Eastside Reign PA,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",T 0-0
11/06/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/07/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/09/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/10/2017, 4:00 PM, 5:15 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
11/11/2017, 1:00 PM,"",12:15 PM,at WPFC G06 Black A,WPFC Soccer Complex,"5702 44th St E  Puyallup, WA  98371-3601",L 0-2
11/11/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear white),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/13/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/14/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
11/15/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/16/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/18/2017,10:00 AM,"", 9:15 AM,vs. Federal Way,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",W 1-0
11/20/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
11/21/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/22/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
11/27/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training( Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
11/28/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/29/2017, 5:45 PM, 7:00 PM, 5:45 PM,Training (Wear Crossfire Jackets),Crossfire Office,,
11/30/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
12/02/2017, 6:30 PM,"", 5:45 PM,vs. GS Surf G06-A,Woodinville Sports Complex,13103 NE 175th Street Woodinville 98072,W 4-0
12/03/2017, 4:00 PM,"", 4:00 PM,Team Holiday Party,Braathen Family,18021 NE 130th Ct Redmond WA 98052,
12/04/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training( Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
12/05/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
12/06/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
12/07/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
12/11/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
12/12/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
12/13/2017, 6:45 PM, 8:00 PM, 6:45 PM,Training (Wear White),John Muir Elementary,14013 132nd Ave NE Kirkland 98034,
12/14/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
12/14/2017, 6:00 PM,"", 6:00 PM,AS Roma Academy,AS Roma Academy,"Lakeland, Florida",
12/15/2017,12:00 AM,"",12:00 AM,AS Roma Academy Showcase vs. TBD,AS Roma Academy,"Lakeland, Florida",
12/16/2017,12:00 AM,"",12:00 AM,AS Roma Academy Showcase vs. TBD,AS Roma Academy,"Lakeland, Florida",
12/17/2017,12:00 AM,"",12:00 AM,AS Roma Academy Showcase vs. TBD,AS Roma Academy,"Lakeland, Florida",
01/02/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
01/03/2018, 6:50 PM, 8:00 PM, 6:50 PM,Trainng (Wear Black),John Muir Elementary,14013 132nd Ave NE Kirkland 98034,
01/04/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (WearWhite),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
01/06/2018,10:30 AM,"", 9:45 AM,vs. Seattle United Tango,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",T 0-0
01/08/2018, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
01/09/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
01/10/2018, 6:45 PM, 8:00 PM, 6:45 PM,Training (Wear White),John Muir Elementary,14013 132nd Ave NE Kirkland 98034,
01/11/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
01/15/2018, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
01/16/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
01/17/2018, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
01/18/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
01/22/2018, 5:30 PM, 7:00 PM, 5:30 PM,Scrimmage Wear Black/Black/Black Uniforms,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
01/23/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
01/24/2018, 6:45 PM, 8:00 PM, 6:45 PM,Training (Wear White),John Muir Elementary,14013 132nd Ave NE Kirkland 98034,
01/25/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
01/27/2018, 2:00 PM,"", 1:15 PM,at Seattle United Tango,Jefferson Playfield,4165 16th Ave South Seattle 98108,L 0-3
01/28/2018,11:30 AM,"",10:45 AM,at G06 Eastside Reign PA,Preston,30634 SE 87th Place Preston WA 98027,W 1-0
01/29/2018, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
01/31/2018, 6:45 PM, 8:00 PM, 6:45 PM,Training (Wear White),John Muir Elementary,14013 132nd Ave NE Kirkland 98034,
02/01/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/02/2018, 4:00 PM, 5:30 PM, 4:00 PM,Scrimmage Wear Red/Black/Red,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
02/05/2018, 6:30 PM,"", 5:45 PM,at PacNW G06 Maroon A,Starfire,,W 7-2
02/06/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/07/2018, 5:30 PM, 6:45 PM, 5:30 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/09/2018, 5:55 PM,"", 5:10 PM,Desert Classic Tournament 2018 vs. Sereno 06 Shank,Rose Mofford,9833 N 25th Ave Phoenix AZ 85021,W 4-0
02/10/2018, 5:25 PM,"", 4:40 PM,Desert Classic Tournament 2018 vs. Real Henderson FC 06 Select,Reach 11,"2425 E Deer Valley Dr, Phoenix, AZ 85050",T 2-2
02/11/2018, 9:50 AM,"", 9:05 AM,Desert Classic Tournament 2018 vs. Legacy 06 Red,Reach 11,"2425 E Deer Valley Dr, Phoenix, AZ 85050",W 4-1
02/11/2018, 2:05 PM,"", 2:05 PM,Desert Classic Tournament 2018 vs. TBD,Reach 11,"2425 E Deer Valley Dr, Phoenix, AZ 85050",
02/13/2018, 4:00 PM, 5:30 PM, 4:00 PM,Practice (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/14/2018, 6:50 PM, 8:00 PM, 6:50 PM,Practice (Wear Black),John Muir Elementary,14013 132nd Ave NE Kirkland 98034,
02/15/2018, 4:00 PM, 5:30 PM, 4:00 PM,Practice (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/20/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/21/2018, 5:30 PM, 6:45 PM, 5:30 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/22/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/24/2018,10:30 AM,"", 9:45 AM,at Federal Way,Karl Grosch,2620 South 312th St Federal Way 98003,L 0-1
02/26/2018, 5:00 PM, 5:30 PM, 5:00 PM,Team Meeting(Players Only),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/26/2018, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
02/27/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/28/2018, 6:45 PM, 8:00 PM, 6:45 PM,Training (Wear White),John Muir Elementary,14013 132nd Ave NE Kirkland 98034,
03/01/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
03/03/2018, 9:00 AM,"", 8:15 AM,vs. GS Surf G06-A,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",W 1-0
03/04/2018, 4:30 PM,"", 3:45 PM,vs. PacNW G06 Maroon A,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",W 3-0
03/06/2018, 4:00 PM,"", 4:00 PM,training (wear black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
03/07/2018, 2:30 PM, 4:45 PM, 2:30 PM,Optional Team Volunteering Hope Link,Hopelink,10110 120th Ave NE Kirkland WA 98033,
03/08/2018, 4:00 PM,"", 4:00 PM,training (wear black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/10/2018,12:00 PM,"",11:15 AM,at Seattle United Tango,Van Asselt Elementary,8311 Beacon Ave S Seattle 98118,W 2-0
03/11/2018,11:00 AM,"",10:15 AM,vs. WPFC G06 Black A,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",L 0-2
03/13/2018, 4:00 PM,"", 4:00 PM,training (wear black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
03/14/2018, 5:30 PM,"", 5:30 PM,training (wear white),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
03/15/2018, 4:00 PM,"", 4:00 PM,training (wear black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/16/2018, 4:00 PM,"", 4:00 PM,training (wear white),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/18/2018, 6:30 PM, 7:30 PM, 6:00 PM,Scrimmage against Crossfire 05 Wear Black,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/19/2018, 5:30 PM, 7:00 PM, 5:30 PM,Training(Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
03/20/2018, 4:00 PM,"", 4:00 PM,training (wear black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
03/21/2018, 5:30 PM, 7:00 PM, 5:30 PM,training (wear white),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/22/2018, 4:00 PM,"", 4:00 PM,training (wear black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/24/2018, 1:30 PM,"",12:45 PM,State Cup Playoffs Prelims at Seattle United G06 Copa A,Van Asselt Elementary,8311 Beacon Ave S Seattle 98118,L 1-2
03/26/2018, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
03/27/2018, 4:00 PM,"", 4:00 PM,training (wear black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
03/28/2018, 5:30 PM,"", 5:30 PM,training (wear white),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/29/2018, 4:00 PM,"", 4:00 PM,training (wear black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/02/2018, 5:30 PM, 7:00 PM, 5:30 PM,Trainng (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
04/03/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
04/04/2018, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
04/05/2018, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
04/07/2018, 2:45 PM,"", 2:15 PM,Scrimmage Game vs Boys Team(Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/09/2018, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/10/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/11/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/12/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/14/2018, 1:00 PM,"",12:15 PM,State Cup Playoffs Prelims vs. Seattle United Tango,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/15/2018,10:30 AM,"",10:30 AM,State Cup Playoffs Prelims at WPFC G06 Black A,WPFC Soccer Complex,"5702 44th St E  Puyallup, WA  98371-3601",
04/17/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/18/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/19/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/23/2018, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
04/24/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/25/2018, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
04/26/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
04/28/2018,11:00 AM,"",10:15 AM,State Cup Playoffs Prelims vs. PacNW G06 Maroon A,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/30/2018, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
05/01/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
05/02/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
05/03/2018, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
05/04/2018, 6:30 PM,"", 6:30 PM,State Cup/Semi's vs. TBD,TBD,,
05/05/2018, 6:30 PM,"", 6:30 PM,State Cup/Semi's vs. TBD,TBD,,
05/06/2018, 9:30 PM,"", 9:30 PM,State Cup Final vs. TBD,TBD,,
''';

  static const String PINNACLE_2017 =
      '''04/08/2017, 5:40 PM,"", 5:40 PM,vs. Free Spirit,Bonnie Lake High School,"10920 199th Ave Ct E, Bonney Lake, WA 98391",L 27-29
04/08/2017, 6:50 PM,"", 6:50 PM,vs. Stanwood,Bonnie Lake High School,"10920 199th Ave Ct E, Bonney Lake, WA 98391",W 33-29
04/09/2017,11:15 AM,"",11:15 AM,vs. QuickHandle,White River High School,26928 120th St East Buckley WA 98321,W 51-4
04/09/2017, 2:00 PM,"", 2:00 PM,Finals! vs. Free Spirit,White River High School,26928 120th St East Buckley WA 98321,W 27-15
04/10/2017, 6:00 PM, 7:30 PM, 6:00 PM,Training,Redmond High School,"17272 NE 104th St, Redmond, WA 98052",
04/13/2017, 7:30 PM, 9:00 PM, 7:30 PM,Training,Redmond High School,"17272 NE 104th St, Redmond, WA 98052",
04/15/2017, 9:00 AM,"", 8:30 AM,NWA Easter Bunny vs. Lady Blackout,Auburn High School,"702 4th Street Northeast, Auburn, WA",W 60-10
04/15/2017, 1:00 PM,"", 1:00 PM,NWA Easter Bunny vs. EBC 5,Auburn High School,"702 4th Street Northeast, Auburn, WA",W 40-8
04/15/2017, 3:00 PM,"", 3:00 PM,NWA Easter Bunny vs. Swish Black,Auburn High School,"702 4th Street Northeast, Auburn, WA",L 22-26
04/17/2017, 6:00 PM, 7:30 PM, 6:00 PM,Training,Pine Lake Middle School,"3200 228th Ave SE, Sammamish, WA 98075",
04/20/2017, 7:30 PM, 9:00 PM, 7:30 PM,Training,Redmond High School,"17272 NE 104th St, Redmond, WA 98052",
04/24/2017, 6:00 PM, 7:30 PM, 6:00 PM,Training,Pine Lake Middle School,"3200 228th Ave SE, Sammamish, WA 98075",
04/27/2017, 7:30 PM, 9:00 PM, 7:30 PM,Training, Evergreen Middle School,"6900 208th Ave. N.E., Redmond, WA 98053",
05/01/2017, 6:00 PM, 7:30 PM, 6:00 PM,Training,Pine Lake Middle School,"3200 228th Ave SE, Sammamish, WA 98075",
05/04/2017, 7:30 PM, 9:00 PM, 7:30 PM,Training,Redmond High School,"17272 NE 104th St, Redmond, WA 98052",
05/06/2017, 9:00 AM,"", 8:30 AM,SYB May Breakaway vs. Switch 4 Black,Auburn Mountview High School,"28900 124th Ave SE, Auburn, WA 98092",W 30-7
05/06/2017,11:10 AM,"",10:40 AM,SYB May Breakaway vs. Ballard,Auburn Mountview High School,"28900 124th Ave SE, Auburn, WA 98092",W 36-18
05/06/2017, 1:20 PM,"",12:50 PM,SYB May Breakaway vs. Northside Swarm 5 Saffold,Auburn Mountview High School,"28900 124th Ave SE, Auburn, WA 98092",W 29-20
05/07/2017,11:10 AM,"",10:40 AM,SYB May Breakaway vs. Purple Haze,Auburn Mountview High School,"28900 124th Ave SE, Auburn, WA 98092",W 28-8
05/07/2017, 1:20 PM,"",12:50 PM,syb may breakaway vs. Swish Black,Auburn Mountview High School,"28900 124th Ave SE, Auburn, WA 98092",L 18-21
05/08/2017, 6:00 PM, 7:30 PM, 6:00 PM,Training,Pine Lake Middle School,"3200 228th Ave SE, Sammamish, WA 98075",
05/11/2017, 7:30 PM, 9:00 PM, 7:30 PM,Training,Redmond High School,"17272 NE 104th St, Redmond, WA 98052",
05/12/2017, 6:00 PM,"", 5:30 PM,Best of the West vs. NBC Hericanes Spokane,West Valley High School Freshman Campus,"9206 Zier Road, Yakima WA 98908",L 16-35
05/13/2017, 9:00 AM,"", 9:00 AM,Best of the West vs. Northwest Heat DT 1,East Valley Central,"2010 Beaudry Rd, Yakima WA 98901",W 32-24
05/13/2017, 1:00 PM,"", 1:00 PM,Best of the West vs. Northwest Magic Elite-Puyallup,Terrace Heights Elementary,"101 N 41st St, Yakima, WA 98901",L 20-21
05/13/2017, 7:30 PM,"", 7:30 PM,Team dinner,Russillo's Pizza and Gelato,"32 N Front St #102, Yakima, WA 98901",
05/14/2017, 9:00 AM,"", 8:30 AM,Best of the West vs. Free Spirit,Davis High School,"212 south 6th Ave, Yakima WA 98902",L 34-35
05/14/2017, 1:00 PM,"",12:30 PM,vs. Purple Haze,Lewis Clark Middle School,"1114 w Pierce, Yakima WA",W 41-32
05/14/2017, 3:40 PM,"", 3:40 PM,vs. Nw Stars Lake Osewago,Lewis Clark Middle School,"1114 w Pierce, Yakima WA",W 33-32
05/15/2017, 6:00 PM, 7:30 PM, 6:00 PM,Training,Pine Lake Middle School,"3200 228th Ave SE, Sammamish, WA 98075",
05/18/2017, 7:30 PM, 9:00 PM, 7:30 PM,Training,Redmond High School,"17272 NE 104th St, Redmond, WA 98052",
05/20/2017,12:15 PM,"",11:45 AM,NWA Tournament of Champions vs. Ballard,Mt Si High School,"8651 Meadowbrook Way SE, Snoqualmie, WA 98065",W 53-8
05/20/2017, 4:35 PM,"", 4:05 PM,NWA Tournament of Champions vs. Swish Black,Mt Si High School,"8651 Meadowbrook Way SE, Snoqualmie, WA 98065",W 29-26
05/21/2017, 1:20 PM,"", 1:20 PM,NWA Tournament of Champions vs. Local Hoops,Mt Si High School,"8651 Meadowbrook Way SE, Snoqualmie, WA 98065",W 26-19
05/21/2017, 3:30 PM,"", 3:30 PM,vs. Swish Black,Mt Si High School,"8651 Meadowbrook Way SE, Snoqualmie, WA 98065",W 27-26
05/22/2017, 6:00 PM, 7:30 PM, 6:00 PM,Training,Pine Lake Middle School,"3200 228th Ave SE, Sammamish, WA 98075",
05/25/2017, 7:30 PM, 9:00 PM, 7:30 PM,Training,Redmond High School,"17272 NE 104th St, Redmond, WA 98052",
06/01/2017, 7:30 PM, 9:00 PM, 7:30 PM,Training,Redmond High School,"17272 NE 104th St, Redmond, WA 98052",
06/03/2017, 9:00 AM,"", 8:30 AM,NWA Summer Slam vs. Swish Black,Auburn High School,"702 4th Street Northeast, Auburn, WA",L 22-31
06/03/2017,11:10 AM,"",10:40 AM,NWA Summer Slam vs. QuickHandle,Auburn High School,"702 4th Street Northeast, Auburn, WA",W 37-9
06/04/2017,10:05 AM,"", 9:35 AM,NWA Summer Slam vs. EBC 5,Auburn High School,"702 4th Street Northeast, Auburn, WA",W 28-12
06/04/2017,12:15 PM,"",12:15 PM,NWA Summer Slam vs. Local Hoops,Auburn High School,"702 4th Street Northeast, Auburn, WA",W 41-16
06/08/2017, 7:30 PM, 9:00 PM, 7:30 PM,Training,Redmond High School,"17272 NE 104th St, Redmond, WA 98052",
06/10/2017, 9:00 AM,"", 9:00 AM,Swishfest vs. Arch Rivals,Lake Washington High School,12033 NE 80th St Kirkland 98033,W 36-2
06/10/2017,11:20 AM,"",10:50 AM,Swish fest vs. Northwest Heat DT 1,Lake Washington High School,12033 NE 80th St Kirkland 98033,L 28-39
06/11/2017, 9:00 AM,"", 8:30 AM,Swishfest vs. Friends Of Hoops,Pacific Courts Newcastle,"7003 132nd Pl SE, Newcastle, WA 98059",L 25-27 (OT)
06/11/2017,11:00 AM,"",11:00 AM,End of Season team BBQ,Rowen's house,"16938 81st ave ne, kenmore wa 98028",
06/11/2017, 4:00 PM,"", 3:30 PM,vs. AthElite,Lake Washington High School,12033 NE 80th St Kirkland 98033,W 49-14''';

  static const String FUSION_2018 =
      '''03/27/2018, 7:00 PM, 9:00 PM, 7:00 PM,Team Practice,Issaquah Middle School,"",
03/28/2018, 7:30 PM, 9:00 PM, 7:30 PM,Team Practice / Workout,Issaquah Middle School,"",
03/29/2018, 7:30 PM, 9:00 PM, 7:30 PM,Team Practice,Issaquah Middle School,"",
04/04/2018, 7:30 PM, 9:00 PM, 7:30 PM,Team practice,Issaquah Middle School,"",
04/05/2018, 7:30 PM, 9:00 PM, 7:30 PM,Team Practice,Issaquah Middle School,"",
04/12/2018, 7:30 PM, 9:00 PM, 7:30 PM,Training,Redmond High School,"",
04/17/2018, 7:30 PM, 9:00 PM, 7:30 PM,Open training,Issaquah Middle School,"",
04/18/2018, 7:30 PM, 9:00 PM, 7:30 PM,Team Practice,Issaquah Middle School,"",
04/19/2018, 7:30 PM, 9:00 PM, 7:30 PM,Training,Redmond High School,"",
04/21/2018,10:05 AM,"", 9:35 AM,WTA vs. AthElite U12,Mill Creek Middle school,"620 Central Ave, Kent Wa, 98030",
04/21/2018,12:15 PM,"",11:45 AM,WTA vs. TBD,Mill Creek Middle school,"620 Central Ave, Kent Wa, 98030",
04/22/2018,12:00 AM,"",11:30 PM,Tournament vs. TBD,TBD,"",
04/24/2018, 7:30 PM, 9:00 PM, 7:30 PM,Open Training,Pine lake Middle School,"",
04/25/2018, 7:30 PM, 9:00 PM, 7:30 PM,Team Practice,Issaquah Middle School,"",
04/26/2018, 7:30 PM, 9:00 PM, 7:30 PM,Training,Redmond High School,"",
05/01/2018, 7:30 PM, 9:00 PM, 7:30 PM,Open Training,Issaquah Middle School,"",
05/02/2018, 7:30 PM, 9:00 PM, 7:30 PM,Team Practice,Issaquah Middle School,"",
05/03/2018, 7:30 PM, 9:00 PM, 7:30 PM,Training,Redmond High School,"",
05/05/2018,12:00 AM,"",11:30 PM,NW All Stars/ Local vs. TBD,TBD,"",
05/06/2018,12:00 AM,"",11:30 PM,Tournament vs. TBD,TBD,"",
05/08/2018, 7:30 PM, 9:00 PM, 7:30 PM,Open training,Issaquah Middle School,"",
05/09/2018, 7:30 PM, 9:00 PM, 7:30 PM,Team Practice,Issaquah Middle School,"",
05/10/2018, 7:30 PM, 9:00 PM, 7:30 PM,Training,Redmond High School,"",
05/11/2018,12:00 AM,"",11:30 PM,Yakima Best of West vs. TBD,Yakima,"",
05/12/2018,12:00 AM,"",11:30 PM,Yakima Best of the West vs. TBD,Yakima,"",
05/13/2018,12:00 AM,"",11:30 PM,Tournament vs. TBD,Yakima,"",
05/15/2018, 7:30 PM, 9:00 PM, 7:30 PM,Open training,Issaquah Middle School,"",
05/16/2018, 7:30 PM, 9:00 PM, 7:30 PM,Team Practice,Issaquah Middle School,"",
05/17/2018, 7:30 PM, 9:00 PM, 7:30 PM,Training,Redmond High School,"",
05/19/2018,12:00 AM,"",11:30 PM,NW All Stars Tournament vs. TBD,TBD,"",
05/20/2018,12:00 AM,"",11:30 PM,Tournament vs. TBD,TBD,"",
05/22/2018, 7:30 PM, 9:00 PM, 7:30 PM,Open training,Issaquah Middle School,"",
05/23/2018, 7:30 PM, 9:00 PM, 7:30 PM,Team Practice,Issaquah Middle School,"",
05/24/2018, 7:30 PM, 9:00 PM, 7:30 PM,Training,Redmond High School,"",
05/26/2018,12:00 AM,"",11:30 PM,WTA Slamma Jamma / Tournament vs. TBD,TBD,"",
05/27/2018,12:00 AM,"",11:30 PM,Tournament vs. TBD,TBD,"",
05/29/2018, 7:30 PM, 9:00 PM, 7:30 PM,Open Training,Issaquah Middle School,"",
05/30/2018, 7:30 PM, 9:00 PM, 7:30 PM,Team Practice,Issaquah High School,"",
05/31/2018, 7:30 PM, 9:00 PM, 7:30 PM,Training,Redmond High School,"",
06/02/2018,12:00 AM,"",11:30 PM,WTA Luau / Tournament vs. TBD,TBD,"",
06/03/2018,12:00 AM,"",11:30 PM,Tournament vs. TBD,TBD,"",
06/04/2018, 7:00 PM, 9:00 PM, 7:00 PM,Team Training / Practice,Issaquah Middle School,"",
06/06/2018, 7:00 PM, 9:00 PM, 7:00 PM,Team Practice,Issaquah High School,"",
06/29/2018,12:00 AM,"",11:30 PM,Oregon City Tournament vs. TBD,Oregon City,"",
06/30/2018,12:00 AM,"",11:30 PM,Oregon City Tournament vs. TBD,Oregon City,"",
07/01/2018,12:00 AM,"",11:30 PM,Oregon City Tournament vs. TBD,Oregon City,"",''';

  static const String CROSSFIRE_2016 =
      '''05/23/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
05/24/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
05/26/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
05/31/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
06/01/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
06/02/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
06/06/2016, 5:30 PM, 7:00 PM, 5:30 PM,Practcie ,Stocker Fields,"27 Pine Avenue, Snohomish, WA 98290",
06/08/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
06/10/2016, 4:00 PM,"", 4:00 PM,vs. Crossfire G12B,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",L 1-2
06/13/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
06/14/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
06/16/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
06/18/2016, 9:30 AM,10:35 AM, 8:45 AM,at NSGSC 06 Setterlund,Stocker Fields,"27 Pine Avenue, Snohomish, WA 98290",W 7-1
06/18/2016, 2:45 PM, 3:50 PM, 2:10 PM,at NSGSC 06 Berry,Stocker Fields,"27 Pine Avenue, Snohomish, WA 98290",W 6-0
06/19/2016,10:45 AM,11:50 AM,10:10 AM,vs. GS Surf G06-A,Stocker Fields,"27 Pine Avenue, Snohomish, WA 98290",W 4-2
06/19/2016, 2:45 PM, 3:50 PM, 2:10 PM,FINAL TBD vs. TBD,Stocker Fields,"27 Pine Avenue, Snohomish, WA 98290",W 6-1
06/21/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
06/22/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
06/23/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
06/27/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
06/28/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
06/29/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
06/30/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
07/05/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
07/06/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training,Redmond High School,17272 NE 104th St  Redmond WA 98052,
07/07/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
07/11/2016, 7:00 PM, 8:15 PM, 7:00 PM,Training,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
07/12/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
07/13/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
07/15/2016, 6:45 PM, 7:40 PM, 6:00 PM,at Seattle United Tango,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",W 1-0
07/16/2016, 9:10 AM,10:05 AM, 8:25 AM,vs. WPFC G06 Black A,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",L 1-3
07/17/2016, 9:30 AM,10:25 AM, 8:45 AM,vs. San Diego Surf EGSL Academy 2006,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",L 0-3
07/17/2016, 6:20 PM, 7:15 PM, 5:35 PM,Semi-Finals vs. Crossfire Challenge TBD,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
07/18/2016,11:15 AM,12:10 PM,10:30 AM,Finals vs. Crossfire Challenge TBD,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
07/20/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
07/21/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
07/26/2016, 5:30 PM, 7:00 PM, 5:30 PM,Practice,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
07/27/2016, 5:30 PM, 7:00 PM, 5:30 PM,vs. Practice,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
07/28/2016, 5:30 PM, 7:00 PM, 5:30 PM,Practcie,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/01/2016, 5:30 PM, 7:00 PM, 5:30 PM,Practice with Coach Lindsay,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/02/2016, 4:00 PM, 5:30 PM, 4:00 PM,Practice with Coach Alex,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/03/2016, 4:00 PM, 5:30 PM, 4:00 PM,Practice with Coach Alex,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/06/2016, 8:00 AM, 8:55 AM, 7:15 AM,at Strikers FC OC EGSL,OC (SoCal Sports Complex),"3300 El Corazon Drive Oceanside, CA 92056-2691",L 0-6
08/06/2016,12:40 PM, 1:35 PM,11:55 AM,vs. San Juan SC Spirits 06 Blue,OC (SoCal Sports Complex),"3300 El Corazon Drive Oceanside, CA 92056-2691",L 0-4
08/07/2016, 8:00 AM, 8:55 AM, 7:15 AM,vs. LAGSB 2006 Elite 1,OC (SoCal Sports Complex),"3300 El Corazon Drive Oceanside, CA 92056-2691",L 0-5
08/09/2016, 5:30 PM, 7:00 PM, 5:30 PM,Practice,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
08/10/2016, 5:30 PM, 7:00 PM, 5:30 PM,Practice,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
08/12/2016, 9:00 AM, 9:55 AM, 8:15 AM,vs. Crossfire G05C,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",L 0-2
08/13/2016, 9:15 AM,10:10 AM, 8:30 AM,vs. NSC 05 White - Reign,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",W 9-0
08/13/2016, 6:45 PM, 7:40 PM, 6:15 PM,vs. MIFC JEDI,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",W 3-0
08/14/2016, 9:45 AM,10:40 AM, 9:10 AM,Semi-Finals at Crossfire G05C,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",L 0-1
08/14/2016, 2:15 PM, 3:10 PM, 1:30 PM,Finals vs. Redapt Cup TBD,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/16/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (wear white),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/17/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (wear black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/18/2016, 5:30 PM,"", 5:30 PM,Training (wear white),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/20/2016, 8:00 AM, 8:55 AM, 7:25 AM,at Westside Timbers WT 06G Copa TS,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",T 1-1
08/20/2016, 2:00 PM, 2:55 PM, 1:15 PM,at Tulatin Hill United SC Hydrogen,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",W 3-0
08/21/2016,12:30 PM, 1:25 PM,11:45 AM,at Spokane Sounders G'06,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",L 1-3
08/23/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (wear white),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/24/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (wear black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/25/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear white),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
08/29/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (wear white),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/30/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (wear black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
08/31/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (wear white),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/01/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
09/06/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (wear white),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/07/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (wear black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/10/2016, 2:30 PM, 3:25 PM, 1:45 PM,at Seattle United G06 Copa A,Jefferson Playfield,4165 16th Ave South Seattle 98108,W 1-0
09/11/2016,10:00 AM,"", 9:15 AM,at FWFC G06 Blue (A),Karl Grosch,2620 South 312th St Federal Way 98003,W 1-0
09/13/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training ( Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/14/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/15/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training ( Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/17/2016,12:45 PM, 1:50 PM,12:00 PM,at Eastside FC G06 Red A,Preston Park,30634 SE 87th Place Issaquah 98027,L 0-4
09/19/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training ( Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
09/20/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/21/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/24/2016,12:00 PM, 1:05 PM,11:15 AM,at PacNW G06 Maroon A,Starfire Complex,"14800 Starfire Way  Tukwila, WA  98188-8502",W 4-1
09/26/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
09/26/2016, 6:00 PM, 7:00 PM, 6:00 PM,FORCE 10 TRAINING (free trail class),Force 10,17935 NE 65th St Redmond,
09/27/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/28/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
09/29/2016, 5:30 PM, 6:50 PM, 5:30 PM,Training (Wear Black),60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
10/01/2016, 8:00 AM, 8:55 AM, 7:25 AM,at NEU PDX,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",W 4-1
10/01/2016, 2:00 PM, 2:55 PM, 1:25 PM,at FC PDX,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",W 4-0
10/02/2016, 9:30 AM,10:25 AM, 8:55 AM,at ISC Gunners,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",W 3-2
10/04/2016, 5:30 PM,"", 4:55 PM,vs. GS Surf G06-A,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",W 3-0
10/05/2016, 5:15 PM, 6:45 PM, 5:15 PM,Training,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
10/06/2016, 5:15 PM, 6:45 PM, 5:15 PM,Training,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",
10/10/2016, 6:00 PM, 7:00 PM, 6:00 PM,Force 10 (Wear White),Force 10,17935 NE 65th St Redmond,
10/11/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
10/12/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
10/13/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
10/17/2016, 6:00 PM, 7:00 PM, 6:00 PM,Force 10 (Wear White),Force 10,17935 NE 65th St Redmond,
10/18/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
10/19/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
10/20/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
10/22/2016, 1:00 PM, 1:55 PM,12:15 PM,at GS Surf G06-A,Ballinger Playfield,"23000 Lakeview Dr  Mountlake Terrace, WA  98043-2312",W 3-0
10/23/2016,10:30 AM,11:25 AM, 9:45 AM,vs. Seattle United G06 Copa A,60 Acres,"Sammamish River Regional Park, 15200 NE 116th St, Redmond, WA 98052",W 2-0
10/24/2016, 6:00 PM, 7:00 PM, 6:00 PM,Force 10 (Wear White),Force 10,17935 NE 65th St Redmond,
10/25/2016, 5:45 PM, 7:00 PM, 5:45 PM,Training Opitional,Hartman,,
10/26/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
10/27/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
11/01/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training- Wear White,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/02/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training-Wear Black,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
11/03/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training-Wear White,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
11/04/2016, 5:30 PM, 6:35 PM, 4:45 PM,vs. Eastside FC G06 Red A,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",W 5-3
11/05/2016, 3:00 PM, 4:00 PM, 2:20 PM,vs. FWFC G06 Blue (A),Redmond High School,17272 NE 104th St  Redmond WA 98052,W 3-0
11/07/2016, 6:00 PM, 7:00 PM, 6:00 PM,Force 10- Wear White,Force 10,17935 NE 65th St Redmond,
11/08/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training-Wear Black,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/09/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training-Wear White,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
11/10/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training-Wear Black,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/12/2016,11:00 AM,12:05 PM,10:15 AM,vs. PacNW G06 Maroon A,Redmond High School,,W 3-1
11/13/2016, 9:00 AM,10:05 AM, 8:15 AM,vs. WPFC G06 Black A,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",T 3-3
11/14/2016, 6:00 PM, 7:00 PM, 6:00 PM,Force 10 Wear White,Force 10,17935 NE 65th St Redmond,
11/15/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training Wear Black,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/16/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training Wear White,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
11/17/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training Wear Black,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/19/2016, 9:00 AM,10:05 AM, 8:15 AM,at WPFC G06 Black A,WPFC Soccer Complex,"5702 44th St E  Puyallup, WA  98371-3601",W 1-0
11/21/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training Wear White,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
11/22/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training Wear Black,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/25/2016, 8:00 AM,"", 7:15 AM,at Eagles SC,4S Ranch Sports Complex,16118 4S Ranch Pkwy San Diego CA 92127,L 0-2
11/25/2016, 5:20 PM,"", 4:35 PM,at San Diego Surf,4S Ranch Sports Complex,16118 4S Ranch Pkwy San Diego CA 92127,L 0-8
11/26/2016, 8:00 AM,"", 7:15 AM,vs. Colorado Storm South Academy,4S Ranch Sports Complex,16118 4S Ranch Pkwy San Diego CA 92127,
11/27/2016,10:20 AM,"",10:20 AM,vs. Thanksgiving Surf TBD,Polo Fields,3885 Via De La Valle Del Mar CA 92014,
11/28/2016, 6:00 PM, 7:00 PM, 6:00 PM,Force 10 Wear White,Force 10,17935 NE 65th St Redmond,
11/29/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training Wear Black,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
11/30/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training Wear White,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
12/01/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training Wear Black,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
12/05/2016, 6:00 PM, 7:00 PM, 6:00 PM,Force 10 (Wear White),Force 10,17935 NE 65th St Redmond,
12/06/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
12/07/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
12/08/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
12/12/2016, 4:30 PM, 6:00 PM, 4:30 PM,Training (Wear White),Hartman,,
12/13/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
12/14/2016, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
12/15/2016, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
01/02/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Hartman,,
01/03/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Hartman,,
01/04/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Hartman,,
01/05/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Hartman,,
01/09/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Hartman,,
01/10/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Hartman,,
01/11/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Hartman,,
01/17/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Hartman,,
01/18/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Hartman,,
01/19/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Hartman,,
01/21/2017, 4:00 PM,"", 3:20 PM,vs. Eastside White,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",W 6-0
01/23/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
01/24/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Hartman,,
01/25/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),Hartman,,
01/26/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Hartman,,
01/30/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Hartman,,
01/31/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black) Notice change of Location,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
02/02/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear white),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/04/2017,12:00 PM,"",11:20 AM,at WPFC G06 Black A,WPFC Soccer Complex,"5702 44th St E  Puyallup, WA  98371-3601",W 2-0
02/06/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
02/07/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/08/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
02/09/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
02/11/2017, 2:00 PM,"", 1:20 PM,vs. FWFC G06 Blue (A),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",T 0-0
02/13/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
02/14/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/15/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
02/16/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/20/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
02/21/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/22/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
02/23/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/27/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
02/28/2017, 4:00 PM, 5:00 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/01/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/02/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/03/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/04/2017, 3:15 PM,"", 2:35 PM,at Seattle United Tango,Van Asselt Elementary,,T 0-0
03/06/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/07/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training(Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/09/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/11/2017, 3:30 PM,"", 2:50 PM,vs. Eastside FC G06 Red A,Redmond High School,,L 1-3
03/12/2017,12:30 PM,"",11:50 AM,at Seattle United G06 Copa A,Van Asselt Elementary,,T 1-1
03/13/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/15/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/16/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear white),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/20/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/21/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/22/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/23/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/26/2017,12:00 PM,"",11:20 AM,at Blackhills FC,Tumwater High School,700 Israel Rd SW Tumwater WA 98501,W 6-0
03/27/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/28/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/29/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
03/30/2017, 4:00 PM, 5:15 PM, 4:00 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/01/2017, 2:30 PM,"", 1:50 PM,vs. FWFC G06 Blue (A),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",W 1-0
04/02/2017,11:00 AM,"",10:20 AM,vs. Eastside White,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",W 2-1
04/04/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/05/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/06/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/08/2017, 3:00 PM,"", 2:15 PM,vs. Seattle United Tango,Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",W 3-1
04/10/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/11/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/12/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
04/13/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/17/2017, 5:30 PM, 7:15 PM, 5:30 PM,Training (Wear White),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/18/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (Wear Black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",
04/19/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training (Wear Black),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
04/20/2017, 4:00 PM, 5:30 PM, 4:00 PM,Training,Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
04/22/2017, 4:45 PM,"", 4:00 PM,vs. Seattle United G06 Copa A,Starfire Complex,"14800 Starfire Way  Tukwila, WA  98188-8502",L 1-5
04/24/2017, 5:00 PM, 6:00 PM, 5:00 PM,Training (Wear White),Grasslawn,"7031 148th Ave NE, Redmond, WA 98052",
04/25/2017, 5:30 PM, 7:00 PM, 5:30 PM,Training (wear black),Marymoor Park,"6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052",''';

  static PlaceResult makePlaceResult(Map<String, dynamic> data) {
    PlaceResult tmp = new PlaceResult.created(new JsObject.jsify(data));
    tmp.geometry.location = new LatLng(data['geometry']['location']['lat'] as num, data['geometry']['location']['lng'] as num);
    return tmp;
  }

  static Map<String, PlaceResult> getDefaultPlaceResult() {
    Map<String, PlaceResult> ret = {};

    PlaceResult tmp = makePlaceResult({
      "formatted_address": "17272 NE 104th St, Redmond, WA 98052, USA",
      "geometry": {
        "location": {"lat": 47.6944972, "lng": -122.1080377},
        "viewport": {
          "northeast": {"lat": 47.69530339999999, "lng": -122.1066935201073},
          "southwest": {"lat": 47.69207859999999, "lng": -122.1093931798928}
        }
      },
      "icon": "https://maps.gstatic.com/mapfiles/place_api/icons/school-71.png",
      "id": "f4ba97557828921b725f0912adce82ed3464bbcb",
      "name": "Redmond High School",
      "opening_hours": {"open_now": true, "weekday_text": []},
      "photos": [
        {
          "height": 2448,
          "html_attributions": [
            "\u003ca href=\"https://maps.google.com/maps/contrib/118021247954479199504/photos\"\u003eJane Lu\u003c/a\u003e"
          ],
          "photo_reference":
              "CmRaAAAASi_S9o84W-XgaQEW-pTP2x89edkbrBy8kPtdN-tHS2u9ky-Ld0h6qOFHwU9Y4qrKHPK2fdQ3r62GLh3hSgpEXtgBfDxYAwgIxj68B_iFwZ5_6hI_Nd-rf66JgnwOXFXfEhCAYD_0mp_zS8UuSiJtksutGhQH0xoJwWJ1rQ_N3HW5N6BbZF7kzQ",
          "width": 3264
        }
      ],
      "place_id": "ChIJp_scjy8NkFQRxe64OeVm5cs",
      "rating": 4,
      "reference":
          "CmRbAAAAZmyuCo9hhIiLgXRxinPi6CVuo4NOzPqXJRoCMSGdmO5qoNvbpVkaszWqeTOJmweKG48bpwHknGhQX49lWUzxnOtGhDcaE97b5auEAL-hqrC71Q8TP8Ue4ozglca-IsofEhC_EJP9Z695Cu2FeMzxVDRkGhTFwjj3VvBKTbPpaqFh050P8grgSQ",
      "types": ["school", "point_of_interest", "establishment"]
    });

    ret["redmond high school"] = tmp;

    tmp = makePlaceResult({
      "formatted_address" : "600 2nd Ave SE, Issaquah, WA 98027, USA",
      "geometry" : {
        "location" : {
          "lat" : 47.52463059999999,
          "lng" : -122.0287266
        },
        "viewport" : {
          "northeast" : {
            "lat" : 47.52598042989272,
            "lng" : -122.0273767701073
          },
          "southwest" : {
            "lat" : 47.52328077010727,
            "lng" : -122.0300764298928
          }
        }
      },
      "icon" : "https://maps.gstatic.com/mapfiles/place_api/icons/school-71.png",
      "id" : "0ab7d3d27aa4da01ac76525e0f24cab13dd92e81",
      "name" : "Issaquah Middle School",
      "photos" : [
        {
          "height" : 1836,
          "html_attributions" : [
            "\u003ca href=\"https://maps.google.com/maps/contrib/112067525194772510403/photos\"\u003eAlmondFace\u003c/a\u003e"
          ],
          "photo_reference" : "CmRaAAAAhA7fPYfEwhnVWFulaO86fxaE0zIk4FY9iAVHwZs9dIXssZEcN_J6W71C0rGlSXcZmseur94BrAvI0hSjBnvrdls9ZgyOjAG6uE2Clw_Fiq9wKw4SyYsLjkChkxcoyL6VEhDdCDo3f6Olz_GVKxQUxHb5GhRHKgl9k60JN0fpPxJ256O5rkwq7g",
          "width" : 3264
        }
      ],
      "place_id" : "ChIJZ6JW8oFlkFQR5MbmrRuWWmI",
      "rating" : 2.7,
      "reference" : "CmRbAAAAbbKlYJ6Wjfv8rMaruJx4GjZAyOcXHo_ZxJ2a4KRjNyWuWY3NVSFfJoWd6ZqQ7PLn0eljdssuqoSmpmFrYgmWTuOooNmxxqjQNYTnvO-KdJWZBn79GwfXgpMl6M_mozeCEhD17kBBqSFDNGKQox-XWjG7GhTNJwdcPhb9_UnroRYIfI7PBvXyFQ",
      "types" : [ "school", "point_of_interest", "establishment" ]
    });

    ret["issaquah middle school"] = tmp;

    tmp = makePlaceResult({
      "formatted_address" : "6046 West Lake Sammamish Pkwy NE, Redmond, WA 98052, USA",
      "geometry" : {
        "location" : {
          "lat" : 47.6617093,
          "lng" : -122.1214992
        },
        "viewport" : {
          "northeast" : {
            "lat" : 47.66305912989273,
            "lng" : -122.1201493701072
          },
          "southwest" : {
            "lat" : 47.66035947010729,
            "lng" : -122.1228490298927
          }
        }
      },
      "icon" : "https://maps.gstatic.com/mapfiles/place_api/icons/generic_recreational-71.png",
      "id" : "28d3b67202cfb71a7cc7c3f4740813e6f3ad9643",
      "name" : "Marymoor Park",
      "photos" : [
        {
          "height" : 2340,
          "html_attributions" : [
            "\u003ca href=\"https://maps.google.com/maps/contrib/109025050233410210310/photos\"\u003eAndrew Norris\u003c/a\u003e"
          ],
          "photo_reference" : "CmRaAAAAEfLjWDQ2sMz6aG-cY_u0bEYvOPmd1h43IOFhm4hZbi6McB2ejhUkPwfJJUJ4TqKNQsZZlpTxd4MjLSDactq1MWMcnIjCJFvIeI6jmTwFdDyNlPLBPZKQmMs2DlZW1pUZEhAUtDMef3H_z4pntm4JWcWfGhTn7UBiMedgRaGZ3I_RBwdVL0F_lQ",
          "width" : 4160
        }
      ],
      "place_id" : "ChIJ0fWNvq9ykFQRHWk-yNgbKgo",
      "rating" : 4.7,
      "reference" : "CmRbAAAAGgsiIM3fHEpM69M1tq54GPGXZo_ULdiZk7BaW8gsAK7rmfVahVUngAQKoPWlQduci0X-1e5f_d700082Rx-ii6LlK2vik7tKzRWeJjAkETPLrvKaAZvRwFYKZDZ6Uh30EhBd6UT9cKBPI_rJDdkEHwpmGhQqSJCwINjkODbIu6Y0lamY7f2iZw",
      "types" : [ "park", "point_of_interest", "establishment" ]
    });

    ret["marymoor park"] = tmp;
    tmp = makePlaceResult({
      "formatted_address" : "7031 148th Ave NE, Redmond, WA 98052, USA",
      "geometry" : {
        "location" : {
          "lat" : 47.66835340000001,
          "lng" : -122.1457814
        },
        "viewport" : {
          "northeast" : {
            "lat" : 47.66969767989273,
            "lng" : -122.1418655
          },
          "southwest" : {
            "lat" : 47.66699802010728,
            "lng" : -122.1470867
          }
        }
      },
      "icon" : "https://maps.gstatic.com/mapfiles/place_api/icons/generic_recreational-71.png",
      "id" : "74312c1ecb4a2178327cc3cd1ce21085c3a2a227",
      "name" : "Grass Lawn Park",
      "opening_hours" : {
        "open_now" : true,
        "weekday_text" : []
      },
      "photos" : [
        {
          "height" : 3456,
          "html_attributions" : [
            "\u003ca href=\"https://maps.google.com/maps/contrib/101447113087746267170/photos\"\u003eWilliam Wynn\u003c/a\u003e"
          ],
          "photo_reference" : "CmRaAAAAlzWRrfBWdl8ebBjDEC54H2omfA-P82M_l0VAnEu5GkvLT2WnS_sJGyURMOVL7upuugrDRbR2Fg_L1dEM8vD7BSRslNyLbJnHYML0OKf4RMQlsb4hUfO05jIGcY3oKmfSEhC9zghD2_xvjZQV1U071UZaGhTOcl2VML301sFWe4FKCkMW3ie_pA",
          "width" : 4608
        }
      ],
      "place_id" : "ChIJz5Tea1RtkFQRKf5kSQ9qxzQ",
      "rating" : 4.7,
      "reference" : "CmRbAAAAqsIdV-zfBoSl1271nP4WhzBXDwSCntBkXpe8com7jUQwzNMDIZ5EY7ZHhWOe038SrjPZki12umCXoHhdYZpAHUITNseQOpGVh-0LdDYOGNyHBX4_2aa122cQTtWG1T64EhDjxtJDtoUegfzFGs_kKFxCGhRZAK2Z87r6OEdxYrvgCfBXf5lIZQ",
      "types" : [ "park", "point_of_interest", "establishment" ]
    });
    ret["grasslawn"] = tmp;

    tmp = makePlaceResult({
      "formatted_address" : "3200 228th Ave SE, Sammamish, WA 98075, USA",
      "geometry" : {
        "location" : {
          "lat" : 47.581255,
          "lng" : -122.0331577
        },
        "viewport" : {
          "northeast" : {
            "lat" : 47.58259197989273,
            "lng" : -122.03198675
          },
          "southwest" : {
            "lat" : 47.57989232010728,
            "lng" : -122.03667055
          }
        }
      },
      "icon" : "https://maps.gstatic.com/mapfiles/place_api/icons/school-71.png",
      "id" : "491f62fd2a434d3c0f7bff340eea47a3a2efe5fe",
      "name" : "Pine Lake Middle School",
      "photos" : [
        {
          "height" : 1944,
          "html_attributions" : [
            "\u003ca href=\"https://maps.google.com/maps/contrib/111363821853168072591/photos\"\u003eMayukha G\u003c/a\u003e"
          ],
          "photo_reference" : "CmRaAAAArixWwJUYkgLjtP2VRgeZ2yqrqqNOhH3GZJa6trKX4a7NZE4GK4IhFsKGUJr6Htv3YY41-JyFADxCFW-OEmNRhTcCbCni6twV2QG11rPnoXEC00aEZUULYmBYyE7-VHjYEhBR4qhZHMxHQHjPFIcfdUW5GhRTdFMkYgdNE3smJK3d_ZYk73139w",
          "width" : 2592
        }
      ],
      "place_id" : "ChIJK9CTiytukFQRXmHYhQiaGmM",
      "rating" : 3.6,
      "reference" : "CmRbAAAAFAGfKhvRcwIkpaU18uCf2cfaEwAC0e8zFXXvAqqnS_pjLfYWV7U6hnL5cBNwRhWmL3sztvezFtT5ddMqoaUXA0yqqQ5Ad4rpyqrlf5YRF2IEVqT21XMdKyWwD7pLH6LEEhDSnBnSJHkkpN-UShAKOsKFGhSphEhVTHUOZnZZ2MaHr17GnqI3BA",
      "types" : [ "school", "point_of_interest", "establishment" ]
    });

    ret["pine lake middle school"] = tmp;

    return ret;
  }
}
