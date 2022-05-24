# Shell Libs

[![CI Check](https://github.com/zhengmz/actions/actions/workflows/lib.yml/badge.svg)](https://github.com/zhengmz/actions/actions/workflows/lib.yml)

Shell Library for other Action.

## Usage by curl

```shell
# Import lib by curl
curl -fsSL https://github.com/zhengmz/actions/raw/lib/functions > /tmp/functions
source /tmp/functions

# Use lib in shell

# echo message in different color
info "information"
warn "warnning message"
error "error log"
log "notice"
```

## Usage by action

```yaml
- name: Import lib action
  if: env.IMPORT_ACTION == 'true'
  id: lib
  uses: zhengmz/actions@lib

- name: Source functions by action
  if: env.IMPORT_ACTION == 'true'
  env:
    f: ${{ steps.lib.outputs.functions }}
  run: |
    echo "$f" | sed 's/\\n/\n/g' > /tmp/functions
    source /tmp/functions
    info "information"
    warn "warning message"
    error "error log"
    log "notice"
```

