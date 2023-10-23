#!/usr/bin/env bash

# See who has processes running (through ps)

echo -e "The following users have processes running:" "\n"
ps a -o user | sort | uniq | awk '{
        if ($1 != "USER")
                    print($1);
}'
