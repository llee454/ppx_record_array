# Record Array PPX

The record array PPX allows developers to define records comprised of
float fields and automatically generates functions that convert these
records into arrays and vice versa.

## Initializing the Build Environment

opam switch create . ocaml-variants.4.10.0+flambda --no-install
opam update
opam install --deps-only .
