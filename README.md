# fio-benchmark
Docker container with fio benchmark bash-script

# How to run

## Option 1:

Run the bash-script *./app/benchmark.sh* which runs all fio-benchmarks configured in the *./app/fio-settings.fio* file.

**Important:** the default location for the test file is */fiodata/fio_data.bin*. Change it in the *./app/fio-settings.fio* file if you like. There is also the possibility to change the test location to a block device. For that delete the *size* option and specify the block device under *filename* (exmaple: /dev/sdb)

**Warning:** the data on the block device will be overwritten !!!

## Option 2:

Run the test as a container. [hub.docker.com/r/kaioeste/fiotest](https://hub.docker.com/r/kaioeste/fiotest)

For example:

`docker run -it --rm -v ./fiodata:/fiodata -v ./results:/app/results kaioeste/fiotest:v0.2`

The first volume mount is where the 20 GB Testfile will be created and the second one specifies the location of the result files.