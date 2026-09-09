#!/bin/bash

catalog_file="/etc/yunohost/apps_catalog.yml"
catalog_id="arcenal"
catalog_url="https://raw.githubusercontent.com/arcenal-coder/arcenal-yunohost-catalog/main"

arcenal_catalog_add() {
    python3 - "$catalog_file" "$catalog_id" "$catalog_url" <<'PY'
import os,sys,tempfile,yaml
path,catalog_id,catalog_url=sys.argv[1:]
data=[]
if os.path.exists(path):
    with open(path,encoding="utf-8") as handle:
        data=yaml.safe_load(handle) or []
if not any(item.get("id")==catalog_id for item in data):
    data.append({"id":catalog_id,"url":catalog_url})
else:
    for item in data:
        if item.get("id")==catalog_id:
            item["url"]=catalog_url
folder=os.path.dirname(path)
fd,tmp=tempfile.mkstemp(prefix="apps_catalog.",suffix=".yml",dir=folder,text=True)
try:
    with os.fdopen(fd,"w",encoding="utf-8") as handle:
        yaml.safe_dump(data,handle,sort_keys=False,allow_unicode=True)
    os.chmod(tmp,0o644)
    os.replace(tmp,path)
finally:
    if os.path.exists(tmp): os.unlink(tmp)
PY
}

arcenal_catalog_remove() {
    python3 - "$catalog_file" "$catalog_id" <<'PY'
import os,sys,tempfile,yaml
path,catalog_id=sys.argv[1:]
if not os.path.exists(path): raise SystemExit(0)
with open(path,encoding="utf-8") as handle:
    data=yaml.safe_load(handle) or []
data=[item for item in data if item.get("id")!=catalog_id]
fd,tmp=tempfile.mkstemp(prefix="apps_catalog.",suffix=".yml",dir=os.path.dirname(path),text=True)
try:
    with os.fdopen(fd,"w",encoding="utf-8") as handle:
        yaml.safe_dump(data,handle,sort_keys=False,allow_unicode=True)
    os.chmod(tmp,0o644)
    os.replace(tmp,path)
finally:
    if os.path.exists(tmp): os.unlink(tmp)
PY
    python3 - "/var/cache/yunohost/repo/${catalog_id}.json" <<'PY'
import os,sys
if os.path.exists(sys.argv[1]): os.unlink(sys.argv[1])
PY
}
