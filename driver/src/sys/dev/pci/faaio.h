#ifndef _DEV_PCI_FAAIO_H_
#define _DEV_PCI_FAAIO_H_

#include <sys/ioccom.h>

#define FAAIO_ADD	_IOWR('W', 1, struct faaio_add)

struct faaio_add {
	uint32_t a;
	uint32_t b;
	uint32_t *result;
};

#endif /* _DEV_PCI_FAAIO_H_ */

