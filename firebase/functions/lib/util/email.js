'use strict';

exports.TEXT_BODY = `
Reminder for upcoming game with {{team.name}}, details below:

Arrive At   : {{arrivalTime}}
Start Time  : {{startTime}}
Address     : {{sharedGame.place.address}}
PlaceName   : {{sharedGame.place.name}}
PlaceNotes  : {{sharedGame.place.notes}}
Uniform     : {{game.uniform}}
Notes       : {{game.notes}}

Availability
{{textAvailability}}

To disable these emails, update your user settings to turn off email for upcoming games.

Map: {{directionsUrl}}

http://www.teamsfuses.com/event/{{team.uid}}/{{game.uid}}

---
Sent by TeamsFuse http://www.teamsfuse.com
`;

exports.HTML_BODY = `
Reminder for upcoming game with <b>{{team.name}}</b>, details below:

<img src="{{teamPhotoUrl}}" width=100 height=100>

<h4><a href="http://www.teamsfuses.com/event/{{team.uid}}/{{game.uid}}">Details</a></h4>
<table>
<tr>
<td>Arrive At</td><td>{{arrivalTime}}</td>
</tr>
<tr>
<td>Start Time</td><td>{{startTime}}</td>
</tr>
<tr>
<td>Address     </td><td><a href="{{directionsUrl}}">{{sharedGame.place.address}}</a></td>
</tr>
<tr>
<td>PlaceName   </td><td> {{sharedGame.place.name}}</td>
</tr>
<tr>
<td>PlaceNotes  </td><td> {{sharedGame.place.notes}}</td>
</tr>
<tr>
<td>Uniform     </td><td> {{game.uniform}}</td>
</tr>
<tr>
<td>Notes       </td><td> {{game.notes}}</td>
</tr>
</table>

<h4>Availability</h4>
{{htmlAvailability}}

<p>
To disable these emails, update your user settings to turn off email for upcoming games.
<p>
Sent by <a href="http://www.teamsfuse.com"><i>TeamsFuse</i></a>
`;
