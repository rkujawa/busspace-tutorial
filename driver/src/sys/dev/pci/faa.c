/*	$NetBSD$	*/

/*
 * Copyright (c) 2012 The NetBSD Foundation, Inc.   
 * All rights reserved.
 *
 * This code is derived from software contributed to The NetBSD Foundation
 * by Radoslaw Kujawa.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <sys/cdefs.h>
__KERNEL_RCSID(0, "$NetBSD$");
#include <sys/param.h>
#include <sys/device.h>
#include <sys/conf.h>

#include <dev/pci/pcivar.h>
#include <dev/pci/pcidevs.h>
#include <dev/pci/faareg.h>
#include <dev/pci/faavar.h>
#include <dev/pci/faaio.h>

static int	faa_match(device_t, cfdata_t, void *);
static void	faa_attach(device_t, device_t, void *);
static bool	faa_check(struct faa_softc *sc);
static uint32_t	faa_add(struct faa_softc *sc, uint32_t a, uint32_t b);

static void	faaioctl_add(struct faa_softc *sc, struct faaio_add *data);

dev_type_open(faaopen);
dev_type_close(faaclose);
dev_type_ioctl(faaioctl);

CFATTACH_DECL_NEW(faa, sizeof(struct faa_softc),
    faa_match, faa_attach, NULL, NULL);

const struct cdevsw faa_cdevsw = {
	faaopen, faaclose, noread, nowrite, faaioctl,
	nostop, notty, nopoll, nommap, nokqfilter, D_OTHER 
};

extern struct cfdriver faa_cd;

static int
faa_match(device_t parent, cfdata_t match, void *aux)
{
        const struct pci_attach_args *pa = (const struct pci_attach_args *)aux;

        if ((PCI_VENDOR(pa->pa_id) == PCI_VENDOR_FAKECARDS) &&
            (PCI_PRODUCT(pa->pa_id) == PCI_PRODUCT_FAKECARDS_AAA))
                return 1;

        return 0;
}

static void
faa_attach(device_t parent, device_t self, void *aux)
{
	struct faa_softc *sc = device_private(self);
	const struct pci_attach_args *paa = aux;
	sc->sc_dev = self;

	pci_aprint_devinfo(paa, NULL);

	if (pci_mapreg_map(paa, FAA_MMREG_BAR, PCI_MAPREG_TYPE_MEM, 0,
	    &sc->sc_regt, &sc->sc_regh, &sc->sc_reg_pa, 0) != 0 ) {
	    aprint_error_dev(sc->sc_dev, "can't map the BAR");
	    return;
	}

	aprint_normal_dev(sc->sc_dev, "registers at 0x%08x\n",
	    (uint32_t) sc->sc_reg_pa);

	if (!faa_check(sc)) {
		aprint_error_dev(sc->sc_dev, "hardware not responding\n");
		return;
	}

	aprint_normal_dev(sc->sc_dev, "just checking: 1 + 2 = %d\n", faa_add(sc, 1, 2));
}

static bool 
faa_check(struct faa_softc *sc) 
{
	uint32_t testval = 0xff11ee22;
	bus_space_write_4(sc->sc_regt, sc->sc_regh, FAA_COMMAND, FAA_COMMAND_STORE_A);
	bus_space_write_4(sc->sc_regt, sc->sc_regh, FAA_DATA, testval);
	if (bus_space_read_4(sc->sc_regt, sc->sc_regh, FAA_DATA) == testval)
		return true;

	return false;
}

static uint32_t
faa_add(struct faa_softc *sc, uint32_t a, uint32_t b)
{
	bus_space_write_4(sc->sc_regt, sc->sc_regh, FAA_COMMAND, FAA_COMMAND_STORE_A);
	bus_space_write_4(sc->sc_regt, sc->sc_regh, FAA_DATA, a);
	bus_space_write_4(sc->sc_regt, sc->sc_regh, FAA_COMMAND, FAA_COMMAND_STORE_B);
	bus_space_write_4(sc->sc_regt, sc->sc_regh, FAA_DATA, b);
	bus_space_write_4(sc->sc_regt, sc->sc_regh, FAA_COMMAND, FAA_COMMAND_ADD);
	return bus_space_read_4(sc->sc_regt, sc->sc_regh, FAA_RESULT);
}

int
faaopen(dev_t dev, int flags, int mode, struct lwp *l)
{
	struct faa_softc *sc;

	sc = device_lookup_private(&faa_cd, minor(dev));

	if (sc == NULL)
		return ENXIO;
	if (sc->sc_flags & FAA_OPEN) 
		return EBUSY;

	sc->sc_flags |= FAA_OPEN;

	return 0;
}

int
faaclose(dev_t dev, int flag, int mode, struct lwp *l)
{
	struct faa_softc *sc;

	sc = device_lookup_private(&faa_cd, minor(dev));

	if (sc->sc_flags & FAA_OPEN)
		sc->sc_flags =~ FAA_OPEN; 

	return 0;
}

int
faaioctl(dev_t dev, u_long cmd, void *data, int flag, struct lwp *l)
{
	struct faa_softc *sc = device_lookup_private(&faa_cd, minor(dev));

	int err;

	switch (cmd) {
	case FAAIO_ADD:
		faaioctl_add(sc, (struct faaio_add *) data);
		return 0;
	default:
		err = EINVAL;
		break;
	}
	return(err);
}

static void
faaioctl_add(struct faa_softc *sc, struct faaio_add *data)
{
	aprint_normal_dev(sc->sc_dev, "got ioctl with a %d, b %d\n",
	    data->a, data->b);

	*(data->result) = faa_add(sc, data->a, data->b);
}

