#!/bin/sh
set -eu

if ! test "${ZIG+1}" && ! command -v zig >/dev/null; then
	printf "ERROR: Set 'ZIG' env or add zig to path\n" >&2
	exit 1
fi

PROGRAM="$(basename "$0")"

case "${PROGRAM}" in
ar | dlltool | lib | ranlib | objcopy | ld.lld)
	set -- "${PROGRAM}" "$@"
	;;
cc | c++)
	## Zig doesn't properly handle these flags so we have to rewrite/ignore.
	## None of these affect the actual compilation target.
	## https://github.com/ziglang/zig/issues/9948
	set -- "${PROGRAM}" --target=$(uname -m)-linux-musl "$@"
	for argv in "$@"; do
		case "${argv}" in
		-Wp,-MD,*) set -- "$@" "-MD" "-MF" "$(echo "$argv" | sed 's/^-Wp,-MD,//')" ;;
		-Wl,--warn-common | -Wl,--verbose | -Wl,-Map,*) ;;
		*) set -- "$@" "${argv}" ;;
		esac
		shift
	done
	;;
*)
	if test -h "$0"; then
		exec "$(dirname "$0")/$(readlink "$0")" "$@"
	fi
	exit
	;;
esac

"${ZIG-zig}" "$@"
