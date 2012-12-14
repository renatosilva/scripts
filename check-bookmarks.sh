#!/bin/bash

# Firefox Check Bookmarks 2012.12.14
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

# This program searches for unorganized bookmarks and for ones containing a
# description, then generates a report to the desktop of current user.

database=("$APPDATA/Mozilla/Firefox/profiles/"*"/places.sqlite")
query_unorganized="select title from moz_bookmarks where parent = 5"
query_described="select title from moz_bookmarks b, moz_items_annos i where b.id = i.item_id and b.type = 1 and title != ''
    and title not in ('Favoritos do dispositivo móvel', 'Favoritos recentes', 'Mais visitados', 'Tags recentes', 'Histórico', 'Downloads', 'Tags') order by b.type"

unorganized=$(sqlite -html "$database" "$query_unorganized")
described=$(sqlite -html "$database" "$query_described")

[[ -z "$unorganized" && -z "$described" ]] && exit
[[ -n "$unorganized" ]] && unorganized="<h3>Não organizados</h3><table>$unorganized</table>"
[[ -n "$described" ]] && described="<h3>Com descrição</h3><table>$described</table>"
echo "<html><head><meta charset='utf-8'/><body>$unorganized $described</body>" > "$USERPROFILE/Desktop/Favoritos pendentes.html"
