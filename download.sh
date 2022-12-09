#!/usr/bin/env bash
urls=url_download.txt

for url in $(cat $urls); do
    wget --content-disposition -P ~/Downloads $url -nv
done
