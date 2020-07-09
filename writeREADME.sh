#!/bin/bash
README="README.md"
LIST="List of Docker images" 

TMP=$(mktemp)

function get_image_info {
    if [ $# -ne 2 ]; then
        echo "get_image_info app version"
        exit 1
    fi
    curl -slSL https://hub.docker.com/v2/repositories/uvarc/$1/tags/$2 | tr ',' '\n' >$TMP
}

cat >$README <<EOF
# rivanna-docker

**Autogenerated - do not edit manually!**  
Run \`writeREADME.sh\` to update this \`README.md\`.

This repository contains Dockerfiles for Rivanna.

## Structure

<pre>
.
├── app1
│   ├── version1
│   │   ├── Dockerfile
│   │   └── README.md
│   └── version2
│       ├── Dockerfile
│       └── README.md
├── app2
│   └── version1
│       ├── Dockerfile
│       └── README.md
├── README.md  # Do not edit this file!
└── writeREADME.sh
</pre>

Each Dockerfile should reside in its own directory with a \`README.md\` with this template:
\`\`\`\`
<name of main app> <version> <any other important info>

<homepage of main app>

<any other apps/packages>

Usage on Rivanna:
\`\`\`
module load singularity
singularity pull docker://uvarc/<app>:<tag>
./<app>_<tag>.sif
\`\`\`
\`\`\`\`

Individual \`README.md\` files are used as the Docker Hub repository description.

To contribute, please visit the [wiki](https://github.com/uvarc/rivanna-docker/wiki) for instructions and tips.

## $LIST

|App|Version|Base Image|Compressed Size|Last Updated (UTC)|By|
|---|---|----|---:|---|---|
EOF

for i in *;  do
    if [ -d $i ]; then
        cd $i
        count=1
        for j in *; do
            if [ -e $j/Dockerfile ]; then
                get_image_info $i $j

                # base image (production for multi-stage)
                base=$(awk '{if($1 ~ "^FROM") print $2}' $j/Dockerfile | tail -1)

                # size in MB
                size=$(awk -F':' '/full_size/ {
                    if ($2>=1e9) printf "%.3f GB", $2/1024/1024/1024
                    else         printf "%.3f MB", $2/1024/1024
                }' $TMP)

                # last updated
                lastup=$(sed -n 's/"last_updated":"\(.*\)T\(.*\)Z"$/\1 \2/p' $TMP)

                # last updated by
                lastby=$(sed -n 's/"last_updater_username":"\(.*\)"$/\1/p' $TMP)

                if [ $count -eq 1 ]; then
                    echo "| [$i](https://hub.docker.com/r/uvarc/$i) | $j | \`$base\` | $size | $lastup | \`$lastby\` |"
                else
                    echo "| | $j | \`$base\` | $size | $lastup | \`$lastby\` |"
                fi
                count=$((count+1))
            fi
        done
        cd ..
    fi
done >>$README

cat >>$README <<EOF

Note:
- App link redirects to Docker Hub repository.
- The \`*.sif\` Singularity image size (created after \`singularity pull\`) is about the same as the compressed size.

EOF

rm $TMP
