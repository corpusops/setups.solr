#!/usr/bin/env bash
# {{ansible_managed}}
# {% set data = cops_solr_vars %}

set -e
cd $(dirname $0)/..
if [ -e bin/solr.env ];then . bin/solr.env;fi
set -x
vv exec $SOLR_LAUNCHER $SOLR_LAUNCHER_ARGS
# vim:set et sts=4 ts=4 tw=80:
