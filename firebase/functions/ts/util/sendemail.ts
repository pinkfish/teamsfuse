import axios, { AxiosRequestConfig, AxiosResponse } from 'axios';
import * as fs from 'fs';
import { apiConfig } from './axios';

export interface Attachment {
    filename: string;
    path?: string | undefined;
    cid: string;
    content?: string | undefined;
    contentType?: string | undefined;
    encoding?: string | undefined;
}

const api = axios.create(apiConfig);

export async function getImageFromUrl(url: string | undefined, filename: string): Promise<AxiosResponse> {
    if (url !== null && url !== undefined) {
        try {
            const getImageOptions: AxiosRequestConfig = {
                responseType: 'arraybuffer',
            };
            const axiosResponse = await api.get(url, getImageOptions);
            console.log(axiosResponse.status);
            return axiosResponse;
        } catch (e) {
            console.error(e);
        }
    }
    return new Promise(function (resolve, reject) {
        fs.readFile(filename, (err, data) => {
            if (err !== null && err !== undefined) {
                reject(err);
            } else {
                // Only need the data since the headers not being there will default
                // to jpg.
                const response: AxiosResponse = {
                    data: data,
                    status: 200,
                    statusText: 'OK',
                    headers: { 'content-type': filename.endsWith('.png') ? 'image/png' : 'image/jpeg' },
                    config: {},
                };
                resolve(response);
            }
        });
    });
}

export function getContentType(fullBody: AxiosResponse) {
    const contentType = fullBody.headers['content-type'];
    if (contentType === 'application/octet-stream') {
        return 'image/jpeg';
    }
    return contentType;
}
