r"""
Fast evaluation of polynomials (Horner's rule)

This file provides fast evaluation of integer polynomials with a real value. We
consider flint and NTL polynomials and values mpfr_t and mpfi_t. If you intend
to implement more it would be better to find a template strategy instead of
duplicating the code.

The code in this file is mostly Sage agnostic and only does library calls.

For appropriate testing see
:mod:`~sage.rings.polynomial.polynomial_integer_dense_flint` and
:mod:`~sage.rings.polynomial.polynomial_integer_dense_ntl`.

.. TODO::

    Integrate these functions into
    :mod:`~sage.rings.polynomial.polynomial_compiled`
"""
#*****************************************************************************
#       Copyright (C) 2016 Vincent Delecroix <20100.delecroix@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  http://www.gnu.org/licenses/
#*****************************************************************************

from sage.libs.mpfr cimport *
from sage.libs.mpfi cimport *
from sage.libs.gmp.mpz cimport *
from sage.libs.gmp.mpq cimport *
from sage.libs.flint.fmpz cimport *
from sage.libs.flint.fmpz_poly cimport *
from sage.libs.ntl.ZZ cimport *
from sage.libs.ntl.ZZX cimport *

cdef fmpz_poly_evaluation_mpfr(mpfr_t res, const fmpz_poly_t poly, const mpfr_t a):
    cdef mpz_t c
    cdef long i

    mpfr_set_ui(res, 0, MPFR_RNDN)
    mpz_init(c)

    for i in range(fmpz_poly_degree(poly), -1, -1):
        mpfr_mul(res, res, a, MPFR_RNDN)
        if not fmpz_is_zero(fmpz_poly_get_coeff_ptr(poly, i)):
            fmpz_poly_get_coeff_mpz(c, poly, i)
            mpfr_add_z(res, res, c, MPFR_RNDN)

    mpz_clear(c)

cdef fmpz_poly_evaluation_mpfi(mpfi_t res, const fmpz_poly_t poly, const mpfi_t a):
    cdef mpz_t c
    cdef long i

    mpfi_set_ui(res, 0)
    mpz_init(c)

    for i in range(fmpz_poly_degree(poly), -1, -1):
        mpfi_mul(res, res, a)
        if not fmpz_is_zero(fmpz_poly_get_coeff_ptr(poly, i)):
            fmpz_poly_get_coeff_mpz(c, poly, i)
            mpfi_add_z(res, res, c)

    mpz_clear(c)


cdef ZZX_evaluation_mpfr(mpfr_t res, ZZX_c poly, const mpfr_t a):
    cdef mpz_t c
    cdef long i

    mpfr_set_ui(res, 0, MPFR_RNDN)
    mpz_init(c)

    for i in range(ZZX_deg(poly), -1, -1):
        mpfr_mul(res, res, a, MPFR_RNDN)
        if not ZZ_IsZero(ZZX_coeff(poly, i)):
            ZZX_getitem_as_mpz(c, &poly, i)
            mpfr_add_z(res, res, c, MPFR_RNDN)

    mpz_clear(c)

cdef ZZX_evaluation_mpfi(mpfi_t res, ZZX_c poly, const mpfi_t a):
    cdef mpz_t c
    cdef long i

    mpfi_set_ui(res, 0)
    mpz_init(c)

    for i in range(ZZX_deg(poly), -1, -1):
        mpfi_mul(res, res, a)
        if not ZZ_IsZero(ZZX_coeff(poly, i)):
            ZZX_getitem_as_mpz(c, &poly, i)
            mpfi_add_z(res, res, c)

    mpz_clear(c)
