# s3-sidecar
A container downloads a compressed file from S3 and extract the files into a local directory `/data`
which can be a shared volume with other containers

## Installing and Running
You need to set the env variables and run it as contaner, and here are the required variables:

```
    AWS_ACCESS_KEY_ID: 'access key'
    AWS_SECRET_ACCESS_KEY: 'access secret'
    AWS_DEFAULT_REGION: 'aws region'
    AWS_BUCKET: 'bucket name'
```

Build the container `docker-compose build`

Then you can run it `docker-compose up`

#How it works

Once you run the container, it will start a script which will run in a loop every 3 seconds.

It will get the new file name we need to download from `CONFIG_PATH` as the last part after `/` and then it will check that the 
content of this file `/data/{file name}` is different from the file name we are downloading.

If they are different it will download the file from S3 and extract it in teh `/data/` directory.

It will create a file `/data/{file name}` contains the name of the extracted file,

then it creates a lock file `/data/update.lock`, this file can be used from other containers to clear their cache.

If the file name in `/data/{file name}` is the same as the `file name` we are downloading, it won't do anything.
