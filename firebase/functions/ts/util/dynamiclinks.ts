import urlBuilder from 'build-url-ts';
import * as functions from 'firebase-functions';
import { apiConfig } from './axios';
import axios, { AxiosInstance, AxiosResponse } from 'axios';

const api = axios.create(apiConfig);

interface ShortLinkResponse {
    shortLink: string;
}

function makeDynamicLongLink(subject: string, path: string): string {
    return urlBuilder('https://link.teamsfuse.com/' + path, {
        queryParams: {
            link: 'https://www.teamsfuse.com/main/' + path,
            apn: 'www.teamsfuse.com',
            dfl: 'https://www.teamsfuse.com',
            ibi: 'com.teamfuse.flutterfuse',
            isi: '1374615208',
            st: 'TeamsFuse - Fusing teams together',
            sd: subject,
            si: 'https://stats.whelksoft.com/assets/assets/images/hands_and_trophy.png',
        },
    });
}

async function getShortUrlDynamicLink(url: string, myApi: AxiosInstance): Promise<string> {
    console.log('getShortUrlDynamicLink ' + url);
    const data = (await myApi({
        method: 'post',
        url: `https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=${functions.config().links.key}`,
        data: {
            longDynamicLink: url,
        },
        responseType: 'json',
    })) as AxiosResponse<ShortLinkResponse>;
    return data.data.shortLink;
}

//
// Returns the show link for the specified url.  The extraUrl should just be the path.
//
export async function getShortLink(subject: string, path: string): Promise<string> {
    const longUrl = makeDynamicLongLink(subject, path);
    return getShortUrlDynamicLink(longUrl, api);
}
