# Shell Libs

[![CI Check](https://github.com/zhengmz/actions/actions/workflows/lib.yml/badge.svg)](https://github.com/zhengmz/actions/actions/workflows/lib.yml)

Shell Library for other Action.

## Usage by curl

```shell
# Import lib by curl
curl -fsSL https://github.com/zhengmz/actions/raw/lib/functions > /tmp/functions
source /tmp/functions

# echo message in different color
info "information"
warn "warnning message"
error "error log"
log "notice"
```

## Usage by action

```yaml
- name: Import lib action
  id: lib
  uses: zhengmz/actions@lib
  with:
    dist: '/tmp/functions'

- name: Use functions by file
  run: |
    source /tmp/functions
    info "information"
    warn "warning message"
    error "error log"
    log "notice"

- name: Use functions by outputs
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

## Inputs

Various inputs are defined to let you configure the action:

| Name | Required | Description | Default |
| --- | :-: | --- | --- |
| `dist` |  | dist file name for copying lib functions<br>set '' to disable copying | `functions` |

