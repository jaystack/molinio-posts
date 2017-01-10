#!/bin/bash

CONTAINER=moliniowebsite_wordpress_1
EXEC="docker exec $CONTAINER"

# Install wp-cli
if [ ! -f /usr/local/bin/wp/wp-cli.phar ]
then
    $EXEC curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    $EXEC chmod +x wp-cli.phar
    $EXEC mv wp-cli.phar /usr/local/bin/wp
fi

for DIRECTORY in ./*
do
    if [ -f "$DIRECTORY"/*.md ]
    then
        CONTENT=$(<"$DIRECTORY"/*.md)
        eval $(head -6 "$DIRECTORY"/meta.conf)

        if [ ! -s "$DIRECTORY"/id ]
        then
            $EXEC wp post create --post_title="$title" --post_content="$CONTENT" --post_date="$date" --post_type=post --post_status=future --allow-root > "$DIRECTORY"/id 
            tail "$DIRECTORY"/id
            sed -i 's|[^0-9]*||g' "$DIRECTORY"/id
        else
            ID=$(<"$DIRECTORY"/id)
            $EXEC wp post update "$ID" --post_title="$title" --post_content="$CONTENT" --post_date="$date" --post_type=post --post_status=future --allow-root
            unset ID
        fi
        
        unset CONTENT
    fi
done

#$EXEC wp post list --allow-root