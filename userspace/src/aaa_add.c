#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>

#include "faaio.h"

static const char* faa_device = "/dev/faa0";

int
main(int argc, char *argv[])
{
	int devfd;
	struct faaio_add faaio;
	uint32_t result;

	if (argc != 3) {
		printf("usage: %s a b\n", argv[0]);
		return 1;
	}

	faaio.result = &result;
	faaio.a = atoi(argv[1]);
	faaio.b = atoi(argv[2]);	

	if ( (devfd = open(faa_device, O_RDWR)) == -1) {
		perror("can't open device file");
		return 1;
	}

	if (ioctl(devfd, FAAIO_ADD, &faaio) == -1) {
		perror("ioctl failed");
		return 1;
	}

	printf("%d\n", result);
	close(devfd); 

	return 0;
}

