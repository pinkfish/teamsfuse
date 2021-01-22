import urlBuilder from 'build-url-ts';
import * as functions from 'firebase-functions';

import { AxiosInstance, AxiosResponse } from 'axios';

interface ShortLinkResponse {
    shortLink: string;
}

export function makeDynamicLongLink(postId: string, inviteSubject: string, extraUrl: string): string {
    return urlBuilder('https://www.teamsfuse.com/' + extraUrl, {
        queryParams: {
            link: 'https://www.teamsfuse.com/' + extraUrl + postId,
            apn: 'www.teamsfuse.com',
            dfl: 'https://www.teamsfuse.com',
            st: 'TeamsFuse - Fusing teams together',
            sd: inviteSubject,
            si: 'https://stats.whelksoft.com/assets/assets/images/hands_and_trophy.png',
        },
    });
}

export async function getShortUrlDynamicLink(url: string, api: AxiosInstance): Promise<string> {
    console.log('getShortUrlDynamicLink ' + url);
    const data = (await api({
        method: 'post',
        url: `https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=${functions.config().links.key}`,
        data: {
            longDynamicLink: url,
        },
        responseType: 'json',
    })) as AxiosResponse<ShortLinkResponse>;
    return data.data.shortLink;
}
