package com.aurora.bdg.model;

import android.os.Handler;
import android.os.Looper;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import okhttp3.MediaType;
import okhttp3.RequestBody;
import okio.BufferedSink;

/* JADX INFO: loaded from: classes.dex */
public class ProgressRequestBody extends RequestBody {
    private static final int DEFAULT_BUFFER_SIZE = 2048;
    private File mFile;
    private UploadCallbacks mListener;
    private String mPath;

    public interface UploadCallbacks {
        void onError();

        void onFinish();

        void onProgressUpdate(int i);
    }

    public ProgressRequestBody(File file, UploadCallbacks uploadCallbacks) {
        this.mFile = file;
        this.mListener = uploadCallbacks;
    }

    @Override // okhttp3.RequestBody
    /* JADX INFO: renamed from: contentType */
    public MediaType get$contentType() {
        return MediaType.parse("image/*");
    }

    @Override // okhttp3.RequestBody
    public long contentLength() throws IOException {
        return this.mFile.length();
    }

    @Override // okhttp3.RequestBody
    public void writeTo(BufferedSink bufferedSink) throws IOException {
        long length = this.mFile.length();
        byte[] bArr = new byte[2048];
        FileInputStream fileInputStream = new FileInputStream(this.mFile);
        try {
            Handler handler = new Handler(Looper.getMainLooper());
            long j = 0;
            while (true) {
                int i = fileInputStream.read(bArr);
                if (i != -1) {
                    handler.post(new ProgressUpdater(j, length));
                    j += (long) i;
                    bufferedSink.write(bArr, 0, i);
                } else {
                    fileInputStream.close();
                    return;
                }
            }
        } catch (Throwable th) {
            fileInputStream.close();
            throw th;
        }
    }

    private class ProgressUpdater implements Runnable {
        private long mTotal;
        private long mUploaded;

        public ProgressUpdater(long j, long j2) {
            this.mUploaded = j;
            this.mTotal = j2;
        }

        @Override // java.lang.Runnable
        public void run() {
            ProgressRequestBody.this.mListener.onProgressUpdate((int) ((this.mUploaded * 100) / this.mTotal));
        }
    }
}
