export const TEXT_BODY: string = `
Reminder for upcoming game with {{team.name}}, details below:

Arrive At   : {{arrivalTime}}{{changedText change.arrival}}
Start Time  : {{startTime}}{{changedText change.startTime}}
Address     : {{sharedGame.place.address}}{{changedText change.place.address}}
PlaceName   : {{sharedGame.place.name}}{{changedText change.place.name}}
PlaceNotes  : {{sharedGame.place.notes}}{{changedText change.place.notes}}
Uniform     : {{game.uniform}}{{changedText change.uniform}}
Notes       : {{game.notes}}{{changedText change.notes}}

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
<td>Arrive At</td><td>{{#changed change.arrival}}{{arrivalTime}}{{/changed}}</td>
</tr>
<tr>
<td>Start Time</td><td>{{#changed change.startTime}}{{startTime}}{{/changed}}</td>
</tr>
<tr>
<td>Address</td><td>{{#changed change.place.address}}<a href="{{directionsUrl}}">{{sharedGame.place.address}}</a>{{/changed}}</td>
</tr>
<tr>
<td>Place Name</td><td>{{#changed change.place.name}}{{sharedGame.place.name}}{{/changed}}</td>
</tr>
<tr>
<td>Place Notes</td><td>{{#changed change.place.notes}}{{sharedGame.place.notes}}{{/changed}}</td>
</tr>
<tr>
<td>Uniform</td><td>{{#changed change.uniform}}{{game.uniform}}{{/changed}}</td>
</tr>
<tr>
<td>Notes</td><td>{{#changed change.notes}}{{game.notes}}{{/changed}}</td>
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
