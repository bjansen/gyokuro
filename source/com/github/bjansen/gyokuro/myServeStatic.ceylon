import ceylon.file {
    Path,
    File,
    parsePath
}
import ceylon.io {
    newOpenFile,
    OpenFile
}
import ceylon.io.buffer {
    ByteBuffer,
    newByteBuffer
}
import ceylon.net.http {
    contentType,
    contentLength,
    Header
}
import ceylon.net.http.server {
    Response,
    Request,
    ServerException
}
import ceylon.net.http.server.endpoints {
    Options
}

"Endpoint for serving static files."
by("Matej Lazar")
shared void myServeStaticFile(
    "Root directory containing files."
    String externalPath, 
    String fileMapper(Request request) => request.path,
    Options options = Options(),
    Anything(Request)? onSuccess = null,
    Anything(ServerException,Request)? onError = null)
(Request request, Response response, void complete()) {
    
    Path filePath = parsePath(externalPath + fileMapper(request));
    if (is File file = filePath.resource) {
        //TODO log
        //print("Serving file: ``filePath.absolutePath.string``");
        
        variable value available = file.size;
        response.addHeader(contentLength(available.string));
        response.addHeader(Header("Cache-Control", "max-age=0, must-revalidate"));
        response.addHeader(Header("ETag", file.lastModifiedMilliseconds.string));

        if (is String cntType = file.contentType) {
            response.addHeader(contentType(cntType));
        }

        if (exists etag = request.header("If-None-Match"), etag == file.lastModifiedMilliseconds.string) {
            response.responseStatus = 304;
        }
        value openFile = newOpenFile(file);
        
        void _onSuccess() {
            openFile.close();
            if (exists onSuccess) {
                onSuccess(request);
            }
            complete();
        }
        
        void _onError(ServerException exception) {
            openFile.close();
            if (exists onError) {
                onError(exception,request);
            }
            complete();
        }
        
        FileWriter(openFile, response, options, _onSuccess, _onError).send();
        
    } else {
        response.responseStatus=404;
        //TODO log
        print("File ``filePath.absolutePath.string`` does not exist.");
    }
}

class FileWriter(
    OpenFile openFile, 
    Response response, 
    Options options, 
    void onSuccess(), 
    void onError(ServerException exception)
) {
    variable value available = openFile.size;
    variable value readFailed = 0;
    value bufferSize = options.outputBufferSize < available 
    then options.outputBufferSize else available;
    ByteBuffer byteBuffer = newByteBuffer(bufferSize);
    
    shared void send() => read();
    
    void read() {
        while (available > 0) {
            try {
                value read = openFile.read(byteBuffer);
                if (read == -1) {
                    available = 0;
                } else if (read == 0) {
                    readFailed ++;
                    if (readFailed > options.readAttempts) {
                        onError(ServerException("Error reading file ``openFile.resource.path``."));
                        return;
                    }
                } else {
                    available -= read;
                    readFailed = 0;
                }
                byteBuffer.flip();

                response.writeByteBuffer(byteBuffer);
                byteBuffer.clear();
            } catch (ServerException e) {
                onError(e);
            }
        }

        onSuccess();
    }
}
