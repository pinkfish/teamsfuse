import * as functions from 'firebase-functions';
import { Storage } from '@google-cloud/storage';
import { spawn } from 'ts-process-promises';
import * as path from 'path';
import * as os from 'os';
import * as fs from 'fs';

const storage = new Storage();

/**
 * When an image is uploaded in the Storage bucket We generate a thumbnail automatically using
 * ImageMagick.
 *
 * FYI!!!! Disabled currently.
 */
export const generateSmallerImage = functions.storage.object().onFinalize(async (object) => {
    const fileBucket = object.bucket; // The Storage bucket that contains the file.
    const filePath = object.name; // File path in the bucket.
    const contentType = object.contentType; // File content type.
    const myMetadata = object.metadata;

    if (filePath === null || filePath === undefined) {
        console.log('No filePath');
        return;
    }

    if (contentType === null || contentType === undefined) {
        console.log('This is not an image.');
        return null;
    }

    // Exit if this is triggered on a file that is not an image.
    if (!contentType.startsWith('image/')) {
        console.log('This is not an image.');
        return null;
    }

    if (myMetadata !== null && myMetadata !== undefined && myMetadata['processed'] !== null) {
        console.log('Already processed.');
    }

    // Get the file name.
    const fileName = path.basename(filePath);
    // Exit if the image is already a thumbnail.
    if (fileName.startsWith('thumb_')) {
        console.log('Already a Thumbnail.');
        return null;
    }

    // Download file from bucket.
    const bucket = storage.bucket(fileBucket);
    const tempFilePath = path.join(os.tmpdir(), fileName);
    const metadata = {
        contentType: contentType,
    };
    await bucket.file(filePath).download({
        destination: tempFilePath,
    });
    console.log('Image downloaded locally to', tempFilePath);
    // Generate a thumbnail using ImageMagick.
    await spawn('convert', [tempFilePath, '-thumbnail', '200x200>', tempFilePath]);

    console.log('Thumbnail created at', tempFilePath);
    // We add a 'thumb_' prefix to thumbnails file name. That's where we'll upload the thumbnail.
    const thumbFileName = `thumb_${fileName}`;
    const thumbFilePath = path.join(path.dirname(filePath), thumbFileName);
    // Uploading the thumbnail.
    await bucket.upload(tempFilePath, {
        destination: thumbFilePath,
        metadata: metadata,
    });

    // Once the thumbnail has been uploaded delete the local file to free up disk space.
    fs.unlinkSync(tempFilePath);
    return;
});
