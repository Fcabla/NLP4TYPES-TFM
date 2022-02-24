

set -ex



test -f "${PREFIX}/share/zoneinfo/leapseconds"
test -f "${PREFIX}/share/zoneinfo/iso3166.tab"
test -f "${PREFIX}/share/zoneinfo/zone1970.tab"
test -f "${PREFIX}/share/zoneinfo/zone.tab"
test -f "${PREFIX}/share/zoneinfo/tzdata.zi"
dirs="$(
  find "${PREFIX}" -mindepth 1 -maxdepth 2 \
  \! -path "${PREFIX}/share" \! -path "${PREFIX}/conda-meta*"
)"
test "${dirs}" = "${PREFIX}/share/zoneinfo"

heads="$(
  find "${PREFIX}/share/zoneinfo" -type f \
    \! -name \*.zi \! -name \*.tab \! -name leapseconds \
    -exec head -c4 {} \; -printf \\n \
    | uniq
)"

heads="$(
  find "${PREFIX}/share/zoneinfo" -type f \
    \! -name \*.zi \! -name \*.tab \! -name leapseconds \
    -exec head -c4 {} \; -print0 \
    | uniq \
    | cut -c1-4 \
)"
test "${heads}" = TZif

exit 0
