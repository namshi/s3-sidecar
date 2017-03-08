# k8s-s3-sidecar
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

It checks the file name `config.txt` file and checks the last file was downloaded which will be in `/data/rev.txt`.

Once the file name changes in `config.txt`, it will download the new file from S3 and extract the files in `/data` directory.

It will create a file `/data/rev.txt` contains the name of the extracted file,

then it creates a lock file `/data/update.lock`, this file can be used from other containers to clear their cache.

and the in each loop it will check if the file name in `/data/rev.txt` is different from the file name in `config.txt`,

If the file name in `/data/rev.txt` is the same as the file name in `config.txt` it won't do anything.
