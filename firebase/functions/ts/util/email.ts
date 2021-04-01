export const TEXT_BODY: string = `
Reminder for upcoming game with {{team.name}}, details below:

Arrive At   : {{arrivalTime}}
Start Time  : {{startTime}}
Address     : {{sharedGame.place.address}}
PlaceName   : {{sharedGame.place.name}}
PlaceNotes  : {{sharedGame.place.notes}}
Uniform     : {{game.uniform}}
Notes       : {{game.notes}}

Availability
{{#availability}}
{{#if yes.length}}
YES
{{#yes}}
  {{name}} {{role}}
{{/yes}}
{{else}}
  No one is going
{{/if}}

{{#if no.length}}
NO
{{#no}}
  {{name}} {{role}}
{{/no}}
{{/if}}

{{#if maybe.length}}
MAYBE
{{#maybe}}
  {{name}} {{role}}
{{/maybe}}
{{/if}}
{{/availability}}

To disable these emails, update your user settings to turn off email for upcoming games.

Map: {{directionsUrl}}

http://www.teamsfuses.com/event/{{team.uid}}/{{game.uid}}

---
Sent by TeamsFuse http://www.teamsfuse.com
`;

export const HTML_BODY = `
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
{{#availability}}
{{#if yes.length}}
<b>Yes</b>
<ul>
{{#yes}}
<li>{{name}} <i>{{role}}</i>
{{/yes}}
</ul>
{{else}}
<b>No one is going</b>
{{/if}}
{{#if no.length}}
<b>No</b>
<ul>
{{#no}}
<li>{{name}} <i>{{role}}</i>
{{/no}}
{{/if}}
{{#if maybe.length}}
<b>Maybe</b>
</ol>
{{#maybe}}
<li>{{name}} <i>{{role}}</i>
{{/maybe}}
{{/if}}
{{/availability}}
</ol>

<p>
To disable these emails, update your user settings to turn off email for upcoming games.
<p>
Sent by <a href="http://www.teamsfuse.com"><i>TeamsFuse</i></a>
`;
