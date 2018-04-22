import React from 'react';
import MyPicker from './MyPicker';
import moment from 'moment-timezone';

export default timeZonePicker = (props) => {
  const { title, input, enabled, ...inputProps } = props;

  if (enabled) {
    optionList = [];
    moment.tz.names().forEach((zoneName) => {
      zone = moment.tz(zoneName);
      console.log('zone', zone.zoneName(), zone._z.offsets);
      // Create it in the format +8: name.
      name = (zone._z.offsets[0] / 60) + ': ' + zoneName;
      data = {
        title: name,
        key: zoneName,
        offset: zone._z.offsets[0]
      }
      optionList.push(data);
    });
    optionList.sort((a, b) => { return a.offset - b.offset});
  } else {
    zone = moment.tz.zone(input.value);
    if (zone != null) {
      if (zone.abbrs.length > 0) {
        zoneName = zone.abbrs[0];
      }
      console.log('zone', zone, zone.abbrs.length, zoneName);
    } else {
      zoneName = input.value;
    }
    optionList = [ { title: zoneName, key: input.value }];
  }

  return <MyPicker title={title} options={optionList} input={input} enabled={enabled} {...inputProps} />
}
