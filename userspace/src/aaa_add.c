#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>

#include "faaio.h"

void add(int, uint32_t, uint32_t);

static const char* faa_device = "/dev/faa0";

int
main(int argc, char *argv[])
{
	int devfd;

	if (argc != 3) {
		printf("usage: %s a b\n", argv[0]);
		return 1;
	}
	if ( (devfd = open(faa_device, O_RDWR)) == -1) {
		perror("can't open device file");
		return 1;
	}

	add(devfd, atoi(argv[1]), atoi(argv[2]));

	close(devfd); 
	return 0;
}

void
add(int devfd, uint32_t a, uint32_t b)
{
	struct faaio_add faaio;
	uint32_t result = 0;

	faaio.result = &result;
	faaio.a = a;
	faaio.b = b;

	if (ioctl(devfd, FAAIO_ADD, &faaio) == -1) {
		perror("ioctl failed");
	}
	printf("%d\n", result);
}
