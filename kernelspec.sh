#!/bin/bash -eu

function check_command() {
    type $1 >/dev/null 2>&1
}

function get_ocaml_version() {
    if check_command opam; then
        opam config var switch
    else
        ocaml -vnum
    fi
}

function create() {
    local bindir=$(opam config var bin)

    cat <<EOF
{
  "display_name": "OCaml ${OCAML_VERSION}",
  "language": "OCaml",
  "argv": [
    "${bindir}/ocaml-jupyter-kernel",
    "--init",
    "${HOME}/.ocamlinit",
    "--merlin",
    "${bindir}/ocamlmerlin",
    "--connection-file",
    "{connection_file}"
  ]
}
EOF
}

function install() {
    local datadir="$(opam config var share)/ocaml-jupyter"
    local install_flags="--name $KERNEL_NAME"

    if check_command jupyter; then
        if ! [ -f "$datadir/kernel.json" ]; then
            mkdir -p "$datadir"
            create > "$datadir/kernel.json"
        fi

        echo jupyter kernelspec install --user $install_flags "$datadir"
    fi
}

function uninstall() {
    if check_command jupyter; then
        if jupyter kernelspec list | grep "$KERNEL_NAME" >/dev/null; then
            echo jupyter kernelspec remove "$KERNEL_NAME" -f
        else
            echo "[ERROR] kernelspec $KERNEL_NAME is not install"
        fi
    fi
}

OCAML_VERSION=$(get_ocaml_version | sed 's@[^0-9A-Za-z_\.+-]@_@g')
KERNEL_NAME=ocaml-jupyter

case $1 in
    install )
        install
    ;;
    uninstall )
    	uninstall
	;;
esac
